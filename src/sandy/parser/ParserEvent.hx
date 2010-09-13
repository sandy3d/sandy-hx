
package sandy.parser;

import flash.events.Event;

import sandy.core.scenegraph.Group;

import sandy.HaxeTypes;

/**
* Events that are used by the parser classes.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		16.03.2007
**/

class ParserEvent extends Event
{
	/**
	* Defines the value of the <code>type</code> property of a <code>onFailEVENT</code> event object.
	*
	* @eventType onFailEVENT
	*/
    static public var FAIL:String = 'onFailEVENT';

	/**
	* Defines the value of the <code>type</code> property of a <code>onInitEVENT</code> event object.
	*
	* @eventType onInitEVENT
	*/
    static public var INIT:String = 'onInitEVENT';

	/**
	* Defines the value of the <code>type</code> property of a <code>onLoadEVENT</code> event object.
	*
	* @eventType onLoadEVENT
	*/
    static public var LOAD:String = 'onLoadEVENT';

	/**
	* Defines the value of the <code>type</code> property of a <code>onProgressEVENT</code> event object.
	*
	* @eventType onProgressEVENT
	*/
	public static var PROGRESS:String = 'onProgressEVENT';

	/**
	* Defines the value of the <code>type</code> property of a <code>onParsingEVENT</code> event object.
	*
	* @eventType onParsingEVENT
	*/
	public static var PARSING:String = 'onParsingEVENT';

	/**
	* The percent of the loading that is complete.
	*/
	public var percent:Float;

	/**
	* The group the object will be assigned to.
	*/
	public var group:Group;

	/**
	 * The ParserEvent constructor
	 *
	 * @param p_sType		The event type string
	 */
	public function new( p_sType:String )
	{
		super( p_sType );
	}
}

