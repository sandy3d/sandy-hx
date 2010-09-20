
package sandy.core.data;

import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* A 3D coordinate.
*
* <p>A representation of a position in a 3D space.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Mirek Mencel
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @author		Bruce Epstein - zeusprod - truncated toString output to 2 decimals
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		0.1
* @version		3.1
* @date 		24.08.2007
*/
class Point3D
{
	/** Returns a new unit point in the X direction */
	public static var UNIT_X(makeUnitX,null) : Point3D;
	/** Returns a new unit point in the Y direction */
	public static var UNIT_Y(makeUnitY,null) : Point3D;
	/** Returns a new unit point in the Z direction */
	public static var UNIT_Z(makeUnitZ,null) : Point3D;

	/**
	* The x coordinate.
	*/
	public var x:Float;
	/**
	* The y coordinate.
	*/
	public var y:Float;
	/**
	* The z coordinate.
	*/
	public var z:Float;

	/**
	* Creates a new vector instance.
	*
	* @param	p_nX	the x coordinate
	* @param	p_nY	the y coordinate
	* @param	p_nZ	the z coordinate
	*/
	public function new(?p_nX:Float = 0.0, ?p_nY:Float = 0.0, ?p_nZ:Float = 0.0)
	{
		x = p_nX;
		y = p_nY;
		z = p_nZ;
	}

	/**
	 * Reset the vector components to 0
	 * after calling this method, x, y and z will be set to 0
	 */
	public function reset( ?px:Float=0.0, ?py:Float=0.0, ?pz:Float=0.0):Void
	{
		x = px; y = py; z = pz;
	}

	/**
	 * Reset the vector components to the minimal value Flash can handle
	 * after calling this method, x, y and z will be set to Float.NEGATIVE_INFINITY;
	 */
	public function resetToNegativeInfinity():Void
	{
		x = y = z = Math.NEGATIVE_INFINITY;
	}

	/**
	 * Reset the vector components to the maximal value Flash can handle
	 * after calling this method, x, y and z will be set to Float.POSITIVE_INFINITY;
	 */
	public function resetToPositiveInfinity():Void
	{
		x = y = z = Math.POSITIVE_INFINITY;
	}

	/**
	 * Returns a clone of thei vector.
	 *
	 * @return 	The clone
	 */
	public function clone():Point3D
	{
	    var l_oV:Point3D = new Point3D( x, y, z );
	    return l_oV;
	}

	/**
	 * Makes this vector a copy of the specified vector.
	 *
	 * <p>All elements of this vector is set to those of the argument vector</p>
	 *
	 * @param p_oPoint3D	The vector to copy
	 */
	public function copy( p_oPoint3D:Point3D ):Void
	{
		x = p_oPoint3D.x;
		y = p_oPoint3D.y;
		z = p_oPoint3D.z;
	}

	/**
	 * Computes and returns the norm of this vector.
	 *
	 * <p>The norm of the vector is sqrt( x*x + y*y + z*z )</p>
	 *
	 * @return 	The norm
	 */
	public function getNorm():Float
	{
		return Math.sqrt( x*x + y*y + z*z );
	}

	/**
	 * Compute and returns the invers of this vector.
	 *
	 * @return 	The inverse
	 */
	public function negate( /*v:Point3D*/ ): Point3D
	{
		// Commented out the argument as it is never used - Petit
		return new Point3D( - x, - y, - z );
	}

	/**
	 * Adds a specified vector to this vector.
	 *
	 * @param v 	The vector to add
	 */
	public function add( v:Point3D ):Void
	{
		x += v.x;
		y += v.y;
		z += v.z;
	}

	/**
	 * Substracts the specified vector from this vector.
	 *
	 * @param {@code v} a {@code Point3D}.
	 * @param {@code w} a {@code Point3D}.
	 * @return The resulting {@code Point3D}.
	 */
	public function sub( v:Point3D ):Void
	{
		x -= v.x;
		y -= v.y;
		z -= v.z;
	}

	/**
	 * Raises this vector to the specified power.
	 *
	 * <p>Each component of the vector is raised to the argument power.<br />
	 * So x = Math.pow( x, pow ), y = Math.pow( y, pow ),z = Math.pow( z, pow )</p>
	 *
	 * @param {@code pow} a {@code Float}.
	 */
	public function pow( pow:Float ):Void
	{
		x = Math.pow( x, pow );
        y = Math.pow( y, pow );
        z = Math.pow( z, pow );
	}

	/**
	 * Multiplies this vector by the specified scalar.
	 *
	 * @param {@code n a {@code Float}.
	 */
	public function scale( n:Float ):Void
	{
		x *= n;
		y *= n;
		z *= n;
	}

	/**
	 * Computes and returns the dot product between this vector and the specified vector.
	 *
	 * @param w 	The vector to multiply
	 * @return 	The dot procuct
	 */
	public function dot( w: Point3D):Float
	{
		return ( x * w.x + y * w.y + z * w.z );
	}

	/**
	 * Computes and returns the cross between this vector and the specified vector.
	 *
	 * @param v 	The vector to make the cross product with ( right side )
	 * @return 	The cross product vector.
	 */
	public function cross( v:Point3D):Point3D
	{
		// cross product vector that will be returned
		return new Point3D(
							(y * v.z) - (z * v.y) ,
		                 	(z * v.x) - (x * v.z) ,
		               		(x * v.y) - (y * v.x)
                           );
	}

	/**
	 * Crosses this vector with the specified vector.
	 *
	 * @param v 	The vector to make the cross product with (right side).
	 */
	public inline function crossWith( v:Point3D):Void
	{
		var cx:Float = (y * v.z) - (z * v.y);
		var cy:Float = (z * v.x) - (x * v.z);
		var cz:Float = (x * v.y) - (y * v.x);
		x = cx; y = cy; z = cz;
	}

	/**
	 * Normalizes this vector.
	 *
	 * <p>After normalizing the vector, the direction is the same, but the length is = 1.</p>
	 */
	public function normalize():Void
	{
		// -- We get the norm of the vector
		var norm:Float = Math.sqrt( x*x + y*y + z*z );
		// -- We escape the process is norm is null or equal to 1
		if( norm == 0. || norm == 1.) return;
		x = x / norm;
		y = y / norm;
		z = z / norm;
	}

	/**
	 * Gives the biggest component of the current vector.
	 * Example : var lMax:Float = new Point3D(5, 6.7, -4).getMaxComponent(); //returns 6.7
	 *
	 * @return The biggest component value of the vector
	 */
	public function getMaxComponent():Float
	{
		return Math.max( x, Math.max( y, z ) );
	}

	/**
	 * Gives the smallest component of the current vector.
	 * Example : var lMin:Float = new Point3D(5, 6.7, -4).getMinComponent(); //returns -4
	 *
	 * @return The smallest component value of the vector
	 */
	public function getMinComponent():Float
	{
		return Math.min( x, Math.min( y, z ) );
	}

	/**
	 * Returns the angle between this vector and the specified vector.
	 *
	 * @param w	The vector making an angle with this one
	 * @return 	The angle in radians
	 */
	public function getAngle ( w:Point3D ):Float
	{
		var n1:Float = getNorm();
		var n2:Float =  w.getNorm();
		var denom:Float = n1 * n2;
		if( denom  == 0 )
		{
			return 0;
		}
		else
		{
			var ncos:Float = dot( w ) / ( denom );
			var sin2:Float = 1 - (ncos * ncos);
			if ( sin2 < 0 )
			{
				trace(" wrong "+ncos);
				sin2 = 0;
			}
			//I took long time to find this bug. Who can guess that (1-cos*cos) is negative ?!
			//sqrt returns a NaN for a negative value !
			return  Math.atan2( Math.sqrt(sin2), ncos );
		}
	}


	/**
	 * Returns a string representing this vector.
	 *
	 * @param decPlaces	Float of decimals
	 * @return	The string representatation
	 */
	public function toString():String
	{
		// Round display to two decimals places
		// Returns "{x, y, z}"
		return "{" + serialize(2) + "}";
	}

	// Useful for XML output
	public function serialize(?decPlaces:Int=2):String
	{
		//returns x,y,x
		return  (NumberUtil.roundToPlaces(x, decPlaces) + "," +
					NumberUtil.roundToPlaces(y, decPlaces) + "," +
					NumberUtil.roundToPlaces(z, decPlaces));
	}

	// Useful for XML input
	public static function deserialize(convertFrom:String):Point3D
	{
		var tmp = convertFrom.split(",");
		if (tmp.length != 3) {
			trace ("Unexpected length of string to deserialize into a Point3D " + convertFrom);
		}
		var ta = new Array();
		for(i in 0...tmp.length) {
			ta[i] = Std.parseFloat(tmp[i]);
		}
		return new Point3D (ta[0], ta[1], ta[2]);
	}


	/**
	 * Is this vector equal to the specified vector?.
	 *
	 * <p>Compares this vector with the vector passed in the argument.<br />
	 * If all components in the two vectors are equal a value of true is returned.</p>
	 *
	 * @return 	true if the the two vectors are equal, fals otherwise.
	 */
	public function equals(p_vector:Point3D):Bool
	{
		return (p_vector.x == x && p_vector.y == y && p_vector.z == z);
	}


	/** Returns a new unit point in the X direction */
	public static function makeUnitX() : Point3D {
		return new Point3D(1.,0.,0.);
	}

	/** Returns a new unit point in the Y direction */
	public static function makeUnitY() : Point3D {
		return new Point3D(0.,1.,0.);
	}

	/** Returns a new unit point in the Z direction */
	public static function makeUnitZ() : Point3D {
		return new Point3D(0.,0.,1.);
	}

}

