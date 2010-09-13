import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Sprite2D;
import sandy.core.scenegraph.TransformGroup;
import sandy.primitive.Sphere;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;

import flash.display.MovieClip;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.Lib;

class Planet extends Sprite {

		var scene:Scene3D;
		var globe:TransformGroup;
		var radius:Float;
		var sphere:Sphere;

		public function new () 
		{ 
				super(); 

				scene = new Scene3D( "myScene", this, new Camera3D( 400, 300 ), new Group("root") );
				globe = new TransformGroup();
				 
				var quality:Int = 15;

				radius = 100; 
				sphere = new Sphere ("mySphere", radius, quality, quality);

				sphere.appearance = new Appearance(  new BitmapMaterial( new World() ) );
				sphere.rotateY += (360 / quality  + 180);
				 
				globe.addChild (sphere); 

				scene.camera.y = 200; 
				scene.camera.lookAt (0, 0, 0);

				scene.root.addChild( globe );

var havana:Bitmap = new Bitmap( new Havana() );
var kingston:Bitmap = new Bitmap( new Kingston() );
				addMarker (23.13, -82.38, havana );
				addMarker (17.98, -76.80, kingston);

				rotateGlobe (null);

				Lib.current.stage.addEventListener (MouseEvent.MOUSE_MOVE, rotateGlobe); 

				Lib.current.stage.addChild(this);
		}

		function rotateGlobe (e:MouseEvent):Void
		{
				globe.rotateY = 0.1 * (Lib.current.stage.mouseX - 275); 
				scene.render();
		}

		function addMarker (lat:Float, lon:Float, marker:Bitmap):Void
		{
				lat *= Math.PI / 180;
				lon *= Math.PI / 180;

				var markerObject:Sprite2D = new Sprite2D ("marker", marker, 1);
				markerObject.autoCenter = false;

				globe.addChild (markerObject);

				markerObject.x = radius * Math.cos (lon) * Math.cos (lat);
				markerObject.z = radius * Math.sin (lon) * Math.cos (lat);
				markerObject.y = radius * Math.sin (lat);

		}

		static function main() {
				new Planet();
		}
}

class World extends flash.display.BitmapData {
		public function new () {
				super(0,0);
		}
}

/*
class HavanaMC extends flash.display.MovieClip {
		public function new () {
				var havana:Havana = new Havana();
				var tyBmp:flash.display.Bitmap = new flash.display.Bitmap( havana );
				super();
				this.addChild( tyBmp );
		}

}
*/

class Havana extends flash.display.BitmapData {
		public function new () {
				super(0,0);
		}
}

class Kingston extends flash.display.BitmapData {
		public function new () {
				super(0,0);
		}
}

