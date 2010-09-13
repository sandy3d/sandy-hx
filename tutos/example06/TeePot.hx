import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.parser.IParser;
import sandy.parser.Parser;
import sandy.parser.ParserEvent;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.Lib;

class TeePot extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var pot:Shape3D;

		public function new () { 
				frame = 0;
				t = 0;

				super(); 

				var parser:IParser = Parser.create("../assets/teieraASE.ASE",Parser.ASE );

				untyped( parser.addEventListener( ParserEvent.FAIL, onError ) );
				untyped( parser.addEventListener( ParserEvent.INIT, createScene ) );
				parser.parse();

				myTextField = new TextField();
				Lib.current.stage.addChild(myTextField);
				myTextField.width = 600;
		}

		function onError( pEvt:ParserEvent ):Void 
		{
				trace( "There is an error in loading your stuff" );
		}

		function createScene( p_eEvent:ParserEvent ):Void {

				camera = new Camera3D( 300, 300 );
				camera.y = 30;
				camera.z = -200;

				var root:Group = p_eEvent.group;

				pot = cast( root.children[0], Shape3D );
				pot.x = 0;

				var materialAttr:MaterialAttributes = new MaterialAttributes( [new LightAttributes( true, 0.2 )] );
				var material:Material = new ColorMaterial( 0xE0F87E, 0.9, materialAttr);
				material.lightingEnable = true;
				var app:Appearance = new Appearance( material);

				pot.appearance = app;

				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );

				Lib.current.stage.addChild(this);

		}

		private var frame:Int;
		private var t:Float;
		var myTextField:TextField;

		function enterFrameHandler( event:Event ):Void {
				frame++;
				pot.pan += 3;
				scene.render();
				if( frame == 1000 )
				{
						var elapsed:Float = (Lib.getTimer() - t);
						myTextField.text = "Rendering time for 1000 frames = "+(elapsed)+" ms";

						removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
				}
		}

		static function main() {
				#if !flash
				neash.Lib.Init("TeePot",400,300);
				#end
				
				new TeePot();
				
				#if !flash
				neash.Lib.Run();
				#end
		}
}


