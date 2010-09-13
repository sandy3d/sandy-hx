import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import sandy.core.Scene3D;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.attributes.ALightAttributes;
import sandy.materials.attributes.GouraudAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.PhongAttributes;
import sandy.materials.attributes.CelShadeAttributes;
import sandy.parser.IParser;
import sandy.parser.Parser;
import sandy.parser.ParserEvent;
import sandy.materials.ColorMaterial;
import sandy.materials.Material;
import sandy.materials.attributes.OutlineAttributes;
import sandy.materials.attributes.PhongAttributesLightMap;

import haxe.Resource;

class ShadeDemo extends Sprite
{
	public static inline var PHONG:String = "phong";
	public static inline var GOURAUD:String = "gouraud";
	public static inline var FLAT:String = "flat";
	public static inline var CEL:String = "cel";
	public static inline var NONE:String = "none";

	private var m_oScene:Scene3D;
	private var keyPressed:IntHash<Bool>;

	public static function main() {
		new ShadeDemo();
	}

	public function new()
	{
		super();
		flash.Lib.current.addChild(this);

		var tf = new flash.text.TextField();

		var format = tf.getTextFormat();
		format.font = "_sans";
		tf.defaultTextFormat = format;
		tf.selectable = false;
		tf.autoSize = flash.text.TextFieldAutoSize.CENTER;
		tf.mouseEnabled = false;
		tf.width = stage.stageWidth;
		addChild(tf);
		tf.text = "Cel, Cel, Phong, Gourard, Flat";
		keyPressed = new IntHash<Bool>();

		var lCamera:Camera3D = new Camera3D( 640, 480 );
		lCamera.z = -550;
		lCamera.y = 80;
		m_oScene = new Scene3D( "mainScene", this, lCamera );
		// --
		load();
	}


	private function _enableEvents():Void
	{
		stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
		addEventListener( Event.ENTER_FRAME, enterFrameHandler );
	}


	public function __onKeyDown(e:KeyboardEvent):Void
	{
		keyPressed.set(e.keyCode, true);
	}

	public function __onKeyUp(e:KeyboardEvent):Void
	{
		keyPressed.set(e.keyCode, false);
	}

	private function _createMaterialAttributes( p_sType:String, outline:Bool ):MaterialAttributes
	{
		var l_oAttr:ALightAttributes = null;
		switch( p_sType )
		{
			case CEL:
				//phong attributes light map
				var palm:PhongAttributesLightMap = new PhongAttributesLightMap();
				//palm.alphas = [[1, 1, 1, 1, 1, 1]];
				/*palm.colors = [[0xFFFF33, 0xFFFF33,
								0xFFCC33, 0xFFCC33,
								0xFF9933, 0xFF9933]];*/
				palm.alphas = [[0.2, 0.2, 0., 0., 0.2, 0.2]];
				palm.colors = [[0xFFFFFF, 0xFFFFFF,
								0x000000, 0x000000,
								0x000000, 0x000000]];
				palm.ratios = [[ 0.,40.,40.,80.,80.,160.]];
				l_oAttr = new CelShadeAttributes(palm);
			case GOURAUD:
				l_oAttr = new GouraudAttributes( true, 0.2 );
			case  PHONG:
				l_oAttr = new PhongAttributes( true, 0.2 );
				//l_oAttr.diffuse = 0.3;
				l_oAttr.specular = 0.5;
				l_oAttr.gloss = 20;
			case FLAT:
				l_oAttr = new LightAttributes( true, 0.2 );
			case NONE:
			default :
				l_oAttr = null;
		}
		if(outline)
			return new MaterialAttributes( [l_oAttr, new OutlineAttributes(1)] );
		else
			return new MaterialAttributes( [l_oAttr] );
	}

	private function _createAppearance( p_sType:String, p_bTexture:Bool, outline:Bool):Appearance
	{
		var l_oBitmap:Bitmap = new Bitmap(new Texture());
		var l_oMat:Material;
		if(p_bTexture == true){
			l_oMat = new BitmapMaterial( l_oBitmap.bitmapData, _createMaterialAttributes(p_sType, outline) );
		} else {
			l_oMat = new ColorMaterial(0xFFCC33,1, _createMaterialAttributes(p_sType, outline));
		}
		l_oMat.lightingEnable = true;
		return new Appearance( l_oMat );
	}

	private function load():Void
	{
		var l_oParser:IParser = Parser.create( Resource.getBytes("Kitty"), Parser.ASE, 0.2 );
		l_oParser.standardAppearance = _createAppearance( PHONG, true, false );
		l_oParser.addEventListener( ParserEvent.INIT, _createScene3D );
		l_oParser.parse();
	}

	private function _createScene3D( p_oEvt:ParserEvent ):Void
	{
		m_oScene.root = new sandy.core.scenegraph.Group();
		m_oScene.root.addChild( m_oScene.camera );
		// --
		var l_oKitty:Shape3D = cast p_oEvt.group.children[0];
		l_oKitty.x = 100;
		l_oKitty.appearance = _createAppearance(CEL, false, true );

		var shapes = new Array<Shape3D>();
		for(i in 0...5) {
			var s = l_oKitty.clone("kitty" + i);
			s.x = -200 + (i * 100);
			s.y = 100;
			shapes[i] = s;
		}
		shapes[0].appearance = _createAppearance(CEL, true, true );
		shapes[1].appearance = _createAppearance(CEL, true, false );
		shapes[2].appearance = _createAppearance(PHONG, true, false );
		shapes[3].appearance = _createAppearance(GOURAUD, true, false);
		shapes[4].appearance = _createAppearance(FLAT, true, false );
		for(i in 0...5)
			m_oScene.root.addChild(shapes[i]);

		// --
		for(i in 0...5) {
			var s = l_oKitty.clone("kitty" + i);
			s.x = -200 + (i * 100);
			shapes[i] = s;
		}
		shapes[0].appearance = _createAppearance(CEL, false, true );
		shapes[1].appearance = _createAppearance(CEL, false, false );
		shapes[2].appearance = _createAppearance(PHONG, false, false );
		shapes[3].appearance = _createAppearance(GOURAUD, false, false);
		shapes[4].appearance = _createAppearance(FLAT, true, true );
		for(i in 0...5)
			m_oScene.root.addChild(shapes[i]);

		// --
		_enableEvents();
	}

	private function enterFrameHandler( event : Event ) : Void
	{
		var cam:Camera3D = m_oScene.camera;
		// --
		if( keyPressed.get(Keyboard.RIGHT) == true )
		{
			cam.rotateY -= 5;
		}
		if( keyPressed.get(Keyboard.LEFT) == true )
		{
			cam.rotateY += 5;
		}
		if( keyPressed.get(Keyboard.UP) == true )
		{
			cam.moveHorizontally( 10 );
		}
		if( keyPressed.get(Keyboard.DOWN) == true )
		{
			cam.moveHorizontally( -10 );
		}
		for( l_oShape in m_oScene.root.children )
		{
			if( Std.is(l_oShape,Shape3D) )
				cast(l_oShape,Shape3D).rotateY++;
		}

		m_oScene.render();
	}

}

class Texture extends BitmapData {
	public function new () {
		super(0,0);
	}
}


