import sandy.core.Scene3D;
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

class MaxCar extends Sprite {
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

				var parser:IParser = Parser.create("../assets/models/3DS/car.3DS", Parser.MAX_3DS );
				var parserLF:IParser = Parser.create("../assets/models/3DS/wheel_Front_L.3DS", Parser.MAX_3DS );
				var parserRF:IParser = Parser.create("../assets/models/3DS/wheel_Front_R.3DS", Parser.MAX_3DS );
				var parserLR:IParser = Parser.create("../assets/models/3DS/wheel_Rear_L.3DS", Parser.MAX_3DS );
				var parserRR:IParser = Parser.create("../assets/models/3DS/wheel_Rear_R.3DS", Parser.MAX_3DS );

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
				car = cast parserStack.getGroupByName("carParser").children[0];
				wheelLF = cast parserStack.getGroupByName("wheelLFParser").children[0];
				wheelRF = cast parserStack.getGroupByName("wheelRFParser").children[0];
				wheelLR = cast parserStack.getGroupByName("wheelLRParser").children[0];
				wheelRR = cast parserStack.getGroupByName("wheelRRParser").children[0];
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
				camera.z = -200;
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

				var material:BitmapMaterial = new BitmapMaterial( cast Reflect.field( queue.data.get( "carSkin" ), "bitmapData" ) );
				var app:Appearance = new Appearance( material );
				car.appearance = app;

				var materialW:BitmapMaterial = new BitmapMaterial( cast Reflect.field( queue.data.get( "wheels" ), "bitmapData" ) );
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
								tg.roll += 2;
						case Keyboard.DOWN: // KEY_DOWN
								tg.roll -= 2;
						case Keyboard.LEFT: // KEY_LEFT
								tg.pan -= 2;
						case Keyboard.RIGHT: // KEY_RIGHT
								tg.pan += 1;
						case Keyboard.DOWN: // PAGE_DOWN
								tg.z -= 5;
						case Keyboard.UP: // PAGE_UP
								tg.z += 5;
				}
		}

		function enterFrameHandler( event:Event ):Void {
				scene.render();
		}

		static function main() {
				#if !flash
				neash.Lib.Init("MaxCar",400,300);
				#end
				
				new MaxCar();
				
				#if !flash
				neash.Lib.Run();
				#end
		}
}


