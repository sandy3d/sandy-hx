
package sandy.materials;

import sandy.HaxeTypes;

/**
* Represents the material types used in Sandy.
*
* <p>All materialy types used in Sandy are registered here as constant properties.<br/>
* If new materials are added to the Sandy library, they should be registered here.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*/
enum MaterialType
{

	/**
	* Specifies the default material.
	*/
		NONE;

	/**
	* Specifies a ColorMaterial
	*/
		COLOR;

	/**
	* Specifies a WireFrameMaterial
	*/
		WIREFRAME;

	/**
	* Specifies a BitmapMaterial
	*/
		BITMAP;

	/**
	* Specifies a MovieMaterial
	*/
		MOVIE;

	/**
	* Specifies a VideoMaterial
	*/
		VIDEO;

	/**
	* Specifies a OutlineMaterial
	*/
		OUTLINE;
}
