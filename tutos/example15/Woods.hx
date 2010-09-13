import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.Sprite2D;
import sandy.events.QueueEvent;
import sandy.events.SandyEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.Plane3D;
import sandy.util.LoaderQueue;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.Lib;

class Woods extends Sprite 
{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var queue:LoaderQueue;
		private var g:Group;
		private var numTree:Int;

		public function new():Void
		{

				numTree = 50;

				super();

				queue = new LoaderQueue();
				queue.add( "grass", new URLRequest("../assets/grass02.jpg") );
				queue.add( "tree", new URLRequest("../assets/tree.gif") );
				queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
				queue.start();

				Lib.current.stage.addChild(this);
		}

		public function loadComplete(event:QueueEvent ):Void
		{  
				camera = new Camera3D( 500, 300 );
				camera.y = 5;
				camera.z = -100;
				camera.near=20;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );
				scene.rectClipping = false;

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
				Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovedHandler);

		}

		private function createScene():Group
		{
				g = new Group();

				var material:BitmapMaterial = new BitmapMaterial( Reflect.field( queue.data.get("grass"), "bitmapData" ) );
				material.lightingEnable = true;
				var app:Appearance = new Appearance( material );

				var one:Shape3D = new Plane3D('one', 400, 700, 15, 15, 
								Plane3D.ZX_ALIGNED);
				one.appearance = app;
				one.y = -20;

				var two:Shape3D = new Plane3D('two', 400, 700, 15, 15, 
								Plane3D.ZX_ALIGNED);
				two.appearance = app;
				two.y = -20;
				two.z = 400;

				var three:Shape3D = new Plane3D('three', 400, 700, 15, 15, 
								Plane3D.ZX_ALIGNED);
				three.appearance = app;
				three.y = -20;
				three.z = 800;

				g.addChild(one);
				g.addChild(two);
				g.addChild(three);

				for(i in 0...numTree)
				{
						var bit:Bitmap = new Bitmap( Reflect.field( queue.data.get("tree"), "bitmapData" ) );
						var s:Sprite2D = new Sprite2D("tree"+i,bit,1);
						s.x = Math.random()*1200 - 300;
						s.z = Math.random()*1200;
						s.y = 0;
						g.addChild(s);
				}
				return g;
		}

		private function enterFrameHandler( event : Event ) : Void
		{
				for (j in 0...numTree)
				{
						if ( Std.is( g.children[j], Sprite2D ) ) {

								var sprit : Sprite2D = untyped g.children[j];
								if(sprit.z<camera.z && sprit.name != "one" && sprit.name != "two" && sprit.name != "three")
								{
										sprit.z = sprit.z+700+Math.random()*100 ;
										sprit.x = Math.random()*1200-300;
								}
								else if(sprit.z<camera.z-120 && (sprit.name == "one" || sprit.name == "two" || sprit.name == "three"))
								{
										sprit.z+=1200;
								}
						}
				}
				scene.render();
		}

		private function keyPressedHandler(event:KeyboardEvent):Void {
				switch( event.keyCode ) {
						case 38: // KEY_UP
								camera.moveForward(5);
						case 40: // KEY_DOWN
								camera.moveForward(-5);
				}
		}

		private function mouseMovedHandler(event:MouseEvent):Void {
				camera.pan=(event.stageX-300/2)/10; 
		}	

		static function main() {
				new Woods();
		}
}


