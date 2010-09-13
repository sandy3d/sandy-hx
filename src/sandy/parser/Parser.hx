
package sandy.parser;

import sandy.HaxeTypes;

/**
* The Parser factory class creates instances of parser classes.
* The specific parser can be specified in the create method's second parameter.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell WEir - haXe port
* @version		3.1
* @date 		04.08.2007
*
* @example To parse a 3DS file at runtime:
*
* <listing version="3.1">
*     var parser:IParser = Parser.create( "/path/to/my/3dsfile.3ds", Parser.MAX_3DS );
* </listing>
*
*/
class Parser<T,ParserClass:IParser, URL: (String,Null<T>)>
{
	/**
	 * Specifies that the ASE (ASCII Scene Export) parser should be used.
	 */
	public inline static var ASE:String = "ASE";
	/**
	 * Specifies that the MD2 (Quake II model) parser should be used.
	 */
	public inline static var MD2:String = "MD2";
	/**
	 * Specifies that the MD3 (Quake III model) parser should be used.
	 */
	public inline static var MD3:String = "MD3";
	/**
	 * Specifies that the 3DS (3D Studio) parser should be used.
	 */
	public inline static var MAX_3DS:String = "3DS";
	/**
	 * Specifies that the COLLADA (COLLAborative Design Activity ) parser should be used.
	 */
	public inline static var COLLADA:String = "DAE";

	/**
	* The create method chooses which parser to use. This can be done automatically
	* by looking at the file extension or by passing the parser type String as the
	* second parameter.
	*
	* @example To parse a 3DS file at runtime:
	*
	* <listing version="3.1">
	*     var parser:IParser = Parser.create( "/path/to/my/3dsfile.3ds", Parser.3DS );
	* </listing>
	*
	* @param p_sFile			Can be either a string pointing to the location of the
	* 							file or an instance of an embedded file
	* @param p_sParserType		The parser type string
	* @param p_nScale			The scale factor
	* @param p_sTextureExtension	Overrides texture extension.
	* @return					The parser to be used
	*/
	public static function create<ParserClass,URL>( p_sFile:URL, ?p_sParserType:String, ?p_nScale:Float = 1.0, ?p_sTextureExtension:String ): ParserClass
	{
		var l_sExt:String,l_iParser:IParser = null;
		// --
		if( Std.is( p_sFile, String ) && p_sParserType == null )
		{
			l_sExt = (cast(p_sFile,String).split('.')).pop();
		}
		else
		{
			l_sExt = p_sParserType;
		}
		// --
		switch( l_sExt.toUpperCase() )
		{
			case ASE:
 				l_iParser = new ASEParser( p_sFile, p_nScale, p_sTextureExtension );
			case MD2:
				l_iParser = new MD2Parser( p_sFile, p_nScale, p_sTextureExtension );
			case MD3:
				l_iParser = new MD3Parser( p_sFile, null, new sandy.util.LoaderQueue(), p_nScale );
			case "OBJ":
			case COLLADA:
				l_iParser = new ColladaParser( p_sFile, p_nScale, p_sTextureExtension );
			case MAX_3DS:
				l_iParser = new Parser3DS( p_sFile, p_nScale, p_sTextureExtension );
			default:
		}
		// --
		return cast l_iParser;
	}
}

