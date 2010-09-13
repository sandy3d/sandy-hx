import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.Material;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.OutlineAttributes;
import sandy.primitive.Box;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.Lib;

class AnimBox extends Sprite {
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var box:Box;
		private var app01:Appearance;
		private var app02:Appearance;
		private var app03:Appearance;

		public function new()
		{ 
				super(); 

				camera = new Camera3D( 300, 300 );
				camera.z = -400;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyPressed );    

				Lib.current.stage.addChild(this);
		}

		private function createScene():Group
		{
				var g:Group = new Group();

				box = new Box( "box",100,100,100);

				box.rotateX = 30;
				box.rotateY = 30;

				var materialAttr01:MaterialAttributes = new MaterialAttributes( 
								[new LightAttributes( true, 0.1)]
								);
				var material01:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr01 );
				material01.lightingEnable = true;
				app01 = new Appearance( material01 );

				var materialAttr02:MaterialAttributes = new MaterialAttributes( 
								[new LightAttributes( true, 0.1), new LineAttributes(3, 0xF43582, 1)]
								);
				var material02:Material = new ColorMaterial( 0xAAEE99, 1, materialAttr02 );
				material02.lightingEnable = true;
				app02 = new Appearance( material02 );

				var materialAttr03:MaterialAttributes = new MaterialAttributes( 
								[new LightAttributes( true, 0.1), new OutlineAttributes(3, 0xFC5858, 1),
								new LineAttributes(1, 0x000000, 1)]
								);
				var material03:Material = new ColorMaterial( 0x9DCCEA, 1, materialAttr03 );
				material03.lightingEnable = true;
				app03 = new Appearance( material03 );

				box.appearance = app01;

				g.addChild( box );

				return g;

		}

		private function enterFrameHandler( event : Event ) : Void
		{
				box.tilt += 1;
				box.pan += 1;
				scene.render();
		}

		private function keyPressed( event:flash.events.KeyboardEvent ):Void 
		{
				switch(event.keyCode) {
						case Keyboard.UP: // KEY_UP
								box.appearance = app01;
						case Keyboard.DOWN: // KEY_DOWN
								box.aPolygons[0].appearance = app01;
								box.aPolygons[1].appearance = app02;
								box.aPolygons[2].appearance = app03;
								box.aPolygons[3].appearance = app02;
								box.aPolygons[4].appearance = app01;
								box.aPolygons[5].appearance = app03;
						case Keyboard.RIGHT: // KEY_RIGHT
								box.appearance = app02;
						case Keyboard.LEFT: // KEY_LEFT
								box.appearance = app03;
				}
		}

		static function main() {
				#if !flash
				neash.Lib.Init("AnimBox",400,300);
				#end
		
				new AnimBox();
				
				#if !flash
				neash.Lib.Run();
				#end
		}

}


