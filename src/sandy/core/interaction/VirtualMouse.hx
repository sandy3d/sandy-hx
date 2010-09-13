

package sandy.core.interaction;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
#if flash
import flash.display.SimpleButton;
#end
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import sandy.core.data.Polygon;
import sandy.core.data.UVCoord;
import sandy.materials.MovieMaterial;
import sandy.util.ArrayUtil;

import sandy.HaxeTypes;

/**
 * VirtualMouse interacting with MovieMaterial
 * Based on the VirtualMouse by senocular
 *
 * @author		Xavier MARTIN - zeflasher - http://dev.webbymx.net
 * @author		Thomas PFEIFFER - kiroukou
 * @author Niel Drummond - haXe port
 *
 *
 */
class VirtualMouse extends EventDispatcher
{
	private static var _oI		: VirtualMouse;

//	target
	private var m_ioTarget		: Sprite;
//	old target
	private var m_ioOldTarget	: Sprite;
	private var location		: Point;
	private var lastLocation	: Point;
	private var lastWithinStage	: Bool;
	private var _lastEvent		: Event;
	private var lastDownTarget:InteractiveObject;

	private var m_oPreviousTargets : Array<InteractiveObject>;
	private var m_oCurrentTargets : Array<InteractiveObject>;
/* ****************************************************************************
* CONSTRUCTOR
**************************************************************************** */
	public function new( access : PrivateConstructorAccess )
	{
		lastWithinStage	= true;
		m_oPreviousTargets = new Array();
		m_oCurrentTargets = new Array();
		super();
		location = new Point(0, 0);
		lastLocation = location.clone();
	}

	public static function getInstance() : VirtualMouse
	{
		if ( _oI == null ) _oI = new VirtualMouse( new PrivateConstructorAccess() );
		return _oI;
	}

/* ****************************************************************************
* PUBLIC FUNCTION
**************************************************************************** */
	public function interactWithTexture(  p_oPoly : Polygon, p_uvTexture : UVCoord, p_event : MouseEvent ) : Void
	{
		var currentTarget:Sprite = null;
		var targetLocal:Point = null;
		// -- recuperation du material applique sur le polygone
		var l_oMaterial:MovieMaterial = null;
		try {
			l_oMaterial = p_oPoly.visible ? cast p_oPoly.appearance.frontMaterial : cast p_oPoly.appearance.backMaterial;
		} catch (e:Dynamic ) {
			return;
		}
		if( l_oMaterial == null ) return;

		m_ioTarget = l_oMaterial.movie;
		location = new Point( p_uvTexture.u * l_oMaterial.texture.width, p_uvTexture.v * l_oMaterial.texture.height );

		if( p_event.type == MouseEvent.MOUSE_OUT )
		{
			targetLocal = p_oPoly.container.globalToLocal(location);
			if( m_ioOldTarget != null )
			{
				// off of last target
				_lastEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false, targetLocal.x, targetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				m_ioOldTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
				// rolls do not propagate
				_lastEvent = new MouseEvent(MouseEvent.ROLL_OUT, false, false, targetLocal.x, targetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				m_ioOldTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);

				m_ioOldTarget = null;
			}
			return;
		}
		// go through each objectsUnderPoint checking:
		//		1) is not ignored
		//		2) is InteractiveObject
		//		3) mouseEnabled
		var objectsUnderPoint:Array<DisplayObject> = m_ioTarget.getObjectsUnderPoint( m_ioTarget.localToGlobal( location ) );
		var currentParent:DisplayObject = null;

		var i:Int = objectsUnderPoint.length;
		while ( --i > -1 )
		{
			currentParent = objectsUnderPoint[i];

			// go through parent hierarchy
			while (currentParent != null)
			{
				// invalid target if in a SimpleButton
#if flash
				if (currentTarget != null && Std.is(currentParent, SimpleButton))
				{
					currentTarget = null;
					// next parent in hierarchy
					currentParent = currentParent.parent;
					continue;

				// invalid target if a parent has a
				// false mouseChildren
				} else
#end
				if ( currentTarget != null && Std.is(currentParent, DisplayObjectContainer) && !cast(currentParent, DisplayObjectContainer).mouseChildren )
				{
					currentTarget = null;
					// next parent in hierarchy
					currentParent = currentParent.parent;
					continue;
				}

				// define target if an InteractiveObject
				// and mouseEnabled is true
				if (currentTarget == null && Std.is(currentParent, DisplayObjectContainer) && cast(currentParent, DisplayObjectContainer).mouseEnabled)
				{
					currentTarget = cast( currentParent, Sprite );
				}

				// if a currentTarget was not found
				// the currentTarget is the texture

				if (currentTarget == null)
				{
					// next parent in hierarchy
					currentParent = currentParent.parent;
					continue;
					//currentTarget = m_ioTarget;
				}

				m_oCurrentTargets.push( currentTarget );
				//if ( !m_ioOldTarget ) m_ioOldTarget = currentTarget.stage as Sprite;
					//currentTarget.stage as Sprite;

				//	if the target is a textfield
				/*	if ( currentTarget is TextField )
				{
					_checkLinks( currentTarget as TextField );
					return;
				}*/

				// get local coordinate locations
				targetLocal = p_oPoly.container.globalToLocal(location);
				var currentTargetLocal:Point = currentTarget.globalToLocal(location);

				// move event
				if (lastLocation.x != location.x || lastLocation.y != location.y)
				{
					var withinStage:Bool = (location.x >= 0 && location.y >= 0 && location.x <= p_oPoly.container.stage.stageWidth && location.y <= p_oPoly.container.stage.stageHeight);
					// mouse leave if left stage
					if ( !withinStage && lastWithinStage )
					{
						_lastEvent = new MouseEvent(Event.MOUSE_LEAVE, false, false);
						p_oPoly.container.stage.dispatchEvent(_lastEvent);
						dispatchEvent(_lastEvent);
					}
					// only mouse move if within stage
					if ( withinStage )
					{
						//_lastEvent = new MouseEvent( MouseEvent.MOUSE_MOVE, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta );
						_lastEvent = new MouseEvent(Event.MOUSE_LEAVE, false, false);
						currentTarget.dispatchEvent(_lastEvent);
						dispatchEvent(_lastEvent);
					}

					// remember if within stage
					lastWithinStage = withinStage;
				}

				// si la frame d'avant on etait pas sur cet object
				if( ArrayUtil.indexOf( m_oPreviousTargets, currentTarget ) == -1 )
				{
					// on to current target
					_lastEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true, false, currentTargetLocal.x, currentTargetLocal.y, m_ioOldTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
					// rolls do not propagate
					_lastEvent = new MouseEvent( MouseEvent.ROLL_OVER, false, false, currentTargetLocal.x, currentTargetLocal.y, m_ioOldTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				// click/up/down events
				if ( p_event.type == MouseEvent.MOUSE_DOWN )
				{
					_lastEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
					// remember last down
					lastDownTarget = currentTarget;
					// mouse is up
				}
				else if ( p_event.type == MouseEvent.MOUSE_UP )
				{
					_lastEvent = new MouseEvent(MouseEvent.MOUSE_UP, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}
				else if ( p_event.type == MouseEvent.CLICK )
				{
					_lastEvent = new MouseEvent(MouseEvent.CLICK, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
					// clear last down
					lastDownTarget = null;
				}
				else if ( p_event.type == MouseEvent.DOUBLE_CLICK && currentTarget.doubleClickEnabled )
				{
					_lastEvent = new MouseEvent(MouseEvent.DOUBLE_CLICK, true, false, currentTargetLocal.x, currentTargetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
					currentTarget.dispatchEvent(_lastEvent);
					dispatchEvent(_lastEvent);
				}

				// next parent in hierarchy
				currentParent = currentParent.parent;

			}
		}

		// roll/mouse (out and over) events
		var l:Int = m_oPreviousTargets.length;
		for(i in 0...l)
		{
			if( ArrayUtil.indexOf( m_oCurrentTargets, m_oPreviousTargets[i] ) == -1 )
			{
				targetLocal = p_oPoly.container.globalToLocal(location);
				m_ioOldTarget = cast m_oPreviousTargets[i];

				// off of last target
				_lastEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true, false, targetLocal.x, targetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				m_ioOldTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
				// rolls do not propagate
				_lastEvent = new MouseEvent(MouseEvent.ROLL_OUT, false, false, targetLocal.x, targetLocal.y, currentTarget, p_event.ctrlKey, p_event.altKey, p_event.shiftKey, p_event.buttonDown, p_event.delta);
				m_ioOldTarget.dispatchEvent(_lastEvent);
				dispatchEvent(_lastEvent);
			}
		}
		// remember last values
		lastLocation = location.clone();
		//m_ioOldTarget = currentTarget;

		m_oPreviousTargets = m_oCurrentTargets.concat([]);
		m_oCurrentTargets = [];
	}

/* ****************************************************************************
* PRIVATE FUNCTIONS
**************************************************************************** */
	private function _checkLinks( tf : TextField ) : Void
	{
		var currentTargetLocal:Point = tf.globalToLocal(location);
		var a : Array<TextLink> = TextLink.getTextLinks( tf );
		var l : Int = a.length;
			for ( i in 0...l )
			{
				if ( cast( ( cast( a[i], TextLink ) ).getBounds(), Rectangle ).containsPoint( currentTargetLocal ) )
					1+1;
			}
	}

}


class PrivateConstructorAccess { public function new () {} }
