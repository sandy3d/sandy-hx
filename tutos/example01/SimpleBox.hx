import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.primitive.Box;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

class SimpleBox extends Sprite {
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
				new SimpleBox();
			}, 400, 300, 24, 0xFFFFFF, nme.Lib.RESIZABLE);
		#else
			new SimpleBox();
		#end
	}
}


