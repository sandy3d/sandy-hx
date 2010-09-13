import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Sprite2D;
import sandy.events.QueueEvent;
import sandy.events.SandyEvent;
import sandy.util.LoaderQueue;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.Lib;
import flash.ui.Keyboard;

class Forest extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var queue:LoaderQueue;
		var numTree:Int;

		public function new () { 
				numTree = 50;

				super(); 

				queue = new LoaderQueue();
				queue.add( "tree", new URLRequest("../assets/tree.gif") );
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
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovedHandler);

		}

		function createScene():Group {

				var g:Group = new Group();

				for( i in 0...numTree ) {

						var tree:DisplayObject = queue.data.get( "tree" ); 
						if ( Reflect.hasField( tree, "bitmapData" ) ) {
								var bd = Reflect.field( tree, "bitmapData" );
								var bit:Bitmap = new Bitmap( bd );
								var s:Sprite2D = new Sprite2D( "tree"+i, bit, 1 );
								s.x = Math.random() * 600 - 300;
								s.z = Math.random() * 600;
								s.y = 0;
								g.addChild( s );
						}
				}

				return g;
		}

		function enterFrameHandler( event:Event ):Void {
				scene.render();
		}

		function keyPressedHandler( event:KeyboardEvent ):Void {
				switch( event.keyCode ) {
						case Keyboard.UP: // KEY_UP
								camera.moveForward(5);
						case Keyboard.DOWN: // KEY_DOWN
								camera.moveForward(-5);
				}
		}

		function mouseMovedHandler( event:MouseEvent ):Void {
				camera.pan = ( event.stageX - 300 / 2 ) / 10;
				camera.pan = ( event.stageY - 300 / 2 ) / 20;
		}

		static function main() {
			#if cpp
				nme.Lib.create(function(){
					new Forest();
				},400,300,24,0xFFFFFF,nme.Lib.RESIZABLE);
			#else
				new Forest();
			#end
		}
}

