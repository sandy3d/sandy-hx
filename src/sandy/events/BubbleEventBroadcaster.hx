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

import Type;

/**
 * BubbleEventBroadcaster defines a custom event broadcaster to work with.
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		Niel Drummond - haXe port
 * @author		Russell Weir - haXe port
 * @version		3.1
 */
class BubbleEventBroadcaster extends EventBroadcaster
{
	private var m_oParent:BubbleEventBroadcaster;

	private var m_oTarget:Dynamic;

 	/**
	 * Constructor.
     */
	public function new(p_oTarget:Dynamic)
	{
		super();
		m_oTarget = p_oTarget;
	}

	/**
	 * Starts receiving bubble events from passed-in child.
	 *
	 * @param child	A BubbleEventBroadcaster instance that will send bubble events.
	 */
	public function addChild(child:BubbleEventBroadcaster):Void
	{
		child.parent = this;
	}

	/**
	 * Stops receiving bubble events from passed-in child.
	 * FIXME : This method has very bad implementation and disabled for the moment
	 *
	 * @param child	A BubbleEventBroadcaster instance that will stop sending bubble events.
	 */
	public function removeChild(child:BubbleEventBroadcaster):Void
	{
		//child.parent = null;
	}

	public var parent(__getParent,__setParent):BubbleEventBroadcaster;
	private function __getParent():BubbleEventBroadcaster
	{
		return m_oParent;
	}

	/**
	 * @private
	 */
	private function __setParent(pEB:BubbleEventBroadcaster):BubbleEventBroadcaster
	{
		m_oParent = pEB;
		return pEB;
	}

	/**
	 * @private
	 */
	public override function dispatchEvent(e:Event):Bool
	{
		switch ( Type.typeof( e ) ) {
			case TClass( BubbleEvent ):
				super.dispatchEvent(e);

				if (parent != null)
				{
					parent.dispatchEvent(e);
				}
			default:
				super.dispatchEvent(e); // used for regular event dispatching
		}
		return true;
	}

}

