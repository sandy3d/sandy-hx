
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;

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

	public class LightDemo extends Sprite
	{

		[Embed(source="../assets/texrin2.jpg")]
		private var Texture:Class;

// 		[Embed( source="assets/models/Rhino.ASE", mimeType="application/octet-stream" )]
// 		private var Rhino:Class;


		private var t:int;
		private var rT:int;
		private var frame:int;

		public function LightDemo()
		{
			t = rT = 0;
			frame = 0;
			init();
		}

		private var m_oSphere:Sphere;
		private var m_oScene:Scene3D;
		private var rhino:Shape3D;

		private var myTextField:TextField;

		public function init():void
		{
			var lCamera:Camera3D = new Camera3D( 640, 480 );
			lCamera.z = -1000;
			lCamera.x = 160;
			lCamera.y = 42;
			m_oScene = new Scene3D( "mainScene", this, lCamera );

			myTextField = new TextField();
			addChild(myTextField);
			myTextField.width = 600;

			// --
			load();
		}

		private function _enableEvents():void
		{
			addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}


		private function _createMaterialAttributes():MaterialAttributes
		{
			return new MaterialAttributes( /*[new PhongAttributes(true, 0.2)]*/ );
		}

		private function _createAppearance():Appearance
		{
			var l_oMat:BitmapMaterial = new BitmapMaterial( new Texture().bitmapData );
			//l_oMat.lightingEnable = true;
			return new Appearance( l_oMat );
		}

		private function load():void
		{
			var l_oParser:sandy.parser.IParser = Parser.create( "../assets/Rhino.ASE", Parser.ASE, 0.1 );
			l_oParser.standardAppearance = _createAppearance();
			l_oParser.addEventListener( ParserEvent.INIT, _createScene3D );
			l_oParser.parse();
		}

		private function _createScene3D( p_oEvt:ParserEvent ):void
		{
			rT = flash.utils.getTimer();
			m_oScene.root = p_oEvt.group;
			rhino = m_oScene.root.children[0];

			m_oScene.root.addChild( m_oScene.camera );

			_enableEvents();
		}

		private function enterFrameHandler( event : Event ) : void
		{
			frame++;

			rhino.rotateY++;
			// --
			m_oScene.render();

			if ( frame == 1000 ) {
					var fin:int = getTimer();
					var out:String = "Total execution time: "+ String( fin - t);
					out += "\nRendering time: " + String(fin -rT);
					/*
					var c:Float = Math.floor( frame/(Lib.getTimer() - t) *100000 );
					var out:String = Std.string( c/100 ) + ' fps';

					*/
					myTextField.text = out;
					removeEventListener(Event.ENTER_FRAME, enterFrameHandler );
					rhino.destroy();
			}
		}

// 		static function main () { new LightDemo(); }

	}

}
