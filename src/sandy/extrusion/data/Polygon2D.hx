package sandy.extrusion.data;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import sandy.HaxeTypes;
import sandy.util.ArrayUtil;

/**
 * 2D polygon class.
 *
 * @author makc
 * @author pedromoraes (haxe port)
 * @author Niel Drummond (haxe port)
 * @version		3.1
 * @date 		04.03.2009
 */
class Polygon2D
{
	/**
	 * Ordered array of Point objects.
	 */
	public var vertices:Array<Point>;

	/**
	 * Creates Polygon2D instance.
	 * @param points array to copy to vertices property.
	 * @see #vertices
	 */
	public function new (?points:Array<Point>)
	{
		// points need to be copied here
		// to set reference use vertices
		if (points != null) this.vertices = points.slice ( 0 );
	}

	/**
	 * Calculates Polygon2D oriented area.
	 * @see http://local.wasp.uwa.edu.au/~pbourke/geometry/clockwise/
	 */
	public function area ():Float
	{
		var a:Float = 0, n:Int = vertices.length;
		var i : Int;
		for ( i in 0 ... n )
		{
			a += vertices[i].x * vertices [(i + 1) % n].y -
				vertices[(i + 1) % n].x * vertices[i].y;
		}
		return 0.5 * a;
	}

	/**
	 * Returns array of edges.
	 * @param reorient If true, vertices in edges are ordered.
	 * @return Array of vertice pairs.
	 */
	public function edges (reorient:Bool = false):Array < Array < Point > >
	{
		var n:Int = vertices.length;
		var r:Array<Array<Point>> = [];
		var i : Int;
		for ( i in 0 ... n )
		{
			r[i] = [];
			r[i][0] = vertices[i].clone ();
			r[i][1] = vertices[(i + 1) % n].clone ();
			if (reorient &&
				((r[i][0].y > r[i][1].y) ||
					((r[i][0].y == r[i][1].y) && (r[i][0].x > r[i][1].x))))
						r[i].reverse ();
		}
		return r;
	}

	/**
	 * Tests if point is inside or not.
	 * At first, I thought this will be needed for tesselation, so here you have it :)
	 * @param point Point to test.
	 * @param includeVertices if false, vertices are not considered to be inside.
	 * @return True if point is inside.
	 */
	public function hitTest (point:Point, ?includeVertices:Bool = true):Bool
	{
		// first, loop through all vertices
		var i:Int;
		var n:Int = vertices.length;
		for ( i in 0 ... n )
		{
			if (Point.distance(vertices[i], point) == 0)
			{
				return includeVertices;
			}
		}

		// due to some topology theorem, if the ray intersects shape
		// perimeter odd number of times, the point is inside

		// shorter and faster code thanks to Alluvian
		// http://board.flashkit.com/board/showpost.php?p=4037392&postcount=5

		var V:Array<Point> = vertices.slice ( 0 ); V.push (V [0]);
		var crossing:Int = 0; n = V.length - 1;

		for ( i in 0 ... n )
		{
			if ( ((V[i].y <= point.y) && (V[i+1].y > point.y)) || ((V[i].y > point.y) && (V[i+1].y <= point.y)) ) {
				var vt:Float = (point.y - V[i].y) / (V[i+1].y - V[i].y);
				if (point.x < V[i].x + vt * (V[i+1].x - V[i].x)) {
					crossing++;
				}
			}
		}

		return (crossing % 2 != 0);
	}

	/**
	 * Checks for edge intersection.
	 * @return True if edges intersect in X pattern.
	 * @see http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
	 */
	private function edge2edge (edge1:Array<Point>, edge2:Array<Point>):Bool
	{
		var x1:Float = edge1[0].x, y1:Float = edge1[0].y,
			x2:Float = edge1[1].x, y2:Float = edge1[1].y,
			x3:Float = edge2[0].x, y3:Float = edge2[0].y,
			x4:Float = edge2[1].x, y4:Float = edge2[1].y;

		// work around bug caused by floating point imprecision
		if (((x1 == x3) && (y1 == y3)) || ((x2 == x4) && (y2 == y4)) ||
			((x1 == x4) && (y1 == y4)) || ((x2 == x3) && (y2 == y3))) return false;

		var a:Float = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
		var b:Float = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
		var d:Float = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);

		return (d != 0) && (0 < a/d) && (a/d < 1) && (0 < b/d) && (b/d < 1);
	}

	/**
	 * Removes links that no longer link to anything.
	 */
	private function removeOrphanLinks () : Void
	{
		var ok:Bool, i:Int, n:Int;
		do
		{
			ok = true;
			n = vertices.length;
			for ( i in 0 ... n )
			{
				if (Point.distance (vertices[(i + n - 1) % n], vertices[(i + 1) % n]) == 0)
				{
					vertices.splice (((i + 1) % n == 0) ? 0 : i, 2); ok = false; break;
				}
			}
		}
		while (!ok);
	}

	/**
	 * Simple polygon tesselator.
	 * <p>This handles both concave and convex non-selfintersecting polygons.</p>
	 * @return Array of Polygon2D objects.
	 */
	public function triangles ():Array<Polygon2D>
	{
		var mesh:Array<Polygon2D> = [];
		var edges1:Array<Array<Point>>;
		var edges2:Array<Array<Point>> = edges();
		var rest:Polygon2D = new Polygon2D (vertices);
		var o:Float = area ();
		var i:Int = 0;
		var j:Int;
		var k:Int;
		var n:Int;
		var m:Int;
		var ok:Bool;

		while (rest.vertices.length > 2)
		{
			n = rest.vertices.length;
			var tri:Polygon2D = new Polygon2D (
				[rest.vertices [(i + n - 1) % n], rest.vertices [i], rest.vertices [(i + 1) % n]]
			);

			// a triangle goes into mesh, if:
			// 1) it has same orientation with the polygon
			// 2) none of other vertices fall inside of triangle
			// 3) it has no open intersections with polygon edges
			ok = false;
			if (tri.area () * o > 0)
			{
				edges1 = tri.edges ();

				ok = true;
				m = vertices.length;
				for ( k in 0 ... m )
				if (tri.hitTest (vertices[k], false))
				{
					ok = false; break;
				}

				if (ok)
				{
					for ( j in 0 ... 3 )
					for ( k in 0 ... m )
					if (edge2edge (edges1[j], edges2[k]))
					{
						ok = false; break;
					}
				}
			}

			// ok, so...
			if (ok)
			{
				mesh.push (tri);
				rest.vertices.splice (i, 1);
				// if we have orphan link left, remove it
				rest.removeOrphanLinks ();
				// start all over
				i = 0;
			}
			else
			{
				i++;
				if (i > n - 1)
					// whatever is left, cannot be handled
					// either because this tesselator sucks, or because vertices list is malformed
					return mesh;
			}
		}
		return mesh;
	}

	/**
	 * Bounding box.
	 */
	public function bbox ():Rectangle
	{
		var xmin:Float = 1e99, xmax:Float = -1e99, ymin:Float = xmin, ymax:Float = xmax;
		var p:Point;
		for ( p in vertices )
		{
			if (p.x < xmin) xmin = p.x;
			if (p.x > xmax) xmax = p.x;
			if (p.y < ymin) ymin = p.y;
			if (p.y > ymax) ymax = p.y;
		}
		return new Rectangle (xmin, ymin, xmax - xmin, ymax - ymin);
	}

		/**
		 * Convex hull.
		 */
		public function convexHull ():Polygon2D
		{
			// code derived from http://notejot.com/2008/11/convex-hull-in-2d-andrews-algorithm/
			var pointsHolder:Array<Point> = new Array<Point> ();
			// need to filter out duplicates 1st
			var i:Int, j:Int, n:Int = vertices.length;
			for ( i in 0 ... n )
			{
				var d:Float = 1;
				j = 0; while((d > 0) && (j < pointsHolder.length)) 
				{
					d *= Point.distance(vertices[i], pointsHolder[j]); j++;
				}
				if (d > 0) 
				{
					pointsHolder.push(vertices[i]);
				}
			}
			
			var topHull:Array<Int> = [];
			var bottomHull:Array<Int> = [];

			// triangles are always convex
			if (pointsHolder.length < 4)
				return new Polygon2D (pointsHolder);

			// lexicographic sort
			ArrayUtil.sortOnLite(pointsHolder,["x", "y"], Array.NUMERIC);

			// compute top part of hull
			topHull.push (0);
			topHull.push (1);

			for (i in 2 ... pointsHolder.length) {
				if(towardsLeft(pointsHolder[topHull[topHull.length - 2]],
				pointsHolder[topHull[topHull.length - 1]], pointsHolder[i])) {
					topHull.pop ();

					while (topHull.length >= 2) {
						if(towardsLeft(pointsHolder[topHull[topHull.length - 2]],
						pointsHolder[topHull[topHull.length - 1]], pointsHolder[i])) {
							topHull.pop ();
						} else {
							topHull.push (i);
							break;
						}
					}
					if (topHull.length == 1)
						topHull.push (i);
				} else {
					topHull.push (i);
				}
			}

			// compute bottom part of hull
			bottomHull.push (0);
			bottomHull.push (1);

			for (i in 2 ... pointsHolder.length) {

				if (!towardsLeft(pointsHolder[bottomHull[bottomHull.length - 2]],
				pointsHolder[bottomHull[bottomHull.length - 1]], pointsHolder[i])) {
					bottomHull.pop ();

					while (bottomHull.length >= 2) {
						if (!towardsLeft(pointsHolder[bottomHull[bottomHull.length - 2]],
						pointsHolder[bottomHull[bottomHull.length - 1]], pointsHolder[i])) {
							bottomHull.pop ();
						} else {
							bottomHull.push (i);
							break;
						}
					}
					if (bottomHull.length == 1)
						bottomHull.push (i);
				} else {
					bottomHull.push (i);
				}
			}

			bottomHull.reverse ();
			bottomHull.shift ();

			// convert to Polygon2D format
			var ix:Array <Int> = topHull.concat (bottomHull);
			var vs:Array <Point> = [];
			for (i in 0 ... ix.length -1)
				vs.push (pointsHolder [ix [i]]);

			return new Polygon2D (vs);
		}

		/**
		 * Used by convexHull() code.
		 */
		private function towardsLeft (origin:Point, p1:Point, p2:Point):Bool {
			// funny thing is that convexHull() works regardless if either < or > is used here
			return (new Polygon2D ([origin, p1, p2]).area () < 0);
		}
}
