
package sandy.primitive;

/**
* The PrimitiveMode class defines modes of creation for some primitives.
*
* <p>Some of the Sandy primitives can be created in one of two modes,
* TRI mode and QUAD mode. TRI mode makes for a better perspective
* distortion for textures, while QUAD mode gives better performance.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class PrimitiveMode
{
	/**
	* Specifies the surfaces of the primitive is built up by rectangular polygons.
	*/
	public static var QUAD:String = "quad";

	/**
	* Specifies the surfaces of the primitive is built up by triangles.
	*/
 	public static var TRI:String = "tri";
}

