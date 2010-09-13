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

class Room extends Sprite {
		var scene:Scene3D;
		var camera:Camera3D;
		var tg:TransformGroup;
		var myCone:Cone;
		var myHedra:Hedra;

		public function new () { 
				super(); 

				camera = new Camera3D( 300, 300 );
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
				tg = new TransformGroup('myGroup');

				var right:Shape3D = new Plane3D('right', 150, 100, 10, 10, 
								Plane3D.YZ_ALIGNED);
				right.moveLateraly(100);
				right.moveForward(50);
				var left:Shape3D = new Plane3D('left', 150, 100, 10, 10, 
								Plane3D.YZ_ALIGNED);
				left.moveLateraly(-100);
				left.moveForward(50);

				var back:Shape3D = new Plane3D('back', 100, 250, 10, 10, 
								Plane3D.XY_ALIGNED);
				back.moveForward(100);

				var bottom:Shape3D = new Plane3D('bottom', 150, 250, 10, 10, 
								Plane3D.ZX_ALIGNED);
				bottom.moveForward(50);
				bottom.moveUpwards(-50);

				var materialAttr:MaterialAttributes = new MaterialAttributes( 
								[new LineAttributes( 0.5, 0x2111BB, 0.4 ),
								new LightAttributes( true, 0.1)]
								);

				var material01:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
				material01.lightingEnable = false;
				var material02:Material = new ColorMaterial( 0xFEA792, 1, materialAttr );
				material02.lightingEnable = false;
				var app01:Appearance = new Appearance( material01 );
				var app02:Appearance = new Appearance( material02 );

				right.enableBackFaceCulling = false;
				right.appearance = app01;
				left.enableBackFaceCulling = false;
				left.appearance = app01;
				back.enableBackFaceCulling = false;
				back.appearance = app02;
				bottom.enableBackFaceCulling = true;
				bottom.appearance = app02;

				right.useSingleContainer = false;
				left.useSingleContainer = false;
				back.useSingleContainer = false;
				bottom.useSingleContainer = false;

				tg.addChild(right);
				tg.addChild(left);
				tg.addChild(back);
				tg.addChild(bottom);
				g.addChild(tg);

				return g;

		}

		function enterFrameHandler( event:Event ):Void {
				scene.render();
		}

		function keyPressed( event:KeyboardEvent ):Void {
				switch( event.keyCode ) {
						case flash.ui.Keyboard.UP: // KEY_UP
								tg.tilt += 2;
						case flash.ui.Keyboard.DOWN: // KEY_DOWN
								tg.tilt -= 2;
						case flash.ui.Keyboard.RIGHT: // KEY_RIGHT
								tg.tilt += 2;
						case flash.ui.Keyboard.LEFT: // KEY_LEFT
								tg.tilt -= 2;
				}
		}

		static function main() {
				#if !flash
				neash.Lib.Init("Room",400,300);
				#end
		
				new Room();
				
				#if !flash
				neash.Lib.Run();
				#end
		}
}


