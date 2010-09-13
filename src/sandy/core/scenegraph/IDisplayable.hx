
package sandy.core.scenegraph;

import flash.display.Sprite;

import sandy.materials.Material;

import sandy.HaxeTypes;

/**
* The IDisplayable interface should be implemented by all visible objects.
*
* <This ensures that all necessary methods are implemented>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*/
interface IDisplayable
{
	function clear():Void;
	// The container of this object
	var container(__getContainer, null):Sprite;
	private function __getContainer():Sprite;

	// The depth of this object
	public var depth(__getDepth, __setDepth):Float;
	private function __getDepth():Float;
	private function __setDepth( p_nDepth:Float ):Float;

	public var changed(__getChanged,__setChanged):Bool;
	private function __getChanged():Bool;
	private function __setChanged(v:Bool):Bool;

	public var material(__getMaterial,__setMaterial):Material;
	private function __getMaterial():Material;
	private function __setMaterial(v:Material):Material;

	// Called only if the useSignelContainer property is enabled!
	function display( ?p_oContainer:Sprite ):Void;
}

