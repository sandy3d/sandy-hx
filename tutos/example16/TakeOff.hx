import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Sprite3D;
import sandy.core.scenegraph.TransformGroup;
import sandy.events.QueueEvent;
import sandy.events.SandyEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.Plane3D;
import sandy.util.LoaderQueue;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.Lib;

import caurina.transitions.Tweener;

class TakeOff extends Sprite 
{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var queue:LoaderQueue;
		private var s:Sprite3D;
		private var tg:TransformGroup;

		private var proxyObj:Dynamic;

		public function new():Void
		{

				super();

				queue = new LoaderQueue();
				queue.add( "plane", new URLRequest("../assets/plane/plane.swf") );
				queue.add( "lane", new URLRequest("../assets/plane/lane.jpg") );
				queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
				queue.start();

				Lib.current.stage.addChild(this);
		}

		public function loadComplete(event:QueueEvent ):Void
		{  
				camera = new Camera3D( 600, 300 );
				camera.y = 10;
				camera.z = -400;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );
				scene.rectClipping = true;
				addEventListener( Event.ENTER_FRAME, enterFrameHandler );

				Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovedHandler);

		}

		private function createScene():Group
		{
				var g:Group = new Group();
				tg = new TransformGroup();

				var lane:Plane3D = new Plane3D( "lane", 800, 300, 5, 5, Plane3D.ZX_ALIGNED );
				var laneMaterial:BitmapMaterial = new BitmapMaterial( Reflect.field( queue.data.get("lane"), 'bitmapData' ) );
				laneMaterial.lightingEnable = true;
				var laneApp:Appearance = new Appearance( laneMaterial );
				lane.enableForcedDepth = true;
				lane.forcedDepth = 9999;
				lane.appearance=laneApp;
				lane.rotateY = 90;
				lane.y = -100;

				s = new Sprite3D("plane",queue.data.get("plane"),1);
				proxyObj = { rotateY:90, x:-300, z:150, y:-80 }
				//s.rotateY = 90;
				//s.x = -300;
				//s.z = 50;
				//s.y = -80;

				tg.addChild(lane);
				tg.addChild(s);
				g.addChild(tg);

				return g;
		}

		private function enterFrameHandler( event : Event ) : Void
		{
				if ( proxyObj != null ) {
						s.rotateY = proxyObj.rotateY;
						s.x = proxyObj.x;
						s.z = proxyObj.z;
						s.y = proxyObj.y;
				}

				scene.render();
		}

		private function keyPressedHandler(event:KeyboardEvent):Void {
				if(event.keyCode == 32) // SPACE
				{
						Tweener.removeAllTweens();
						Tweener.addTween(proxyObj, {x:100, time:3, transition:"linear"});
						Tweener.addTween(proxyObj, {y:400, time:4, delay:3,transition:"linear"});
						Tweener.addTween(proxyObj, {x:700, time:4, delay:3,transition:"linear", onComplete:updatePosition});
						Tweener.addTween(proxyObj, {y:-80, time:4, delay:7,transition:"linear"});
						Tweener.addTween(proxyObj, {x:0, time:4, delay:7,transition:"linear"});
						Tweener.addTween(proxyObj, {x:300, time:3, delay:11,transition:"linear"});
						Tweener.addTween(proxyObj, {rotateY:270, time:3, delay:14,transition:"linear"});
						Tweener.addTween(proxyObj, {x:-300, time:6, delay:17,transition:"linear"});
						Tweener.addTween(proxyObj, {rotateY:90, time:3, delay:23,transition:"linear"});
				}
		}

		public function updatePosition():Void {
				proxyObj.x = -700;
		}	

		private function mouseMovedHandler(event:MouseEvent):Void {
				tg.pan=(event.stageX-600/2)/10;
		}	

		static function main() {
				new TakeOff();
		}
}


