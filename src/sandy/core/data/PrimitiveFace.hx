
package sandy.core.data;

import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;

import sandy.HaxeTypes;

/**
* PrimitiveFace is a tool for generated primitive, allowing users (for some specifics primitives) to get the face polygon array
* to have an easier manipulation.
* @author		Thomas Pfeiffer - kiroukou
* @author		Xavier Martin - zeflasher
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		20.09.2007
**/
class PrimitiveFace
{
	private var m_iPrimitive	: Shape3D;
	private var m_oAppearance	: Appearance;

	/**
	* The array containing the polygon instances own by this primitive face
	*/
	public var aPolygons		: Array<Polygon>;

	/**
	* PrimitiveFace class
	* This class is a tool for the primitives. It will stores all the polygons that are owned by the visible primitive face.
	*
	* @param p_iPrimitive The primitive this face will be linked to
	*/
	public function new( p_iPrimitive:Shape3D )
	{
		aPolygons	= new Array();

		m_iPrimitive = p_iPrimitive;
	}

	public var primitive(__getPrimitive,null):Shape3D;
	private function __getPrimitive():Shape3D
	{
		return m_iPrimitive;
	}

	public function addPolygon( p_oPolyId:Int ):Void
	{
		aPolygons.push( m_iPrimitive.aPolygons[p_oPolyId] );
	}

	/**
	* The appearance of this face.
	*/
	public var appearance(__getAppearance,__setAppearance):Appearance;
	private function __setAppearance( p_oApp:Appearance ):Appearance
	{
		// Now we register to the update event
		m_oAppearance = p_oApp;
		// --
		if( m_iPrimitive.geometry != null )	// ?? is it needed?
		{
			for ( v in aPolygons )
				v.appearance = m_oAppearance;
		}
		return p_oApp;
	}

	private function __getAppearance():Appearance
	{
		return m_oAppearance;
	}
}

