import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.Material;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.primitive.Box;
import sandy.primitive.Sphere;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;

class DesertShapes extends Sprite {
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var box:Box;
		private var sphere:Sphere;
		private var app01:Appearance;
		private var app02:Appearance;

		private var img:Palm;
		private var bitmap:Bitmap;

		public function new()
		{ 

				img = new Palm();
				bitmap = new Bitmap( img );

				super(); 

				camera = new Camera3D( 300, 300 );
				camera.z = -400;

				var root:Group = createScene();

				scene = new Scene3D( "scene", this, camera, root );

				addEventListener( Event.ENTER_FRAME, enterFrameHandler );
				Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyPressed );    

				Lib.current.stage.addChild(this);
		}

		private function createScene():Group
		{
				var g:Group = new Group();

				box = new Box( "box",80,80,80);

				box.rotateX = 30;
				box.rotateY = 30;
				box.x = -80;

				sphere = new Sphere("sphere", 50,10,10);
				sphere.x = 80;

				var materialAttr01:MaterialAttributes = new MaterialAttributes( 
								[new LightAttributes( true, 0.1)]
								);
				var material01:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr01 );
				material01.lightingEnable = true;
				app01 = new Appearance( material01 );

				var material02:BitmapMaterial = new BitmapMaterial( bitmap.bitmapData );
				material02.lightingEnable = true;
				app02 = new Appearance( material02 );

				box.appearance = app02;
				sphere.appearance = app02;

				g.addChild( box );
				g.addChild( sphere );

				return g;

		}

		private function enterFrameHandler( event : Event ) : Void
		{
				box.tilt += 1;
				box.pan += 1;
				sphere.pan += 1;
				scene.render();
		}

		private function keyPressed( event:flash.events.KeyboardEvent ):Void 
		{
				switch(event.keyCode) {
						case 38: // KEY_UP
								box.aPolygons[0].appearance = app02;
								box.aPolygons[1].appearance = app02;
								box.aPolygons[2].appearance = app02;
								box.aPolygons[3].appearance = app02;
						case 40: // KEY_DOWN
								box.appearance = app01;
						case 39: // KEY_RIGHT
								box.aPolygons[4].appearance = app02;
								box.aPolygons[5].appearance = app02;
								box.aPolygons[6].appearance = app02;
								box.aPolygons[7].appearance = app02;
						case 37: // KEY_LEFT
								box.aPolygons[8].appearance = app02;
								box.aPolygons[9].appearance = app02;
								box.aPolygons[10].appearance = app02;
								box.aPolygons[11].appearance = app02;
				}
		}

		static function main() {
				new DesertShapes();
		}

}

class Palm extends flash.display.BitmapData {
		public function new () {
				super(0,0);
		}
}
