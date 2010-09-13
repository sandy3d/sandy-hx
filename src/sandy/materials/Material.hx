
package sandy.materials;

import flash.display.Sprite;
import flash.filters.BitmapFilter;

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.scenegraph.Sprite2D;
import sandy.materials.attributes.MaterialAttributes;

import sandy.HaxeTypes;

/**
* The Material class is the base class for all materials.
*
* <p>Since the Material object is essentially a blank material, this class can be used
* to apply attributes without any material to a 3D object.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*
* @see Appearance
*/
class Material
{
	/**
	* The attributes of this material.
	*/
	public var attributes:MaterialAttributes;

	/**
	* Specify if the material use the vertex normal information.
	*
	* @default false
	*/
	public var useVertexNormal:Bool;

	/**
	* Specifies if the material can receive light and have light attributes applied to it.
	* Can be useful to rapidly disable light on the object when unneeded.
	*/
	public var lightingEnable:Bool;

	/**
	 * Specifies if the material can automatically be disposed when unused
	 * Default value is to true
	 */
	public var autoDispose:Bool;

	/**
	* Creates a material.
	*
	* <p>This constructor is never called directly - but by sub class constructors.</p>
	* @param p_oAttr	The attributes for this material.
	*/
	public function new( ?p_oAttr:MaterialAttributes )
	{
		//initializers
		repeat = true;
		m_nFlags = 0;

		_filters 	= [];
		_useLight = false;
		_id = _ID_++;
		attributes = (p_oAttr == null) ? new MaterialAttributes() : p_oAttr;
		m_bModified = true;
		m_oType = MaterialType.NONE;
		m_nRefCounting = 0;
		m_oPolygonMap = new IntHash<Int>();
		autoDispose = true;
		lastBegin = 0;
		lastFinish = 0;
	}

	private var m_oPolygonMap:IntHash<Int>;
	private var m_nRefCounting:Int;

	/**
	* Method to call when you want to release the resources of that material (filters, attributes and lreferences to polygons)
	* Shape3D.DEFAULT_MATERIAL Material can't be disposed because might be used for later shape3D creations
	*/
	public function dispose():Void
	{
		var l_oApp:Appearance;
		var l_oPoly:Polygon;
		for( l_sLabel in m_oPolygonMap )
		{
			l_oPoly = Polygon.POLYGON_MAP.get(l_sLabel);
			m_oPolygonMap.remove(l_sLabel);
			if(l_oPoly == null) continue;
			unlink(l_oPoly);
			l_oApp = l_oPoly.appearance;
			if(l_oApp == null) continue;
			if( l_oApp.frontMaterial == this )
				l_oApp.frontMaterial = null;
			else if( l_oApp.backMaterial == this )
				l_oApp.backMaterial = null;
		}
		attributes = null;
		_filters = null;
	}

	/**
	* The unique id of this material.
	*/
	public var id(__getId,null):Float;
	private function __getId():Float
	{
		return _id;
	}

	/**
	* Calls begin method of the MaterialAttributes associated with this material.
	*
	* @param p_oScene	The scene.
	*
	* @see sandy.materials.attributes.MaterialAttributes#begin()
	*/
	public function begin( p_oScene:Scene3D ):Void
	{
		if (lastBegin != p_oScene.frameCount) {
			if( attributes != null )
				attributes.begin( p_oScene );
			lastBegin = p_oScene.frameCount;
		}
	}

	/**
	* Calls finish method of the MaterialAttributes associated with this material.
	*
	* @param p_oScene	The scene.
	*
	* @see sandy.materials.attributes.MaterialAttributes#finish()
	*/
	public function finish( p_oScene:Scene3D ):Void
	{
		if (lastFinish != p_oScene.frameCount) {
			if( attributes != null )
				attributes.finish(p_oScene );
			lastFinish = p_oScene.frameCount;
		}
		// --
		m_bModified = false;
	}

	/**
	* Renders the polygon dress in this material.
	*
	* <p>Implemented by sub classes.</p>
	*
	* @see sandy.core.Scene3D
	* @see sandy.core.data.Polygon
	*/
	public function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):Void
	{
		if( attributes != null )
			attributes.draw( p_mcContainer.graphics, p_oPolygon, this, p_oScene ) ;
		// --
		if( _filters != null && _filters.length > 0 )
			p_mcContainer.filters = _filters;
	}

	/**
	* Renders the sprite dress in this material.
	*
	* <p>Basically only needed to apply attributes to sprites</p>
	*
	* @see sandy.core.scenegraph.Sprite2D
	* @see sandy.core.Scene3D
	*/
	public function renderSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		if( attributes != null )
		{
			attributes.drawOnSprite( p_oSprite, p_oMaterial, p_oScene );
		}
		// --
		if( _filters != null && _filters.length > 0 )
			p_oSprite.content.filters = _filters;
	}

	/**
	* Calls init method of the MaterialAttributes associated with this material.
	*
	* @see sandy.materials.attributes.MaterialAttributes#init()
	*/
	public function init( p_oPolygon:Polygon ):Void
	{
		if( !m_oPolygonMap.exists(p_oPolygon.id) )
		{
			m_oPolygonMap.set(p_oPolygon.id, 1);
			m_nRefCounting ++;
			if( attributes != null )
				attributes.init( p_oPolygon );
		}
		else
		{
			m_oPolygonMap.set(p_oPolygon.id, m_oPolygonMap.get(p_oPolygon.id) + 1);
		}
	}

	/**
	* Calls unlink method of the MaterialAttributes associated with this material.
	*
	* @see sandy.materials.attributes.MaterialAttributes#unlink()
	*/
	public function unlink( p_oPolygon:Polygon ):Void
	{
			if( !m_oPolygonMap.exists(p_oPolygon.id) )
			{
				m_oPolygonMap.set( p_oPolygon.id, m_oPolygonMap.get(p_oPolygon.id) - 1 );
				if( m_oPolygonMap.get(p_oPolygon.id) == 0 )
				{
					m_oPolygonMap.remove(p_oPolygon.id);
					m_nRefCounting --;
					if( attributes != null )
						attributes.unlink( p_oPolygon );
				}
			}
			//
			if( autoDispose && m_nRefCounting <= 0 )
			{
				dispose();
			}
	}

	/**
	 * Unlink all the non used polygons
	 */
	public function unlinkAll():haxe.FastList<Polygon>
	{
		var l_aUnlinked:haxe.FastList<Polygon> = new haxe.FastList<Polygon>();
		var l_oApp:Appearance;
		var l_oPoly:Polygon;
		for( l_sLabel in m_oPolygonMap )
		{
			l_oPoly = Polygon.POLYGON_MAP.get( l_sLabel );
			if (l_oPoly == null) continue;
			l_oApp = l_oPoly.appearance;
			if( l_oApp.frontMaterial == this || l_oApp.backMaterial == this )
			{
				unlink(l_oPoly);
				l_aUnlinked.add( l_oPoly );
			}
		}
		return l_aUnlinked;
	}


	/**
	* The material type of this material.
	*
	* @default MaterialType.NONE
	*
	* @see MaterialType
	*/
	public var type(__getType,null):MaterialType;
	private function __getType():MaterialType
	{
		return m_oType;
	}

	/**
	* The array of filters for this material.
	*
	* <p>You use this property to add an array of filters you want to apply to this material<br>
	* To remove the filters, just assign an empty array.</p>
	*/
	private function __setFilters( a:Array<BitmapFilter> ):Array<BitmapFilter>
	{
		if( a != _filters) {
			_filters = a;
			m_bModified = true;
		}
		return a;
	}

	/**
	* Contains specific material flags.
	*/
	public var flags(__getFlags,null):Int;
	public function __getFlags():Int
	{
		var l_nFlags:Int = m_nFlags;
		if( attributes != null )
			l_nFlags |= attributes.flags;
		return l_nFlags;
	}
	/**
	* The array of filters for this material.
	*
	* <p>You use this property to add an array of filters you want to apply to this material<br>
	* To remove the filters, just assign an empty array.</p>
	*/
	public var filters(__getFilters,__setFilters):Array<BitmapFilter>;
	public function __getFilters():Array<BitmapFilter>
	{
		return _filters;
	}

	/**
	* The modified state of this material.
	*
	* <p>true if this material or its line attributes were modified since last rendered, false otherwise.</p>
	*/
	public var modified(__getModified,null):Bool;
	private function __getModified():Bool
	{
		return (m_bModified);// && ((lineAttributes) ? lineAttributes.modified : true));
	}

	/**
	* The repeat property.
	*
	* This affects the way textured materials are mapped for U or V out of 0-1 range.
	*/
	public var repeat:Bool;

	//////////////////
	// PROPERTIES
	//////////////////
	/**
	* DO NOT TOUCH THIS PROPERTY UNLESS YOU PERFECTLY KNOW WHAT YOU ARE DOING.
	* this flag property contains the specific material flags.
	*/
	private var m_nFlags:Int;
	private var m_bModified:Bool;
	private var lastBegin:Int;
	private var lastFinish:Int;
	private var _useLight : Bool;
	private var m_oType:MaterialType;
	private var _filters:Array<BitmapFilter>;
	private var _id:Float;
	private static var _ID_:Float = 0;

	//private static var create:Bool;
}

