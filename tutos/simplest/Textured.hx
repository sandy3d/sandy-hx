import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.primitive.Sphere;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import flash.display.Sprite;
import flash.Lib;

class Textured extends Sprite {

		public function new () { 
				super(); 

				var scene:Scene3D = new Scene3D( "myScene", this, new Camera3D( 400, 300 ), new Group("root") );
				var sphere:Sphere = new Sphere("mySphere");

				sphere.appearance = new Appearance(  new BitmapMaterial( new Palm() ) );

				scene.root.addChild( sphere );
				scene.render();
				Lib.current.stage.addChild(this);
		}

		static function main() {
				new Textured();
		}
}

class Palm extends flash.display.BitmapData {
		public function new () {
				super(0,0);
		}
}

