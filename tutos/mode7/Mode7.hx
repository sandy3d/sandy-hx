import flash.display.Sprite;
import flash.display.Shape;
import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display.StageQuality;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.Lib;

import sandy.core.scenegraph.mode7.CameraMode7;
import sandy.core.Scene3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.mode7.Mode7;

import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.Sphere;

class Mode7 extends Sprite
{
	private static inline var _framerate:Int = 30;
	private static inline var _surfaceWidth:Int = 800;
	private static inline var _surfaceHeight:Int = 400;
	private var _mainSurface:Sprite;
	private var _3dSurface:Sprite;
	private var _rootScene:Group;
	private var _3dScene:Scene3D;
	private var _camera:CameraMode7;
	private var _mode7Surface:Shape;
	private var _mode7:sandy.core.scenegraph.mode7.Mode7;
	
	// keys and buttons pressed
	private var _upPush:Int;
	private var _downPush:Int;
	private var _leftPush:Int;
	private var _rightPush:Int;
	
	public function new ()
	{
		super ();
		// stage init
		var stage = Lib.current.stage;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.frameRate = Math.round(_framerate * 1.3);
		stage.quality = StageQuality.HIGH;

		// main surface
		_mainSurface = new Sprite();
		addChild (_mainSurface);
		_mainSurface.scrollRect = new Rectangle(0,0,_surfaceWidth,_surfaceHeight);

		////// we init the 3D
		_3dSurface = new Sprite();
		_mainSurface.addChild (_3dSurface);
		_rootScene = new Group("root");
		// note the special mode7 camera
		_camera = new CameraMode7(_surfaceWidth,_surfaceHeight);
		_camera.x = 0;
		_camera.y = 100;
		_camera.z = 0;
		_camera.tilt = 20;
		_3dScene = new Scene3D("scene",_3dSurface,_camera,_rootScene);
		_rootScene.addChild (_camera);
		_mode7 = new sandy.core.scenegraph.mode7.Mode7();
		var l_oTexture:BitmapData = new GroundTextureMap (0, 0);
		_mode7.setBitmap ( l_oTexture );
		_mode7.setHorizon (true, 0x000000, 1);
		_mode7.setNearFar (true);
		_rootScene.addChild( _mode7 );
		_mode7.repeatMap = false;

		var s:Sphere = new Sphere ("sphere", 50);
		s.appearance = new Appearance ( new BitmapMaterial (l_oTexture) );
		_rootScene.addChild( s ); s.y =  50;
		//////
		// init some variables
		_upPush = 0;
		_downPush = 0;
		_leftPush = 0;
		_rightPush = 0;

		// add listeners
		//stage.addEventListener (Event.RESIZE, onResize);
		stage.addEventListener (Event.ENTER_FRAME, onEnterFrameHandler);

		stage.addEventListener (KeyboardEvent.KEY_DOWN, onKey);
		stage.addEventListener (KeyboardEvent.KEY_UP, onKey);

		// ask for a resize
		var l_oEvt = new Event( Event.RESIZE );
		onResize ();

		//Lib.current.stage.addChild(this);
		//Lib.current.stage.addChild(_mainSurface);
		Lib.current.stage.addChild(_3dSurface);

	}

	// private functions //

	// events callbacks //

	private function onResize ():Void
	{
		trace( "foo" );
		var stage = Lib.current.stage;
		_mainSurface.x = Math.round((stage.stageWidth - _surfaceWidth) / 2);
		_mainSurface.y = Math.round((stage.stageHeight - _surfaceHeight) / 2);
	}

	private function onEnterFrameHandler (evt:Event):Void
	{
		cast(_3dScene.root.getChildByName("sphere"), Shape3D).rotateY ++;
		_camera.rotateY += (_leftPush - _rightPush) * 2;
		var rotationRadian:Float=Math.PI*_camera.rotateY/180;
		_camera.x += Math.sin(- rotationRadian) * (_upPush - _downPush) * 8;
		_camera.z += Math.cos(- rotationRadian) * (_upPush - _downPush) * 8;
		_3dScene.render ();
	}

	private function onKey (kEvt:KeyboardEvent):Void
	{
		if (kEvt.type==KeyboardEvent.KEY_DOWN)
		{
			if (kEvt.keyCode==Keyboard.UP)
			{
				_upPush=1;
			}
			else if (kEvt.keyCode == Keyboard.DOWN)
			{
				_downPush=1;
			}
			else if (kEvt.keyCode == Keyboard.LEFT)
			{
				_leftPush=1;
			}
			else if (kEvt.keyCode == Keyboard.RIGHT)
			{
				_rightPush=1;
			}
		}
		else if (kEvt.type == KeyboardEvent.KEY_UP)
		{
			if (kEvt.keyCode==Keyboard.UP)
			{
				_upPush=0;
			}
			else if (kEvt.keyCode == Keyboard.DOWN)
			{
				_downPush=0;
			}
			else if (kEvt.keyCode == Keyboard.LEFT)
			{
				_leftPush=0;
			}
			else if (kEvt.keyCode == Keyboard.RIGHT)
			{
				_rightPush=0;
			}
		}
	}

	static function main() {
			new Mode7();
	}
}


class GroundTextureMap extends flash.display.BitmapData {
		public function new (a,b) {
				super(a,b);
		}
}

