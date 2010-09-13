
package sandy.math;

import sandy.HaxeTypes;

typedef ColorMathRGB = {
		r:Float,
		g:Float,
		b:Float
}
/**
 * Math functions for colors.
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		Tabin Cédric - thecaptain
 * @author		Nicolas Coevoet - [ NikO ]

 *
 */
/**
* Math functions for colors.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Tabin Cédric - thecaptain
* @author		Nicolas Coevoet - [ NikO ]
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		0.1
* @version		3.1
* @date 		26.07.2007
*/
class ColorMath
{

	/**
	 * Returns the color with altered alpha value.
	 *
	 * @param c	32-bit color.
	 * @param a	New alpha. 	( 0 - 1 )
	 * @return	The hexadecimal value
	 */
	public static function applyAlpha (c:Int32, a:Float): Int32
	{
		#if neko
			var a0 = I32.toInt(I32.ushr(c, 24));
			var a1 = I32.shl(I32.ofInt(Math.floor(a * a0)), 24);
			return I32.add(
					I32.and(c, I32.ofInt(0xFFFFFF)),
					a1);
		#else
			var a0:Int = Std.int(c / 0x1000000);
			return (c & 0xFFFFFF) + Math.floor(a * a0) * 0x1000000;
		#end
	}

	/**
	 * Converts color component values ( rgb ) to one hexadecimal value.
	 *
	 * @param r	Red Color. 	( 0 - 255 )
	 * @param g	Green Color. 	( 0 - 255 )
	 * @param b	Blue Color. 	( 0 - 255 )
	 * @return	The hexadecimal value
	 */
	public static function rgb2hex(r:Int, g:Int, b:Int):Int
	{
		return ((r << 16) | (g << 8) | b);
	}

	/**
	 * Converts a hexadecimal color value to rgb components
	 *
	 * @param	hex	hexadecimal color.
	 * @return	The rgb color of the hexadecimal given.
	 */
	public static function hex2rgb(hex:Int):ColorMathRGB
	{
		var r:Float;
		var g:Float;
		var b:Float;
		r = (0xFF0000 & hex) >> 16;
		g = (0x00FF00 & hex) >> 8;
		b = (0x0000FF & hex);
		return {r:r,g:g,b:b} ;
	}

	/**
	* Converts hexadecimal color value to normalized rgb components ( 0 - 1 ).
	*
	* @param	hex	hexadecimal color value.
	* @return	The normalized rgb components ( 0 - 1.0 )
	*/
	public static function hex2rgbn(hex:Int):Dynamic
	{
		var r:Float;
		var g:Float;
		var b:Float;
		r = (0xFF0000 & hex) >> 16;
		g = (0x00FF00 & hex) >> 8;
		b = (0x0000FF & hex);
		return {r:r/255,g:g/255,b:b/255} ;
	}

	/**
	 * Calculate the colour for a particular lighting strength.
	 * This converts the supplied pre-multiplied RGB colour into HSL
	 * then modifies the L according to the light strength.
	 * The result is then mapped back into the RGB space.
	 */
	public static function calculateLitColour(col:Int, lightStrength:Float):Float
	{
		var r:Float = ( col >> 16 )& 0xFF;
		var g:Float = ( col >> 8 ) & 0xFF;
		var b:Float = ( col ) 		& 0xFF;

		// divide by 256
		r *= 0.00390625;
		g *= 0.00390625;
		b *= 0.00390625;

		var min:Float = 0.0, mid:Float = 0.0, max:Float = 0.0, delta:Float = 0.0;
		var l:Float = 0.0, s:Float = 0.0, h:Float = 0.0, F:Float = 0.0, n:Int = 0;

		var a:Array<Float> = [r,g,b];
		a.sort(function (a,b) {return ((a>b)?1:(a<b)?-1:0); } );

		min = a[0];
		mid = a[1];
		max = a[2];

		var range:Float = max - min;

		l = (min + max) * 0.5;

		if (l == 0)
		{
			s = 1;
		}
		else
		{
			delta = range * 0.5;

			if (l < 0.5)
			{
				s = delta / l;
			}
			else
			{
				s = delta / (1 - l);
			}

			if (range != 0)
			{
				while (true)
				{
					if (r == max)
					{
						if (b == min) n = 0;
						else n = 5;

						break;
					}

					if (g == max)
					{
						if (b == min) n = 1;
						else n = 2;

						break;
					}

					if (r == min) n = 3;
					else n = 4;

					break;
				}

				if ((n % 2) == 0)
				{
					F = mid - min;
				}
				else
				{
					F = max - mid;
				}

				F = F / range;
				h = 60 * (n + F);
			}
		}

		if (lightStrength < 0.5)
		{
			delta = s * lightStrength;
		}
		else
		{
			delta = s * (1 - lightStrength);
		}


		min = lightStrength - delta;
		max = lightStrength + delta;

		n = Math.floor(h / 60);
		F = (h - n*60) * delta / 30;
		n %= 6;

		var mu:Float = min + F;
		var md:Float = max - F;

		switch (n)
		{
			case 0: r = max; g= mu;  b= min;
			case 1: r = md;  g= max; b= min;
			case 2: r = min; g= max; b= mu;
			case 3: r = min; g= md;  b= max;
			case 4: r = mu;  g= min; b= max;
			case 5: r = max; g= min; b= md;
		}

		return (Std.int(r * 256) << 16 | Std.int(g * 256) << 8 |  Std.int(b * 256));
	}
}

