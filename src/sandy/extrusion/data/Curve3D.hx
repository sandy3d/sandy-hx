package sandy.extrusion.data;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;

import sandy.HaxeTypes;

/**
* Specifies a curve in 3D space.
* @author makc
* @author pedromoraes (haxe port)
* @author Niel Drummond (haxe port)
* @version		3.1
* @date 		04.03.2009
*/
class Curve3D
{
	/**
	 * Array of points that curve passes through.
	 */
	public var v:Array<Point3D>;

	/**
	 * Array of tangent unit Point3Ds at curve points.
	 */
	public var t:Array<Point3D>;

	/**
	 * Array of normal unit Point3Ds at curve points.
	 */
	public var n:Array<Point3D>;

	/**
	 * Array of binormal unit Point3Ds at curve points. Set to null in order to re-calculate it from t and n.
	 * @see http://en.wikipedia.org/wiki/Frenet-Serret_frame
	 */
	public var b(getB,setB):Array<Point3D>;
	private function getB():Array<Point3D> {
		if (_b == null) b = null; return _b;
	}

	private function setB(arg:Array<Point3D>):Array<Point3D> {
		if (arg != null) {
			_b = arg;
		} else if ((t != null) && (n != null)) {
			_b = []; var i:Int;var N:Int = Std.int( Math.min (t.length, n.length) );
			for ( i in 0 ... N ) {
				_b [i] = t[i].cross (n[i]);
			}
		}
		return arg;
	}

	private var _b:Array<Point3D>;

	/**
	 * Array of scalar values at curve points. toSections method uses
	 * these values to scale crossections.
	 */
	public var s:Array<Float>;

	/**
	 * Computes matrices to use this curve as extrusion path.
	 * @param stabilize whether to flip normals after inflection points.
	 * @return array of Matrix4 objects.
	 * @see Extrusion
	 */
	public function toSections (?stabilize:Bool = true):Array<Matrix4> {
		if ((t == null) || (n == null)) return null;

		var sections:Array<Matrix4> = [];
		var i:Int;
		var N:Int = Std.int( Math.min(t.length, n.length) );
		var m1:Matrix4;
		var m2:Matrix4 = new Matrix4();
		var normal:Point3D = new Point3D();
		var binormal:Point3D = new Point3D();
		for ( i in 0 ... N ) {
			normal.copy (n [i]); binormal.copy (b [i]);
			if (stabilize && (i > 0)) {
				if ( n[i - 1].dot (normal) * t[i - 1].dot (t [i]) < 0 ) {
					normal.scale ( -1); binormal.scale ( -1);
				}
			}
			m1 = new Matrix4(); 
			m1.fromPoint3Ds(normal, binormal, t[i], v[i]);
			m2.scale (s [i], s [i], s [i]); 
			m1.multiply (m2);
			sections [i] = m1;
		}
		return sections;
	}

	/**
	 * Return Point3D perpendicular to Point3D and as close to hint as possible.
	 * @param	Point3D
	 * @param	hint
	 * @return
	 */
	private function orthogonalize (p_oPoint:Point3D, hint:Point3D):Point3D {
		var w:Point3D = p_oPoint.cross (hint);
		w.crossWith (p_oPoint);
		return w;
	}

	/**
	 * Creates empty Curve3D object.
	 */
	public function new () {
		v = [];
		t = [];
		n = [];
		s = [];
	}

}
