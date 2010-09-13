
package sandy.primitive;

import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.core.data.Point3D;

import sandy.HaxeTypes;

/**
* The Sphere class is used for creating a sphere primitive
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir
* @version		3.1
* @date 		26.07.2007
*
* @example To create a sphere with radius 150 and with default settings
* for the number of horizontal and vertical segments, use the following statement:
*
* <listing version="3.1">
*     var mySphere:Sphere = new Sphere( "theSphere", 150);
*  </listing>
*/
class Sphere extends Shape3D, implements Primitive3D
{
	private var radius:Float;

	/**
	* The number of horizontal segments.
	*/
	public var segmentsW :Int;

	/**
	* The number of vertical segments.
	*/
	public var segmentsH :Int;

	/**
	* The default radius for a sphere.
	*/
	static public inline var DEFAULT_RADIUS :Float = 100;

	/**
	* The default scale for a sphere texture.
	*/
	static public inline var DEFAULT_SCALE :Float = 1;

	/**
	* The default number of horizontal segments for a sphere.
	*/
	static public inline var DEFAULT_SEGMENTSW :Float = 8;

	/**
	* The default number of vertical segments for a sphere.
	*/
	static public inline var DEFAULT_SEGMENTSH :Float = 6;

	/**
	* The minimum number of horizontal segments for a sphere.
	*/
	static public inline var MIN_SEGMENTSW :Float = 3;

	/**
	* The minimum number of vertical segments for a sphere.
	*/
	static public inline var MIN_SEGMENTSH :Float = 2;

	/**
	* Creates a Sphere primitive.
	*
	* <p>The sphere is created centered at the origin of the world coordinate system,
	* with its poles on the y axis</p>
	*
	* @param p_sName 		A string identifier for this object.
	* @param p_nRadius		Radius of the sphere.
	* @param p_nSegmentsW	Number of horizontal segments.
	* @param p_nSegmentsH	Number of vertical segments.
	*/
	public function new( p_sName:String = null, p_nRadius:Float = 100.0, p_nSegmentsW:Int=8, p_nSegmentsH:Int=6 )
	{
		super( p_sName );
		setConvexFlag (true);
		// --
		this.segmentsW = Std.int(Math.max( MIN_SEGMENTSW, (p_nSegmentsW == 0 ? DEFAULT_SEGMENTSW : p_nSegmentsW)));
		this.segmentsH = Std.int(Math.max( MIN_SEGMENTSH, (p_nSegmentsH == 0 ? DEFAULT_SEGMENTSH : p_nSegmentsH)));
		radius = (p_nRadius != 0) ? p_nRadius : DEFAULT_RADIUS; // Defaults to 100
		// --
		var scale :Float = DEFAULT_SCALE;
		// --
		geometry = generate();
	}

	public override function clone( ?p_sName:String = "", ?p_bKeepTransform:Bool=false ):Shape3D
	{
		var o = new Sphere( p_sName, radius, segmentsW, segmentsH);
		o.copy(this, p_bKeepTransform, false);
		return o;
	}

	/**
	* Generates the geometry for the sphere.
	*
	* @return The geometry object for the sphere.
	*
	* @see sandy.core.scenegraph.Geometry3D
	*/
	public function generate<T>(?arguments:Array<T>):Geometry3D
	{
		if (arguments == null) arguments = new Array();

		var l_oGeometry:Geometry3D = new Geometry3D();
		// --
		var i:Int, j:Int, k:Int;
		var iHor:Int = Std.int(Math.max(3,this.segmentsW));
		var iVer:Int = Std.int(Math.max(2,this.segmentsH));
		// --
		var aVtc:Array<Array<Int>> = new Array();
		for ( j in 0...(iVer+1) )
		{ // vertical
			var fRad1:Float = (j/iVer);
			var fZ:Float = -radius*Math.cos(fRad1*Math.PI);
			var fRds:Float = radius*Math.sin(fRad1*Math.PI);
			var aRow:Array<Int> = new Array();
			var oVtx:Int = 0;
			for ( i in 0...iHor )
			{ // horizontal
				var fRad2:Float = (2*i/iHor);
				var fX:Float = fRds*Math.sin(fRad2*Math.PI);
				var fY:Float = fRds*Math.cos(fRad2*Math.PI);
				if (!((j==0||j==iVer)&&i>0))
				{ // top||bottom = 1 vertex
					oVtx = l_oGeometry.setVertex( l_oGeometry.getNextVertexID(), fY, fZ, fX );//fY, -fZ, fX );
				}
				aRow.push(oVtx);
			}
			aVtc.push(aRow);
		}
		// --
		var iVerNum:Int = aVtc.length;
		for ( j in 0...iVerNum )
		{
			var iHorNum:Int = aVtc[j].length;
			if (j>0)
			{ // &&i>=0
				for ( i in 0...iHorNum )
				{
					// select vertices
					var bEnd:Bool = i==(iHorNum-0);
					// --
					var l_nP1:Int = aVtc[j][bEnd?0:i];
					var l_nP2:Int = aVtc[j][(i==0?iHorNum:i)-1];
					var l_nP3:Int = aVtc[j-1][(i==0?iHorNum:i)-1];
					var l_nP4:Int = aVtc[j-1][bEnd?0:i];
					// uv
					var fJ0:Float = j		/ (iVerNum-1);
					var fJ1:Float = (j-1)	/ (iVerNum-1);
					var fI0:Float = (i+1)	/ iHorNum;
					var fI1:Float = i		/ iHorNum;

					var l_nUV4:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI0, 1-fJ1 );
					var l_nUV1:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI0, 1-fJ0 );
					var l_nUV2:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI1, 1-fJ0 );
					var l_nUV3:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), fI1, 1-fJ1 );
					var l_nF:Int;

					// 2 faces
					if (j<(aVtc.length-1))
					{
						l_nF = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), [l_nP1, l_nP2, l_nP3] );
						l_oGeometry.setFaceUVCoordsIds( l_nF, [l_nUV1, l_nUV2, l_nUV3] );
						//aFace.push( new Face3D(new Array(aP1,aP2,aP3),new Array(aP1uv,aP2uv,aP3uv)) );
					}
					if (j>1)
					{
						l_nF = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), [l_nP1, l_nP3, l_nP4] );
						l_oGeometry.setFaceUVCoordsIds( l_nF, [l_nUV1, l_nUV3, l_nUV4] );
						//aFace.push( new Face3D(new Array(aP1,aP3,aP4), new Array(aP1uv,aP3uv,aP4uv)) );
					}

				}
			}
		}
		// --
		return l_oGeometry;
	}

	/**
	* @private
	*/
	public override function toString():String
	{
		return "sandy.primitive.Sphere";
	}
}

