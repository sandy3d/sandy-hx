/*
# ***** BEGIN LICENSE BLOCK *****
Copyright the original author or authors.
Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
	http://www.mozilla.org/MPL/MPL-1.1.html
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# ***** END LICENSE BLOCK *****
*/

package sandy.events;

import flash.events.Event;
import sandy.util.LoaderQueue;

/**
 * Conatains events use for loading resources.
 *
 *
 * @author 		Russell Weir - haXe port
 * @see sandy.util.LoaderQueue
 * @see BubbleEventBroadcaster
 */
class QueueEvent extends Event
{
	private var _loaders:Hash<QueueElement>;

	/**
	* Defines the value of the <code>type</code> property of a <code>queueComplete</code> event object.
	*
	* @eventType queueComplete
	*/
	public static var QUEUE_COMPLETE:String = "queueComplete";

	/**
	* Defines the value of the <code>type</code> property of a <code>queueResourceLoaded</code> event object.
	*
	* @eventType queueResourceLoaded
	*/
	public static var QUEUE_RESOURCE_LOADED:String = "queueResourceLoaded";

	/**
	* Defines the value of the <code>type</code> property of a <code>queueLoaderError</code> event object.
	*
	* @eventType queueLoaderError
	*/
	public static var QUEUE_LOADER_ERROR:String = "queueLoaderError";




 	/**
	 * Constructor.
	 *
	 * @param type The event type; indicates the action that caused the event.
	 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
	 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
     */
	public function new(type:String, ?bubbles:Bool=false, ?cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
		_loaders = loaders;
	}

    /**
     * Someone care to explain?
     */
	public var loaders(__getLoaders,__setLoaders):Hash<QueueElement>;
	private function __getLoaders():Hash<QueueElement>
	{
		return _loaders;
	}

	/**
	 * @private
	 */
	private function __setLoaders(loaderObject:Hash<QueueElement>):Hash<QueueElement>
	{
		_loaders = loaderObject;
		return loaderObject;
	}

	/**
	 * @private
	 */
	override public function clone():Event
    {
    	var e:QueueEvent = new QueueEvent(type, bubbles, cancelable);
    	e.loaders = _loaders;
        return e;
    }
}

