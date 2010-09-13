import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.Sphere;
import sandy.primitive.Plane3D;
import caurina.transitions.Tweener;

class VertBounce extends Sprite 
{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var sphere:Sphere;
		private var bottom:Plane3D;
		private var wilson:Plane3D;

		private var img:MyBall;
		private var bitmap:Bitmap;
		private var imgCrt:MyCourt;
		private var bitmapCrt:Bitmap;
		private var imgWils:MyWilson;
		private var bitmapWils:Bitmap;

		private var proxyObj:Dynamic;

		public function new():Void
		{  
				img=new MyBall();
				bitmap=new Bitmap(img);
				imgCrt=new MyCourt();
				bitmapCrt=new Bitmap(imgCrt);
				imgWils=new MyWilson();
				bitmapWils=new Bitmap(imgWils);

				super();

				camera = new Camera3D( 600, 300 );
				camera.z = -300;
				camera.x = 0;
				camera.y = 150;
				camera.lookAt(0,0,0);

				var root:Group = createScene();
				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);

				flash.Lib.current.stage.addChild(this);
		}

		private function createScene():Group
		{
				var g:Group = new Group();

				bottom = new Plane3D('bottom', 300, 530, 10, 10, 
							Plane3D.ZX_ALIGNED);

				var materialCrt:BitmapMaterial = new BitmapMaterial( bitmapCrt.bitmapData );
				materialCrt.lightingEnable = true;
				var appCrt:Appearance = new Appearance( materialCrt );

				bottom.enableBackFaceCulling = false;
				bottom.useSingleContainer = false;
				bottom.appearance = appCrt;

				wilson = new Plane3D('wilson', 160, 40, 12, 12, 
								Plane3D.YZ_ALIGNED );
				wilson.rotateZ = 195;
				wilson.y = 22;
				wilson.x = -200;

				var materialWils:BitmapMaterial = new BitmapMaterial( bitmapWils.bitmapData );
				materialWils.lightingEnable = true;
				var appWils:Appearance = new Appearance( materialWils );

				wilson.enableBackFaceCulling = false;
				wilson.useSingleContainer = false;
				wilson.appearance = appWils;

				sphere = new Sphere("sphere", 20,10,10);
				sphere.z = 0;
				sphere.x = 0;
				sphere.y = 20;
				var materialImg:BitmapMaterial = new BitmapMaterial( bitmap.bitmapData );
				sphere.rotateY = 110;

				materialImg.lightingEnable = true;
				var appImg:Appearance = new Appearance( materialImg );

				sphere.enableBackFaceCulling = false;
				sphere.useSingleContainer = false;
				sphere.appearance = appImg; 

				g.addChild( sphere);
				g.addChild( bottom );
				g.addChild( wilson );

				return g;
		}

		private function enterFrameHandler( event : Event ) : Void
		{
				scene.render();
				if ( proxyObj != null )
						sphere.y = proxyObj.y;
		}

		private function keyPressed(event:KeyboardEvent):Void {
				switch(event.keyCode) {
						case 34: // PAGE_DOWN
								camera.z -=5;
						case 33: // PAGE_UP
								camera.z +=5;
						case 32: // SPACE
								Tweener.removeAllTweens();
								sphere.z = 0;
								sphere.x = 0;
								sphere.y = 120;
								proxyObj = { y:120 };
								Tweener.addTween(proxyObj, {y:20, time:7, transition:"myBouncer"}) ;
				}
		}

		static function main () { new VertBounce(); }

}

