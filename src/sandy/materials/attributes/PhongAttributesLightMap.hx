
package sandy.materials.attributes;

import sandy.HaxeTypes;

/**
 * A lightmap used for some of the shaders.
 *
 * @version		3.0.2
 */
class PhongAttributesLightMap
{
	/**
	 * An array of an array which contains the alphas of the strata. The values of the inner array must be between 0 and 1.
	 */
	public var alphas:Array<Array<Float>>;

	/**
	 * An array of an array which contains the colors of the strata.
	 */
	public var colors:Array<Array<Int>>;

	/**
	 * An array of an array which contains the ratios (length) of each strata.
	 */
	public var ratios:Array<Array<Float>>;

	public function new () {
		alphas = [[], []];
		colors = [[], []];
		ratios = [[], []];
	}
}
