import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Cone;
import sandy.primitive.Hedra;
import sandy.primitive.Plane3D;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;

class RotPot extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var tg:TransformGroup;
		var pot:Teiera;

		public function new () { 
				super(); 

				camera = new Camera3D( 300, 300 );
				camera.z = -400;
				camera.lookAt( 0, 0, 0 );

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );

				Lib.current.stage.addChild(this);
		}

		function createScene():Group {

				var g:Group = new Group( "myGroup" );

				var materialAttr:MaterialAttributes = new MaterialAttributes( [new LightAttributes( true, 0.2 )] );
				var material:Material = new ColorMaterial( 0xE0F87E, 0.9, materialAttr );
				material.lightingEnable = true;
				var app:Appearance = new Appearance( material );

				pot = new Teiera( "pot" );
				pot.appearance = app;
				pot.enableBackFaceCulling = false;
				g.addChild( pot );

				return g;

		}

		function enterFrameHandler( event:Event ):Void {
				pot.pan += 5;
				scene.render();
		}

		static function main() {
				#if !flash
				neash.Lib.Init("RotPot",400,300);
				#end
				
				new RotPot();
				
				#if !flash
				neash.Lib.Run();
				#end
		}
}


