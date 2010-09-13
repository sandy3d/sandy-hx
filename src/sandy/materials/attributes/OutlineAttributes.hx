
package sandy.materials.attributes;

import flash.display.Graphics;
import flash.geom.Rectangle;
// import flash.utils.Dictionary;

import sandy.core.Scene3D;
import sandy.core.data.Edge3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Sprite2D;
import sandy.materials.Material;
import sandy.util.ArrayUtil;

import sandy.HaxeTypes;

/**
* Holds all outline attributes data for a material.
*
* <p>Each material can have an outline attribute to outline the whole 3D shape.<br/>
* The OutlineAttributes class stores all the information to draw this outline shape</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		09.09.2007
*/
class OutlineAttributes extends AAttributes
{
	private var SHAPE_MAP:IntHash<Bool>;
	// --
	private var m_nThickness:Int;
	private var m_nColor:Int;
	private var m_nAlpha:Float;
	// --
	private var m_nAngleThreshold:Float;
	// --
	/**
	 * Whether the attribute has been modified since it's last render.
	 */
	public var modified:Bool;

	/**
	 * Creates a new OutlineAttributes object.
	 *
	 * @param p_nThickness	The line thickness.
	 * @param p_nColor		The line color.
	 * @param p_nAlpha		The alpha transparency value of the material.
	 */
	public function new( ?p_nThickness:Int = 1, ?p_nColor:Int = 0, ?p_nAlpha:Float = 1.0 )
	{
		SHAPE_MAP = new IntHash();
		m_nAngleThreshold = 181.0;

		m_nThickness = p_nThickness;
		m_nAlpha = p_nAlpha;
		m_nColor = p_nColor;


		// --
		super();
		modified = true;
	}

	/**
	 * Indicates the alpha transparency value of the outline. Valid values are 0 (fully transparent) to 1 (fully opaque).
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
	public var thickness(__getThickness,__setThickness):Int;
	private function __getThickness():Int
	{
		return m_nThickness;
	}

	/**
	 * The angle threshold. Attribute will additionally draw edges between faces that form greater angle than this value.
	 */
	public var angleThreshold(__getAngleThreshold,__setAngleThreshold):Float;
	private function __getAngleThreshold():Float
	{
		return m_nAngleThreshold;
	}

	/**
	 * @private
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
	private function __setThickness(p_nValue:Int):Int
	{
		m_nThickness = p_nValue;
		modified = true;
        return p_nValue;
	}

	public function __setAngleThreshold(p_nValue:Float):Float
	{
		m_nAngleThreshold = p_nValue;
		return p_nValue;
	}

	/**
	* @private
	*/
	override public function init( p_oPolygon:Polygon ):Void
	{
		// to keep reference to the shapes/polygons that use this attribute
		// -- attempt to create the neighboors relation between polygons
		if( SHAPE_MAP.get(p_oPolygon.shape.id) == null )
		{
			// if this shape hasn't been registered yet, we compute its polygon relation to be able
			// to draw the outline.
			var l_aPoly:Array<Polygon> = p_oPolygon.shape.aPolygons;
			var a:Int = l_aPoly.length, lCount:Int = 0;
			var lP1:Polygon, lP2:Polygon;
			var l_aEdges:Array<Edge3D>;
			// if any of polygons of this shape have neighbour information, do not re-calculate it
			var l_bNoInfo:Bool = true;
			for( i in 0...a)
			{
				if ( l_aPoly[i].aNeighboors.length > 0 )
					l_bNoInfo = false;
			}
			if ( l_bNoInfo )
			{
				for( i in 0...a-1 )
				{
					lP1 = l_aPoly[i];
					for( j in i+1...a )
					{
						lP2 = l_aPoly[j];
						l_aEdges = lP2.aEdges;
						// --
						lCount = 0;
						// -- check if they share at least 2 vertices
						for ( l_oEdge in lP1.aEdges )
							// FIXME: optimise Polygon with less Arrays, and you won't need this
							if( ArrayUtil.indexOf(l_aEdges, l_oEdge) > -1) lCount += 1;
						// --
						if( lCount > 0 )
						{
							lP1.aNeighboors.push( lP2 );
							lP2.aNeighboors.push( lP1 );
						}
					}
				}
			}
			// --
			SHAPE_MAP.set(p_oPolygon.shape.id, true);
		}
	}

	/**
	* @private
	*/
	override public function unlink( p_oPolygon:Polygon ):Void
	{
		// to remove reference to the shapes/polygons that use this attribute
		// TODO : can we free the memory of SHAPE_MAP ? Don't think so, and would it be really necessary? not sure either.
	}

	/**
	* @private
	*/
	override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		var l_oEdge:Edge3D;
		var l_oPolygon:Polygon;
		var l_bFound:Bool;
		var l_bVisible:Bool = p_oPolygon.visible;
		// --
		var l_oNormal:Vertex = null;
		var l_nDotThreshold:Float = 0.0;
		if (m_nAngleThreshold < 180)
		{
			l_oNormal = p_oPolygon.normal;
			l_nDotThreshold = Math.cos (m_nAngleThreshold * 0.017453292519943295769236907684886 /* Math.PI / 180 */ );
		}
		// --
		p_oGraphics.lineStyle( m_nThickness, m_nColor, m_nAlpha );
		// --
		for ( l_oEdge in p_oPolygon.aEdges )
		{
			l_bFound = false;
			// --
			for ( l_oPolygon in p_oPolygon.aNeighboors )
			{
				// aNeighboor not visible, does it share an edge?
				// if so, we draw it
				if( ArrayUtil.indexOf(l_oPolygon.aEdges, l_oEdge) > -1 )
				{
					if(( l_oPolygon.visible != l_bVisible ) ||
						((m_nAngleThreshold < 180) && (l_oNormal.dot (l_oPolygon.normal) < l_nDotThreshold )) )
					{
						p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
						p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
					}
					l_bFound = true;
				}
			}
			// -- if not shared with any neighboor, it is an extremity edge that shall be drawn
			if( l_bFound == false )
			{
				p_oGraphics.moveTo( l_oEdge.vertex1.sx, l_oEdge.vertex1.sy );
				p_oGraphics.lineTo( l_oEdge.vertex2.sx, l_oEdge.vertex2.sy );
			}
		}
	}

	/**
	* @private
	*/
	override public function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		var g:Graphics = p_oSprite.container.graphics; g.clear ();
		var r:Rectangle = p_oSprite.container.getBounds (p_oSprite.container);
		g.lineStyle (m_nThickness, m_nColor, m_nAlpha); g.drawRect (r.x, r.y, r.width, r.height);
	}
}

