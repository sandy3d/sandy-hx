
package sandy.primitive;

import sandy.core.data.PrimitiveFace;
import sandy.core.data.Vertex;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;

import sandy.HaxeTypes;

/**
* The Cylinder class is used for creating a cylinder primitive, a cone or a truncated cone.
*
* <p>All credits go to Tim Knipt from suite75.net who created the AS2 implementation.
* Original sources available at : http://www.suite75.net/svn/papervision3d/tim/as2/org/papervision3d/objects/Cylinder.as</p>
*
* @author		Xavier Martin ( ajout fonction getTop, getBottom, getTop )
* @author		Thomas Pfeiffer ( adaption for Sandy )
* @author		Tim Knipt
* @author		Niel Drummond - haXe port
* @author		Russell Weir
* @version		3.1
* @date 		26.07.2007
*
* @example To create a cylinder with a base radius of 150 and a height of 300,
* with default number of faces, use the following statement:
*
* <listing version="3.1">
*     var cyl:Cylinder = new Cylinder( "theCylinder", 150, 300 );
*  </listing>
* To create a truncated cone, you pass a top radius value to the constructor
* <listing version="3.1">
*     var tCone:Cylinder = new Cylinder( "trunkCone", 150, 300, 0, 0, 40 );
*  </listing>
*/
class Cylinder extends Shape3D, implements Primitive3D
{
	/**
	* The number of horizontal segments.
	*/
	public var segmentsW(default,null) :Int;

	/**
	* The number of vertical segments.
	*/
	public var segmentsH(default,null) :Int;

	/**
	* The default radius for a cylinder.
	*/
	static public inline var DEFAULT_RADIUS :Float = 100.;

	/**
	* The default height for a cylinder.
	*/
	static public inline var DEFAULT_HEIGHT :Float = 100.;

	/**
	* The default scale for a cylinder texture.
	*/
	static public inline var DEFAULT_SCALE :Float = 1.;

	/**
	* The default number of horizontal segments for a cylinder.
	*/
	static public inline var DEFAULT_SEGMENTSW :Float = 8.;

	/**
	* The default number of vertical segments for a cylinder.
	*/
	static public inline var DEFAULT_SEGMENTSH :Float = 6.;

	/**
	* The minimum number of horizontal segments for a cylinder.
	*/
	static public inline var MIN_SEGMENTSW :Float = 3.;

	/**
	* The minimum number of vertical segments for a cylinder.
	*/
	static public inline var MIN_SEGMENTSH :Float = 2.;


	private var topRadius:Float;
	private var radius:Float;
	private var height:Float;

	private var m_bIsTopExcluded:Bool;
	private var m_bIsBottomExcluded:Bool;

	private var m_bIsWholeMappingEnabled:Bool;

	/**
	* Number of polygon for the base ( so bottom and top )
	*/
	private var m_nPolBase : Int;

	/**
	* Number of polygon to jump to come back on the same face ( side ) you were on
	* as the cylinder is rendered in rows
	*/
	private var m_nNextPolFace : Int;

	private var m_aFaces : Array<PrimitiveFace>;

	/**
	* Creates a Cylinder primitive or truncated cone.
	*
	* <p>The cylinder is created at the origin of the world coordinate system, with its axis
	* along the y axis, and with the bottom and top surfaces paralell to the zx plane</p>
	*
	* <p>All arguments to the constructor have default values, and are optional.
	* If you pass in a top radius, that is different from the bottom radius,
	* a truncated cone is created.</p>
	* <p>By passing true values to one or both of p_bExcludeBottom and p_bExludeTop,
	* you exclude the bottom and/or top surfaces from being created.</p>
	*
	* @param p_sName 			A string identifier for this object.
	* @param p_nRadius			Radius of the cylinder.
	* @param p_nHeight			Height of the cylinder.
	* @param p_nSegmentsW		Number of horizontal segments.
	* @param p_nSegmentsH		Number of vertical segments.
	* @param p_nTopRadius		An optional parameter for cone - or diverging cylinders.
	* @param p_bExcludeBottom	If set to true, the bottom face is not created.
	* @param p_bExludeTop		If set to true, the top face is not created.
	* @param p_bWholeMapping 	Specifies how the material applied to the cylinder will
	* be mapped. If set to <code>false</code>, the material will be mapped to each individual
	* face, rather than to the whole cylinder.
	*/
	public function new( p_sName:String = null, p_nRadius:Float = 100.0, p_nHeight:Float = 100.0,
						p_nSegmentsW:Int=8, p_nSegmentsH=6,
						?p_nTopRadius:Float,
						p_bExcludeBottom:Bool=false, p_bExludeTop:Bool=false,
						p_bWholeMapping:Bool=true )
	{
		if (p_nTopRadius == null) p_nTopRadius = Math.NaN;

		super( p_sName );

		this.segmentsW = Std.int(Math.max( MIN_SEGMENTSW, (p_nSegmentsW == 0 ? DEFAULT_SEGMENTSW : p_nSegmentsW)));
		this.segmentsH = Std.int(Math.max( MIN_SEGMENTSH, (p_nSegmentsH == 0 ? DEFAULT_SEGMENTSH : p_nSegmentsH)));
		radius = (p_nRadius==0) ? DEFAULT_RADIUS : p_nRadius; // Defaults to 100
		height = (p_nHeight==0) ? DEFAULT_HEIGHT : p_nHeight; // Defaults to 100
		topRadius = ( Math.isNaN(p_nTopRadius) ) ? radius : p_nTopRadius;

		var scale :Float = DEFAULT_SCALE;
		m_bIsBottomExcluded = p_bExcludeBottom;
		m_bIsTopExcluded = p_bExludeTop;
		m_bIsWholeMappingEnabled = p_bWholeMapping;

		/**/
		m_nPolBase = (!m_bIsBottomExcluded) ? this.segmentsW - 2 : 0;
		m_nNextPolFace = this.segmentsW * 2;

		geometry = generate();
		_generateFaces();
	}

	public override function clone( ?p_sName:String = "", ?p_bKeepTransform:Bool=false ):Shape3D
	{
		var o = new Cylinder( p_sName, radius, height,
				segmentsW, segmentsH,
				topRadius,
				m_bIsBottomExcluded, m_bIsTopExcluded,
				m_bIsWholeMappingEnabled );
		o.copy(this, p_bKeepTransform, false);
		return o;
	}

	/**
	* Generates the geometry for the cylinder.
	*
	* @return The geometry object for the cylinder.
	*
	* @see sandy.core.scenegraph.Geometry3D
	*/
	public function generate<T>(?arguments:Array<T>):Geometry3D
	{
		var l_oGeometry3D:Geometry3D = new Geometry3D();
		// --
		var i:Float, j:Float, k:Float;
		var iHor:Int = Std.int(Math.max(3,this.segmentsW));
		var iVer:Int = Std.int(Math.max(2,this.segmentsH));
		var aVtc:Array<Array<Int>> = new Array();
		// --
		for ( j in 0...(iVer+1) )
		{ // vertical
			var fRad1:Float = (j/iVer);
			var fZ:Float = height*(j/(iVer+0))-height/2;
			var fRds:Float = topRadius+(radius-topRadius)*(1-j/(iVer));
			var aRow:Array<Int> = new Array();
			var oVtx:Int;
			// --
			for ( i in 0...(iHor) )
			{ // horizontal
				var fRad2:Float = (2*i/iHor);
				var fX:Float = fRds*Math.sin(fRad2*Math.PI);
				var fY:Float = fRds*Math.cos(fRad2*Math.PI);
				// --
				oVtx = l_oGeometry3D.setVertex( l_oGeometry3D.getNextVertexID(), fY, fZ, fX );//fY, -fZ, fX );
				aRow.push(oVtx);
			}
			aVtc.push(aRow);
		}

		var iVerNum:Int = aVtc.length;

		var aP4uv:Int, aP1uv:Int, aP2uv:Int, aP3uv:Int;
		var aP1:Int, aP2:Int, aP3:Int, aP4:Int;
		var l_oP1:Vertex, l_oP2:Vertex, l_oP3:Vertex;
		// --
		var nF:Int;
		for ( j in 0...iVerNum )
		{
			var iHorNum:Int = aVtc[j].length;
			for ( i in 0...iHorNum )
			{
				if ( j > 0 && i >= 0 )
				{
					// select vertices
					var bEnd:Bool = i==(iHorNum-0);
					// --
					aP1 = aVtc[j][bEnd?0:i];
					aP2 = aVtc[j][(i==0?iHorNum:i)-1];
					aP3 = aVtc[j-1][(i==0?iHorNum:i)-1];
					aP4 = aVtc[j-1][bEnd?0:i];
					// -- uv
					var fJ0:Float, fJ1:Float, fI0:Float, fI1:Float;
					if( m_bIsWholeMappingEnabled )
					{
						fJ0 = j		/ (iVerNum-1);
						fJ1 = (j-1)	/ (iVerNum-1);
						fI0 = (i+1)	/ iHorNum;
						fI1 = i		/ iHorNum;
					}
					else
					{
						fJ0 = ((j))	/ iVer;
						fJ1 = ((j-1))  / iVer;
						fI0 = 0;
						fI1 = 1;
					}
					//
					aP4uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI0, 1-fJ1);
					aP1uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI0, 1-fJ0);
					aP2uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI1, 1-fJ0);
					aP3uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), fI1, 1-fJ1);
					// 2 faces
					nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), [aP1, aP2, aP3] );
					l_oGeometry3D.setFaceUVCoordsIds( nF, [aP1uv, aP2uv, aP3uv] );

					nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), [aP1, aP3, aP4] );
					l_oGeometry3D.setFaceUVCoordsIds( nF, [aP1uv, aP3uv, aP4uv] );
				}
			}
			if ((j==0 && !m_bIsTopExcluded) || ( j==(iVerNum-1) && !m_bIsBottomExcluded ) )
			{
				for (i in 0...(iHorNum-2))
				{
					// uv
					var iI:Int = Math.floor(i/2);
					aP1 = aVtc[j][iI];
					aP2 = (i%2==0)? (aVtc[j][iHorNum-2-iI]) : (aVtc[j][iI+1]);
					aP3 = (i%2==0)? (aVtc[j][iHorNum-1-iI]) : (aVtc[j][iHorNum-2-iI]);

					// --
					l_oP1 = l_oGeometry3D.aVertex[aP1];
					l_oP2 = l_oGeometry3D.aVertex[aP2];
					l_oP3 = l_oGeometry3D.aVertex[aP3];
					// --
					var bTop:Bool = j==0;
					aP1uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), (bTop?1:0)+(bTop?-1:1)*(l_oP1.x/radius/2+.5), 1-(l_oP1.z/radius/2+.5) );
					aP2uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), (bTop?1:0)+(bTop?-1:1)*(l_oP2.x/radius/2+.5), 1-(l_oP2.z/radius/2+.5) );
					aP3uv = l_oGeometry3D.setUVCoords(l_oGeometry3D.getNextUVCoordID(), (bTop?1:0)+(bTop?-1:1)*(l_oP3.x/radius/2+.5), 1-(l_oP3.z/radius/2+.5) );

					// face
					if (j==0)
					{
						nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), [aP1, aP3, aP2] );
						l_oGeometry3D.setFaceUVCoordsIds( nF, [aP1uv, aP3uv, aP2uv] );
					}
					else
					{
						nF = l_oGeometry3D.setFaceVertexIds( l_oGeometry3D.getNextFaceID(), [aP1, aP2, aP3] );
						l_oGeometry3D.setFaceUVCoordsIds( nF, [aP1uv, aP2uv, aP3uv] );
					}
					//if (j==0)	aFace.push( new Face3D(new Array(aP1,aP3,aP2), this.material, new Array(aP1uv,aP3uv,aP2uv)) );
					//else		aFace.push( new Face3D(new Array(aP1,aP2,aP3), this.material, new Array(aP1uv,aP2uv,aP3uv)) );
				}
			}
		}
		// --
		return l_oGeometry3D;
	}

	private function _generateFaces() : Void
	{
		m_aFaces = new Array();
		// --
		if ( !m_bIsBottomExcluded )
		{
			m_aFaces[ 0 ] = new PrimitiveFace( this );
			for ( ib in 0...m_nPolBase )
			{
				m_aFaces[ 0 ].addPolygon( ib );
			}
		}
		else m_aFaces[ 0 ] = null;

		if ( !m_bIsTopExcluded )
		{
			m_aFaces[ 1 ] = new PrimitiveFace( this );
			for ( it in 0...m_nPolBase )
			{
				 m_aFaces[ 1 ].addPolygon( it + ( m_nPolBase ) + ( m_nNextPolFace * this.segmentsH ) );
			}
		}
		else m_aFaces[ 1 ] = null;

		for ( i in 0...this.segmentsW )
		{
			m_aFaces[ i + 2 ] = new PrimitiveFace( this );
			for ( j in 0...this.segmentsH )
			{
				m_aFaces[ i + 2 ].addPolygon( m_nPolBase + ( i * 2 ) + ( j * m_nNextPolFace ) );
				m_aFaces[ i + 2 ].addPolygon( m_nPolBase + ( i * 2 ) + ( j * m_nNextPolFace ) + 1 );
			}
		}
	}

	/**
	* Returns a PrimitiveFace object ( an array of polygons ) defining the bottom face.
	*
	* @return	The PrimitiveFace object of the bottom face.
	*
	* @see PrimitiveFace
	*/
	public function getBottom() : PrimitiveFace
	{
		return m_aFaces[ 0 ];
	}

	/**
	* Returns a PrimitiveFace object ( an array of polygons ) defining the top face.
	*
	* @return	The PrimitiveFace object of the top face.
	*
	* @see PrimitiveFace
	*/
	public function getTop() : PrimitiveFace
	{
		return m_aFaces[ 1 ];
	}

	/**
	* Returns a PrimitiveFace object ( an array of polygons ) defining the specified face.
	*
	* @param	p_nFace The requested face
	* @return	The PrimitiveFace object of the specified face.
	*
	* @see PrimitiveFace
	*/
	public function getFace( p_nFace : Int ) : PrimitiveFace
	{
		return m_aFaces[ 2 + p_nFace ];
	}

	/**
	* Calculates the radius depending on the number of sides you want and their width.
	* <p>[<strong>ToDo</strong>: Elaborate on this a bit, please :) ]</p>
	*
	* @param	p_nSideNumber The number of sides the cylinder has
	* @param	p_nSideWidth  Width of a side
	* @return	The radius
	*/
	public static function CALCUL_RADIUS_FROM_SIDE( p_nSideNumber : Int, p_nSideWidth : Int ) : Float
	{
		/*	think sin( a - b) = sina cosb - cosa sinb
		*	think sin( a + b) = sina cosb + cosa sinb
		*	think sin2( a ) + cos2( a ) = 1
		*	r = s * ( sin( alpha / 2 ) / sin ( alpha )
		*	r = s * ( sin ( 180/2 - 180/n ) / sin ( 2 * 180 / n ) )
		* 	r = s * ( cos ( 180 / n ) / ( 2 sin (180/n) cos (180/n )
		* 	r = s * ( cos ( 180 / n ) / ( 2 sin (180/n) cos (180/n )
		* 	r = s * ( 1 / ( 2sin 180/n )
		* 	or 2r = s * ( 1 / sin 180/n )
		*/
		return ( p_nSideWidth / ( 2 * Math.sin( Math.PI / p_nSideNumber ) ) );
	}

	/**
	* @private
	*/
	public override function toString():String
	{
		return "sandy.primitive.Cylinder";
	}
}

