
package sandy.materials.attributes;

import sandy.core.SandyFlags;
import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.materials.BitmapMaterial;
import sandy.materials.Material;

import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
// import flash.utils.Dictionary;

import sandy.HaxeTypes;


/**
* Applies cylindric environment map.
*
* @author		makc
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
*/
class CylinderEnvMap extends AAttributes
{
	/**
	* A bitmap-based material to use for environment map.
	*/
	public var mapMaterial:BitmapMaterial;

	/**
	* Non-zero value adds sphere normals to actual normals for mapping.
	* Use this with flat surfaces or cylinders.
	*/
	public var spherize:Float;

	/**
	* Create the CylinderEnvMap object.
	*
	* @param p_oBitmapMaterial A bitmap-based material to use for environment map.
	*/
	public function new (p_oBitmapMaterial:BitmapMaterial)
	{
		// public initializers
		spherize = 0.0;
		// private initializers
		aN = [new Point3D (), new Point3D (), new Point3D ()];
		aNP = [new Point (), new Point (), new Point ()];
		matrix = new Matrix();
		matrix2 = new Matrix();

		super();

		mapMaterial = p_oBitmapMaterial; mapMaterial.forceUpdate = true;

		m_nFlags |= SandyFlags.VERTEX_NORMAL_WORLD;
	}

	/**
	* @private
	*/
	override public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):Void
	{
		var l_oVertex:Vertex,
			v:Point3D, dv:Point3D,
			p:Point, p1:Point, p2:Point,
			m2a:Float, m2b:Float, m2c:Float, m2d:Float, a:Float;

		// get vertices and prepare matrix2
		m_aPoints = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;

		l_oVertex = m_aPoints [0];
		matrix2.tx = l_oVertex.sx; m2a = m2c = -l_oVertex.sx;
		matrix2.ty = l_oVertex.sy; m2b = m2d = -l_oVertex.sy;

		l_oVertex = m_aPoints [1];
		m2a += l_oVertex.sx; matrix2.a = m2a;
		m2b += l_oVertex.sy; matrix2.b = m2b;

		l_oVertex = m_aPoints [2];
		m2c += l_oVertex.sx; matrix2.c = m2c;
		m2d += l_oVertex.sy; matrix2.d = m2d;

		// transform 1st three normals
		for (i in 0...3)
		{
			v = aN [i]; v.copy (p_oPolygon.vertexNormals [i].getCameraPoint3D ());

			if (spherize > 0)
			{
				// too bad, m_aPoints [i].getWorldPoint3D () gives viewMatrix-based coordinates
				// when vertexNormals [i].getWorldPoint3D () gives modelMatrix-based ones :(
				// so we have to use cache for modelMatrix-based vertex coords (and also scaled)
				l_oVertex = m_aPoints [i];
				if ( m_oVertices [l_oVertex.id] == null)
				{
					dv = l_oVertex.getPoint3D ().clone ();
					dv.sub (p_oPolygon.shape.geometryCenter);
					p_oPolygon.shape.modelMatrix.transform3x3( dv );
					dv.normalize ();
					dv.scale (spherize);
					m_oVertices [l_oVertex.id] = dv;
				}
				else
				{
					dv = m_oVertices [l_oVertex.id];
				}
				v.add (dv);
				v.normalize ();
			}

			if (!p_oPolygon.visible) v.scale (-1);
		}

		// calculate coordinates in map texture
		computeMapping ();

		// simple hack to resolve bad projections
		// where the hell do they keep coming from?
		p = aNP[0]; p1 = aNP[1]; p2 = aNP[2];
		a = (p.x - p1.x) * (p.y - p2.y) - (p.y - p1.y) * (p.x - p2.x);
		while ((-2 < a) && (a < 2))
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
		p_oGraphics.beginBitmapFill( mapMaterial.texture, matrix, mapMaterial.repeat, mapMaterial.smooth );

		// render the map
		p_oGraphics.moveTo( m_aPoints[0].sx, m_aPoints[0].sy );
		for ( l_oVertex in m_aPoints )
		{
			p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy  );
		}
		p_oGraphics.endFill();

		// --
		m_aPoints = null;
	}

	/**
	* @private override this to create custom mapping m_aPoints, aN -> aNP
	*/
	private function computeMapping ():Void
	{
		var p:Point, v:Point3D;
		for (i in 0...3)
		{
			p = aNP [i]; v = aN [i];

			// x, z = -1 -> u = 0.5
			p.x = 0.5 * (1 + Math.atan2 (v.x, -v.z) / Math.PI);

			// y -> v
			p.y = 0.5 * (1 - v.y);

			// re-calculate into map coordinates
			p.x *= mapMaterial.texture.width;
			p.y *= mapMaterial.texture.height;
		}
	}

	/**
	* @private
	*/
	private var aN:Array<Point3D>;

	/**
	* @private
	*/
	private var aNP:Array<Point>;

	/**
	* @private
	*/
	private var m_aPoints:Array<Vertex>;

	// vertex dictionary
	private var m_oVertices:Array<Point3D>;

	/**
	* @private
	*/
	override public function begin( p_oScene:Scene3D ):Void
	{
		// clear vertex dictionary
		m_oVertices = [];
	}

	// --
	private var matrix:Matrix;
	private var matrix2:Matrix;
}

