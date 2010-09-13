
package sandy.core.light;

import flash.events.EventDispatcher;

import sandy.core.data.Point3D;
import sandy.events.SandyEvent;
import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* The Light3D class is used for creating the light of the world.
*
* <p>The light in Sandy is a light source at infinity, emitting parallel colored light.
* The direction, color, and intensity of the light can be changes.</p>
*
* @author	Thomas Pfeiffer - kiroukou
* @author	Niel Drummond - haXe port
* @author	Russell Weir - haXe port
* @version		3.1
* @date 	26.07.2007
*/
class Light3D extends EventDispatcher
{
	/**
	* Maximum value accepted. If the default value (150) seems too big or too small for you, you can change it.
	* But be aware that the actual lighting calculations are normalised i.e. 0 -> MAX_POWER becomes 0 -> 1
	*/
	public static inline var MAX_POWER:Float = 150;

	/**
	 * Public property which stores the modification of that light instance in case it changed.
	 * It is useful for the cache system
	 */
	public var changed:Bool;

	/**
	 * Creates a new light source.
	 *
	 * @param p_oD		The direction of the emitted light.
	 * @param p_nPow	Intensity of the emitted light.
	 *
		* @see sandy.core.data.Point3D
	 */
	public function new(p_oD:Point3D, p_nPow:Float)
	{
		super();
		_dir = p_oD;
		_dir.normalize();
		setPower(p_nPow);
	}

	/**
	 * The the power of the light. A number between 0 and MAX_POWER is necessary.
	 * The highter the power of the light is, the less the shadows are visibles.
	 *
	 * @param n	Float a Float between 0 and MAX_POWER. This number is the light intensity.
	 */
	public function setPower(p_nPow:Float):Void
	{
		_power =  NumberUtil.constrain(p_nPow, 0, Light3D.MAX_POWER);
		_nPower = _power / Light3D.MAX_POWER;
		changed = true;
		dispatchEvent(new SandyEvent(SandyEvent.LIGHT_UPDATED));
	}

	/**
	 * Returns the intensity of the light.
	 *
	 * @return The intensity as a number between 0 - MAX_POWER.
	 */
	public function getPower():Float
	{
		return _power;
	}

	/**
	 * Returns the power of the light normalized to the range 0 -> 1
	 *
	 * @return Float a number between 0 and 1
	 */
	public function getNormalizedPower():Float
	{
		return _nPower;
	}

	/**
	 * Returns the direction of the light.
	 *
	 * @return 	The light direction
	 *
     * @see sandy.core.data.Point3D
	 */
	public function getDirectionPoint3D():Point3D
	{
		return _dir;
	}

	/**
	 * Uneeded? setDirectionPoint3D() does the same thing...
	 *
	 * @param x	The x coordinate
	 * @param y	The y coordinate
	 * @param z	The z coordinate
	 */
	public function setDirection(x:Float, y:Float, z:Float):Void
	{
		_dir.x = x; _dir.y = y; _dir.z = z;
		_dir.normalize();
		changed = true;
		dispatchEvent(new SandyEvent(SandyEvent.LIGHT_UPDATED));
	}

	/**
	 * Sets the direction of the Light3D.
	 *
	 * @param x	A Point3D object representing the direction of the light.
	 *
     * @see sandy.core.data.Point3D
	 */
	public function setDirectionPoint3D(pDir:Point3D):Void
	{
		_dir = pDir;
		_dir.normalize();
		changed = true;
		dispatchEvent(new SandyEvent(SandyEvent.LIGHT_UPDATED));
	}

	/**
	 * Calculates the strength of this light based on the supplied normal.
	 *
	 * @return Float	The strength between 0 and 1
	 *
     * @see sandy.core.data.Point3D
	 */
	public function calculate(normal:Point3D):Float
	{
		var DP:Float = _dir.dot(normal);
		DP = -DP;

		// if DP is less than 0 then the face is facing away from the light
		// so set it to zero
		if (DP < 0)
		{
			DP = 0;
		}

		return _nPower * DP;
	}

	/**
	 * Not in use...
	 */
	public function destroy():Void
	{
		//How clean the listeners here?
		//removeEventListener(SandyEvent.LIGHT_UPDATED, );
	}

	/**
	 * Color of the light.
	 */
	public var color(__getColor, __setColor):Int;
	public function __getColor():Int
	{
		return _color;
	}

	/**
	 * @private
	 */
	private function __setColor(p_nColor:Int):Int
	{
		_color = p_nColor;
		changed = true;

		// we don't send LIGHT_UPDATED to aVoid recalculating light maps needlessly
		// some event still has to be sent though, just in case...
		dispatchEvent(new SandyEvent(SandyEvent.LIGHT_COLOR_CHANGED));
		return p_nColor;
	}

	// Direction of the light. It is 3D vector.
	//Please refer to the Light tutorial to learn more about Sandy's lights.
	private var _dir:Point3D;
	private var _power:Float;
	private var _nPower:Float;
	private var _color:Int;
}

