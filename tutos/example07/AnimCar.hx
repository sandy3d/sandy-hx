import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.TransformGroup;
import sandy.events.SandyEvent;
import sandy.events.QueueEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.parser.IParser;
import sandy.parser.Parser;
import sandy.parser.ParserStack;
import sandy.util.LoaderQueue;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLRequest;
import flash.ui.Keyboard;
import flash.Lib;

class AnimCar extends Sprite {
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var tg:TransformGroup;
		private var car:Shape3D;
		private var wheelLF:Shape3D;
		private var wheelRF:Shape3D;
		private var wheelLR:Shape3D;
		private var wheelRR:Shape3D;
		private var queue:LoaderQueue;
		private var parserStack:ParserStack;

		public function new () { 
				super(); 

				var parser:IParser = Parser.create("../assets/models/ASE/car.ASE",Parser.ASE );
				var parserLF:IParser = Parser.create("../assets/models/ASE/wheel_Front_L.ASE",Parser.ASE );
				var parserRF:IParser = Parser.create("../assets/models/ASE/wheel_Front_R.ASE",Parser.ASE );
				var parserLR:IParser = Parser.create("../assets/models/ASE/wheel_Rear_L.ASE",Parser.ASE );
				var parserRR:IParser = Parser.create("../assets/models/ASE/wheel_Rear_R.ASE",Parser.ASE );

				parserStack = new ParserStack();
				parserStack.add("carParser",parser);
				parserStack.add("wheelLFParser",parserLF);
				parserStack.add("wheelRFParser",parserRF);
				parserStack.add("wheelLRParser",parserLR);
				parserStack.add("wheelRRParser",parserRR);
				parserStack.addEventListener(ParserStack.COMPLETE, parserComplete );
				parserStack.start();

		}

		private function parserComplete(pEvt:Event ):Void
		{
				car = untyped parserStack.getGroupByName("carParser").children[0];
				wheelLF = untyped parserStack.getGroupByName("wheelLFParser").children[0];
				wheelRF = untyped parserStack.getGroupByName("wheelRFParser").children[0];
				wheelLR = untyped parserStack.getGroupByName("wheelLRParser").children[0];
				wheelRR = untyped parserStack.getGroupByName("wheelRRParser").children[0];
				loadSkins();
		}


		private function loadSkins(){
				queue = new LoaderQueue();
				queue.add( "carSkin", new URLRequest("../assets/textures/car.jpg") );
				queue.add( "wheels", new URLRequest("../assets/textures/wheel.jpg") ); 
				queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
				queue.start();
		}

		// Create the scene graph based on the root Group of the scene
		private function loadComplete(event:QueueEvent)
		{
				camera = new Camera3D( 600, 300 );
				camera.y = 30;
				camera.z = -150;
				camera.near = 10;

				var root:Group = createScene();
				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);

				Lib.current.stage.addChild(this);
		}

		private function createScene():Group
		{
				var g:Group = new Group();

				tg = new TransformGroup('myGroup');

				var bd = Reflect.field( queue.data.get( "carSkin" ), "bitmapData" );
				
				var material:BitmapMaterial = new BitmapMaterial( bd );
				var app:Appearance = new Appearance( material );
				car.appearance = app;
				
				bd = Reflect.field( queue.data.get( "wheels" ), "bitmapData" );

				var materialW:BitmapMaterial = new BitmapMaterial( bd );
				var appW:Appearance = new Appearance( materialW );
				wheelLF.appearance = appW;
				wheelRF.appearance = appW;
				wheelLR.appearance = appW;
				wheelRR.appearance = appW;

				car.useSingleContainer = false;
				wheelLF.useSingleContainer = false;
				wheelRF.useSingleContainer = false;
				wheelLR.useSingleContainer = false;
				wheelRR.useSingleContainer = false;

				wheelRF.geometryCenter = new Point3D(-24,-11.5,-48.5);
				wheelRF.x += 24;
				wheelRF.y += 11.5;
				wheelRF.z += 48.5;

				wheelLF.geometryCenter = new Point3D(24.5,-11.5,-48.5);
				wheelLF.x -= 24.5;
				wheelLF.y += 11.5;
				wheelLF.z += 48.5;

				wheelRR.geometryCenter = new Point3D(-24,-11.5,41);
				wheelRR.x += 24;
				wheelRR.y += 11.5;
				wheelRR.z -= 41;

				wheelLR.geometryCenter = new Point3D(24.5,-11.5,41);
				wheelLR.x -= 24.5;
				wheelLR.y += 11.5;
				wheelLR.z -= 41;

				tg.addChild( wheelLF );
				tg.addChild( wheelRF );
				tg.addChild( wheelLR );
				tg.addChild( wheelRR );
				tg.addChild( car );

				tg.rotateY = -130;

				g.addChild( tg );
				return g;
		}

		function keyPressedHandler( event:KeyboardEvent ):Void {
				switch( event.keyCode ) {
						case Keyboard.UP: // KEY_UP
								wheelLF.tilt += 2;
								wheelRF.tilt += 2;
								wheelRR.tilt += 2;
								wheelLR.tilt += 2;
						case Keyboard.DOWN: // KEY_DOWN
								wheelLF.tilt -= 2;
								wheelRF.tilt -= 2;
								wheelRR.tilt -= 2;
								wheelLR.tilt -= 2;
						case Keyboard.LEFT: // KEY_LEFT
								if ( wheelLF.pan >= -40 ) {
										wheelLF.tilt = 0;
										wheelRF.tilt = 0;
										wheelLF.pan -= 2;
										wheelRF.pan -= 2;
								} 
						case Keyboard.RIGHT: // KEY_RIGHT
								if ( wheelLF.pan <= 40 ) {
										wheelLF.tilt = 0;
										wheelRF.tilt = 0;
										wheelLF.pan += 2;
										wheelRF.pan += 2;
								}
						case Keyboard.PAGE_DOWN: // PAGE_DOWN
								tg.z -=5;
						case Keyboard.PAGE_UP: // PAGE_UP
								tg.z +=5;
				}

				if(tg.z < -100){
						tg.visible = false;
				} else if (tg.z > -100) {
						tg.visible = true;
				}

		}

		function enterFrameHandler( event:Event ):Void {
				scene.render();
		}

		static function main() {
				#if !flash
				neash.Lib.Init("AnimCar",400,300);
				#end
		
				new AnimCar();
				
				#if !flash
				neash.Lib.Run();
				#end
		}
}


