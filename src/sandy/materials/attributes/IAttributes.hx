
package sandy.materials.attributes;

import flash.display.Graphics;

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.scenegraph.Sprite2D;
import sandy.materials.Material;

import sandy.HaxeTypes;

/**
* Interface for all the elements that represent a material attribute property.
* This interface is important to make attributes really flexible and allow users to extend it.
*/
interface IAttributes
{
	function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):Void;

	function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):Void;

	function init( p_oPolygon:Polygon ):Void;

	function unlink( p_oPolygon:Polygon ):Void;

	function begin( p_oScene:Scene3D ):Void;

	function finish( p_oScene:Scene3D ):Void;

	var flags(__getFlags,null):Int;
	private function __getFlags():Int;
}

