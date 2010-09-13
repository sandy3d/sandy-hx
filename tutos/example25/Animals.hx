
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.Lib;


import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.events.SandyEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.util.LoaderQueue;

import sandy.primitive.MD2;

class Animals extends Sprite {
	private var scene:Scene3D;
	private var queue:LoaderQueue;

	private var imp:MD2;
	private var imp02:MD2;

	public function new() { 
		super();

		queue = new LoaderQueue();
		queue.add( "bird", new URLRequest("../assets/md2/bird_final.md2"), BIN );
		queue.add( "horse", new URLRequest("../assets/md2/horse.md2"), BIN );
		queue.add( "birdSkin", new URLRequest("../assets/md2/bird_final.jpg"), IMAGE );
		queue.add( "horseSkin", new URLRequest("../assets/md2/horse.jpg"), IMAGE ); 
		queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadMD2Complete );
		queue.start();
	}

	private function loadMD2Complete(event:Event):Void {

		scene = new Scene3D( "scene", this, new Camera3D( 600, 600 ), new Group() );
		imp = new MD2 ( "imp", queue.data.get("horse"), 2 ); 
		imp.y = -100;
		imp02 = new MD2 ( "imp02", queue.data.get("bird"), 0.05 );
		imp02.y = 50;
		imp02.x = 0;
		imp.appearance = new Appearance (new BitmapMaterial( queue.data.get( "horseSkin" ).bitmapData ));
		imp02.appearance = new Appearance (new BitmapMaterial( queue.data.get( "birdSkin" ).bitmapData ));        
		scene.root.addChild( imp );
		scene.root.addChild( imp02 );
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		Lib.current.stage.addEventListener (MouseEvent.MOUSE_MOVE, mouseMovedHandler);


		Lib.current.stage.addChild(this);
	}

	private function mouseMovedHandler (event:MouseEvent):Void{
		imp.rotateY=(event.stageX-600/2)/4;
	}

	private function enterFrameHandler( event : Event ) : Void {
		if (imp != null) {
			//imp.rotateY += 1; 
			imp.frame += 0.3;
			imp02.frame += 0.3;
		}
		scene.render();
	}
	static function main() {
		new Animals();
	}
}

