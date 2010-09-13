
package sandy.extrusion;

import flash.geom.Point;
import flash.geom.Rectangle;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.PrimitiveFace;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.extrusion.data.Polygon2D;

import sandy.HaxeTypes;

/**
 * Very basic extrusion class.
 * @author makc
 * @author pedromoraes (haxe port)
 * @author Niel Drummond (haxe port)
 * @version		3.1
 * @date 		04.03.2009
 */
class Extrusion extends Shape3D {

	/**
	 * Extrudes 2D polygon.
	 * @param	name Shape name.
	 * @param	profile Polygon to extrude.
	 * @param	sections Array of transformation matrices.
	 * @param	closeFront Flag to close extrusion front end.
	 * @param	closeBack Flag to close extrusion back end.
	 * @see Matrix4
	 * @see Polygon2D
	 */
	public function new (name:String, profile:Polygon2D, ?sections:Array < Matrix4 > = null, ?closeFront:Bool = true, ?closeBack:Bool = true) {
		super();

		var a:Float = profile.area();
		var i:Int;
		var j:Int;
		var k:Int;
		var g:Geometry3D = new Geometry3D();
		var v:Point3D = new Point3D();

		// arrays to store face IDs
		var backFaceIDs:Array<Int> = [];
		var frontFaceIDs:Array<Int> = [], sideFaceIDs:Array<Int> = [];

		// find links
		// 2nd vertex in link edge goes to array
		var links:Array<Point> = [], n:Int = profile.vertices.length;
		for ( i in 1 ... n + 1 )
		for ( j in 1 ... n + 1 ) {
			if ((Point.distance (profile.vertices [i % n], profile.vertices [j - 1]) == 0) &&
				(Point.distance (profile.vertices [j % n], profile.vertices [i - 1]) == 0)) links.push (profile.vertices [i]);
		}

		// if no matrices are passed, use Identity
		if (sections == null) sections = [];
		var l_sections:Array<Matrix4> = sections.slice( 0 );
		if (l_sections.length < 1) l_sections.push (new Matrix4());

		// construct profile vertices and side surface, if any
		for ( i in 0 ... l_sections.length ) {
			var m:Matrix4 = l_sections [i];

			for ( j in 0 ... n + 1 ) {
				if (j < n) {
					v.x = profile.vertices [j].x;
					v.y = profile.vertices [j].y;
					v.z = 0;
					m.transform(v);
					g.setVertex (j + i * n, v.x, v.y, v.z);
				}
				g.setUVCoords (j + i * (n + 1), j / n, i / (l_sections.length - 1));
			}

			if (i > 0) {
				for ( j in 1 ... n + 1 ) {
					if ( !Lambda.exists( links, function (value) { return value == profile.vertices[j % n]; } ) )
					{
						k = g.getNextFaceID ();
						var i1:Int = j % n + i * n;
						var i2:Int = (a > 0) ? (j + (i - 1) * n - 1) : (j + i * n - 1);
						var i3:Int = (a > 0) ? (j + i * n - 1) : (j + (i - 1) * n - 1);
						var i4:Int = (a > 0) ? (j % n + (i - 1) * n) : (j + (i - 1) * n - 1);
						var i5:Int = (a > 0) ? (j + (i - 1) * n - 1) : (j % n + (i - 1) * n);
						g.setFaceVertexIds (k, [ i1, i2, i3 ] );
						g.setFaceVertexIds (k + 1, [ i1, i4, i5 ] );
						i1 = j + i * (n + 1);
						i2 = (a > 0) ? (j + (i - 1) * (n + 1) - 1) : (j + i * (n + 1) - 1);
						i3 = (a > 0) ? (j + i * (n + 1) - 1) : (j + (i - 1) * (n + 1) - 1);
						i4 = (a > 0) ? (j + (i - 1) * (n + 1)) : (j + (i - 1) * (n + 1) - 1);
						i5 = (a > 0) ? (j + (i - 1) * (n + 1) - 1) : (j + (i - 1) * (n + 1));
						g.setFaceUVCoordsIds (k, [ i1, i2, i3 ] );
						g.setFaceUVCoordsIds (k + 1, [ i1, i4, i5 ] );
						sideFaceIDs.push (k + 1);
					}
				}
			}
		}

		links = null;

		if (closeFront || closeBack) {
			// profiles need separate UV mapping
			var p:Int = g.getNextUVCoordID ();
			var b:Rectangle = profile.bbox ();
			for ( i in 0 ... profile.vertices.length )
				g.setUVCoords (p + i, (profile.vertices [i].x - b.x) / b.width, (profile.vertices [i].y - b.y) / b.height);

			// triangulate profile
			var triangles:Array<Polygon2D> = profile.triangles ();

			var q:Int = g.getNextVertexID () - profile.vertices.length;
			for ( tri in triangles ) {
				var v1:Int = 0;
				Lambda.mapi( profile.vertices, function (index, value) { v1 = ( value == tri.vertices[0] ) ? index : v1; return null;} );
				var v2:Int = 0;
				Lambda.mapi( profile.vertices, function (index, value) { v2 = ( value == tri.vertices[(a > 0) ? 1 : 2] ) ? index : v2; return null; } );
				var v3:Int = 0;
				Lambda.mapi( profile.vertices, function (index, value) { v3 = ( value == tri.vertices[(a > 0) ? 2 : 1] ) ? index : v3; return null; } );
				if (closeFront) {
					// add front surface
					k = g.getNextFaceID ();
					g.setFaceVertexIds (k, [v1, v2, v3] );
					g.setFaceUVCoordsIds (k, [p + v1, p + v2, p + v3] );
					frontFaceIDs.push (k);
				}

				if (closeBack) {
					// add back surface
					k = g.getNextFaceID ();
					g.setFaceVertexIds (k, [ q + v1, q + v3, q + v2 ] );
					g.setFaceUVCoordsIds (k, [ p + v1, p + v3, p + v2 ] );
					backFaceIDs.push (k);
				}
			}
		}

		geometry = g;
		// generate faces
		backFace = new PrimitiveFace (this);
		while (backFaceIDs.length > 0) backFace.addPolygon (backFaceIDs.pop ());

		frontFace = new PrimitiveFace (this);
		while (frontFaceIDs.length > 0) frontFace.addPolygon (frontFaceIDs.pop ());

		sideFace = new PrimitiveFace (this);
		while (sideFaceIDs.length > 0) sideFace.addPolygon (sideFaceIDs.pop ());

	}

	/**
	 * Collection of polygons on the back surface of extruded shape.
	 * Texture is mapped to fit profile bounding box on this face.
	 */
	var backFace(default, null):PrimitiveFace;

	/**
	 * Collection of polygons on the front surface of extruded shape.
	 * Texture is mapped to fit profile bounding box on this face.
	 */
	var frontFace(default, null):PrimitiveFace;

	/**
	 * Collection of polygons on the side surface of extruded shape.
	 * Texture U coordinate is mapped from 0 to 1 along the profile, and
	 * V coordinate is mapped from 0 at the front edge to 1 at the back edge.
	 */
	var sideFace(default, null):PrimitiveFace;
}
