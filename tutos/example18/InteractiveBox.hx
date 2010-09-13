import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.events.Shape3DEvent;
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.Material;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.primitive.Box;
import sandy.primitive.PrimitiveMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.Lib;

class InteractiveBox extends Sprite {
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var myBox:Box;
		private var myText:TextField;

		public function new()
		{ 
				myText = new TextField();

				super(); 

				camera = new Camera3D( 300, 300 );
				camera.x = 100;
				camera.y = 100;
				camera.z = -300;
				camera.lookAt(0,0,0);

				myText.width = 200;
				myText.x = 20;
				myText.y = 20;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );

				Lib.current.stage.addChild(this);
		}

		private function createScene():Group
		{
				var g:Group = new Group();

				myBox = new Box("theBox", 100, 100, 100, 2 );

				var materialAttr:MaterialAttributes = new MaterialAttributes( 
								[new LineAttributes( 0.5, 0x2111BB, 0.4 ),
								new LightAttributes( true, 0.1)]
								);

				var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
				material.lightingEnable = true;
				var app:Appearance = new Appearance( material );
				myBox.appearance = app;

				myBox.useSingleContainer = false;
				myBox.enableEvents = true;
				myBox.addEventListener( MouseEvent.CLICK, clickHandler );

				g.addChild(myBox);

				return g;
		}

		private function enterFrameHandler( event : Event ) : Void
		{
				myBox.pan +=1;
				myBox.tilt -=1;
				scene.render();
		}

		private function clickHandler(myEvent:Shape3DEvent):Void {
				myText.text = "Polygon id = " + (myEvent.polygon.id);
				this.addChild(myText);
		}

		static function main() {
				#if !flash
				neash.Lib.Init("InteractiveBox",400,300);
				#end
		
				new InteractiveBox();
				
				#if !flash
				neash.Lib.Run();
				#end
		}

}

