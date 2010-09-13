import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.Event;

import flash.text.TextField;
import flash.Lib;

import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Box;
import sandy.primitive.Cylinder;
import sandy.primitive.Plane3D;

class ClippingDemo extends Sprite
{
	static inline var  SCREEN_WIDTH:Int = 640;
	static inline var  SCREEN_HEIGHT:Int = 450;
	
	public static inline var  radius:UInt = 800;
	public static inline var  innerRadius:UInt = 700;
	
	private var box:Box;
	private var world : Scene3D;
	private var camera : Camera3D;
	private var keyPressed:Array<Bool>;
	
	/*
	[Embed(source="assets/textures/ouem_el-ma_lake.jpg")]
	private var Texture:Class<BitmapData>;
	*/
	
	/*
	[Embed(source="assets/textures/may.jpg")]
	private var Texture2:Class<BitmapData>;
	*/
	
	private var frame:UInt;
	private var m_nWay:Int;
	private var t:Float;
	
	public function new()
	{
	 frame = 0;
	 m_nWay = 1;
		super();

		Lib.current.stage.addChild( this );
		init();
	}
	
	public function init():Void
	{
		// -- INIT
		keyPressed = [];
		// -- User interface
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
	
		// --
		var l_mcWorld:MovieClip = new MovieClip();
		l_mcWorld.x = (Lib.current.stage.stageWidth - SCREEN_WIDTH) / 2;
		l_mcWorld.y = 0;//(Lib.current.stage.stageHeight - SCREEN_HEIGHT) / 2;
		addChild(l_mcWorld);
		// --
		camera = new Camera3D( SCREEN_WIDTH, SCREEN_HEIGHT );
		camera.y = 80;
		// -- create scen

		var lPlane:Plane3D = new Plane3D( "myPlane", 1500, 1500, 2, 2, Plane3D.ZX_ALIGNED );
		//lPlane.swapCulling();
		//lPlane.enableBackFaceCulling = false;
		//lPlane.enableClipping = true;
		lPlane.appearance = new Appearance( new ColorMaterial( 0xd27e02, 1) );
		lPlane.enableForcedDepth = true;
		lPlane.forcedDepth = 5000000;
		
		var cylinder:Shape3D = new Cylinder( "myCylinder", radius, 600, 15, 8, radius, true, true);
		cylinder.swapCulling();
		cylinder.enableClipping = true;
		cylinder.useSingleContainer = false;
		cylinder.y = 200;
		
		box = new Box( "box", 150, 150, 150, 4 );
		box.y = 100;
		box.enableBackFaceCulling = false;
		box.enableClipping = true;

		
		var pic:Texture = new Texture();
		var pic2:Texture2 = new Texture2();
		
		var lAppearance:Appearance = new Appearance( new BitmapMaterial( pic2 ) ,
										 			 new BitmapMaterial( pic ) );
		
		box.appearance = lAppearance;
		//(box.appearance.frontMaterial as ColorMaterial).lightingEnable = true;
		lPlane.appearance = new Appearance( new ColorMaterial() );
		
		cylinder.appearance = new Appearance( new BitmapMaterial( pic2, new MaterialAttributes( [new LineAttributes()] ) ) );
		
		// --			
		var g:Group = new Group("root");
		g.addChild( lPlane ); 
		g.addChild( cylinder );
		g.addChild( box );
		
		world = new Scene3D( "scene", this, camera, g );
		g.addChild( world.camera );
		// --
		t = Lib.getTimer();
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		
		return;
	}


	public function __onKeyDown(e:KeyboardEvent):Void
	{
           keyPressed[e.keyCode]=true;
       }

       public function __onKeyUp(e:KeyboardEvent):Void
       {
          keyPressed[e.keyCode]=false;
       }
 
	private function enterFrameHandler( event : Event ) : Void
	{
		var cam:Camera3D = world.camera;
		//var oldPos:Point3D = cam.getPosition();
		// --
		/*
		if( keyPressed[Keyboard.RIGHT] ) 
		{   
		    cam.rotateY -= 5;
		}
		if( keyPressed[Keyboard.LEFT] )     
		{
		    cam.rotateY += 5;
		}		
		if( keyPressed[Keyboard.UP] )
		{ 
		    cam.moveForward( 15 );
		}
		if( keyPressed[Keyboard.DOWN] )
		{ 
		    cam.moveForward( -15 );
		}
		*/
		cam.moveForward( m_nWay * 15 );
		if( cam.getPosition().getNorm() > innerRadius )
			m_nWay = -m_nWay;
		
		box.rotateX += 1;
		box.rotateZ += 2;
		world.render();

		frame++;
		if( frame == 1000 )
		{
			var elapsed:Float = (Lib.getTimer() - t);
			flash.Lib.trace("Rendering time for 1000 frames = "+(elapsed)+" ms" );
			removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	}
	static function main () {
			new ClippingDemo();
	}
}


class Texture extends BitmapData
{
	public function new()
	{
		super(0,0);
	}
}

class Texture2 extends BitmapData
{
	public function new()
	{
		super(0,0);
	}
}

