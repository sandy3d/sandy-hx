import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Sprite3D;
import sandy.events.QueueEvent;
import sandy.events.SandyEvent;
import sandy.util.LoaderQueue;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLRequest;
import flash.Lib;
import flash.ui.Keyboard;

class Airplane extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var queue:LoaderQueue;
		var s:Sprite3D;

		public function new () { 
				super(); 

				queue = new LoaderQueue();
				queue.add( "plane", new URLRequest("../assets/plane/plane.swf") );
				queue.addEventListener( SandyEvent.QUEUE_COMPLETE, loadComplete );
				queue.start();

				Lib.current.stage.addChild(this);
		}

		public function loadComplete( event:QueueEvent ):Void {  
				camera = new Camera3D( 500, 300 );
				camera.y = 10;
				camera.z = -300;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );
				scene.rectClipping = true;

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);

		}

		function createScene():Group {

				var g:Group = new Group();

				s = new Sprite3D( "plane", queue.data.get( "plane" ), 2 );
				s.rotateY = 90;
				s.x = 0;
				s.z = 0;
				s.y = 0;
				g.addChild( s );

				return g;
		}

		function enterFrameHandler( event:Event ):Void {

				if ( s.rotateY == 0 ) s.rotateY = 0.1;
				if ( s.x > 220 && s.z < 0 ) s.x = -220;
				else if ( s.x < -220 && s.z < 0 ) s.x = 220;
				else if ( s.z < -250 ) s.z = 1000; 

				s.moveForward(-7);

				scene.render();
		}

		function keyPressedHandler( event:KeyboardEvent ):Void {
				if ( event.keyCode == Keyboard.RIGHT ) s.rotateY -= 5; // KEY_RIGHT
				if ( event.keyCode == Keyboard.LEFT ) s.rotateY += 5; // KEY_LEFT
		}

		static function main() {
			#if cpp
				nme.Lib.create(function(){
					new Airplane();
				},400,300,24,0xFFFFFF,nme.Lib.RESIZABLE);
			#else
				new Airplane();
			#end
		}
}


