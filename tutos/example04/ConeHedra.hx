import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Line3D;
import sandy.primitive.Hedra;
import sandy.primitive.Cone;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;

class ConeHedra extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var tg:TransformGroup;
		var myCone:Cone;
		var myHedra:Hedra;

		public function new () { 
				super(); 

				camera = new Camera3D( 300, 300 );
				camera.x = 100;
				camera.y = 100;
				camera.z = -400;
				camera.lookAt( 0, 0, 0 );

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );
				
				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyPressed );

				Lib.current.stage.addChild(this);
		}

		function createScene():Group {
				var g:Group = new Group();

				var myXLine:Line3D = new Line3D( "x-coord", [new Point3D( -50, 0, 0 ), new Point3D( 50, 0, 0 )] );
				var myYLine:Line3D = new Line3D( "y-coord", [new Point3D( 0, -50, 0 ), new Point3D( 0, 50, 0 )] );
				var myZLine:Line3D = new Line3D( "z-coord", [new Point3D( 0, 0, -50 ), new Point3D( 0, 0, 50 )] );

				tg = new TransformGroup( 'myGroup' );

				myCone = new Cone( "theObj1", 50, 100 );
				myHedra = new Hedra( "theObj2", 80, 60, 60 );

				myCone.x = -160;
				myCone.z = 150;
				myHedra.x = 90;

				var materialAttr:MaterialAttributes = new MaterialAttributes(
								[new LineAttributes( 0.5, 0x2111BB, 0.4 ),
								new LightAttributes( true, 0.1 )]
				);

				var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
				material.lightingEnable = true;
				var app:Appearance = new Appearance( material );

				myCone.appearance = app;
				myHedra.appearance = app;

				tg.addChild( myCone );
				tg.addChild( myHedra );

				g.addChild( tg );
				g.addChild( myXLine );
				g.addChild( myYLine );
				g.addChild( myZLine );

				return g;
		}

		function enterFrameHandler( event:Event ):Void {
				myHedra.pan += 4;
				myCone.pan += 4;
				scene.render();
		}

		function keyPressed( event:KeyboardEvent ):Void {
				switch( event.keyCode ) {
						case Keyboard.UP: // KEY_UP
								tg.y += 2;
						case Keyboard.DOWN: // KEY_DOWN
								tg.y -= 2;
						case Keyboard.RIGHT: // KEY_RIGHT
								tg.roll += 2;
						case Keyboard.LEFT: // KEY_LEFT
								tg.roll -= 2;
				}
		}

		static function main() {
			#if cpp
				nme.Lib.create(function(){
					new ConeHedra();
				},400,300,24,0xFFFFFF,nme.Lib.RESIZABLE);
			#else
				new ConeHedra();
			#end
		}
}

