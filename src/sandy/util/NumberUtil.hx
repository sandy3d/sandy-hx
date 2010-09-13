
package sandy.util;

import sandy.HaxeTypes;

/**
* Utility class for useful numeric constants and number manipulation.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class NumberUtil
{
	/**
	* Math constant 2*pi
	*/
	public static inline var TWO_PI : Float = 6.283185307179586477;

	/**
	* Math constant pi
	*/
	public static inline var PI : Float = 3.141592653589793238;

	/**
	* Math constant pi/2
	*/
	public static inline var HALF_PI : Float = 1.570796326794896619; // Math.PI / 2

	/**
	* Constant used to convert angle from radians to degrees
	*/
	public static inline var TO_DEGREE : Float = 57.29577951308232088; // 180 / Math.PI

	/**
	* Constant used to convert degrees to radians.
	*/
	public static inline var TO_RADIAN : Float = 0.01745329251994329577; // Math.PI / 180

	/**
	* Value used to compare numbers with.
	*
	* <p>Basically used to say if a number is zero or not.<br />
	* Adjust this number with regard to the precision of your application</p>
	*/
	public static inline var TOL:Float = 0.00001;

	/**
	* Is the number small enough to be regarded as zero?.
	*
	* <p>Adjust the TOL property depending on the precision of your application</p>
	*
	* @param p_nN 	The number to compare to zero
	* @return 	true if the number is to be regarded as zero, false otherwise.
	*/
	public static inline function isZero( p_nN:Float ):Bool
	{
		return Math.abs( p_nN ) < TOL ;
	}

	/**
	* Are the numbers close enough to be regarded as equal?.
	*
	* <p>Adjust the TOL property depending on the precision of your application</p>
	*
	* @param p_nN 	The first number
	* @param p_nM 	The second number
	* @return 	true if the numbers are regarded as equal, false otherwise.
	*/
	public static inline function areEqual( p_nN:Float, p_nM:Float ):Bool
	{
		return Math.abs( p_nN - p_nM ) < TOL ;
	}

	/**
	* Converts an angle from radians to degrees
	*
	* @param p_nRad	A number representing the angle in radians
	* @return 		The angle in degrees
	*/
	public static inline function toDegree ( p_nRad:Float ):Float
	{
		return p_nRad * TO_DEGREE;
	}

	/**
	* Converts an angle from degrees to radians.
	*
	* @param p_nDeg 	A number representing the angle in dregrees
	* @return 		The angle in radians
	*/
	public static inline function toRadian ( p_nDeg:Float ):Float
	{
		return p_nDeg * TO_RADIAN;
	}

	/**
	* Constrains a number to a given interval
	*
	* @param p_nN 		The number to constrain
	* @param p_nMin 	The minimal valid value
	* @param p_nMax 	The maximal valid value
	* @return 		The constrained number
	*/
	public static inline function constrain( p_nN:Float, p_nMin:Float, p_nMax:Float ):Float
	{
		return Math.max( Math.min( p_nN, p_nMax ) , p_nMin );
	}

	/**
	* Rounds a number to specified accuracy.
	*
	* <p>To round off the number to 2 decimals, set the the accuracy to 0.01</p>
	*
	* @param p_nN 			The number to round off
	* @param p_nRoundToInterval 	The accuracy to which to round
	* @return 			The rounded number
	*/
	public static inline function roundTo (p_nN:Float, ?p_nRoundToInterval:Float):Float
	{
		if (p_nRoundToInterval == 0.)
		{
			p_nRoundToInterval = 1.;
		}
		return Math.round(p_nN/p_nRoundToInterval) * p_nRoundToInterval;
	}

	/**
	* Rounds a number to specified accuracy.
	*
	* <p>To round off the number to 2 decimals, set the the accuracy to 2</p>
	*
	* @param p_nN 			The number to round off
	* @param p_nPlaces 		The accuracy to which to round
	* @return 				The rounded number
	*/
	public static inline function roundToPlaces(p_nN:Float, p_nPlaces:Int=2 ) : Float {
		var mul = Math.pow(10, p_nPlaces);
		var j = Math.round(p_nN * mul) / mul;
		return j;
	}
}

