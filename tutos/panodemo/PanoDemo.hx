import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.ui.Keyboard;
import flash.Lib;

import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.events.QueueEvent;
import sandy.events.SandyEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.SkyBox;
import sandy.util.LoaderQueue;
import sandy.util.NumberUtil;
import sandy.materials.Material;

/**
 * PanoDemo is here to demonstrate the Sandy SkyBox.
 * The images GOLD11 - GOLD66 are © VRWAY Communication
 * We are allowed to use them for demo of Sandy 3d
 * provided we credit them with name and a link to their site:
 * http://www.arounder.com/
 *
 * @author	petit@petitpub.com
 */
class PanoDemo extends Sprite
{
	public function new():Void
	{
		running = false;
	 	keyPressed = new Array();
	 	queue = new LoaderQueue();

		super();

		init();
		Lib.current.stage.addChild(this);
	}
	
	private var scene:Scene3D;
	private var shape:SkyBox;
	private var planeNames:Array<String>;
	private var running:Bool;
	private var keyPressed:Array<Bool>;
	private var queue:LoaderQueue;
	private var camera:Camera3D;

	public function init():Void
	{
		var root = createScene();
		camera = new Camera3D( 800, 500 );
		camera.fov = 50;
		// We must reset the camera to coinside with the real camera
		camera.z = 0;
		camera.rotateY -= 130; // Just to make the start interesting
		planeNames = [ "GOLD44", "GOLD22" , "GOLD66", "GOLD55","GOLD11" , "GOLD33" ];			
		scene = new Scene3D( "scene", this, camera, root );
		// --
		loadImages();	
	}

	// Keyboard events
	public function __onKeyDown(e:KeyboardEvent):Void
	{
           keyPressed[e.keyCode] = true;
	   switch( e.keyCode ) {
		case Keyboard.CONTROL :
			{camera.fov+=2;
			if (camera.fov > 80 ) camera.fov = 80;
			if (camera.fov < 20 ) camera.fov = 20;
			scene.render();
			}
		case Keyboard.SHIFT :
			{camera.fov-=2;
			if (camera.fov > 80 ) camera.fov = 80;
			if (camera.fov < 20 ) camera.fov = 20;
			scene.render();
			}
			
		case Keyboard.UP : 	
			scene.camera.tilt -= 0.5;
			scene.render();
		case Keyboard.DOWN :	
			scene.camera.tilt += 0.5;
			scene.render();
		case Keyboard.RIGHT :
			scene.camera.rotateY -= 2;
			scene.render();
		case Keyboard.LEFT : 
			scene.camera.rotateY += 2;
			scene.render();
		case Keyboard.SPACE : 
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
	}

	public function __onKeyUp(e:KeyboardEvent):Void
	{
		keyPressed[e.keyCode] = false;
	}
	
	// Mouse events
	private function downHandler( p_oEvt:MouseEvent ):Void
	{
		running = true;
	}
	private function upHandler( p_oEvt:MouseEvent ):Void
	{
		running = false;
	}
	// Mousweel handler changes field of view ( zooming )
	private function wheelHandler( p_oEvt:MouseEvent ):Void
	{
		camera.fov-=p_oEvt.delta;
		if (camera.fov > 80 ) camera.fov = 80;
		if (camera.fov < 20 ) camera.fov = 20;
		scene.render();
	}

	//  -- Loading images
	private function loadImages():Void
	{
		// --
		for ( i in 0...6)
		{
			queue.add( planeNames[i], new URLRequest("../assets/golden/"+planeNames[i]+".jpg") );
		}
		// --
		queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadComplete );
		queue.start();
	}
	
	private function getMaterial( p_nId:UInt ):Material
	{
		var l_nPrecision:UInt = 10;
		var l_oMat:BitmapMaterial = new BitmapMaterial( Reflect.field( queue.data.get(planeNames[p_nId]), "bitmapData" ), null, l_nPrecision );
		l_oMat.repeat = true;
		l_oMat.maxRecurssionDepth = 6;
		return l_oMat;
	}
	
	// Image loading is complete, let's dress the skybox
	private function loadComplete( event:QueueEvent ):Void 
	{			
		shape.front.appearance = new Appearance( getMaterial(1) );
		shape.back.appearance = new Appearance( getMaterial(0) );
		shape.left.appearance = new Appearance( getMaterial(4) );
		shape.right.appearance = new Appearance( getMaterial(5) );
		shape.top.appearance = new Appearance( getMaterial(3) );
		shape.bottom.appearance = new Appearance(  getMaterial(2) );				
		// --
		
		shape.front.enableClipping = true;
		shape.back.enableClipping = true;
		shape.left.enableClipping = true;
		shape.right.enableClipping = true;
		shape.top.enableClipping = true;
		shape.bottom.enableClipping = true;
		// --
		stage.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
		// --		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
		// --
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		scene.render(); // first render
	}
	
	// Create the root Group and the object tree 
	private function createScene():Group
	{
		var root:Group = new Group("root");
		shape = new SkyBox( "pano", 5000, 4, 4 );
		root.addChild( shape );
		return root;
	}
	
	var frame:Null<Int>;
	private function enterFrameHandler( event : Event ) : Void
	{
		if( running )
		{
			scene.camera.rotateY += (400-mouseX)/400;
			scene.camera.tilt += ( mouseY - 250)/250;

			//scene.camera.tilt = NumberUtil.constrain( scene.camera.tilt, -88, 88 );		
			scene.render();
			flash.Lib.trace(Std.string( Math.floor( frame/(Lib.getTimer()) *1000 ) ) + 'fps');

		}
	}
	
	// Entry point for the application
	static function main () {
		new PanoDemo();
	}
}
