
package sandy.primitive;

import sandy.core.data.Point3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;

import sandy.HaxeTypes;

/**
* The Torus class is used for creating a torus primitive. A torus can be seen as a doughnut.
*
* <p>All credits go to Tim Knipt from suite75.net who created the AS2 implementation.
* Original sources available at : http://www.suite75.net/svn/papervision3d/tim/as2/org/papervision3d/objects/Torus.as</p>
*
* @author		Thomas Pfeiffer ( adaption for Sandy )
* @author		Tim Knipt
* @author		Niel Drummond - haXe port
* @author		Russell Weir
* @version		3.1
* @date 		26.07.2007
*
* @example To create a torus with a large radius of 250, a small radius of 80,
* and with default settings for the number of horizontal and vertical segments,
* use the following statement:
*
* <listing version="3.1">
*     var torus:Torus = new Torus( "theTorus", 250, 80 );
*  </listing>
*/
class Torus extends Shape3D, implements Primitive3D
{
	/**
	 * Large radius.
	 */
	public var largeRadius:Float;

	/**
	 * Small radius.
	 */
	public var smallRadius:Float;

	/**
	 * Array of vertex normals.
	 */
	public var normals:Array<Point3D>;

	/**
	* The number of horizontal segments.
	*/
	public var segmentsW :Int;

	/**
	* The number of vertical segments.
	*/
	public var segmentsH :Int;

	/**
	* The default large radius for a sphere.
	*/
	static public inline var DEFAULT_LARGE_RADIUS :Float = 100;

	/**
	* The default small radius for a sphere.
	*/
	static public inline var DEFAULT_SMALL_RADIUS :Float = 50;

	/**
	* The default scale for a torus texture.
	*/
	static public inline var DEFAULT_SCALE :Float = 1;

	/**
	* The default number of horizontal segments for a torus.
	*/
	static public inline var DEFAULT_SEGMENTSW :Float = 12;

	/**
	* The default number of vertical segments for a torus.
	*/
	static public inline var DEFAULT_SEGMENTSH :Float = 8;

	/**
	* The minimum number of horizontal segments for a torus.
	*/
	static public inline var MIN_SEGMENTSW :Float = 3;

	/**
	* The minimum number of vertical segments for a torus.
	*/
	static public inline var MIN_SEGMENTSH :Float = 2;

	/**
	* Creates a Torus primitive.
	*
	* <p>A torus is created at the origin of the world coordinate system, centered, with its axis along the y axis.</p>
	*
	* @param p_sName 		A string identifier for this object.
	* @param p_nLargeRadius	Large radius of the torus.
	* @param p_nSmallRadius	Small radius of the torus.
	* @param p_nSegmentsW	Number of horizontal segments.
	* @param p_nSegmentsH	Number of vertical segments.
	*/
	public function new( p_sName : String = null, p_nLargeRadius:Float=100., p_nSmallRadius:Float=50. , p_nSegmentsW:Int=12, p_nSegmentsH:Int=8 )
	{
		super(p_sName);
		// --
		this.segmentsW = Std.int(Math.max( MIN_SEGMENTSW, (p_nSegmentsW == 0 ? DEFAULT_SEGMENTSW : p_nSegmentsW)));
		this.segmentsH = Std.int(Math.max( MIN_SEGMENTSH, (p_nSegmentsH == 0 ? DEFAULT_SEGMENTSH : p_nSegmentsH)));
		this.largeRadius = (p_nLargeRadius == 0 ? DEFAULT_LARGE_RADIUS : p_nLargeRadius);
		this.smallRadius = (p_nSmallRadius == 0 ? DEFAULT_SMALL_RADIUS : p_nSmallRadius);
		// --
		geometry = generate();
	}

	public override function clone( ?p_sName:String = "", ?p_bKeepTransform:Bool=false ):Shape3D
	{
		var o = new Torus( p_sName, largeRadius, smallRadius, segmentsW, segmentsH);
		o.copy(this, p_bKeepTransform, false);
		return o;
	}

	/**
	* Generates the geometry for the torus.
	*
	* @return The geometry object for the torus.
	*
	* @see sandy.core.scenegraph.Geometry3D
	*/
	public function generate<T>(?arguments:Array<T>) : Geometry3D
	{
		if (arguments == null) arguments = [];

		var l_oGeometry:Geometry3D = new Geometry3D();
		// --
		var r1:Float = this.largeRadius;
		var r2:Float = this.smallRadius;
		var steps1:Int = this.segmentsW;
		var steps2:Int = this.segmentsH;
		// How large are the angular steps in radians
		var step1r:Float = (2.0 * Math.PI) / steps1;
		var step2r:Float = (2.0 * Math.PI) / steps2;

		// We build the torus in slices that go from a1a to a1b
		var a1a:Float = 0;
		var a1b:Float = step1r;

		for(s in 0...steps1)
		{
			// We build a slice out of quadrilaterals that range from
			// angles a2a to a2b.
			var a2a:Float = 0;
			var a2b:Float = step2r;

			for(s2 in 0...steps2 )
			{
				var vn0:Array<Point3D> = torusVertex(a1a, r1, a2a, r2);
				var vn1:Array<Point3D> = torusVertex(a1b, r1, a2a, r2);
				var vn2:Array<Point3D> = torusVertex(a1b, r1, a2b, r2);
				var vn3:Array<Point3D> = torusVertex(a1a, r1, a2b, r2);

				// -- vertices
				var l_nP0:Int = l_oGeometry.setVertex( l_oGeometry.getNextVertexID(), vn0[0].x, vn0[0].y, vn0[0].z);
				var l_nP1:Int = l_oGeometry.setVertex( l_oGeometry.getNextVertexID(), vn1[0].x, vn1[0].y, vn1[0].z);
				var l_nP2:Int = l_oGeometry.setVertex( l_oGeometry.getNextVertexID(), vn2[0].x, vn2[0].y, vn2[0].z);
				var l_nP3:Int = l_oGeometry.setVertex( l_oGeometry.getNextVertexID(), vn3[0].x, vn3[0].y, vn3[0].z);

				// -- normals
				var l_nN0:Float = l_oGeometry.setVertexNormal( l_oGeometry.getNextVertexNormalID(), vn0[1].x, vn0[1].y, vn0[1].z);
				var l_nN1:Float = l_oGeometry.setVertexNormal( l_oGeometry.getNextVertexNormalID(), vn1[1].x, vn1[1].y, vn1[1].z);
				var l_nN2:Float = l_oGeometry.setVertexNormal( l_oGeometry.getNextVertexNormalID(), vn2[1].x, vn2[1].y, vn2[1].z);
				var l_nN3:Float = l_oGeometry.setVertexNormal( l_oGeometry.getNextVertexNormalID(), vn3[1].x, vn3[1].y, vn3[1].z);

				// -- uv
				var ux1:Float = (s		/ steps1);
				var ux0:Float = ((s+1)	/ steps1);
				var uy0:Float = (s2	/ steps2);
				var uy1:Float = ((s2+1)/ steps2);

				var l_nUV0:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), 1-ux1, uy0);
				var l_nUV1:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), 1-ux0, uy0);
				var l_nUV2:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), 1-ux0, uy1);
				var l_nUV3:Int = l_oGeometry.setUVCoords( l_oGeometry.getNextUVCoordID(), 1-ux1, uy1);

				// -- faces
				var l_nF0:Int = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), [l_nP0, l_nP2, l_nP1] );
				l_oGeometry.setFaceUVCoordsIds( l_nF0, [l_nUV0, l_nUV2, l_nUV1] );

				var l_nF1:Int = l_oGeometry.setFaceVertexIds( l_oGeometry.getNextFaceID(), [l_nP0, l_nP3, l_nP2] );
				l_oGeometry.setFaceUVCoordsIds( l_nF1, [l_nUV0, l_nUV3, l_nUV2] );

				a2a = a2b;
				a2b += step2r;
			}

			a1a = a1b;
			a1b += step1r;
		}
		// --
		return l_oGeometry;
	}

	/**
	* Compute the x,y,z coordinates and surface normal for a torus vertex.
	*
	* @param a1	The angle relative to the center of the torus
	* @param r1	Radius of the entire torus
	* @param a2	The angle relative to the center of the torus slice
	* @param r2	Radius of the torus ring cross-section
	*
	* @return Array [0]: vertex, [1]: normal
	*/
	private function torusVertex(a1:Float, r1:Float, a2:Float, r2:Float):Array<Point3D>
	{
		// Some sines and cosines we'll need.
		var ca1:Float = Math.cos(a1);
		var sa1:Float = Math.sin(a1);
		var ca2:Float = Math.cos(a2);
		var sa2:Float = Math.sin(a2);

		// What is the center of the slice we are on.
		var centerx:Float = r1 * ca1;
		var centerz:Float = -r1 * sa1;    // Note, y is zero

		var n:Point3D = new Point3D();
		// Compute the surface normal
		n.x = ca2 * ca1;          // x
		n.y = sa2;                // y
		n.z = -ca2 * sa1;         // z

		var v:Point3D = new Point3D();
		// And the vertex
		v.x = centerx + r2 * n.x;
		v.y = r2 * n.y;
		v.z = centerz + r2 * n.z;

		return [v, n];
	}

	/**
	* @private
	*/
	public override function toString():String
	{
		return "sandy.primitive.Torus";
	}
}

