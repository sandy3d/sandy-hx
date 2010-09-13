
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Mouse;
import flash.ui.Keyboard;
import flash.Lib;

import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.data.Point3D;
import sandy.events.SandyEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.primitive.Cylinder;
import sandy.primitive.KeyFramedShape3D;
import sandy.primitive.MD2;
import sandy.primitive.Sphere;
import sandy.util.LoaderQueue;

class TankGame extends Sprite {

	private var queue:LoaderQueue;
	private var scene:Scene3D;
	public var camera:Camera3D;
	private var arrayDemon:Array<KeyFramedShape3D>;
	private var demonTest:MD2;
	private var demondie:MD2;
	private var gun:Cylinder;
	private var bt:Array<Int>;
	private var bullet:Sphere;
	private var fire:Bool;
	private var directionBall:Float;
	private var idInterval:haxe.Timer;
	private var myText:TextField;
	private var myFormat:TextFormat;
	private var score:Int;

	public function new() { 
		arrayDemon = [];
		gun = new Cylinder( "gun", 3, 50, 13, 6 );
		bt = [];
		bullet = new Sphere( "bullet", 3);
		fire = false;
		directionBall = 0;
		idInterval = null;
		myText = new TextField();
		myFormat = new TextFormat();
		score = 0;

		super();

		queue = new LoaderQueue();
		queue.add( "demon", new URLRequest("../assets/demon/Demon.md2"), BIN );
		queue.add( "demondie", new URLRequest("../assets/demon/Demondie.md2"), BIN );
		queue.add( "demonSkin", new URLRequest("../assets/demon/Skindemon.jpg"), IMAGE );
		queue.add( "demondieSkin", new URLRequest("../assets/demon/Skindemondie.jpg"), IMAGE ); 
		queue.addEventListener(SandyEvent.QUEUE_COMPLETE, loadMD2Complete );
		queue.start();
	}

	private function loadMD2Complete(event:Event):Void {
		// let's add the "gun" in the screen
		gun.x = 0;
		gun.y = 50;
		gun.z = -260;
		gun.rotateX = 90;
		gun.geometryCenter = new Point3D(0,20,0);
		Mouse.hide();
		// let's add the score points:

		myText.width = 200;
		myText.text = "00";
		myFormat.color =  0x000000;
		myFormat.size = 24;  
		myFormat.italic = true;  
		myText.setTextFormat(myFormat);  
		myText.textColor = 0xFFFFFF;
		myText.x = 83;
		myText.y = 33;
		addChild(myText);

		// We create the "group" that is the tree of all the visible objects
		var root:Group = createScene();

		camera = new Camera3D( 600, 450 );
		camera.z = -400;
		camera.y = 100;

		camera.lookAt(0,0,0);

		// We create a Scene and we add the camera and the objects tree 
		scene = new Scene3D( "scene", this, camera, root );

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovedHandler);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );

		Lib.current.stage.addChild( this );
	}


	private function createScene():Group
	{
		// Create the root Group
		var g:Group = new Group();

		// the normal demon
		arrayDemon[0]  = new MD2 ( "dem", queue.data.get("demon"), 0.5 );
		arrayDemon[0].appearance = new Appearance (new BitmapMaterial( queue.data.get("demonSkin").bitmapData ));
		arrayDemon[0].z = (Math.random()-0.5)*1000 + 500;
		arrayDemon[0].x = (Math.random()-0.5)*600;
		arrayDemon[0].pan = 90;
		g.addChild( arrayDemon[0]);

		for ( i in 1...7 ){
			arrayDemon[i] = cast( arrayDemon[0].clone("dem"), KeyFramedShape3D );  
			arrayDemon[i].pan = 90;
			arrayDemon[i].z = (Math.random()-0.5)*1000 + 500;
			arrayDemon[i].x = (Math.random()-0.5)*600;
			g.addChild( arrayDemon[i] );
		}

		// the demondie
		arrayDemon[7] = new MD2 ("demdie", queue.data.get("demondie"), 0.5);
		arrayDemon[7].appearance = new Appearance (new BitmapMaterial( queue.data.get("demondieSkin").bitmapData ));
		arrayDemon[7].pan = 90;
		arrayDemon[7].visible = false;
		g.addChild( arrayDemon[7]);

		// let's concentrate on gun and bullets now:

		var materialAttr:MaterialAttributes = new MaterialAttributes( 
				[ new LightAttributes( true, 0.1) ]
				);

		var material:Material = new ColorMaterial( 0x666666, 1, materialAttr );
		material.lightingEnable = true;
		var app:Appearance = new Appearance( material );
		bullet.appearance = app;
		gun.appearance = app;

		bullet.visible = false;
		g.addChild(bullet);
		g.addChild(gun);
		return g;
	}


	private function enterFrameHandler( event : Event ) : Void {

		// let's make the monster walking
		for ( j in 0...7 ) {
			if (arrayDemon[j] != null) {
				arrayDemon[j].frame += 0.3;
				arrayDemon[j].z -= 1;
				if (arrayDemon[j].z < -100) { 
					arrayDemon[j].x = (Math.random()-0.5)*600;
					arrayDemon[j].z = 500;
				}
			}
		}
		// let's fire the bullet
		if(fire && bullet.z < 1000) {
			bullet.z +=25;
			bullet.x -=directionBall/2;
		} else {
			bullet.visible = false;
		}

		// let's check for hitting monster:
		for ( k in 0...7 ) {
			if (arrayDemon[k] != null) {
				var x1:Float = arrayDemon[k].x - bullet.x;
				var x2:Float = arrayDemon[k].y - bullet.y;
				var x3:Float = arrayDemon[k].z - bullet.z;
				var dist = Math.sqrt(x1*x1+x2*x2+x3*x3);
				if (dist < 60) {
					arrayDemon[7].x = arrayDemon[k].x;
					arrayDemon[7].y = arrayDemon[k].y;
					arrayDemon[7].z = arrayDemon[k].z;
					arrayDemon[7].frame = 0;
					arrayDemon[7].visible = true;
					arrayDemon[k].visible = false;
					//idInterval = setInterval( dieMonster, 100, k );
					idInterval = new haxe.Timer(100);
					idInterval.run = callback( dieMonster, k );
					bullet.z = 1100;
					score += 10; 
					myText.text = Std.string(score);
					myText.setTextFormat(myFormat);
					myText.textColor = 0xFFFFFF;
				}
			}
		}

		// let's clear interval now if any 
		if(idInterval != null && arrayDemon[7].frame>5){
			//idInterval = null;
		}
		scene.render();
	}

	private function dieMonster(h:Int){
	  if ( arrayDemon[7].visible )
	  {
		arrayDemon[7].frame += 0.3;
	} else { 
		arrayDemon[7].frame = 0;
	}
	  
			if (arrayDemon[7].frame > 5 && h != 7 ){
				arrayDemon[7].visible = false;
				arrayDemon[h].x = (Math.random()-0.5)*600;
				arrayDemon[h].z = 500;
				arrayDemon[h].visible = true;
			}
	}

	private function mouseMovedHandler(event:MouseEvent):Void {
		gun.roll=(300-event.stageX)/7;
	}

	private function keyPressed(event:KeyboardEvent):Void {
		switch(event.keyCode) {
			case Keyboard.SPACE:
				directionBall = gun.roll;
				fireBall();
		}
	}

	private function fireBall(){
		bullet.x = 0;
		bullet.y = 50;
		bullet.z = -260;
		fire = true;
		bullet.visible = true;
	}

	static function main() {
		new TankGame();
	}
}


