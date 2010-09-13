
package sandy.events;

import flash.events.Event;
import flash.events.EventDispatcher;

/**
* The event broadcaster of Sandy.
*
* @author		Russell Weir - haXe port
* @version		3.1
*/
class EventBroadcaster extends EventDispatcher
{
	public function new()
	{
		super();
	}

	override public function dispatchEvent(evt:Event):Bool
	{
		if (hasEventListener(evt.type) || evt.bubbles)
		{
			return super.dispatchEvent(evt);
		}
		return true;
	}
}
