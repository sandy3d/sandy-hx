
package sandy.materials;

import sandy.core.Scene3D;
import sandy.materials.Material;
import sandy.core.data.Polygon;

import sandy.HaxeTypes;

/**
* Represents the appearance property of the visible objects.
*
* <p>The appearance holds the front and back materials of the object.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*
* @see 	sandy.core.scenegraph.Shape3D
*/
class Appearance
{
	/**
	* Creates an appearance with front and back materials.
	*
	* <p>If no material is passed, the default material for back and front is a default ColorMaterial.<br />
	* If only a front material is passed, it will be used as back material as well.</p>
	*
	* @param p_oFront	The front material
	* @param p_oBack	The back material
	*
	* @see sandy.materials.ColorMaterial
	* @see sandy.materials.Material
	*/
	public function new( ?p_oFront:Material, ?p_oBack:Material )
	{
		m_oFrontMaterial = (p_oFront != null) 	? p_oFront :	new ColorMaterial();
		m_oBackMaterial  = (p_oBack != null) 	? p_oBack  :	m_oFrontMaterial;
	}

	/**
	* Return if the light has been enable on one of the 2 material (OR exclusion).
	* @return Boolean true if light is enable on one of the front/back material
	*/
	public var lightingEnable(__getLightingEnable,__setLightingEnable):Bool;
	private function __getLightingEnable():Bool
	{
		return m_oFrontMaterial.lightingEnable || m_oBackMaterial.lightingEnable;
	}

	/**
	* Enable/Disable the light on the front and back materials on that appearance object
	* @param p_bValue Boolean true to enable light effect on materials, false value to disable it.
	*/
	private function __setLightingEnable( p_bValue:Bool ):Bool
	{
		m_oFrontMaterial.lightingEnable = p_bValue;
		if( m_oFrontMaterial != m_oBackMaterial )
			m_oBackMaterial.lightingEnable = p_bValue;
		return p_bValue;
	}

	/**
	* Get the use of vertex normal feature of the appearance.
	*
	* <p><b>Note: Only one of the materials is using this feature.</p>
	*/
	public var useVertexNormal(__getUseVertexNormal,null):Bool;
	private function __getUseVertexNormal():Bool
	{
		return (m_oBackMaterial.useVertexNormal && m_oFrontMaterial.useVertexNormal );
	}


	/**
	* @private
	*/
	private function __setFrontMaterial( p_oMat:Material ):Material
	{
		if( m_oFrontMaterial == p_oMat ) return null;
		// --
		var l_aUnLinked:haxe.FastList<Polygon> = new haxe.FastList<Polygon>();
		if( m_oFrontMaterial != null )
			l_aUnLinked = m_oFrontMaterial.unlinkAll();
		// --
		m_oFrontMaterial = p_oMat;
		if( m_oFrontMaterial == null ) return null;
		// --
		for ( l_oPoly in l_aUnLinked )
		{
			m_oFrontMaterial.init(l_oPoly);
		}
		if( m_oBackMaterial == null )
		{
			m_oBackMaterial = p_oMat;
		}
		return p_oMat;
	}

	/**
		* Dispose the front and back materials.
		* Be careful, this may affect the other shapes that are using the same appearance or materials.
		* References to front and back materials are set to null.
		*/
	public function dispose() : Void
	{
		var l_oPoly:Polygon;
		var l_aUnLinked:haxe.FastList<Polygon>;
		// --
		if( m_oFrontMaterial != null )
		{
			l_aUnLinked = m_oFrontMaterial.unlinkAll();
			for( l_oPoly in l_aUnLinked )
			{
				if( l_oPoly.appearance != null )
					l_oPoly.appearance = null;
			}
			if (m_oFrontMaterial.autoDispose)
				m_oFrontMaterial.dispose();
			l_aUnLinked = null;
		}

		if( m_oFrontMaterial != m_oBackMaterial )
		{
			l_aUnLinked = m_oBackMaterial.unlinkAll();
			for( l_oPoly in l_aUnLinked )
			{
				if( l_oPoly.appearance != null )
					l_oPoly.appearance = null;
			}
			if (m_oBackMaterial.autoDispose)
				m_oBackMaterial.dispose();
			l_aUnLinked = null;
		}
		// --
		m_oFrontMaterial = null;
		m_oBackMaterial = null;
	}

	/**
	* @private
	*/
	private function __setBackMaterial( p_oMat:Material ):Material
	{
		if( m_oBackMaterial == p_oMat ) return null;
		// --
		var l_aUnLinked:haxe.FastList<Polygon> = new haxe.FastList<Polygon>();
		if( m_oBackMaterial != null )
			l_aUnLinked = m_oBackMaterial.unlinkAll();
		// --
		m_oBackMaterial = p_oMat;
		if( m_oBackMaterial == null ) return null;
		// --
		for ( l_oPoly in l_aUnLinked )
		{
			m_oBackMaterial.init(l_oPoly);
		}
		if( m_oFrontMaterial == null )
		{
			m_oFrontMaterial = p_oMat;
		}
		return p_oMat;
	}

	/**
	* The front material held by this appearance.
	*/
	public var frontMaterial(__getFrontMaterial,__setFrontMaterial):Material;
	private function __getFrontMaterial():Material
	{
		return m_oFrontMaterial;
	}

	/**
	* The back material held by this appearance.
	*/
	public var backMaterial(__getBackMaterial,__setBackMaterial):Material;
	private function __getBackMaterial():Material
	{
		return m_oBackMaterial;
	}

	/**
	* Returns a boolean if the appearance has been modified and needs a redraw.
	* @return Boolean true if one of the material has changed, false otherwise
	*/
	public var modified(__getModified,null) : Bool;
	public function __getModified():Bool
	{
		return m_oFrontMaterial.modified || m_oBackMaterial.modified;
	}

	/**
	* Returns the flags for the front and back materials.
	*
	* @see sandy.core.SandyFlags
	*/
	public var flags(__getFlags,null):Int;
	private function __getFlags():Int
	{
		var l_nFlag:Int = 0;
		// --
		if( m_oFrontMaterial != null )
		{
			l_nFlag =  m_oFrontMaterial.flags;
		}
		if( m_oBackMaterial != null && m_oFrontMaterial != m_oBackMaterial )
		{
			l_nFlag |= m_oBackMaterial.flags;
		}
		return l_nFlag;
	}

	/**
	* Returns a string representation of this object.
	*
	* @return	The fully qualified name of this object.
	*/
	public function toString():String
	{
		return "sandy.materials.Appearance";
	}

	// --
	private var m_oFrontMaterial:Material;
	private var m_oBackMaterial:Material;
}

