
package sandy.math;

import sandy.core.data.Plane;
import sandy.core.data.Point3D;

import sandy.HaxeTypes;

/**
* Math functions for planes.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir- haXe port
* @since		0.3
* @version		3.1
* @date 		26.07.2007
*/
class PlaneMath
{
	/**
	 * Specifies a negative distance from a Point3D to a plane.
	 */
	public static var NEGATIVE:Int = -1;

	/**
	 * Specifies a Point3D is on a plane.
	 */
	public static var ON_PLANE:Int = 0;

	/**
	 * Specifies a positive distance from a Point3D to a plane.
	 */
	public static var POSITIVE:Int = 1;

	/**
	 * Normalizes the plane.
	 *
	 * <p>Often before making some calculations with a plane you have to normalize it.</p>
	 *
	 * @param p_oPlane 	The plane to normalize.
	 */
	public static function normalizePlane( p_oPlane:Plane ):Void
	{
		var mag:Float;
		mag = Math.sqrt( p_oPlane.a * p_oPlane.a + p_oPlane.b * p_oPlane.b + p_oPlane.c * p_oPlane.c );
		p_oPlane.a = p_oPlane.a / mag;
		p_oPlane.b = p_oPlane.b / mag;
		p_oPlane.c = p_oPlane.c / mag;
		p_oPlane.d = p_oPlane.d / mag;
	}

	/**
	 * Computes the distance between a plane and a 3D point (a vector here).
	 *
	 * @param p_oPlane The plane we want to compute the distance from
	 * @param pt 	The point in space
	 * @return 	The distance between the point and the plane.
	 */
	public static function distanceToPoint( p_oPlane:Plane, p_oPoint:Point3D ):Float
	{
		return p_oPlane.a * p_oPoint.x + p_oPlane.b * p_oPoint.y + p_oPlane.c * p_oPoint.z + p_oPlane.d ;
	}

	/**
	 * Returns a classification constant depending on a points position relative to a plane.
	 *
	 * <p>The classification is one of PlaneMath.NEGATIVE PlaneMath.POSITIVE PlaneMath.ON_PLANE</p>
	 *
	 * @param p_oPlane 	The reference plane
	 * @param p_oPoint 		The point we want to classify
	 * @return 		The classification of the point
	 */
	public static function classifyPoint( p_oPlane:Plane, p_oPoint3D:Point3D ):Int
	{
		var d:Float;
		d = PlaneMath.distanceToPoint( p_oPlane, p_oPoint3D );
		if (d < 0) return PlaneMath.NEGATIVE;
		if (d > 0) return PlaneMath.POSITIVE;
		return PlaneMath.ON_PLANE;
	}

	/**
	 * Computes a plane from three specified points.
	 *
	 * @param p_oPointA	The first point
	 * @param p_oPointB	The second point
	 * @param p_oPointC	The third point
	 * @return 	The Plane object
	 */
	public static function computePlaneFromPoints( p_oPointA:Point3D, p_oPointB:Point3D, p_oPointC:Point3D ):Plane
	{
		var n:Point3D = Point3DMath.cross( Point3DMath.sub( p_oPointA, p_oPointB), Point3DMath.sub( p_oPointA, p_oPointC) );
		Point3DMath.normalize( n );
		var d:Float = Point3DMath.dot( p_oPointA, n);
		// --
		return new Plane( n.x, n.y, n.z, d);
	}
	/**
	 * Computes a plane from a normal vector and a specified point.
	 *
	 * @param p_oNormal	The normal vector
	 * @param p_oPoint	The point.
	 * @return 		The Plane object
	 */
	public static function createFromNormalAndPoint( p_oNormal:Point3D, p_oPoint:Point3D ):Plane
	{
		var p:Plane = new Plane();
		Point3DMath.normalize(p_oNormal);
		p.a = p_oNormal.x;
		p.b = p_oNormal.y;
		p.c = p_oNormal.z;
		p.d = p_oNormal.dot (p_oPoint) * -1;
		PlaneMath.normalizePlane( p );
		return p;
	}

}

