
package sandy.math;

import flash.geom.Point;

import sandy.bounds.BSphere;
import sandy.core.Scene3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Polygon;
import sandy.core.data.Point3D;
import sandy.core.data.Vertex;
import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* An util class with static method which provides useful
* functions related to intersection
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		18.10.2007
*/
class IntersectionMath
{
	/**
	* Determines whether two bounding spheres intersect.
	*
	* @param p_oBSphereA	The first bounding sphere.
	* @param p_oBSphereB	The second bounding sphere.
	*
	* @return Whether the two spheres intersect.
	*/
	public static function intersectionBSphere( p_oBSphereA:BSphere, p_oBSphereB:BSphere ):Bool
	{
		var l_oVec:Point3D = p_oBSphereA.position.clone();
		l_oVec.sub( p_oBSphereB.position );
		var l_nDist:Float = p_oBSphereA.radius + p_oBSphereB.radius;
		// --
		var l_nNorm:Float = l_oVec.getNorm();
			return (l_nNorm <= l_nDist);
	}


	/**
	 * Computes the smallest distance between two 3D lines.
	 * <p>As 3D lines cannot intersect, we compute two points, first owning to the first 3D line, and the second point owning to the second 3D line.</p>
	 * <p>The two points define a segment which length represents the shortest distance between these two lines.</p>
	 *
	 * @param p_oPointA	A Point3D of the first 3D line.
	 * @param p_oPointB	Another Point3D of the first 3D line.
	 * @param p_oPointC	A Point3D of the second 3D line.
	 * @param p_oPointD	Another Point3D of the second 3D line.
	 *
	 * @return An array containing the Point3Ds of the segment connecting the two 3D lines.
	 */
	public static function intersectionLine3D( p_oPointA:Point3D, p_oPointB:Point3D, p_oPointC:Point3D, p_oPointD:Point3D ):Array<Point3D>
	{
		var res:Array<Point3D> = [
			new Point3D (0.5 * (p_oPointA.x + p_oPointB.x), 0.5 * (p_oPointA.y + p_oPointB.y), 0.5 * (p_oPointA.z + p_oPointB.z)),
			new Point3D (0.5 * (p_oPointC.x + p_oPointD.x), 0.5 * (p_oPointC.y + p_oPointD.y), 0.5 * ( p_oPointC.z + p_oPointD.z))
		];

		var p13_x:Float = p_oPointA.x - p_oPointC.x;
		var p13_y:Float = p_oPointA.y - p_oPointC.y;
		var p13_z:Float = p_oPointA.z - p_oPointC.z;

		var p43_x:Float = p_oPointD.x - p_oPointC.x;
		var p43_y:Float = p_oPointD.y - p_oPointC.y;
		var p43_z:Float = p_oPointD.z - p_oPointC.z;

		if (NumberUtil.isZero (p43_x) && NumberUtil.isZero (p43_y) && NumberUtil.isZero (p43_z))
			return res;

		var p21_x:Float = p_oPointB.x - p_oPointA.x;
		var p21_y:Float = p_oPointB.y - p_oPointA.y;
		var p21_z:Float = p_oPointB.z - p_oPointA.z;

		if (NumberUtil.isZero (p21_x) && NumberUtil.isZero (p21_y) && NumberUtil.isZero (p21_z))
			return res;

		var d1343:Float = p13_x * p43_x + p13_y * p43_y + p13_z * p43_z;
		var d4321:Float = p43_x * p21_x + p43_y * p21_y + p43_z * p21_z;
		var d1321:Float = p13_x * p21_x + p13_y * p21_y + p13_z * p21_z;
		var d4343:Float = p43_x * p43_x + p43_y * p43_y + p43_z * p43_z;
		var d2121:Float = p21_x * p21_x + p21_y * p21_y + p21_z * p21_z;

		var denom:Float = d2121 * d4343 - d4321 * d4321;

		if (NumberUtil.isZero (denom))
			return res;

		var mua:Float = (d1343 * d4321 - d1321 * d4343) / denom;
		var mub:Float = (d1343 + d4321 * mua) / d4343;

		return [
			new Point3D (p_oPointA.x + mua * p21_x, p_oPointA.y + mua * p21_y, p_oPointA.z + mua * p21_z),
			new Point3D (p_oPointC.x + mub * p43_x, p_oPointC.y + mub * p43_y, p_oPointC.z + mub * p43_z)
		];
	}

	/**
	* Computation of the intersection point between 2 2D lines AB and CD.
	* This function returns the intersection point.
	* Returns null in case the two lines are coincident or parallel
	*
	* Original implementation : http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
	*/
	public static function intersectionLine2D( p_oPointA:Point, p_oPointB:Point, p_oPointC:Point, p_oPointD:Point ):Point
	{
		var	xA:Float = p_oPointA.x;
		var yA:Float = p_oPointA.y;
		var xB:Float = p_oPointB.x;
		var yB:Float = p_oPointB.y;
		var xC:Float = p_oPointC.x;
		var yC:Float = p_oPointC.y;
		var xD:Float = p_oPointD.x;
		var yD:Float = p_oPointD.y;

		var denom:Float = ( ( yD - yC )*( xB - xA ) - ( xD - xC )*( yB - yA ) );
		// -- if lines are parallel
		if( denom == 0 ) return null;

		var uA:Float =  ( ( xD - xC )*( yA - yC ) - ( yD - yC )*( xA - xC ) );
		uA /= denom;

		// we shall compute uB and test uA == uB == 0 to test coincidence
		/*
		uB =  ( ( xB - xA )*( yA - yC ) - ( yB - yA )*( xA - xC ) );
		uB /= denom;
		*/
		return new Point( xA + uA * ( xB - xA ), yA + uA*( yB - yA ) );
	}

	/*
		** From http://www.blackpawn.com/texts/pointinpoly/default.html
		** Points right on the perimeter are NOT treated as in.
		** AS3 implementation : tcorbet
		*/
	public static function isPointInTriangle2D ( p_oPoint:Point, p_oA:Point, p_oB:Point, p_oC:Point ):Bool
	{
		var oneOverDenom:Float = (1 /
			(((p_oA.y - p_oC.y) * (p_oB.x - p_oC.x)) +
			((p_oB.y - p_oC.y) * (p_oC.x - p_oA.x))));
		var b1:Float = (oneOverDenom *
			(((p_oPoint.y - p_oC.y) * (p_oB.x - p_oC.x)) +
			((p_oB.y - p_oC.y) * (p_oC.x - p_oPoint.x))));
		var b2:Float = (oneOverDenom *
			(((p_oPoint.y - p_oA.y) * (p_oC.x - p_oA.x)) +
			((p_oC.y - p_oA.y) * (p_oA.x - p_oPoint.x))));
		var b3:Float = (oneOverDenom *
			(((p_oPoint.y - p_oB.y) * (p_oA.x - p_oB.x)) +
			((p_oA.y - p_oB.y) * (p_oB.x - p_oPoint.x))));

		return ((b1 > 0) && (b2 > 0) && (b3 > 0));
	}
}

