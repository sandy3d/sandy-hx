
package sandy.primitive;

import sandy.core.scenegraph.Geometry3D;
import sandy.core.data.Point3D;

import sandy.HaxeTypes;

/**
* An interface implemented by all 3D primitive classes.
*
* <p>This is to ensure that all primitives classes implements the necessary method(s)</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		10/05/2007
*/
interface Primitive3D
{
	/**
	* Generates the geometry for the primitive.
	*
	* @return The geometry object for the primitive.
	*
	* @see sandy.core.scenegraph.Geometry3D
	*/
	public function generate<T>(?arguments:Array<T>):Geometry3D;
}

