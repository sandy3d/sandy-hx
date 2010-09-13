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
import sandy.materials.attributes.OutlineAttributes;
import sandy.primitive.Box;
import sandy.primitive.Sphere;
import sandy.primitive.Plane3D;
import sandy.util.LoaderQueue;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLRequest;
import flash.Lib;

class InteractiveMovieClip extends Sprite 
{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var plane:Plane3D;
		private var plane2:Plane3D;
		private var plane3:Plane3D;
		private var queue:LoaderQueue;
		private var img:Parquet;
		private var bitmap:Bitmap;

		public function new():Void
		{
				img=new Parquet();
				bitmap=new Bitmap(img);

				super();

				queue = new LoaderQueue();
				queue.add( "myClip", new URLRequest("../assets/MyClipMona.swf") );
				queue.add( "myClip2", new URLRequest("../assets/MyClipGarden.swf") );
				queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
				queue.start();

				Lib.current.stage.addChild(this);
		}

		public function loadComplete(event:QueueEvent ):Void
		{  
				camera = new Camera3D( 600, 400 );
				camera.x = 180;
				camera.y = 0;
				camera.z = -600;
				camera.pan -=10;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
		}

		private function createScene():Group
		{
				var g:Group = new Group();

				var materialAttr03:MaterialAttributes = new MaterialAttributes( 
								[new OutlineAttributes(3, 0xFC5858, 1)]);

				var material01:MovieMaterial = new MovieMaterial( 
								untyped( queue.data.get("myClip") ),0,materialAttr03, false, 200, 350);
				var app01:Appearance = new Appearance( material01);

				var material02:MovieMaterial = new MovieMaterial( 
								untyped( queue.data.get("myClip2") ),0,materialAttr03, false, 200, 350);
				var app02:Appearance = new Appearance( material02);


				plane = new Plane3D( "thePlane", 200, 350, 10, 10, Plane3D.XY_ALIGNED );
				plane.enableBackFaceCulling = false;
				plane.enableInteractivity = true;
				plane.appearance = app01;
				plane.pan = -70;
				plane.tilt = 0;
				plane.x = -110;

				plane2 = new Plane3D( "thePlane2", 200, 350, 10, 10, Plane3D.XY_ALIGNED );
				plane2.enableBackFaceCulling = false;
				plane2.enableInteractivity = true;
				plane2.appearance = app02;
				//plane2.roll = -90;
				plane2.tilt = 0;
				plane2.x = 130;
				plane2.z = 160;

				var material03:BitmapMaterial = new BitmapMaterial( bitmap.bitmapData );
				material03.lightingEnable = true;
				var app03:Appearance  = new Appearance( material03 );
				plane3 = new Plane3D( "thePlane3", 400, 800, 10, 10, Plane3D.ZX_ALIGNED );
				plane3.appearance = app03;
				plane3.y = -100;
				plane3.enableForcedDepth = true;
				plane3.forcedDepth = 999999;

				// we now add all the object to the root group:
				g.addChild(plane);
				g.addChild(plane2);
				g.addChild(plane3);

				return g;
		}

		private function enterFrameHandler( event : Event ) : Void
		{
				scene.render();
		}

		private function keyPressedHandler(event:flash.events.KeyboardEvent):Void 
		{
				switch(event.keyCode) {
						case 38: // KEY_UP
								camera.tilt +=2;
						case 40: // KEY_DOWN
								camera.tilt -=2;
						case 37: // KEY_LEFT
								camera.pan -=2;
						case 39: // KEY_RIGHT
								camera.pan +=2;
						case 34: // PAGE_DOWN
								camera.z -=5;
						case 33: // PAGE_UP
								camera.z +=5;
				}
		}
		static function main () {
				new InteractiveMovieClip();
		}
}

class Parquet extends BitmapData {
		public function new () {
				super( 0, 0);
		}

}
