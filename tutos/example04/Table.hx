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
import sandy.primitive.Box;
import sandy.primitive.Cylinder;
import sandy.primitive.Line3D;
import sandy.primitive.Sphere;
import sandy.primitive.PrimitiveMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;

class Table extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var tg:TransformGroup;
		var lightX:Float;
		var lightY:Float;
		var lightZ:Float;

		public function new () { 
				lightX = 0;
				lightY = 0;
				lightZ = 10;

				super(); 

				camera = new Camera3D( 300, 300 );
				camera.z = -400;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );
				scene.light.setDirection( lightX, lightY, lightZ );
				
				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyPressed );

				Lib.current.stage.addChild(this);
		}

		function createScene():Group {
				var g:Group = new Group();
				tg = new TransformGroup();

				var materialAttr:MaterialAttributes = new MaterialAttributes(
								[new LineAttributes( 0, 0x2111BB, 0 ),
								new LightAttributes( true, 0.1 )]
				);

				var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
				material.lightingEnable = true;
				var app:Appearance = new Appearance( material );

				var materialAttr2:MaterialAttributes = new MaterialAttributes(
								[new LineAttributes( 0, 0x2111BB, 0 ),
								new LightAttributes( true, 0.1 )]
				);

				var material2:Material = new ColorMaterial( 0xCC0000, 1, materialAttr );
				material2.lightingEnable = true;
				var app2:Appearance = new Appearance( material2 );

				var materialAttr3:MaterialAttributes = new MaterialAttributes(
								[new LineAttributes( 0, 0x2111BB, 0 ),
								new LightAttributes( true, 0.1 )]
				);

				var material3:Material = new ColorMaterial( 0x008AE6, 1, materialAttr );
				material3.lightingEnable = true;
				var app3:Appearance = new Appearance( material3 );

				var table = new Box( "table", 10, 150, 200, 1 );
				table.useSingleContainer = false;
				table.appearance = app;
				table.rotateY = 90;
				table.rotateX = 90;

				var leg01:Cylinder = new Cylinder( "leg01", 5, 80 );
				leg01.appearance = app;
				leg01.x = -80;
				leg01.y = -45;
				leg01.z = 50;

				var leg02:Cylinder = new Cylinder( "leg02", 5, 80 );
				leg02.appearance = app;
				leg02.x = 80;
				leg02.y = -45;
				leg02.z = 50;

				var leg03:Cylinder = new Cylinder( "leg03", 5, 80 );
				leg03.appearance = app;
				leg03.x = -80;
				leg03.y = -45;
				leg03.z = -50;

				var leg04:Cylinder = new Cylinder( "leg04", 5, 80 );
				leg04.appearance = app;
				leg04.x = 80;
				leg04.y = -45;
				leg04.z = -50;

				var mySphere:Sphere = new Sphere( "theSphere", 20, 20, 8);
				mySphere.useSingleContainer = true;
				mySphere.appearance = app2;
				mySphere.y = 25;
				mySphere.x = -30;

				var myBox:Box = new Box( "theBox", 60, 60, 60, 3 );
				myBox.useSingleContainer = true;
				myBox.appearance = app3;
				myBox.rotateY = 30;
				myBox.y = 35;
				myBox.x = 40;

				tg.addChild(table);
				tg.addChild(leg01);
				tg.addChild(leg02);
				tg.addChild(leg03);
				tg.addChild(leg04);
				tg.addChild(mySphere);
				tg.addChild(myBox);

				tg.rotateX = 5;

				g.addChild( tg );

				return g;
		}

		function enterFrameHandler( event:Event ):Void {
				scene.render();
		}

		function keyPressed( event:KeyboardEvent ):Void {
				switch( event.keyCode ) {
						case Keyboard.PAGE_DOWN: // PAGE_DOWN
								scene.light.setPower( scene.light.getPower() - 5 );
						case Keyboard.PAGE_UP: // PAGE_UP
								scene.light.setPower( scene.light.getPower() + 5 );
						case Keyboard.UP: // KEY_UP
								lightY += 10;
								scene.light.setDirection( lightX, lightY, lightZ );
						case Keyboard.DOWN: // KEY_DOWN
								lightY -= 10;
								scene.light.setDirection( lightX, lightY, lightZ );
						case Keyboard.RIGHT: // KEY_RIGHT
								lightX += 10;
								scene.light.setDirection( lightX, lightY, lightZ );
						case Keyboard.LEFT: // KEY_LEFT
								lightX -= 10;
								scene.light.setDirection( lightX, lightY, lightZ );
				}
				camera.changed = true;
		}

		static function main() {
			#if cpp
				nme.Lib.create(function(){
					new Table();
				},400,300,24,0xFFFFFF,nme.Lib.RESIZABLE);
			#else
				new Table();
			#end
		}
}

