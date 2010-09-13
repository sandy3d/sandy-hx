package utils;

import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Camera3D;
import sandy.HaxeTypes;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

/**
* A class to add quick
**/
class ObjectTransformer {

	public var camera : Camera3D;

	public var controlObject : ATransformable;
	/** Current mouse move handler is OnEnterFrame (true) or MouseMove event (false) **/
	public var mouseMoveHandlerFrame(default,null) : Bool;

	/** The + and - keys will fire an onControlObjectChage call with this value **/
	public var controlIdx : Int;

	public var tracePositions : Bool;

	public var playerMode : Bool;

	public var lockView : Bool;
	private var enabled : Bool;

	public function new(?p_oControlObj : ATransformable, ?p_oCamera : Camera3D) {
		this.controlObject = p_oControlObj;
		this.lockView = true;
		this.enabled = false;
		this.camera = p_oCamera;
	}

	public function enable() {
		setupEventListeners();
		enabled = true;
	}

	public function disable() {
		removeEventListeners();
		enabled = false;
	}

	/**
		use this method to set the currently controlled object (controlObject) and reset the controlIdx
		if it goes outside your bounds.
	**/
	public dynamic function onControlObjectChage(v:Int) : Void {
	}

	/**
	* Override with a function that tells if controlObject can be controlled by the user. Not needed
	* if controlObject can always be controlled.
	*/
	public dynamic function isControlable(v:ATransformable) : Bool {
		return true;
	}

	/**
	* Called when the "i" key is pressed, for adding an instance
	*/
	public dynamic function onAddInstance() : Void {
	}

	/**
	* Override for when the "m" key is pressed, for toggling perhaps between
	* wireframe material and texture for a model
	**/
	public dynamic function onToggleAppearance() : Void {
	}

	function keyPressedHandler( event:KeyboardEvent ):Void {
		var speed = (event.shiftKey) ? 30.0 : 15.0;

		var o : ATransformable = controlObject;
		if(o == null || !isControlable(o))
			o = null;

		switch( event.keyCode ) {
		case 38: // KEY_UP
			if(o!=null) o.tilt += 2;
		case 40: // KEY_DOWN
			if(o!=null) o.tilt -= 2;
		case 37: // KEY_LEFT
		case 39: // KEY_RIGHT
		case 34: // PAGE_DOWN
			if(o!=null) o.z -=5;
		case 33: // PAGE_UP
			if(o!=null) o.z +=5;
		case "W".code:
			if(o!=null) {
				o.moveForward(speed);
				tracePosition(o);
			}
		case "X".code:
			if(o!=null) {
				o.moveForward(-speed);
				tracePosition(o);
			}
		case "E".code:
			if(o!=null) {
				o.moveUpwards(speed);
				tracePosition(o);
			}
		case "C".code:
			if(o!=null) {
				o.moveUpwards(-speed);
				tracePosition(o);
			}
		case "A".code:
			if(o!=null) {
				o.moveSideways(-speed);
				tracePosition(o);
			}
		case "D".code:
			if(o!=null) {
				o.moveSideways(speed);
				tracePosition(o);
			}
		case "I".code:
			onAddInstance();
		case "M".code:
			onToggleAppearance();
		case "S".code:
			if(camera != null) camera.lookAt(0,0,0);
		case "H".code:
			toggleMouseMoveHandler();
		default:
			switch( event.charCode ) {
			case "+".code:
				controlIdx++;
				onControlObjectChage(controlIdx);
			case "-".code:
				if(controlIdx > 0) {
					controlIdx--;
					onControlObjectChage(controlIdx);
				}
			case "1".code:
				if(camera != null) {
					camera.pan = 0;
					camera.tilt = 0;
					camera.x = 12.463779249610774;
					camera.y = 86.81944937011123;
					camera.z = -341.95501802544277;
					camera.lookAt(0,0,0);
				}
			case "2".code:
				if(camera != null) {
					camera.pan = 0;
					camera.tilt = 0;
					camera.x = -270;
					camera.y = 7500;
					camera.z = 0;
					camera.lookAt(0,0,0);
				}
			case "3".code:
				if(camera != null) {
					camera.pan = 0;
					camera.tilt = 0;
					camera.x = 1259.5276163805672;
					camera.y = 633.7425592323983;
					camera.z = -3730.822307778265;
					camera.lookAt(0,0,0);
				}
			case "4".code:
				if(camera != null) {
					camera.pan = -24.7;
					camera.tilt = 11.4;
					camera.x = 919.226680915148;
					camera.y = 776.6297723599828;
					camera.z = -741.2991679302072;
				}
			default:
			}
		}
	}

	private function toggleMouseMoveHandler() : Void {
		mouseMoveHandlerFrame = !mouseMoveHandlerFrame;
		var flc = flash.Lib.current;

	}

	private function mouseMovedHandler(evt:MouseEvent) : Void {
		updateTiltPan();
		evt.updateAfterEvent();
	}

	private function mouseDownHandler(evt:MouseEvent) : Void {
		lockView = !lockView;
	}

	private function mouseLeaveHandler(evt:Event) : Void {
		if(controlObject.name == "Camera") {
			controlObject.tilt = 0.;
			controlObject.pan = 0.;
		}
	}

	private function onEnterFrame(_) : Void {
		updateTiltPan();
	}

	public dynamic function updateTiltPan() : Void {
		if(lockView)
			return;
		var o : ATransformable = controlObject;
		if(!isControlable(o))
			return;

		var flc = flash.Lib.current;
		var wd2 = flc.stage.stageWidth/2;
		var hd2 = flc.stage.stageHeight/2;
		var max = 190.0;

		if(!playerMode) {
			o.tilt = 0.0;
			o.pan = 0.0;
 			o.pan=(flc.stage.mouseX-wd2)/wd2*max;
			o.tilt=(flc.stage.mouseY-hd2)/hd2*max;
		}
		else {
// 			o.pan = 0.0;
// 			o.rotateX = 0.0;
// 			o.rotateX=(flc.stage.mouseY-hd2)/hd2*max;
//			o.pan=(flc.stage.mouseX-wd2)/wd2*max;

			o.tilt = 0.0;
			o.rotateY = 0.0;
			o.rotateY=-(flc.stage.mouseX-wd2)/wd2*max;
 			o.tilt=(flc.stage.mouseY-hd2)/hd2*max;
		}
    }



	private function setupEventListeners() {
		var stage = flash.Lib.current.stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		setupMouseEventListeners();
	}

	private function removeEventListeners() {
		var stage = flash.Lib.current.stage;
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		removeMouseHandlers();
	}

	private function setupMouseEventListeners() {
		var stage = flash.Lib.current.stage;
		removeMouseHandlers();
		if(mouseMoveHandlerFrame) {
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true );
		} else {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovedHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
		}
	}

	private function removeMouseHandlers() {
		var stage = flash.Lib.current.stage;
		stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMovedHandler);
		stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
	}

	private function tracePosition(o:ATransformable) {
		if(tracePositions)
			trace(o.getPosition(ABSOLUTE));
	}
}