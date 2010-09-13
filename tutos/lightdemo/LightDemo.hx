import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.Lib;

import sandy.core.Scene3D;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.attributes.MaterialAttributes;
//import sandy.materials.attributes.PhongAttributes;
import sandy.parser.IParser;
import sandy.parser.Parser;
import sandy.parser.ParserEvent;
import sandy.primitive.Sphere;

class LightDemo extends Sprite
{

	private var t:Int;
	private var rT:Int;
	private var frame:Int;

	public function new(d = "goo")
	{
		t = rT = 0;
		frame = 0;
		keyPressed = new Array();
		super();

		Lib.current.stage.addChild( this );
		init();
	}

	private var m_oSphere:Sphere;
	private var m_oScene:Scene3D;
	private var rhino:Shape3D;

	private var keyPressed:Array<Bool>;
	var myTextField:TextField;

	public function init():Void
	{
		var lCamera:Camera3D = new Camera3D( 640, 480 );
		lCamera.z = -1000;
		lCamera.x = 160;
		lCamera.y = 42;
		m_oScene = new Scene3D( "mainScene", this, lCamera );

		myTextField = new TextField();
		Lib.current.stage.addChild(myTextField);
		myTextField.width = 600;

		// --
		load();
	}

	private function _enableEvents():Void
	{
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );
	}


	public function __onKeyDown(e:KeyboardEvent):Void
	{
           keyPressed[e.keyCode]=true;
       }

       public function __onKeyUp(e:KeyboardEvent):Void
       {
          keyPressed[e.keyCode]=false;
       }

 		private function _createMaterialAttributes():MaterialAttributes
 		{
 			return new MaterialAttributes( /*[new PhongAttributes(true, 0.2)]*/ );
 		}

  	private function _createAppearance():Appearance
  	{
  		var l_oMat:BitmapMaterial = new BitmapMaterial( new Texture() );//, _createMaterialAttributes() );
  		//l_oMat.lightingEnable = true;
  		return new Appearance( l_oMat );
  	}

  	private function load():Void
  	{
  		var l_oParser:sandy.parser.ASEParser = Parser.create( "../assets/Rhino.ASE", Parser.ASE, 0.1 );
  		l_oParser.standardAppearance = _createAppearance();
  		l_oParser.addEventListener( ParserEvent.INIT, _createScene3D );
  		l_oParser.parse();
  	}

 		private function _createScene3D( p_oEvt:ParserEvent ):Void
	{
		rT = Lib.getTimer();
		m_oScene.root = p_oEvt.group;
		rhino = untyped m_oScene.root.children[0];
		//m_oScene.root = new Group();
		/*
		m_oSphere = new Sphere("mySphere", 30 );
		m_oSphere.x = 200;
		m_oSphere.geometryCenter = new Point3D( 50, 0, 0 );
		var l_oSphereMaterial:ColorMaterial = new ColorMaterial( 0xFF0000, 1, _createMaterialAttributes() );
		l_oSphereMaterial.lightingEnable = true;
		m_oSphere.appearance = new Appearance( l_oSphereMaterial  );
		m_oScene.root.addChild( m_oSphere );
		*/
		m_oScene.root.addChild( m_oScene.camera );

		_enableEvents();

	}

	private function enterFrameHandler( event : Event ) : Void
	{
			/*
			var cam:Camera3D = m_oScene.camera;
		// --
		if( keyPressed[39] )
		{
		    cam.rotateY -= 5;
		}
		if( keyPressed[37] )
		{
		    cam.rotateY += 5;
		}
		if( keyPressed[38] && !keyPressed[32] )
		{
		    cam.moveForward( 10 );
		}
		if( keyPressed[40] && !keyPressed[32]  )
		{
		    cam.moveForward( -10 );
		}

		if( keyPressed[38] && keyPressed[32]  )
		{
		    cam.moveVertically( 10 );
		}
		if( keyPressed[40] && keyPressed[32]  )
		{
		    cam.moveVertically( -10 );
		}

		// --
		for ( l_oObject in m_oScene.root.children )
		{
			if( Std.is(l_oObject, Shape3D) )
			{
				l_oObject.rotateY ++;
			}
		}
		*/
		frame++;

		rhino.rotateY++;
		// --
		m_oScene.render();

		if ( frame == 1000 ) {
			var fin = Lib.getTimer();
				trace("Total execution time: "+ (fin - t) );
				trace("Rendering time: " + (fin -rT) );
				/*
							var c:Float = Math.floor( frame/(Lib.getTimer() - t) *100000 );
							var out:String = Std.string( c/100 ) + ' fps';

							myTextField.text = out;
					*/

				removeEventListener(Event.ENTER_FRAME, enterFrameHandler );
				rhino.destroy();
		}
	}

	static function main () { new LightDemo(); }

}

class Texture extends BitmapData
{
	public function new()
	{
		super(0,0);
	}
}

