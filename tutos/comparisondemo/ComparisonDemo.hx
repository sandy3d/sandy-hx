import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.Lib;

import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.parser.IParser;
import sandy.parser.Parser;
import sandy.parser.ASEParser;
import sandy.parser.ParserEvent;

class ComparisonDemo extends Sprite
{
	/*
	[Embed(source="assets/textures/texrin2.jpg")]
	private var Texture:Class;
	*/
	
	/*
	[Embed( source="assets/models/Rhino.ASE", mimeType="application/octet-stream" )]
	private var Rhino:Class;
	*/
	
	private var kitty:Shape3D;
	private var frame:Int;
	private var t:Float;
	private var m_oScene:Scene3D;
	private var aObjects:Array<Shape3D>;
	
	public function new()
	{
	 frame = 0;
	 t = 0;
	 aObjects = new Array();

		super();

		myTextField = new TextField();
		Lib.current.stage.addChild(myTextField);
		myTextField.width = 600;

		Lib.current.stage.addChild( this );
		init();
	}

	var myTextField:TextField;
	
	public function init():Void
	{
		// --
		var lCamera:Camera3D = new Camera3D( 640, 480 );
		lCamera.z = -1500;
		m_oScene = new Scene3D( "mainScene", this, lCamera );	
		// --
		load();
	}
	
	private function _enableEvents():Void
	{
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );
	}


  	private function _createAppearance():Appearance
  	{
  		var l_oMat:BitmapMaterial = new BitmapMaterial( new Texture() );
  		return new Appearance( l_oMat );
  	}
  	
  	private function load():Void
  	{
  		var l_oParser:ASEParser = Parser.create( "../assets/Rhino.ASE", Parser.ASE, 0.1 );
  		l_oParser.standardAppearance = _createAppearance();
  		l_oParser.addEventListener( ParserEvent.INIT, _createScene3D );
  		l_oParser.parse();
  	}
  	
 		private function _createScene3D( p_oEvt:ParserEvent ):Void
	{
		m_oScene.root = p_oEvt.group;
	
		var root:Group = p_oEvt.group;
		
		kitty = untyped root.children[0];
		//kitty.useSingleContainer = false;
		//kitty.enableClipping = true;
		
		var kitty2:Shape3D = kitty.clone("kitty2");
		kitty2.x = 400;
		//kitty2.useSingleContainer = false;
		//kitty2.enableClipping = true;
		root.addChild( kitty2 );
		
		var kitty3:Shape3D = untyped kitty.clone("kitty3");
		kitty3.x = -400;
		//kitty3.enableClipping = true;
		//kitty3.useSingleContainer = false;
		root.addChild( kitty3 );
		
		var kitty4:Shape3D = untyped kitty.clone("kitty4");
		kitty4.y = 200;
		//kitty4.enableClipping = true;
		//kitty4.useSingleContainer = false;
		root.addChild( kitty4 );
		
		var kitty5:Shape3D = untyped kitty.clone("kitty5");
		kitty5.y = -200;
		//kitty5.enableClipping = true;
		//kitty5.useSingleContainer = false;
		root.addChild( kitty5 );
		
		//root.useSingleContainer = false;
		
		aObjects.push( kitty );
		aObjects.push( kitty2 );
		aObjects.push( kitty3 );
		aObjects.push( kitty4 );
		aObjects.push( kitty5 );
	
		m_oScene.root.addChild( m_oScene.camera );
		
		t = Lib.getTimer();
		_enableEvents();
	}	
	
	private function enterFrameHandler( event : Event ) : Void
	{
		frame++;
		// --
		for ( kitty in aObjects )
			kitty.rotateY ++;
		// --
		m_oScene.render();
		
		var c:Float = Math.floor( frame/(Lib.getTimer() - t) *100000 );
				var out:String = Std.string( c/100 ) + ' fps';
		myTextField.text = out;

		if( frame == 1000 )
		{
			var elapsed:Float = (Lib.getTimer() - t);
			flash.Lib.trace( "Rendering time for 1000 frames = "+(elapsed)+" ms" );
		myTextField.text = "Rendering time for 1000 frames = "+(elapsed)+" ms";

			removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}
	}
	
	static function main () { new ComparisonDemo(); }
}

class Texture extends BitmapData
{
	public function new()
	{
		super(0,0);
	}
}

