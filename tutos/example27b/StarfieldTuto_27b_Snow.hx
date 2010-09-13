import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.StarField;
import sandy.core.scenegraph.Sprite2D;
import sandy.core.Scene3D;
import sandy.materials.Material;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.MediumAttributes;
import sandy.core.data.Vertex;
import sandy.core.data.Point3D;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;

class StarfieldTuto_27b_Snow extends Sprite {
	// screen size
	static var w = 400;
	static var h = 300;
	// sandy scene
	private var scene:Scene3D;
	// snowflakes starfield
	private var snow:StarField;
	// trees array
	private var trees:Array<Sprite2D>;

	public static function main() : Void
	{
		flash.Lib.current.stage.addChild( new StarfieldTuto_27b_Snow() );
	}

	public function new () : Void {
		super();
		trees = [];
		// set up scene
		scene = new Scene3D ("StarField", this, new Camera3D (w, h), new Group (""));
		scene.camera.near = 0;
		// set up snow
		snow = new StarField ();

		// TODO make snowflakes here
		var snowflake:Snowflake = new Snowflake();

		for ( k in 0 ... 1000 )
		{
			snow.stars [k] = new Vertex (
				/* .x = */ w * (k - 500) / 500,
				/* .y = */ 600 * (Math.random () - 0.5),
				/* .z = */ (1000 - scene.camera.z) * Math.random () + scene.camera.z
			);
			snow.starSprites [k] = snowflake;
		}

		snow.depth = -1; scene.root.addChild (snow);

		// set up trees in the background
		var tree_bmp:BitmapData = new TreePng (1, 1);
		var darkness:Material = new Material (
			new MaterialAttributes (
				[
					new MediumAttributes (0xFF000000,
					new Point3D (0, 0, 300),
					new Point3D (0, 0, 1000))
				]
			)
		);
		for ( i in 0 ... 16 )
		{
			trees [i] = new Sprite2D ("tree" + i, new Bitmap (tree_bmp),
				0.5 * (1 + Math.random ()));
			trees [i].autoCenter = false;
			trees [i].floorCenter = true;
			trees [i].x = w * (i - 8) / 8;
			trees [i].y = -tree_bmp.height;
			trees [i].z = (1000 - scene.camera.z) * Math.random () + scene.camera.z;
			trees [i].material = darkness;

			scene.root.addChild (trees [i]);
		}

		// subscribe to Event.ENTER_FRAME
		addEventListener (Event.ENTER_FRAME, enterFrameHandler);
	}


	private function enterFrameHandler (event:Event) : Void {
		// move trees
		for ( i in 0 ... trees.length ) {
			trees [i].z -= 10; if (trees [i].z < scene.camera.z) trees [i].z = 1000;
		}
		
		// move snowflakes
		var star : Vertex = null;
		for ( k in 0 ... 1000 ) {
			star = snow.stars[ k ];
			star.z -= 10; if (star.z < scene.camera.z) star.z = 1000;
			// additionally, move them down
			star.y -= 5; if (star.y < -300) star.y = 300;
			// additionally, move them side to side
			star.x = w * (k - 500) / 500 + 10 * Math.sin (star.y * 3e-2);
		}

		// render the scene
		scene.render ();
	}

}

class TreePng extends flash.display.BitmapData
{
	
}

class Snowflake extends flash.display.Sprite
{
	
}
