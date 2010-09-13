
package sandy.math;

import sandy.core.data.Point3D;

import sandy.HaxeTypes;


/**
 * Math functions for Point3D manipulations.
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		Niel Drummond - haXe port
 * @author		Russell Weir - haXe port
 * @since		0.2
 * @version		3.1
 * @date 		26.07.2007
 *
 */
class Point3DMath
{

	/**
	 * Computes the norm of a 3D Point3D.
	 *
	 * @param p_oV 	The Point3D.
	 * @return 	The norm of the Point3D.
	 */
	public static inline function getNorm( p_oV:Point3D ):Float
	{
		return Math.sqrt( p_oV.x*p_oV.x + p_oV.y*p_oV.y + p_oV.z*p_oV.z );
	}

	/**
	 * Computes the oposite Point3D of a specified 3D Point3D.
	 *
	 * @param p_oV 	The Point3D.
	 * @return 	The opposed Point3D.
	 */
	public static function negate( p_oV:Point3D ): Point3D
	{
		return new Point3D( - p_oV.x, - p_oV.y, - p_oV.z );
	}

	/**
	 * Adds two 3D vectors.
	 *
	 * @param p_oV 	The first Point3D
	 * @param p_oW 	The second Point3D
	 * @return 	The resulting Point3D
	 */
	public static function addPoint3D( p_oV:Point3D, p_oW:Point3D ): Point3D
	{
		return new Point3D( 	p_oV.x + p_oW.x ,
                           	p_oV.y + p_oW.y ,
                           	p_oV.z + p_oW.z );
	}

	/**
	 * Substracts one 3D Point3D from another
	 *
	 * @param p_oV 	The Point3D to subtract from
	 * @param p_oW	The Point3D to subtract
	 * @return 	The resulting Point3D
	 */
	public static function sub( p_oV:Point3D, p_oW:Point3D ): Point3D
	{
		return new Point3D(	p_oV.x - p_oW.x ,
                            p_oV.y - p_oW.y ,
                            p_oV.z - p_oW.z );
	}

	/**
	 * Computes the power of a 3D Point3D.
	 *
	 * <p>Here the meaning of the power of a Point3D is a new Point3D<br />
	 * where each element is the the n:th power of the corresponding element.</p>
	 * <p>Ex: A^n = ( A.x^n, A.y^n, A.z^n ) </p>
	 *
	 * @param p_oV		The Point3D.
	 * @param p_nExp	The exponent
	 * @return 		The resulting Point3D.
	 */
	public static function pow( p_oV:Point3D, p_nExp:Float ): Point3D
	{
		return new Point3D(	Math.pow( p_oV.x, p_nExp ) ,
                            Math.pow( p_oV.y, p_nExp ) ,
                            Math.pow( p_oV.z, p_nExp ) );
	}
	/**
	 * Multiplies a 3D Point3D by specified scalar.
	 *
	 * @param p_oV 	The Point3D to multiply
	 * @param n 	The scaler to multiply
	 * @return 	The resulting Point3D
	 */
	public static function scale( p_oV:Point3D, n:Float ): Point3D
	{
		return new Point3D(	p_oV.x * n ,
                            		p_oV.y * n ,
                            		p_oV.z * n
                            	);
	}

	/**
	 * Computes the dot product the two 3D vectors.
	 *
	 * @param p_oV 	The first Point3D
	 * @param p_oW 	The second Point3D
	 * @return 	The dot procuct
	 */
	public static function dot( p_oV: Point3D, p_oW: Point3D):Float
	{
		return ( p_oV.x * p_oW.x + p_oV.y * p_oW.y + p_oW.z * p_oV.z );
	}

	/**
	 * Computes the cross product of two 3D vectors.
	 *
	 * @param p_oW	The first Point3D
	 * @param p_oV	The second Point3D
	 * @return 	The resulting cross product
	 */
	public static function cross(p_oW:Point3D, p_oV:Point3D):Point3D
	{
		// cross product Point3D that will be returned
                // calculate the components of the cross product
		return new Point3D(	(p_oW.y * p_oV.z) - (p_oW.z * p_oV.y) ,
                            		(p_oW.z * p_oV.x) - (p_oW.x * p_oV.z) ,
                            		(p_oW.x * p_oV.y) - (p_oW.y * p_oV.x)
                            	);
	}

	/**
	 * Normalizes a 3d Point3D.
	 *
	 * @param p_oV 	The Point3D to normalize
	 * @return 	true if the normalization was successful, false otherwise.
	 */
	public inline static function normalize( p_oV:Point3D ): Bool
	{
		// -- We get the norm of the Point3D
		var norm:Float = Point3DMath.getNorm( p_oV );
		// -- We escape the process is norm is null or equal to 1
		if( norm == 0 || norm == 1) {
				return false;
		} else {
				p_oV.x /= norm;
				p_oV.y /= norm;
				p_oV.z /= norm;

				return true;
		}
	}

	/**
	 * Calculates the angle between two 3D vectors.
	 *
	 * @param p_oV	The first Point3D
	 * @param p_oW	The second Point3D
	 * @return	The angle in radians between the two vectors.
	 */
	public static function getAngle ( p_oV:Point3D, p_oW:Point3D ):Float
	{
		var ncos:Float = Point3DMath.dot( p_oV, p_oW ) / ( Point3DMath.getNorm(p_oV) * Point3DMath.getNorm(p_oW) );
		var sin2:Float = 1 - ncos * ncos;
		if (sin2<0)
		{
			trace(" wrong "+ncos);
			sin2 = 0;
		}
		//I took long time to find this bug. Who can guess that (1-cos*cos) is negative ?!
		//sqrt returns a NaN for a negative value !
		return  Math.atan2( Math.sqrt(sin2), ncos );
	}

	/**
	 * Returns a random Point3D contained betweeen the first and second values
	 */
	public static function sphrand( inner:Float, outer:Float ):Point3D
	{
		//create and normalize a Point3D
		var v:Point3D = new Point3D(Math.random()-.5, Math.random()-.5,
		Math.random()-.5);
		v.normalize();

		//find a random position between the inner and outer radii
		var r:Float = Math.random();
		r = (outer - inner)*r + inner;

		//set the normalized Point3D to the new radius
		v.scale(r);

	   return v;
	}

	/**
	* Returns the distance between two Point3Ds
	*/
	public static function distance( pA : Point3D, pB : Point3D ) : Float {
		var x = pB.x - pA.x;
		var y = pB.y - pA.y;
		var z = pB.z - pA.z;
		return Math.sqrt( x * x + y * y + z * z );
	}

	/**
	* Returns the distance squared between two Point3Ds. This method avoids the
	* overhead of a Math.sqrt() call.
	*/
	public static function distanceSquared( pA : Point3D, pB : Point3D ) : Float {
		var x = pB.x - pA.x;
		var y = pB.y - pA.y;
		var z = pB.z - pA.z;
		return x * x + y * y + z * z;
	}

	/**
	 * Clones a 3D Point3D.
	 *
	 * @param p_oV 	The Point3D
	 * @return 	The clone
	 */
	public static function clone( p_oV:Point3D ): Point3D
	{
		return new Point3D( p_oV.x, p_oV.y, p_oV.z );
	}

}

