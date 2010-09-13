
package sandy.materials;

/**
* Interface for setting and getting alpha on a material.
*
* @author		flexrails
* @version		3.1
* @date 		22.03.2008
**/
interface IAlphaMaterial
{
	/**
	 * Indicates the alpha transparency value of the material. Valid values are 0 (fully transparent) to 1 (fully opaque).
	 */
	public var alpha(__getAlpha,__setAlpha):Float;
	private function __setAlpha(p_nValue:Float):Float;

	/**
	 * @private
	 */
	private function __getAlpha():Float;
}

