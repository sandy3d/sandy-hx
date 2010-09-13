import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Box;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

class ShadedBox extends Sprite {
	var scene:Scene3D;
	var camera:Camera3D;

	public function new () { 
		super(); 

		camera = new Camera3D( 300, 300 );
		camera.z = -400;

		var root:Group = createScene();

		scene = new Scene3D( "scene", this, camera, root );
		
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );

		Lib.current.stage.addChild(this);
	}

	function createScene():Group {
		var g:Group = new Group();

		var box = new Box( "box", 100, 100, 100 );

		var materialAttr:MaterialAttributes = new MaterialAttributes(
						[new LineAttributes( 0.5, 0x2111BB, 0.4 ),
						new LightAttributes( true, 0.1 )]
		);

		var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
		material.lightingEnable = true;
		var app:Appearance = new Appearance( material );

		box.appearance = app;

		box.rotateX = 30;
		box.rotateY = 30;

		g.addChild( box );

		return g;
	}

	function enterFrameHandler( event:Event ):Void {
		scene.render();
	}

	static function main() {
		#if cpp
			nme.Lib.create(function(){
				new ShadedBox();
			},400,300,24,0xFFFFFF,nme.Lib.RESIZABLE);
		#else
			new ShadedBox();
		#end
	}
}


