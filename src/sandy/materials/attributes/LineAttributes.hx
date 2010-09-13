
package sandy.materials.attributes;

import flash.display.Graphics;

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.materials.Material;

import sandy.HaxeTypes;

/**
* Holds all line attribute data for a material.
*
* <p>Some materials have line attributes to outline the faces of a 3D shape.<br/>
* In these cases a LineAttributes object holds all line attribute data</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class LineAttributes extends AAttributes, implements IAttributes
{
	private var m_nThickness:Float;
	private var m_nColor:Int;
	private var m_nAlpha:Float;
	// --
	/**
	 * Whether the attribute has been modified since it's last render.
	 */
	public var modified:Bool;

	/**
	 * Creates a new LineAttributes object.
	 *
	 * @param p_nThickness	The line thickness.
	 * @param p_nColor		The line color.
	 * @param p_nAlpha		The alpha transparency value of the material.
	 */
	public function new( p_nThickness:Float = 1.0, p_nColor:Int = 1, p_nAlpha:Float = 1.0 )
	{
		m_nThickness = p_nThickness;
		m_nAlpha = p_nAlpha;
		m_nColor = p_nColor;
		// --
		modified = true;

		super();
	}

	/**
	 * Indicates the alpha transparency value of the line. Valid values are 0 (fully transparent) to 1 (fully opaque).
	 *
	 * @default 1.0
	 */
	public var alpha(__getAlpha,__setAlpha):Float;
	private function __getAlpha():Float
	{
		return m_nAlpha;
	}

	/**
	 * The line color.
	 */
	public var color(__getColor,__setColor):Int;
	private function __getColor():Int
	{
		return m_nColor;
	}

	/**
	 * The line thickness.
	 */
	public var thickness(__getThickness,__setThickness):Float;
	private function __getThickness():Float
	{
		return m_nThickness;
	}

	/**
	 * The alpha value for the lines ( 0 - 1 )
	 *
	 * Alpha = 0 means fully transparent, alpha = 1 fully opaque.
	 */
	private function __setAlpha(p_nValue:Float):Float
	{
		m_nAlpha = p_nValue;
		modified = true;
		return p_nValue;
	}

	/**
	 * The line color
	 */
	private function __setColor(p_nValue:Int):Int
	{
		m_nColor = p_nValue;
		modified = true;
		return p_nValue;
	}

	/**
	 * The line thickness
	 */
	private function __setThickness(p_nValue:Float):Float
	{
		m_nThickness = p_nValue;
		modified = true;
		return p_nValue;
	}

	/**
	 * Draw the edges of the polygon into the graphics object.
	 *
	 * @param p_oGraphics the Graphics object to draw attributes into
	 * @param p_oPolygon the polygon which is going to be drawn
	 * @param p_oMaterial the referring material
	 * @param p_oScene the scene
	 */
	override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		var l_aPoints:Array<Vertex> = (p_oPolygon.isClipped)?p_oPolygon.cvertices : p_oPolygon.vertices;
		var l_oVertex:Vertex;
		p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
		// --
		p_oGraphics.moveTo( l_aPoints[0].sx, l_aPoints[0].sy );

		var lId:Int = l_aPoints.length;
		while( (l_oVertex = l_aPoints[ --lId ]) != null ) {
			p_oGraphics.lineTo( l_oVertex.sx, l_oVertex.sy );
		}
	}
}

