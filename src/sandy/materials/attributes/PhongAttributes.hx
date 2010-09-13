
package sandy.materials.attributes;

import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.core.light.Light3D;
import sandy.events.SandyEvent;
import sandy.materials.Material;
import sandy.util.NumberUtil;

import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
// import flash.utils.Dictionary;

import sandy.HaxeTypes;

/**
* Realize a Phong shading on a material.
* <p>In true Phong shading, normals are supposed to be interpolated across the surface;
* here scaled normal projections are interpolated in the light map space. The downside of
* this method is that in case of low poly models interpolation results are inaccurate -
* in this case you can improve the result using GouraudAttributes for ambient and diffuse,
* and then this attribute for specular reflection.</p>
*
* @author		Makc
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		15.12.2007
*/
class PhongAttributes extends ALightAttributes
{
	/**
	* Non-zero value adds sphere normals to actual normals for light rendering.
	* Use this with flat surfaces or cylinders.
	*/
	public var spherize:Float;

	/**
	* Flag for rendering mode.
	* <p>If true, only specular highlight is rendered, when useBright is also true.<br />
	* If false (the default) ambient and diffuse reflections will also be rendered.</p>
	*/
	public var onlySpecular:Bool;

	/**
	* Flag for lightening mode.
	* <p>If true (the default), the lit objects use full light range from black to white.<br />
	* If false they just range from black to their normal appearance; additionally, current
	* implementation does not render specular reflection in this case.</p>
	*/
	public var useBright (__getUseBright,__setUseBright):Bool;
	private function __getUseBright ():Bool
	{
		return _useBright;
	}

	/**
	* @private
	*/
	private function __setUseBright (p_bUseBright:Bool):Bool
	{
		if (_useBright != p_bUseBright)
		{
			_useBright = p_bUseBright; m_oLightMaps = new haxe.FastList<PhongAttributesLightMap> ();
		}
		return p_bUseBright;
	}

	/**
	* Compute the light map.
	* <p>Normally you should not need to call this function, as it is done for you automatically
	* when it is needed. You might call it to compute light map in advance, though.</p>
	*
	* @param p_oLight Light3D object to make the light map for.
	* @param p_nQuality Quality of light response approximation. A value between 2 and 15 is expected
	* (Flash radial gradient is used internally light map, thus we can only roughly approximate exact
	* lighting).
	* @param p_nSamples A number of calculated samples per anchor. Positive value is expected (greater
	* values will produce a little bit more accurate interpolation with non-equally spaced anchors).
	*
	* @see sandy.core.light.Light3D
	*/
	public function computeLightMap (p_oLight:Light3D, ?p_nQuality:Int = 4, ?p_nSamples:Int = 4):Void
	{
		var i:Int, j:Int;
		var l_nQuality:Int = Std.int( NumberUtil.constrain (p_nQuality, 2, 15) );
		var l_nSamples:Int = Std.int( Math.max (p_nSamples, 1) );
		var N:Int = l_nQuality * l_nSamples;

		// store Blinn vector, and replace it with light direction
		// this is to simplify specular map calculation
		var l_oCurrentH:Point3D = m_oCurrentH.clone (); m_oCurrentH.copy (m_oCurrentL);

		// take arbitrary vector perpendicular to light direction and normalize it
		var e:Point3D = (Math.abs (m_oCurrentL.x) + Math.abs (m_oCurrentL.y) > 0) ?
			new Point3D (m_oCurrentL.y, -m_oCurrentL.x, 0) : new Point3D (m_oCurrentL.z, 0, -m_oCurrentL.x); e.normalize ();

		// sample ambient + diffuse and specular separately
		var n:Point3D = new Point3D ();
		var l_aReflection:Array<Array<Float>> = [new Array (), new Array ()];
		var S:Array<Float> = [0.0, 0.0], t:Array<Float> = [-1.0, -1.0];
		for (i in 0...N)
		{
			// radius in the lightmap (scaled 0 to 1) and its complimentary number (to parabola)
			var r:Float = i * 1.0 / (N - 1), q:Float = 0.5 * (1 - r * r);
			// take arbitrary normal that will map to radius r in the lightmap
			n.x = e.x * r - m_oCurrentL.x * q;
			n.y = e.y * r - m_oCurrentL.y * q;
			n.z = e.z * r - m_oCurrentL.z * q;
			n.normalize ();
			// calculate reflection from that normal
			l_aReflection [0] [i] = calculate (n, true, true);
			l_aReflection [1] [i] = calculate (n, true) - l_aReflection [0] [i];

			for (j in 0...2)
			{
				// constrain values (note: this is different from constraining their sum)
				l_aReflection [j] [i] = NumberUtil.constrain (l_aReflection [j] [i], 0, 1);
				// integrate it
				S [j] += l_aReflection [j] [i];
				// find transparent points for maps with useBright enabled
				if (useBright)
				{
					if (l_aReflection [j] [0] > 0.5)
						if (l_aReflection [j] [i] <= 0.5)
							t [j] = ((l_aReflection [j] [i-1] - 0.5) * i + (0.5 - l_aReflection [j] [i]) * (i-1)) /
									(l_aReflection [j] [i-1] - l_aReflection [j] [i]);
				}
			}
		}

		// restore original Blinn vector
		m_oCurrentH.copy (l_oCurrentH);

		// compute the light map
		var l_oLightMap:PhongAttributesLightMap = new PhongAttributesLightMap ();
		var I:Array<Float> = [0.0, 0.0], s:Array<Float> = [0.0, 0.0];
		for (i in 0...N)
		for (j in 0...2)
		{
			// skip if we have enough points for j-th map
			// if this happens, algorithm below doesnt work well :(
			if (I [j] > l_nQuality -1) continue;

			// try to fit curve better with non-equally spaced anchors
			s [j] += l_aReflection [j] [i];
			if ((s [j] >= S [j] * I [j] / (l_nQuality -1)) || (N - i <= l_nQuality - I [j]))
			{
				if (useBright)
				{
					if (j == 0)
					{
						// this is in effect only for ambient + diffuse
						l_oLightMap.alphas [j].push ((l_aReflection [j] [i] > 0.5) ? 2 * l_aReflection [j] [i] - 1 : 1 - 2 * l_aReflection [j] [i]);
						l_oLightMap.colors [j].push ((l_aReflection [j] [i] > 0.5) ? 0xFFFFFF : 0);
						l_oLightMap.ratios [j].push ((i * 255) / (N - 1));
						if ((i <= t [j]) && (t [j] <= i + 1))
						{
							// we need to add two transparent points, but the number of points is limited
							// we might have to remove one or two points in order to do this
							if (l_nQuality > 13)
							{
								I [j] += 1;
								if (l_nQuality > 14)
								{
									l_oLightMap.alphas [j].pop ();
									l_oLightMap.colors [j].pop ();
									l_oLightMap.ratios [j].pop ();
								}
							}

							l_oLightMap.alphas [j].push (0);
							l_oLightMap.colors [j].push (0xFFFFFF);
							l_oLightMap.ratios [j].push ((t [j] * 255) / (N - 1));

							l_oLightMap.alphas [j].push (0);
							l_oLightMap.colors [j].push (0);
							l_oLightMap.ratios [j].push ((t [j] * 255) / (N - 1));
						}
					}

					else
					{
						// it is not really possible to support specular with this method in our limited 3.0 system
						// so what we do here is not correct light map, but a hack losely based on actual values
						l_oLightMap.alphas [j].push (2.5 * l_aReflection [j] [i] * l_aReflection [j] [i]);
						l_oLightMap.colors [j].push (0xFFFFFF);
						l_oLightMap.ratios [j].push ((i * 255) / (N - 1));
					}
				}

				else
				{
					l_oLightMap.alphas [j].push (1 - l_aReflection [j] [i]);
					l_oLightMap.colors [j].push (0);
					l_oLightMap.ratios [j].push ((i * 255) / (N - 1));
				}
				I [j] += 1;
			}
		}

		// store light map
		m_oLightMaps.add( l_oLightMap );
	}

	/**
	* Create the PhongAttributes object.
	* @param p_bBright The brightness (value for useBright).
	* @param p_bBright The brightness (value for useBright).
	* @param p_nAmbient The ambient light value. A value between 0 and 1 is expected.
	* @param p_nQuality Quality of light response approximation. A value between 2 and 15 is expected.
	* @param p_nSamples A number of calculated samples per anchor. Positive value is expected.
	*/
	public function new (?p_bBright:Bool = false, ?p_nAmbient:Float = 0.0, ?p_nQuality:Int = 15, ?p_nSamples:Int = 4)
	{
		m_oLightMaps = new haxe.FastList<PhongAttributesLightMap> ();
		_useBright = true;

		aN0 = [new Point3D (), new Point3D (), new Point3D ()];
		aN  = [new Point3D (), new Point3D (), new Point3D ()];
		aNP = [new Point (), new Point (), new Point ()];

		matrix = new Matrix();
		matrix2 = new Matrix();

		dv = new Point3D ();
		e1 = new Point3D ();
		e2 = new Point3D ();

		spherize = 0;
		onlySpecular = false;

		super();

		useBright = p_bBright;
		ambient = NumberUtil.constrain (p_nAmbient, 0, 1);

		m_nQuality = p_nQuality;
		m_nSamples = p_nSamples;
	}

	// default quality to pass to computeLightMap (set in constructor)
	private var m_nQuality:Int;

	// default samples to pass to computeLightMap (set in constructor)
	private var m_nSamples:Int;

	// fastlist to hold light maps
	private var m_oLightMaps:haxe.FastList<PhongAttributesLightMap>;

	// on SandyEvent.LIGHT_UPDATED we update the light map for this light *IF* we have it
	private function watchForUpdatedLights (p_oEvent:SandyEvent):Void
	{
		if ( m_oLightMaps.first() != null )
		{
			computeLightMap (p_oEvent.target, m_nQuality, m_nSamples);
		}
	}

	// light map to use in this rendering session
	private var m_oCurrentLightMap:PhongAttributesLightMap;

	// set current light map for "draw" to use
	override public function begin( p_oScene:Scene3D ):Void
	{
		super.begin (p_oScene);

		var l_oLight:Light3D = p_oScene.light;

		// first entry is always Scene3D light
		if ( m_oLightMaps.first() == null)
		{
			// if we have no map yet, subscribe to this light updates and make the map
			l_oLight.addEventListener (SandyEvent.LIGHT_UPDATED, watchForUpdatedLights);
			computeLightMap (l_oLight, m_nQuality, m_nSamples);
		}

		m_oCurrentLightMap = m_oLightMaps.first();
	}

	override public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):Void
	{
		super.draw (p_oGraphics, p_oPolygon, p_oMaterial, p_oScene);

		var i:Int, j:Int, l_oVertex:Vertex,
			v:Point3D,
			p:Point, p1:Point, p2:Point,
			m2a:Float, m2b:Float, m2c:Float, m2d:Float, a:Float;

		// got anything at all to do?
		if( !p_oMaterial.lightingEnable )
			return;

		// get vertices and prepare matrix2
		var l_aPoints:Array<Vertex> = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;

		l_oVertex = l_aPoints [0];
		matrix2.tx = l_oVertex.sx; m2a = m2c = -l_oVertex.sx;
		matrix2.ty = l_oVertex.sy; m2b = m2d = -l_oVertex.sy;

		l_oVertex = l_aPoints [1];
		m2a += l_oVertex.sx; matrix2.a = m2a;
		m2b += l_oVertex.sy; matrix2.b = m2b;

		l_oVertex = l_aPoints [2];
		m2c += l_oVertex.sx; matrix2.c = m2c;
		m2d += l_oVertex.sy; matrix2.d = m2d;

		// transform 1st three normals
		for (i in 0...3)
		{
			v = aN0 [i]; v.copy (p_oPolygon.vertexNormals [i].getPoint3D());

			if (spherize > 0)
			{
				l_oVertex = l_aPoints [i];

				dv.copy (l_oVertex.getPoint3D ());
				dv.sub (p_oPolygon.shape.geometryCenter);
				dv.normalize ();
				dv.scale (spherize);

				v.add (dv);
				v.normalize ();
			}

			if (!p_oPolygon.visible) v.scale (-1);
		}

		// apply ambient + diffuse and specular maps separately
		// note we cannot correctly render specular with useBright off
		var j = onlySpecular ? 1 : 0;
		while ( j < (_useBright ? 2 : 1))
		{
			// get highlight direction vector
			var d:Point3D = (j == 0) ? m_oCurrentL : m_oCurrentH;

			// see if we are on the backside relative to d
			var backside:Bool = true;
			for (i in 0...3)
			{
				v = aN [i]; v.copy (aN0 [i]);

				var d_dot_aNi:Float = d.dot (v);
				if (d_dot_aNi < 0) backside = false;

				// intersect with parabola - q(r) in computeLightMap() corresponds to this
				v.scale (1 / (1 - d_dot_aNi));
			}

			if (backside)
			{
				// no reflection here - render the face in solid ambient
				// the way specular is done now, we dont need to render it at all on the backside
				if (j == 0)
				{
					var aI:Float = ambient * m_nI;
					if (useBright)
						p_oGraphics.beginFill( (aI < 0.5) ? 0 : 0xFFFFFF, (aI < 0.5) ? (1 - 2 * aI) : (2 * aI - 1) );
					else
						p_oGraphics.beginFill( 0, 1 - aI );
				}
			}

			else
			{
				// calculate two arbitrary vectors perpendicular to light direction
				if ((d.x != 0) || (d.y != 0))
				{
					e1.x = d.y; e1.y = -d.x; e1.z = 0;
				}
				else
				{
					e1.x = d.z; e1.y = 0; e1.z = -d.x;
				}
				e2.copy (d); e2.crossWith (e1);
				e1.normalize ();
				e2.normalize ();

				for (i in 0...3)
				{
					p = aNP [i]; v = aN [i];

					// project aN [i] onto e1 and e2
					p.x = e1.dot (v);
					p.y = e2.dot (v);

					// re-calculate into light map coordinates
					p.x = (16384 - 1) * 0.05 * p.x;
					p.y = (16384 - 1) * 0.05 * p.y;
				}

				// simple hack to resolve bad projections
				// where the hell do they keep coming from?
				p = aNP[0]; p1 = aNP[1]; p2 = aNP[2];
				a = (p.x - p1.x) * (p.y - p2.y) - (p.y - p1.y) * (p.x - p2.x);
				while ((-20 < a) && (a < 20))
				{
					p.x--; p1.y++; p2.x++;
					a = (p.x - p1.x) * (p.y - p2.y) - (p.y - p1.y) * (p.x - p2.x);
				}

				// compute gradient matrix
				matrix.a = p1.x - p.x;
				matrix.b = p1.y - p.y;
				matrix.c = p2.x - p.x;
				matrix.d = p2.y - p.y;
				matrix.tx = p.x;
				matrix.ty = p.y;
				matrix.invert ();

				matrix.concat (matrix2);
				p_oGraphics.beginGradientFill( flash.display.GradientType.RADIAL, m_oCurrentLightMap.colors [j], m_oCurrentLightMap.alphas [j], m_oCurrentLightMap.ratios [j], matrix );
			}

			if (!backside || (j == 0))
			{
				// render the lighting
				p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );
				for ( l_oVertex in l_aPoints )
				{
					p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy  );
				}
				p_oGraphics.endFill();
			}
			j++;
		}
		// --
		l_aPoints = null;
	}

	/**
	* when Phong model parameters change, any light maps we had are no longer valid
	*/
	override private function onPropertyChange ():Void
	{
		m_oLightMaps = new haxe.FastList<PhongAttributesLightMap> ();
	}

	// --
	private var _useBright:Bool;

	private var aN0:Array<Point3D>;
	private var aN:Array<Point3D>;
	private var aNP:Array<Point>;

	private var dv:Point3D;
	private var e1:Point3D;
	private var e2:Point3D;

	private var matrix:Matrix;
	private var matrix2:Matrix;
}


