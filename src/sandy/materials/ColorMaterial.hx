
package sandy.materials;

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.materials.attributes.MaterialAttributes;

import flash.display.Graphics;
import flash.display.Sprite;

import sandy.HaxeTypes;


/**
* Displays a color with on the faces of a 3D shape.
*
* <p>Used to show colored faces, possibly with lines at the edges of the faces.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author 		Niel Drummond - haXe port
* @author 		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class ColorMaterial extends Material, implements IAlphaMaterial
{
	private var m_nColor:Int;
	private var m_nAlpha:Float;

	/**
	 * Creates a new ColorMaterial.
	 *
	 * @param p_nColor 	The color for this material in hexadecimal notation.
	 * @param p_nAlpha	The alpha transparency value of the material.
	 * @param p_oAttr	The attributes for this material.
	 *
	 * @see sandy.materials.attributes.MaterialAttributes
	 */
	public function new( p_nColor:Int = 0x00, p_nAlpha:Float = 1.0, ?p_oAttr:MaterialAttributes )
	{
		super(p_oAttr);
		// --
		m_oType = MaterialType.COLOR;
		// --
		m_nColor = p_nColor;
		m_nAlpha = p_nAlpha;
	}

	/**
	 * Renders this material on the face it dresses
	 *
	 * @param p_oScene		The current scene
	 * @param p_oPolygon	The face to be rendered
	 * @param p_mcContainer	The container to draw on
	 */
	public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):Void
	{
		var l_points:Array<Vertex> = (p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices;
		if( l_points.length == 0 ) return;
		var l_oVertex:Vertex;
		var lId:Int = l_points.length;
		var l_graphics:Graphics = p_mcContainer.graphics;
		// --
		l_graphics.lineStyle();
		l_graphics.beginFill( m_nColor, m_nAlpha );
		l_graphics.moveTo( l_points[0].sx, l_points[0].sy );
		while( (l_oVertex = l_points[ --lId ]) != null )
			l_graphics.lineTo( l_oVertex.sx, l_oVertex.sy );
		l_graphics.endFill();
		// --
		super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
		//if( attributes != null )  attributes.draw( l_graphics, p_oPolygon, this, p_oScene ) ;

	}

	/**
	 * Indicates the alpha transparency value of the material. Valid values are 0 (fully transparent) to 1 (fully opaque).
	 *
	 * @default 1.0
	 */
	public var alpha(__getAlpha,__setAlpha):Float;
	private function __getAlpha():Float
	{
		return m_nAlpha;
	}

	/**
	 * The color of this material.
	 *
	 * @default 0x00
	 */
	public var color(__getColor,__setColor):Int;
	private function __getColor():Int
	{
		return m_nColor;
	}


	/**
	 * The alpha value for this material ( 0 - 1 )
	 *
	 * Alpha = 0 means fully transparent, alpha = 1 fully opaque.
	 */
	private function __setAlpha(p_nValue:Float):Float
	{
		m_nAlpha = p_nValue;
		m_bModified = true;
		return p_nValue;
	}

	/**
	 * The color of this material
	 */
	private function __setColor(p_nValue:Int):Int
	{
		m_nColor = p_nValue;
		m_bModified = true;
		return p_nValue;
	}

}

