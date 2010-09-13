
package sandy.events;

import flash.events.Event;

/**
* Conatains custom Sandy events.
*
* @author	Dennis Ippel
* @author	Niel Drummond - haXe port
* @author	Russell Weir - haXe port
* @version		3.1
*
* @see BubbleEventBroadcaster
*/
class SandyEvent extends Event
{
	/**
	* Defines the value of the <code>type</code> property of a <code>lightAdded</code> event object.
	*
	* @eventType lightAdded
	*
	* @see sandy.core.Scene3D
	*/
	public static inline var LIGHT_ADDED:String = "lightAdded";

	/**
	* Defines the value of the <code>type</code> property of a <code>lightUpdated</code> event object.
	*
	* @eventType lightUpdated
	*
	* @see sandy.core.light.Light3D
	*/
	public static inline var LIGHT_UPDATED:String = "lightUpdated";

	/**
	* Defines the value of the <code>type</code> property of a <code>lightColorChanged</code> event object.
	*
	* @eventType lightColorChanged
	*
	* @see sandy.core.light.Light3D
	*/
	public static inline var LIGHT_COLOR_CHANGED:String = "lightColorChanged";

	/**
	* Defines the value of the <code>type</code> property of a <code>scene_render</code> event object.
	*
	* @eventType scene_render
	*
	* @see sandy.core.Scene3D
	*/
	public static inline var SCENE_RENDER:String = "scene_render";

	/**
	* Defines the value of the <code>type</code> property of a <code>scene_render_finish</code> event object.
	*
	* @eventType scene_render_finish
	*
	* @see sandy.core.Scene3D
	*/
	public static inline var SCENE_RENDER_FINISH:String = "scene_render_finish";

    /**
     * Indicates the scene has been culled.
     *
     * @eventType scene_cull
     *
     * @see sandy.core.Scene3D
     */
	public static inline var SCENE_CULL:String = "scene_cull";

    /**
     * Indicates the scene has been updated.
     *
     * @eventType scene_update
     *
     * @see sandy.core.Scene3D
     */
	public static inline var SCENE_UPDATE:String = "scene_update";

    /**
     * Indicates the display list has been rendered.
     *
     * @eventType scene_render_display_list
     *
     * @see sandy.core.Scene3D
     */
	public static inline var SCENE_RENDER_DISPLAYLIST:String = "scene_render_display_list";

	/**
	* Defines the value of the <code>type</code> property of a <code>containerCreated</code> event object.
	* Not in use?
	*
	* @eventType containerCreated
	*
	* @see sandy.core.World3D
	*/
	public static inline var CONTAINER_CREATED:String = "containerCreated";

	/**
	* Defines the value of the <code>type</code> property of a <code>queueComplete</code> event object.
	* Deprecated, use QueueEvent.QUEUE_COMPLETE instead.
	*
	* @eventType queueComplete
	*
	* @see sandy.util.LoaderQueue
	*/
	public static inline var QUEUE_COMPLETE:String = "queueComplete";

	/**
	* Defines the value of the <code>type</code> property of a <code>queueLoaderError</code> event object.
	* Deprecated, use QueueEvent.QUEUE_LOADER_ERROR instead.
	*
	* @eventType queueLoaderError
	*
	* @see sandy.util.LoaderQueue
	*/
	public static inline var QUEUE_LOADER_ERROR:String = "queueLoaderError";

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
	}

	/**
	 * @private
	 */
	override public function clone():Event
    {
        return new SandyEvent(type, bubbles, cancelable);
    }
}

