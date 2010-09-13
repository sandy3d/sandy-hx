package sandy.core.data;

import sandy.math.PlaneMath;
import sandy.util.ArrayUtil;

typedef PObj = {
	area : Float,
	faces : Array<Polygon>,
	plane: Plane
}

/**
 * BSP tree node.
 * @author makc
 */
class BSPNode {
	public var faces:Array<Polygon>;
	public var plane:Plane;
	public var positive:BSPNode;
	public var negative:BSPNode;

	public function new () {}

	/**
	 * Creates BSP tree from list of faces without cutting them (hence "lazy").
	 * Faces are ordered by coplanar area.
	 */
	public static function makeLazyBSP (faces:Array<Polygon>, threshold:Float):BSPNode {
		var planes:Array<PObj> = lazyBSPFaces2Planes (faces, threshold);
		var pobj:PObj = planes.pop ();
		var node:BSPNode = new BSPNode();
		node.faces = pobj.faces;
		node.plane = pobj.plane;
		// if there are more planes, split their polygons into positive and negative sets
		if (planes.length > 0) {
			var pos:Array<Polygon> = [];
			var neg:Array<Polygon> = [];
			for (pobj in planes) {
				var polys:Array<Polygon> = pobj.faces;
				for (poly in polys) {
					var dist:Float = 0;
					for (v in poly.vertices) {
						dist += node.plane.a * v.x + node.plane.b * v.y + node.plane.c * v.z + node.plane.d;
					}
					if (dist > 0) pos.push (poly); else neg.push (poly);
				}
			}
			if (pos.length > 0) node.positive = makeLazyBSP (pos, threshold);
			if (neg.length > 0) node.negative = makeLazyBSP (neg, threshold);
		}
		trace( node );
		return node;
	}

	private static function lazyBSPFaces2Planes (faces:Array<Polygon>, threshold:Float):Array<PObj> {
		var fba:Array<Polygon> = faces.slice (0);
		
		ArrayUtil.sortOnLite(fba,["area"],ArrayUtil.SORT_DESCENDING|ArrayUtil.SORT_NUMERIC);
		
		// create array of info about planes
		var planes:Array<PObj> = [];
		for (poly in fba) {
			// calculate center of polygon
			var center:Point3D = poly.a.getPoint3D ();
			center.x += poly.b.x; center.y += poly.b.y; center.z += poly.b.z;
			center.x += poly.c.x; center.y += poly.c.y; center.z += poly.c.z;
			if (poly.d != null) {
				center.x += poly.d.x; center.y += poly.d.y; center.z += poly.d.z;
				center.scale (0.25);
			} else {
				center.scale (1/3);
			}

			var pobj:PObj;
			var found:Bool = false;
			for (i in 0...planes.length) {
				pobj = planes [i];
				var p:Plane = pobj.plane;
				// if poly is in p, store it in face list
				if ((Math.abs (p.a * center.x + p.b * center.y + p.c * center.z + p.d) < threshold) &&
						(Math.abs (p.a * poly.normal.x + p.b * poly.normal.y + p.c * poly.normal.z) > 1 - threshold)) {
					pobj.area += poly.area; pobj.faces.push (poly); found = true; break;
				}
			}
			if (!found) {
				// new plane
				pobj = {
					area: poly.area,
					faces: [ poly ],
					plane: PlaneMath.createFromNormalAndPoint (poly.normal.getPoint3D (), center)
				};
				planes.push (pobj);
			}
		}
		
		ArrayUtil.sortOnLite(planes,["area"],ArrayUtil.SORT_NUMERIC);
		
		return planes;
	}
}

