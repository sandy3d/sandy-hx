package sandy.extrusion.data;

import sandy.core.data.Point3D;
import sandy.math.FastMath;

import sandy.HaxeTypes;

/**
* Circular, spiral or helix arc.
* @author makc
* @author pedromoraes (haxe port)
* @author Niel Drummond (haxe port)
* @version		3.1
* @date 		04.03.2009
*/
class Lathe extends Curve3D {

	/**
	 * Generates circular, spiral or helix arc.
	 * @param	center Arc center.
	 * @param	axis Axis of revolution.
	 * @param	reference A Point3D that specifies direction to count angle from. Must be non-collinear to axis.
	 * @param	angle0 Start angle.
	 * @param	angle1 End angle.
	 * @param	step Angle step.
	 * @param	radius0 Start radius.
	 * @param	radius1 End radius.
	 * @param	height0 Start height.
	 * @param	height1 End height.
	 * @param	scale0 Start scale.
	 * @param	scale1 End scale.
	 */
	public function new(center:Point3D, axis:Point3D, reference:Point3D, ?angle0:Float = 0.0, ?angle1:Float = 3.14159265, ?step:Float = 0.3, ?radius0:Float = 100.0, ?radius1:Float = 100.0, ?height0:Float = 0.0, ?height1:Float = 0.0, ?scale0:Float = 1.0, ?scale1:Float = 1.0)
	{
		super ();

		// compute local coordinates
		var x:Point3D = orthogonalize (axis, reference);
			if (x.getNorm () > 0) x.normalize (); else x.x = 1;
		var y:Point3D = axis.clone ();
			if (y.getNorm () > 0) y.normalize (); else y.y = 1;
		var z:Point3D = x.cross (y);

		// compute dot bases
		var basex:Point3D = new Point3D (x.x, y.x, z.x);
		var basey:Point3D = new Point3D (x.y, y.y, z.y);
		var basez:Point3D = new Point3D (x.z, y.z, z.z);

		// generate curve
		var a:Float = angle0;
		while (((angle0 <= angle1) && (a <= angle1)) || ((angle0 > angle1) && (a >= angle1))) {
			var ca:Float = Math.cos (a), sa:Float = Math.sin (a);

			var r:Float = radius0;
			if (angle1 != angle0) r = (a - angle0) * (radius1 - radius0) / (angle1 - angle0) + radius0;

			var h:Float = height0;
			if (angle1 != angle0) h = (a - angle0) * (height1 - height0) / (angle1 - angle0) + height0;

			// point x = r cos a, z = r sin a, y = h
			var Point3D:Point3D = new Point3D (r * ca, h, r * sa);
			v.push (new Point3D (basex.dot (Point3D), basey.dot (Point3D), basez.dot (Point3D)));

			// tangent (thank to mathcad for this solution :)
			var tangent:Point3D = new Point3D ( -r * sa, 0, r * ca);
			if (angle1 != angle0) {
				tangent.x += ca * (radius1 - radius0) / (angle1 - angle0);
				tangent.y +=      (height1 - height0) / (angle1 - angle0);
				tangent.z += sa * (radius1 - radius0) / (angle1 - angle0);
			}
			if (tangent.getNorm () > 0) tangent.normalize (); else tangent.z = 1;
			t.push (new Point3D (basex.dot (tangent), basey.dot (tangent), basez.dot (tangent)));

			// normal (too lazy to solve this; but should be close to x = -cos a, z = -sin a, y = 0)
			var normal:Point3D = orthogonalize (tangent, new Point3D (-ca, 0, -sa));
			if (normal.getNorm () > 0) normal.normalize (); else normal.y = 1;
			n.push (new Point3D (basex.dot (normal), basey.dot (normal), basez.dot (normal)));

			// scale
			var scale:Float = scale0;
			if (angle1 != angle0) scale = (a - angle0) * (scale1 - scale0) / (angle1 - angle0) + scale0;
			s.push (scale);

			// next angle
			a += step;
		}
	}

}
