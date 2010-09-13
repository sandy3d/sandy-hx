
package sandy.parser;

import sandy.materials.Appearance;

import sandy.HaxeTypes;


/**
* The IParser interface defines the interface that parser classes such as ColladaParser must implement.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		26.07.2007
*/
interface IParser
{
		/**
		* This method starts the parsing process.
		*/
		public function parse():Void;

		/**
		* Creates a transformable node in the object tree of the world.
		*
		* @param p_oAppearance The default appearance that will be applied to the parsed obj
		*/
		public var standardAppearance( null, __setStandardAppearance ):Appearance;
		private function __setStandardAppearance( p_oAppearance:Appearance ):Appearance;
		
		/**
		* A unique id between all IParser. It is automatically set by AParser.
		*/
		public var m_nId:Int;
}

