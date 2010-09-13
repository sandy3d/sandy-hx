
package sandy.events;

import flash.events.Event;

/**
* BubbleEvent defines a custom event type to work with.
*
* @author		Thomas Pfeiffer
* @author		Niel Drummond - haXe port
* @author		Russell Weir
* @version		3.1
*
* @see BubbleEventBroadcaster
*/
class BubbleEvent extends Event
{
	/**
	* Additional information that may be passed by the event
	**/
	public var info(default,null) : Dynamic;
	/**
	 * The event target.
	 */
	public var object(__getObject,null):Dynamic;

	private var m_oTarget:Dynamic;

	/**
	* Creates a new BubbleEvent instance.
	*
	* @example
	* <listing version="3.1">
	*   var e:BubbleEvent = new BubbleEvent(MyClass.onSomething, this);
	* </listing>
	*
	* @param e		A name for the event.
	* @param oT	The event target.
	* @param info
	*/
	public function new(e:String, oT:Dynamic, p_Info=null)
	{
		super(e, true, true);
		this.m_oTarget = oT;
		this.info = p_Info;
	}

	private function __getObject():Dynamic
	{
		return m_oTarget;
	}

	/**
	 * Returns the string representation of this instance.
	 *
	 * @return String representation of this instance
	 */
	public override function toString():String
	{
		return "BubbleEvent";
	}
}

