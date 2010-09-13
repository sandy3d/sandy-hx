import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.media.Sound;
import flash.Lib;
import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.core.scenegraph.Sound3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.Sphere;
import sandy.primitive.Plane3D;
import caurina.transitions.Tweener;

class BasketBall extends Sprite 
{
		private var sphereS:Sphere;
		private var img:MyBall;
		private var bitmap:Bitmap;
		private var img2:MyCourt;
		private var bitmap2:Bitmap;
		private var sound:Sound;

		private var plane:Plane3D;
		private var tg1:TransformGroup;
		private var tg2:TransformGroup;
		private var bounce:Sound3D;

		private var scene:Scene3D;
		private var camera:Camera3D;

		private var moveDirection:Int;
		private var speed:Float;

		public function new():Void
		{  
				img=new MyBall();
				bitmap=new Bitmap(img);
				img2=new MyCourt();
				bitmap2=new Bitmap(img2);
				sound= new BallBounce();

				moveDirection = -1;
				speed = 3;

				super();

				camera = new Camera3D( 600, 300 );
				camera.z = -400;
				camera.y = 100;
				camera.lookAt (0,0,0);
				var root:Group = createScene();
				scene = new Scene3D( "scene", this, camera, root );

				flash.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
				flash.Lib.current.stage.addEventListener (MouseEvent.MOUSE_MOVE, mouseMovedHandler);
				addEventListener ( Event.ENTER_FRAME, enterFrameHandler );

				flash.Lib.current.stage.addChild(this);
		}

		private function createScene():Group
		{
				var g:Group = new Group();
				tg1 = new TransformGroup('myGroup');
				tg2 = new TransformGroup('myGroup');

				sphereS = new Sphere( "theSphere", 20,15,15);

				var material:BitmapMaterial = new BitmapMaterial( bitmap.bitmapData );
				var app:Appearance = new Appearance( material );			

				sphereS.appearance = app;
				sphereS.useSingleContainer = false;

				sphereS.x = 100;
				sphereS.y = 0;
				sphereS.z = 0;

				plane = new Plane3D( "thePlane", 300, 500, 2, 2, Plane3D.ZX_ALIGNED );
				plane.y = -100;
				plane.rotateY = 0;

				var material2:BitmapMaterial = new BitmapMaterial( bitmap2.bitmapData );
				var app2:Appearance = new Appearance( material2 );

				plane.useSingleContainer = false;
				plane.enableBackFaceCulling = false;
				plane.appearance = app2;

				bounce = new Sound3D("bounce", sound, 1, 3, 1500);
				bounce.type = SPEECH;
				bounce.loops = 0;

				tg1.addChild(sphereS);
				tg1.addChild(bounce);
				tg2.addChild(plane);
				tg2.addChild(tg1);

				g.addChild (tg2);

				return g;
		}

		private function mouseMovedHandler (event:MouseEvent):Void
		{
				tg2.rotateY=(event.stageX-600/2)/5;
		}

		private function keyPressed(event:KeyboardEvent):Void {
				switch (event.keyCode)
				{
						case 39: // KEY_RIGHT
								tg1.moveLateraly(5);
						case 37: // KEY_LEFT
								tg1.moveLateraly(-5);
						case 38: // KEY_UP
								tg1.moveHorizontally(5);
						case 40: // KEY_DOWN
								tg1.moveHorizontally(-5);

				}
		}

		private function enterFrameHandler( event : Event ) : Void
		{
		scene.render ();
		sphereS.roll -= 4;
		sphereS.y += speed * moveDirection;
		if (sphereS.y < -85){
				bounce.play();
				moveDirection = 1;
		}
		else if (sphereS.y > 100)
				moveDirection = -1;
		}

		static function main () { new BasketBall(); }

}

class MyBall extends BitmapData {
		public function new () {
				super (0,0);
		}
}

class MyCourt extends BitmapData {
		public function new () {
				super(0,0);

		}

}
				
