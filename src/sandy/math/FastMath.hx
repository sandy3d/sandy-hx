
package sandy.math;

import sandy.HaxeTypes;

/**
* 	Fast trigonometry functions using cache table and precalculated data.
* 	Based on Michael Kraus implementation.
*
* 	@author	Mirek Mencel	// miras@polychrome.pl
* 	@author Niel Drummond - haXe port
*	@author Russell Weir - haXe optimizations
*	@notes Using vector
*/
class FastMath
{
	/**
	* The precision of the lookup table.
	* <p>The bigger this number, the more entries there are in the lookup table, which gives more accurate results.</p>
	*/
	public static inline var PRECISION:Int = 0x020000;

	/**
	* Math constant pi&#42;2.
	*/
	public static inline var TWO_PI:Float = 6.283185307179586477; // Math.PI * 2

	/**
	* Math constant pi/2.
	*/
	public static inline var HALF_PI:Float = 1.570796326794896619; //Math.PI/2;

	// OPTIMIZATION CONSTANTS
	/**
	* <code>PRECISION</code> - 1.
	*/
	public static inline var PRECISION_S:Int = PRECISION - 1;

	/**
	* <code>PRECISION</code> / <code>TWO_PI</code>.
	*/
	public static inline var PRECISION_DIV_2PI:Float = PRECISION / TWO_PI;

	// Precalculated values with given precision
	private static var sinTable:TypedArray<Float>;
	private static var tanTable:TypedArray<Float>;

	public static function initialized() : Bool {
		if(sinTable == null)
			initialize();
		return true;
	}

	public static function initialize():Void
	{
		var rad_slice = TWO_PI / PRECISION;

		sinTable = new TypedArray();
		tanTable = new TypedArray();

		var rad:Float = 0;
		// --
		for (i in 0...PRECISION)
		{
			rad = i * rad_slice;
			sinTable[i] = Math.sin(rad);
			tanTable[i] = Math.tan(rad);
		}
	}

	private static inline function radToIndex(radians:Float):Int
	{
		return Std.int(radians * PRECISION_DIV_2PI ) & (PRECISION_S);
	}

	/**
	* Returns the sine of a given value, by looking up it's approximation in a
	* precomputed table.
	* @param radians The value to sine.
	* @return The approximation of the value's sine.
	*/
	public static inline function sin(radians:Float):Float
	{
		return sinTable[ radToIndex(radians) ];
	}

	/**
	* Returns the cosine of a given value, by looking up it's approximation in a
	* precomputed table.
	* @param radians The value to cosine.
	* @return The approximation of the value's cosine.
	*/
	public static inline function cos(radians:Float ):Float
	{
		return sinTable[ radToIndex(HALF_PI-radians) ];
	}

	/**
	* Returns the tangent of a given value, by looking up it's approximation in a
	* precomputed table.
	* @param radians The value to tan.
	* @return The approximation of the value's tangent.
	*/
	public static inline function tan(radians:Float):Float
	{
		return tanTable[ radToIndex(radians) ];
	}

	private static function __init__() {
		#if SANDY_USE_FAST_MATH
		initialize();
		#end
	}
}

