import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Line3D;
import sandy.primitive.Torus;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;

class ShadedTorus extends Sprite {
	var scene:Scene3D;
	var camera:Camera3D;

	public function new () { 
		super(); 

		camera = new Camera3D( 300, 300 );
		camera.z = -400;

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

		var torus:Torus = new Torus( "theTorus", 120, 20 );

		var materialAttr:MaterialAttributes = new MaterialAttributes(
						[new LineAttributes( 0.5, 0x2111BB, 0.4 ),
						new LightAttributes( true, 0.1 )]
		);

		var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
		material.lightingEnable = true;
		var app:Appearance = new Appearance( material );

		torus.appearance = app;

		torus.rotateX = 30;
		torus.rotateY = 30;

		g.addChild( myXLine );
		g.addChild( myYLine );
		g.addChild( myZLine );
		g.addChild( torus );

		return g;
	}

	function enterFrameHandler( event:Event ):Void {
		scene.render();
	}

	function keyPressed( event:KeyboardEvent ):Void {
		switch( event.keyCode ) {
			case Keyboard.UP:
					camera.tilt += 2;
			case Keyboard.DOWN:
					camera.tilt -= 2;
			case Keyboard.RIGHT:
					camera.pan -= 2;
			case Keyboard.LEFT:
					camera.pan += 2;
			case Keyboard.CONTROL:
					camera.roll += 2;
			case Keyboard.PAGE_DOWN:
					camera.z -= 5;
			case Keyboard.PAGE_UP:
					camera.z += 5;
		}
	}

	static function main() {
		#if cpp
			nme.Lib.create(function(){
				new ShadedTorus();
			},400,300,24,0xFFFFFF,nme.Lib.RESIZABLE);
		#else
			new ShadedTorus();
		#end
	}
}

