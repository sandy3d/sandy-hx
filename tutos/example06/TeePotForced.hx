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
import flash.Lib;

class TeePotForced extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var pot:Shape3D;

		public function new () { 
				count = 0;

				super(); 

				var parser:IParser = Parser.create("../assets/teieraASE.ASE",Parser.ASE );

				untyped( parser.addEventListener( ParserEvent.FAIL, onError ) );
				untyped( parser.addEventListener( ParserEvent.INIT, createScene ) );
				parser.parse();

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
				pot.enableForcedDepth = true;
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

		var t1:Null<Float>;
		var t2:Null<Float>;
		var count:Int;

		function enterFrameHandler( event:Event ):Void {
				pot.pan += 3;
				scene.render();
				if ( t1 == null ) t1 = Lib.getTimer();
				if ( count == 100 ) {
						t2 = Lib.getTimer();
						trace( t2 - t1 );
				}
				count++;
		}

		static function main() {
				#if !flash
				neash.Lib.Init("TeePotForced",400,300);
				#end
				
				new TeePotForced();
				
				#if !flash
				neash.Lib.Run();
				#end
		}
}


