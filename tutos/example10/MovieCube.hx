import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.events.QueueEvent;
import sandy.events.SandyEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.Material;
import sandy.materials.MovieMaterial;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.primitive.Box;
import sandy.primitive.Sphere;
import sandy.util.LoaderQueue;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLRequest;
import flash.Lib;

class MovieCube extends Sprite 
{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var box:Box;
		private var queue:LoaderQueue;

		public function new():Void
		{
				super();
				queue = new LoaderQueue();
				queue.add( "test", new URLRequest("main.swf") );
				queue.add( "test2", new URLRequest("main2.swf") ); 
				queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
				queue.start();
				Lib.current.stage.addChild(this);
		}

		public function loadComplete(event:QueueEvent ):Void
		{  
				camera = new Camera3D( 300, 300 );
				camera.z = -400;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		private function createScene():Group
		{
				var g:Group = new Group();

				box = new Box( "box",100,100,100);

				box.rotateX = 30;
				box.rotateY = 30;
				box.x = 0;

				var materialAttr:MaterialAttributes = new MaterialAttributes( 
								[new LineAttributes( 0, 0xD7D79D, 0 ),
								new LightAttributes( true, 0.1)]
								);

				var material:Material = new ColorMaterial( 0xD7D79D, 1, materialAttr );
				material.lightingEnable = true;
				var app:Appearance = new Appearance( material );		


				var material01:MovieMaterial = new MovieMaterial( 
								untyped( queue.data.get("test") ),40);
				material01.lightingEnable = true;
				var app01:Appearance = new Appearance( material01 );

				trace( queue.data.get("test2") );
				var material02:MovieMaterial = new MovieMaterial( 
								untyped( queue.data.get("test2") ),40);
				material02.lightingEnable = true;
				var app02:Appearance = new Appearance( material02 );

				box.appearance = app; 
				box.aPolygons[0].appearance = app01;
				box.aPolygons[1].appearance = app01;
				box.aPolygons[2].appearance = app02;
				box.aPolygons[3].appearance = app02;
				box.aPolygons[10].appearance = app02;
				box.aPolygons[11].appearance = app02;
				g.addChild( box );

				return g;
		}

		private function enterFrameHandler( event : Event ) : Void
		{
				box.tilt += 1;
				box.pan += 1;
				scene.render();
		}
		static function main () {
				new MovieCube();
		}
}

