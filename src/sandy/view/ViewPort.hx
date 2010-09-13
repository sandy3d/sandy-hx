
package sandy.view;

import flash.geom.Point;

import sandy.HaxeTypes;

/**
* The view port represents the rendered screen.
*
* <p>This is the area where the view of the camera is projected.<br/>
* It may be the whole or only a part of the stage</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		James Dahl - optimization with bitwise and int type.
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class ViewPort
{

	/**
	* Offset to change the viewport center.
	* For example, if you set myCamera.viewport.offset.y to 100, everything drawn at the screen will be moved 100 pixels down (due to Flash vertical axis convention).
	*/
	public var offset:Point;

	/**
	* Flag which specifies if the viewport dimension has changed
	*/
	public var hasChanged:Bool;

	/**
	* Creates a new ViewPort.
	*
	* @param p_nW 	The width of the rendered screen
	* @param p_nH 	The height of the rendered screen
	**/
	public function new ( p_nW:Int, p_nH:Int )
	{
		offset = new Point();
		hasChanged = false;
		m_nW = 0;
		m_nW2 = 0;
		m_nH = 0;
		m_nH2 = 0;
		m_nRatio = 0.0;

		width = p_nW;
		height = p_nH;
	}

	/**
	* Updates the view port
	*/
	public function update():Void
	{
		m_nW2 = m_nW / 2;
		m_nH2 = m_nH / 2;
		// --
		m_nRatio = (m_nH != 0)? m_nW / m_nH : 0;
		// --
		hasChanged = true;
	}


	public var width(__getWidth,__setWidth):Int;
	public function __getWidth():Int { return m_nW; }
	public var height(__getHeight,__setHeight):Int;
	public function __getHeight():Int { return m_nH; }
	public var width2(__getWidth2,null):Float;
	public function __getWidth2():Float { return m_nW2; }
	public var height2(__getHeight2,null):Float;
	public function __getHeight2():Float { return m_nH2; }
	public var ratio(__getRatio,null):Float;
	public function __getRatio():Float { return m_nRatio; }

	private function __setWidth( p_nValue:Int ):Int { m_nW = p_nValue; update(); return p_nValue; }
	private function __setHeight( p_nValue:Int ):Int { m_nH = p_nValue; update(); return p_nValue; }


	private var m_nW:Int;
	private var m_nW2:Float;
	private var m_nH:Int;
	private var m_nH2:Float;
	private var m_nRatio:Float;
}

