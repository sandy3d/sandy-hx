
package sandy.materials;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;

import sandy.core.Scene3D;
import sandy.core.scenegraph.Shape3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.core.data.UVCoord;
import sandy.materials.attributes.MaterialAttributes;
import sandy.util.NumberUtil;

import sandy.HaxeTypes;

#if js
import Html5Dom;
#end

/**
* Displays a bitmap on the faces of a 3D shape.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Xavier Martin - zeflasher - transparency managment
* @author		Makc for first renderRect implementation
* @author		James Dahl - optimization in renderRec method
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class BitmapMaterial extends Material, implements IAlphaMaterial
{

	/**
	* This property enables smooth bitmap rendering when set to true.
	* The default value is set to false to have the best performance first.
	* Enable this property have a performance impact, use it warefully
	*/
	public var smooth:Bool;

	/**
	* Precision of the bitmap mapping.
	* This material uses an affine linear mapping. It results in a lack of accuracy at rendering time when the surface to draw is too big.
	* One usual solution is to augment the number of polygon, but the performance cost can be quite big.
	* Another solution is to change the precision property value. The lower the value, the more accurate the perspective correction is.
	* To disable the perspective correction, set this property to zero, which is also the default value
	* If you use the precision to solve the distortion issue, you can reduce the primitives quality (except if you are experiencing some sorting issues)
	*/
	public var precision:Int;

	/**
	* Maximum  recurssion depth when using precision > 1 (which enables the perspective correction).
	* The bigger the number is, the more accurate the result will be.
	* Try to change this value to fits your needs to obtain the best performance.
	*/
	public var maxRecurssionDepth:Int;

	#if js
	static inline var TEXTURED_FRAGMENT_SHADER:String = '
#ifdef GL_ES
		precision highp float;
#endif

		uniform sampler2D uSurface;

		varying vec2 vTexCoord;
		varying float vLightWeight;

		void main(void) {
			vec4 color = texture2D(uSurface, vec2(vTexCoord.s, vTexCoord.t));
			gl_FragColor = vec4(color.rgb * vLightWeight, color.a);
		}
	';

	static inline var TEXTURED_VERTEX_SHADER:String = '
		attribute vec3 aVertPos;
		attribute vec3 aVertNorm;
		attribute vec2 aTexCoord;

		uniform mat4 uViewMatrix;
		uniform mat4 uProjMatrix;
		uniform mat4 uNormMatrix;

		uniform vec3 uLightDir;

		varying vec2 vTexCoord;
		varying float vLightWeight;

		void main(void) {
			
			// --

			vec4 viewPos = uViewMatrix  * vec4(aVertPos, 1.0);
			gl_Position = uProjMatrix * viewPos;
			vTexCoord = aTexCoord;

			// --

			vec4 normal = uNormMatrix * vec4(aVertNorm, 1.0);
			vLightWeight = 1.0 + dot(normal.xyz, uLightDir);
		}
	';
	static inline var SHADER_BUFFER_IDENTIFIERS = [ "aVertPos", "aVertNorm", "aTexCoord" ];
	static inline var SHADER_BUFFER_UNIFORMS = [ "uViewMatrix", "uProjMatrix", "uNormMatrix", "uLightDir" ];
	#end

	/**
	* Creates a new BitmapMaterial.
	* <p>Please note that we use internally a copy of the constructor bitmapdata. That means in case you need to access this bitmapdata, you can't just use the same reference
	* but you shall use the BitmapMaterial#texture getter property to make it work.</p>
	*
	* @param p_oTexture	The bitmapdata for this material.
	* @param p_oAttr		The attributes for this material.
	* @param p_nPrecision	The precision of this material. Using a precision with 0 makes the material behave as before. Then 1 as precision is very high and requires a lot of computation but proceed a the best perpective mapping correction. Bigger values are less CPU intensive but also less accurate. Usually a value of 5 is enough.
	*
	* @see sandy.materials.attributes.MaterialAttributes
	*/
	public function new( ?p_oTexture:BitmapData, ?p_oAttr:MaterialAttributes, p_nPrecision:Int = 0)
	{
		smooth = false;
		precision = 0;
		maxRecurssionDepth = 5;

		m_oDrawMatrix = new Matrix();
		m_oColorTransform = new ColorTransform();

		map = new Matrix();
		m_nAlpha = 1.0;
		m_nRecLevel = 0;
		m_oPoint = new Point();
		matrix = new Matrix();
		m_oTiling = new Point( 1, 1 );
		m_oOffset = new Point( 0, 0 );
		forceUpdate = false;

		#if (js && SANDY_WEBGL)
		if ( jeash.Lib.mOpenGL )
		{
			if (m_sFragmentShader == null )
				m_sFragmentShader = TEXTURED_FRAGMENT_SHADER;
			if (m_sVertexShader == null )
				m_sVertexShader = TEXTURED_VERTEX_SHADER;
			m_oShaderGL = Graphics.CreateShaderGL( m_sFragmentShader, m_sVertexShader, SHADER_BUFFER_IDENTIFIERS );
		}
		#end


		super(p_oAttr);
		// --
		m_oType = MaterialType.BITMAP;
		// --
		texture = p_oTexture;
// 		var temp:BitmapData = new BitmapData( p_oTexture.width, p_oTexture.height, true, 0 );
// 		temp.draw( p_oTexture );
// 		texture = temp;
		// --
		m_oPolygonMatrixMap = new IntHash();
		precision = p_nPrecision;
	}

	/**
	* Renders this material on the face it dresses
	*
	* @param p_oScene		The current scene
	* @param p_oPolygon	The face to be rendered
	* @param p_mcContainer	The container to draw on
	*/
	public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):Void
	{
		if( m_oTexture == null ) return;
		// --
		var l_points:Array<Vertex>, l_uv:Array<UVCoord>;
		// --
		polygon = p_oPolygon;
		graphics = p_mcContainer.graphics;
		// --
		m_nRecLevel = 0;
		// --

		if( polygon.isClipped || polygon.vertices.length > 3 )
		{
			l_points = polygon.isClipped ? p_oPolygon.cvertices : p_oPolygon.vertices;
			l_uv = polygon.isClipped ? p_oPolygon.caUVCoord : p_oPolygon.aUVCoord;
			// --
			for( i in 1...l_points.length - 1)
			{
				map = _createTextureMatrix( l_uv[0].u, l_uv[0].v, l_uv[i].u, l_uv[i].v, l_uv[i+1].u, l_uv[i+1].v );
				// --
				var v0 = l_points[0];
				var v1 = l_points[i];
				var v2 = l_points[i+1];

				if( precision == 0 )
				{
					renderTriangle(map.a, map.b, map.c, map.d, map.tx, map.ty, v0.sx, v0.sy, v1.sx, v1.sy, v2.sx, v2.sy );
				}
				else
				{
					#if cpp
					renderRec(	[map.a, map.b, map.c, map.d, map.tx, map.ty,
								v0.sx, v0.sy, v0.wz,
								v1.sx, v1.sy, v1.wz,
								v2.sx, v2.sy, v2.wz]);
					#else
					renderRec(	map.a, map.b, map.c, map.d, map.tx, map.ty,
								v0.sx, v0.sy, v0.wz,
								v1.sx, v1.sy, v1.wz,
								v2.sx, v2.sy, v2.wz);
					#end
				}
			}
		}
		else
		{
			l_points = p_oPolygon.vertices;
			l_uv = p_oPolygon.aUVCoord;
			// --
			map = m_oPolygonMatrixMap.get(polygon.id);
			if(map != null) {
				var v0:Vertex = l_points[0];
				var v1:Vertex = l_points[1];
				var v2:Vertex = l_points[2];
				if( precision == 0 )
				{
					renderTriangle(map.a, map.b, map.c, map.d, map.tx, map.ty, v0.sx, v0.sy, v1.sx, v1.sy, v2.sx, v2.sy );
				}
				else
				{
					#if cpp
					renderRec(	[map.a, map.b, map.c, map.d, map.tx, map.ty,
								v0.sx, v0.sy, v0.wz,
								v1.sx, v1.sy, v1.wz,
								v2.sx, v2.sy, v2.wz]);
					#else
					renderRec(	map.a, map.b, map.c, map.d, map.tx, map.ty,
								v0.sx, v0.sy, v0.wz,
								v1.sx, v1.sy, v1.wz,
								v2.sx, v2.sy, v2.wz);
					#end
				}
			}
		}
		// --
		super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
		// --
		l_points = null;
		l_uv = null;
	}

#if cpp
private function renderRec( args:Array<Float> ):Void
	{
		var ta:Float = args[0]; 
		var tb:Float = args[1]; 
		var tc:Float = args[2]; 
		var td:Float = args[3]; 
		var tx:Float = args[4]; 
		var ty:Float = args[5]; 
		var ax:Float = args[6]; 
		var ay:Float = args[7]; 
		var az:Float = args[8]; 
		var bx:Float = args[9]; 
		var by:Float = args[10]; 
		var bz:Float = args[11]; 
		var cx:Float = args[12]; 
		var cy:Float = args[13]; 
		var cz:Float = args[14];
	
		m_nRecLevel++;
		var ta2:Float = ta+ta;
		var tb2:Float = tb+tb;
		var tc2:Float = tc+tc;
		var td2:Float = td+td;
		var tx2:Float = tx+tx;
		var ty2:Float = ty+ty;
		var mabz:Float = 2 / (az + bz);
		var mbcz:Float = 2 / (bz + cz);
		var mcaz:Float = 2 / (cz + az);
		var mabx:Float = (ax*az + bx*bz)*mabz;
		var maby:Float = (ay*az + by*bz)*mabz;
		var mbcx:Float = (bx*bz + cx*cz)*mbcz;
		var mbcy:Float = (by*bz + cy*cz)*mbcz;
		var mcax:Float = (cx*cz + ax*az)*mcaz;
		var mcay:Float = (cy*cz + ay*az)*mcaz;
		var dabx:Float = ax + bx - mabx;
		var daby:Float = ay + by - maby;
		var dbcx:Float = bx + cx - mbcx;
		var dbcy:Float = by + cy - mbcy;
		var dcax:Float = cx + ax - mcax;
		var dcay:Float = cy + ay - mcay;
		var dsab:Float = (dabx*dabx + daby*daby);
		var dsbc:Float = (dbcx*dbcx + dbcy*dbcy);
		var dsca:Float = (dcax*dcax + dcay*dcay);
		var mabxHalf:Float = mabx*0.5;
		var mabyHalf:Float = maby*0.5;
		var azbzHalf:Float = (az+bz)*0.5;
		var mcaxHalf:Float = mcax*0.5;
		var mcayHalf:Float = mcay*0.5;
		var czazHalf:Float = (cz+az)*0.5;
		var mbcxHalf:Float = mbcx*0.5;
		var mbcyHalf:Float = mbcy*0.5;
		var bzczHalf:Float = (bz+cz)*0.5;

		if (( m_nRecLevel > maxRecurssionDepth ) || ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision))){
			renderTriangle(ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy);
			m_nRecLevel--;
		} else if ((dsab > precision) && (dsca > precision) && (dsbc > precision) ){
			renderRec([ta2, tb2, tc2, td2, tx2, ty2,
				ax, ay, az, mabxHalf, mabyHalf, azbzHalf, mcaxHalf, mcayHalf, czazHalf]);

			renderRec([ta2, tb2, tc2, td2, tx2-1, ty2,
				mabxHalf, mabyHalf, azbzHalf, bx, by, bz, mbcxHalf, mbcyHalf, bzczHalf]);

			renderRec([ta2, tb2, tc2, td2, tx2, ty2-1,
				mcaxHalf, mcayHalf, czazHalf, mbcxHalf, mbcyHalf, bzczHalf, cx, cy, cz]);

			renderRec([-ta2, -tb2, -tc2, -td2, -tx2+1, -ty2+1,
				mbcxHalf, mbcyHalf, bzczHalf, mcaxHalf, mcayHalf, czazHalf, mabxHalf, mabyHalf, azbzHalf]);

			m_nRecLevel--;
		} else {
			var dmax:Float = Math.max(dsab, Math.max(dsca, dsbc));
			
			if (dsab == dmax) {
				renderRec([ta2, tb, tc2, td, tx2, ty,
					ax, ay, az, mabxHalf, mabyHalf, azbzHalf, cx, cy, cz]);

				renderRec([ta2+tb, tb, tc2+td, td, tx2+ty-1, ty,
					mabxHalf, mabyHalf, azbzHalf, bx, by, bz, cx, cy, cz]);

				m_nRecLevel--;
			} else if (dsca == dmax){
				renderRec([ta, tb2, tc, td2, tx, ty2,
					ax, ay, az, bx, by, bz, mcaxHalf, mcayHalf, czazHalf]);

				renderRec([ta, tb2 + ta, tc, td2 + tc, tx, ty2+tx-1,
					mcaxHalf, mcayHalf, czazHalf, bx, by, bz, cx, cy, cz]);

				m_nRecLevel--;
			} else {
				renderRec([ta-tb, tb2, tc-td, td2, tx-ty, ty2,
					ax, ay, az, bx, by, bz, mbcxHalf, mbcyHalf, bzczHalf]);

				renderRec([ta2, tb-ta, tc2, td-tc, tx2, ty-tx,
					ax, ay, az, mbcxHalf, mbcyHalf, bzczHalf, cx, cy, cz]);

				m_nRecLevel--;
			}
		}
	}
#else
	private function renderRec( ta:Float, tb:Float, tc:Float, td:Float, tx:Float, ty:Float,
	ax:Float, ay:Float, az:Float, bx:Float, by:Float, bz:Float, cx:Float, cy:Float, cz:Float):Void
	{
		m_nRecLevel++;
		var ta2:Float = ta+ta;
		var tb2:Float = tb+tb;
		var tc2:Float = tc+tc;
		var td2:Float = td+td;
		var tx2:Float = tx+tx;
		var ty2:Float = ty+ty;
		var mabz:Float = 2 / (az + bz);
		var mbcz:Float = 2 / (bz + cz);
		var mcaz:Float = 2 / (cz + az);
		var mabx:Float = (ax*az + bx*bz)*mabz;
		var maby:Float = (ay*az + by*bz)*mabz;
		var mbcx:Float = (bx*bz + cx*cz)*mbcz;
		var mbcy:Float = (by*bz + cy*cz)*mbcz;
		var mcax:Float = (cx*cz + ax*az)*mcaz;
		var mcay:Float = (cy*cz + ay*az)*mcaz;
		var dabx:Float = ax + bx - mabx;
		var daby:Float = ay + by - maby;
		var dbcx:Float = bx + cx - mbcx;
		var dbcy:Float = by + cy - mbcy;
		var dcax:Float = cx + ax - mcax;
		var dcay:Float = cy + ay - mcay;
		var dsab:Float = (dabx*dabx + daby*daby);
		var dsbc:Float = (dbcx*dbcx + dbcy*dbcy);
		var dsca:Float = (dcax*dcax + dcay*dcay);
		var mabxHalf:Float = mabx*0.5;
		var mabyHalf:Float = maby*0.5;
		var azbzHalf:Float = (az+bz)*0.5;
		var mcaxHalf:Float = mcax*0.5;
		var mcayHalf:Float = mcay*0.5;
		var czazHalf:Float = (cz+az)*0.5;
		var mbcxHalf:Float = mbcx*0.5;
		var mbcyHalf:Float = mbcy*0.5;
		var bzczHalf:Float = (bz+cz)*0.5;

		if (( m_nRecLevel > maxRecurssionDepth ) || ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision)))
		{
			renderTriangle(ta, tb, tc, td, tx, ty, ax, ay, bx, by, cx, cy);
			m_nRecLevel--; return;
		}

		if ((dsab > precision) && (dsca > precision) && (dsbc > precision) )
		{
			renderRec(ta2, tb2, tc2, td2, tx2, ty2,
				ax, ay, az, mabxHalf, mabyHalf, azbzHalf, mcaxHalf, mcayHalf, czazHalf);

			renderRec(ta2, tb2, tc2, td2, tx2-1, ty2,
				mabxHalf, mabyHalf, azbzHalf, bx, by, bz, mbcxHalf, mbcyHalf, bzczHalf);

			renderRec(ta2, tb2, tc2, td2, tx2, ty2-1,
				mcaxHalf, mcayHalf, czazHalf, mbcxHalf, mbcyHalf, bzczHalf, cx, cy, cz);

			renderRec(-ta2, -tb2, -tc2, -td2, -tx2+1, -ty2+1,
				mbcxHalf, mbcyHalf, bzczHalf, mcaxHalf, mcayHalf, czazHalf, mabxHalf, mabyHalf, azbzHalf);

			m_nRecLevel--; return;
		}

		var dmax:Float = Math.max(dsab, Math.max(dsca, dsbc));

		if (dsab == dmax)
		{
			renderRec(ta2, tb, tc2, td, tx2, ty,
				ax, ay, az, mabxHalf, mabyHalf, azbzHalf, cx, cy, cz);

			renderRec(ta2+tb, tb, tc2+td, td, tx2+ty-1, ty,
				mabxHalf, mabyHalf, azbzHalf, bx, by, bz, cx, cy, cz);

			m_nRecLevel--; return;
		}

		if (dsca == dmax)
		{
			renderRec(ta, tb2, tc, td2, tx, ty2,
				ax, ay, az, bx, by, bz, mcaxHalf, mcayHalf, czazHalf);

			renderRec(ta, tb2 + ta, tc, td2 + tc, tx, ty2+tx-1,
				mcaxHalf, mcayHalf, czazHalf, bx, by, bz, cx, cy, cz);

			m_nRecLevel--; return;
		}

		renderRec(ta-tb, tb2, tc-td, td2, tx-ty, ty2,
			ax, ay, az, bx, by, bz, mbcxHalf, mbcyHalf, bzczHalf);

		renderRec(ta2, tb-ta, tc2, td-tc, tx2, ty-tx,
			ax, ay, az, mbcxHalf, mbcyHalf, bzczHalf, cx, cy, cz);

		m_nRecLevel--;
	}
#end

	private function renderTriangle(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float,
		v0x:Float, v0y:Float, v1x:Float, v1y:Float, v2x:Float, v2y:Float):Void
	{
		var a2:Float = v1x - v0x;
		var b2:Float = v1y - v0y;
		var c2:Float = v2x - v0x;
		var d2:Float = v2y - v0y;

		matrix.a = a*a2 + b*c2;
		matrix.b = a*b2 + b*d2;
		matrix.c = c*a2 + d*c2;
		matrix.d = c*b2 + d*d2;
		matrix.tx = tx*a2 + ty*c2 + v0x;
		matrix.ty = tx*b2 + ty*d2 + v0y;

		// smooth threshold
		var st:Float = v0x*(d2 - b2) - v1x*d2 + v2x*b2; if (st < 0) st = -st;

		graphics.lineStyle();
		graphics.beginBitmapFill((m_nAlpha == 1) ? m_oTexture : m_oTextureClone, matrix, repeat, smooth && (st > 100));
		graphics.moveTo(v0x, v0y);
		graphics.lineTo(v1x, v1y);
		graphics.lineTo(v2x, v2y);
		graphics.endFill();
	}


// 	private function _createTextureMatrix( p_aUv:Array<UVCoord> ):Matrix
// 	{
// 		var u0: Float = (p_aUv[0].u * m_oTiling.x + m_oOffset.x) * m_nWidth,
// 			v0: Float = (p_aUv[0].v * m_oTiling.y + m_oOffset.y) * m_nHeight,
// 			u1: Float = (p_aUv[1].u * m_oTiling.x + m_oOffset.x) * m_nWidth,
// 			v1: Float = (p_aUv[1].v * m_oTiling.y + m_oOffset.y) * m_nHeight,
// 			u2: Float = (p_aUv[2].u * m_oTiling.x + m_oOffset.x) * m_nWidth,
// 			v2: Float = (p_aUv[2].v * m_oTiling.y + m_oOffset.y) * m_nHeight;
// 		// -- Fix perpendicular projections. Not sure it is really useful here since there's no texture prjection. This will certainly solve the freeze problem tho
// 		if( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) )
// 		{
// 			u0 -= (u0 > 0.05)? 0.05 : -0.05;
// 			v0 -= (v0 > 0.07)? 0.07 : -0.07;
// 		}
// 		if( u2 == u1 && v2 == v1 )
// 		{
// 			u2 -= (u2 > 0.05)? 0.04 : -0.04;
// 			v2 -= (v2 > 0.06)? 0.06 : -0.06;
// 		}
// 		// --
// 		var m:Matrix = new Matrix( (u1 - u0), (v1 - v0), (u2 - u0), (v2 - v0), u0, v0 );
// 		m.invert();
// 		return m;
// 	}

	private function _createTextureMatrix( p_nU0:Float, p_nV0:Float, p_nU1:Float, p_nV1:Float, p_nU2:Float, p_nV2:Float ):Matrix
	{
		var u0: Float = (p_nU0 * m_oTiling.x + m_oOffset.x) * m_nWidth,
			v0: Float = (p_nV0 * m_oTiling.y + m_oOffset.y) * m_nHeight,
			u1: Float = (p_nU1 * m_oTiling.x + m_oOffset.x) * m_nWidth,
			v1: Float = (p_nV1 * m_oTiling.y + m_oOffset.y) * m_nHeight,
			u2: Float = (p_nU2 * m_oTiling.x + m_oOffset.x) * m_nWidth,
			v2: Float = (p_nV2 * m_oTiling.y + m_oOffset.y) * m_nHeight;
		// -- Fix perpendicular projections. Not sure it is really useful here since there's no texture prjection. This will certainly solve the freeze problem tho
		if( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) )
		{
			u0 -= (u0 > 0.05)? 0.05 : -0.05;
			v0 -= (v0 > 0.07)? 0.07 : -0.07;
		}
		if( u2 == u1 && v2 == v1 )
		{
			u2 -= (u2 > 0.05)? 0.04 : -0.04;
			v2 -= (v2 > 0.06)? 0.06 : -0.06;
		}
		// --
		var m:Matrix = new Matrix( (u1 - u0), (v1 - v0), (u2 - u0), (v2 - v0), u0, v0 );
		m.invert();
		return m;
	}


	/**
	* The texture ( bitmap ) of this material.
	*/
	public var texture(__getTexture,__setTexture):BitmapData;
	private function __getTexture():BitmapData
	{
		return m_oTexture;
	}

	/**
	* @private
	*/
	private function __setTexture( p_oTexture:BitmapData ):BitmapData
	{
		if( p_oTexture == m_oTexture )
		{
			return p_oTexture;
		}
		else
		{
			if( m_oTexture != null ) m_oTexture.dispose();
		}
		// --
		var l_bReWrap:Bool = false;
		if( m_nHeight != p_oTexture.height) l_bReWrap = true;
		else if( m_nWidth != p_oTexture.width) l_bReWrap = true;
		// --
		m_oTexture = p_oTexture;

		m_nHeight = m_oTexture.height;
		m_nWidth = m_oTexture.width;
		m_nInvHeight = 1/m_nHeight;
		m_nInvWidth = 1/m_nWidth;

		// -- We reinitialize the precomputed matrix
		if( l_bReWrap && m_oPolygonMatrixMap != null )
		{
			for( l_sID in m_oPolygonMatrixMap.keys() )
			{
				var l_oPoly:Polygon = Polygon.POLYGON_MAP.get( l_sID );
				unlink( l_oPoly );
				init( l_oPoly );
			}
		}
		return p_oTexture;
	}

	/**
	* Sets texture tiling and optional offset. Tiling is applied first.
	*/
	public function setTiling( p_nW:Float, p_nH:Float, p_nU:Float = 0.0, p_nV:Float = 0.0 ):Void
	{
		m_oTiling.x = p_nW;
		m_oTiling.y = p_nH;
		// --
		m_oOffset.x = p_nU - Math.floor (p_nU);
		m_oOffset.y = p_nV - Math.floor (p_nV);
		// --
		m_bModified = true;
		// is this necessary now?
		for( l_sID in m_oPolygonMatrixMap.keys() )
		{
			var l_oPoly:Polygon = Polygon.POLYGON_MAP.get( l_sID );
			unlink( l_oPoly );
			init( l_oPoly );
		}
	}

	/**
	* Changes the transparency of the texture.
	*
	* <p>The passed value is the percentage of opacity. Note that in order for this to work with animated texture,
	* you need set material transparency every time after new texture frame is rendered.</p>
	*
	* @param p_nValue 	A value between 0 and 1. (automatically constrained)
	*/
	public function setTransparency( p_nValue:Float ):Void
	{
		if (m_oTexture == null)
		{
			throw "Setting transparency requires setting texture first.";
		}

		p_nValue = NumberUtil.constrain( p_nValue, 0, 1 ); m_nAlpha = p_nValue;

		if (p_nValue == 1) return;

		if (m_oTextureClone != null)
		{
			if ((m_oTextureClone.height != m_oTexture.height) ||
				(m_oTextureClone.width != m_oTexture.width))
			{
					m_oTextureClone.dispose ();
					m_oTextureClone = null;
			}
		}

		if (m_oTextureClone == null)
		{
			m_oTextureClone = new BitmapData (m_oTexture.width, m_oTexture.height, true, 0);
		}

		m_oColorTransform.alphaMultiplier = p_nValue;
		m_oTextureClone.lock ();
		m_oTextureClone.fillRect (m_oTextureClone.rect, #if neko cast #end 0 );
		m_oTextureClone.draw (m_oTexture, m_oDrawMatrix, m_oColorTransform);
		m_oTextureClone.unlock ();
	}

	private var m_oTextureClone:BitmapData;
	private var m_oDrawMatrix:Matrix;
	private var m_oColorTransform:ColorTransform;

	/**
	* Indicates the alpha transparency value of the material. Valid values are 0 (fully transparent) to 1 (fully opaque).
	*
	* @default 1.0
	*/
	public var alpha(__getAlpha,__setAlpha):Float;
	private function __getAlpha():Float
	{
		return m_nAlpha;
	}

	private function __setAlpha(p_nValue:Float):Float
	{
		setTransparency(p_nValue);
		m_bModified = true;
		return p_nValue;
	}

	override public function dispose():Void
	{
		super.dispose();
		if( m_oTexture != null ) m_oTexture.dispose();
		m_oTexture = null;
		if( m_oTextureClone != null ) m_oTextureClone.dispose();
		m_oTextureClone = null;
		m_oPolygonMatrixMap = null;
	}

	public override function unlink( p_oPolygon:Polygon ):Void
	{
		if( m_oPolygonMatrixMap != null )
		{
			if( m_oPolygonMatrixMap.exists(p_oPolygon.id) )
				m_oPolygonMatrixMap.remove(p_oPolygon.id);
		}
		// --
		super.unlink( p_oPolygon );
	}

	/**
	* @param p_oPolygon	The face dressed by this material
	*/
	public override function init( p_oPolygon:Polygon ):Void
	{
		if( m_oPolygonMatrixMap != null && p_oPolygon.vertices.length >= 3 )
		{
			var m:Matrix = null;
			// --
			if( m_nWidth > 0 && m_nHeight > 0 )
			{
				var l_aUV:Array<UVCoord> = p_oPolygon.aUVCoord;
				if( l_aUV != null )
				{
					m = _createTextureMatrix( l_aUV[0].u, l_aUV[0].v, l_aUV[1].u, l_aUV[1].v, l_aUV[2].u, l_aUV[2].v );
				}
			}
			// --
			m_oPolygonMatrixMap.set(p_oPolygon.id, m);
		}
		// --
		super.init( p_oPolygon );
	}

	#if (js && SANDY_WEBGL)
	/**
	* @param p_oGraphics	The graphics object that will draw this material
	*/
	public override function initGL( p_oShape:Shape3D, p_oSprite:Sprite ):Void
	{
		p_oSprite.graphics.beginBitmapFill(m_oTexture);
		var gl : WebGLRenderingContext = jeash.Lib.canvas.getContext(jeash.Lib.context);
		for (key in SHADER_BUFFER_UNIFORMS)
			p_oShape.uniforms.set(key, gl.getUniformLocation( p_oSprite.graphics.mShaderGL, key ));
	}

	/**
	* Called every frame, sets GPU uniforms if associated with this material.
	*
	* @param p_oGraphics	The graphics object that will draw this material
	*/
	override public function setMatrixUniformsGL( p_oShape:Shape3D, p_oSprite:Sprite )
	{
		var gl : WebGLRenderingContext = jeash.Lib.canvas.getContext(jeash.Lib.context);

		// --

		// set projection matrix uniform

		var _c = p_oShape.scene.camera.projectionMatrix.clone();
		_c.transpose();
		gl.uniformMatrix4fv( p_oShape.uniforms.get("uProjMatrix"), false, _c.toArray() );

		// --

		// set view matrix uniform

		var _v = p_oShape.scene.camera.viewMatrix.clone();
		var _m = p_oShape.viewMatrix.clone();
		_v.multiply( _m );
		_v.transpose();

		gl.uniformMatrix4fv( p_oShape.uniforms.get("uViewMatrix"), false, _v.toArray() );

		// --

		// set normal uniform

		var _n = p_oShape.viewMatrix.clone();
		_n.inverse();
		_n.multiply( _m );
		_n.transpose();
		gl.uniformMatrix4fv( p_oShape.uniforms.get("uNormMatrix"), false, _n.toArray() );

		// --

		// set light direction

		var _d = p_oShape.scene.light.getDirectionPoint3D();
		gl.uniform3f( p_oShape.uniforms.get("uLightDir"), _d.x, _d.y, _d.z );


		return true;
	}

	#end

	/**
	* Returns a string representation of this object.
	*
	* @return	The fully qualified name of this object.
	*/
	public function toString():String
	{
		return 'sandy.materials.BitmapMaterial' ;
	}

	var polygon:Polygon;
	var graphics:Graphics;
	var map:Matrix;

	private var m_oTexture:BitmapData;

	private var m_nHeight:Float;
	private var m_nWidth:Float;
	private var m_nInvHeight:Float;
	private var m_nInvWidth:Float;
	private var m_nAlpha:Float;

	private var m_nRecLevel:Int;

	private var m_oPolygonMatrixMap:IntHash<Matrix>;

	private var m_oPoint:Point;

	private var matrix:Matrix;

	private var m_oTiling:Point;

	private var m_oOffset:Point;

	public var forceUpdate:Bool;
}

