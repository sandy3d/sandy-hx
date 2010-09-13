package;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Point;
import flash.Lib;

import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.extrusion.data.Polygon2D;
import sandy.extrusion.data.Curve3D;
import sandy.extrusion.Extrusion;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.MediumAttributes;

class Advanced extends Sprite
{
	private var scene:Scene3D;

	private var ext:Extrusion;

	static function main() : Void
	{
		Lib.current.addChild( new Advanced() );
	}
	
	public function new():Void
	{
		super();
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
		Lib.current.stage.align = StageAlign.BOTTOM_RIGHT;

		var jack:Bitmap = getLibBitmap("Jack"); jack.y = 300; addChild (jack);
		var sandySprite:Sprite = new Sprite(); addChild (sandySprite);

		// minimal sandy setup
		scene = new Scene3D ("scene", sandySprite, new Camera3D (400, 300), new Group("root"));

		// tentacle profile
		var profile:Polygon2D = new Polygon2D ([
			new Point (-3, 25), new Point (-34, -1), new Point (-2, -26), new Point (20, -13), new Point (20, 14)
		]);

		// create tentacle
		var tentacle:Curve3D = new Curve3D();
		for ( i in 0 ... 21 ) {
			// add path point (arbitrary formula here)
			tentacle.v.push (new Point3D (i * i - 100 - 100 * Math.sin ((i - 5) * 0.2), 100 - i * i, 20 * i));
			// specify tangent Point3D at that point (for best results, we derive this from path equation here)
			var t:Point3D = new Point3D (2 * i - 100 * 0.2 * Math.cos ((i - 5) * 0.2), -2 * i, 20); t.normalize ();
			tentacle.t.push (t);
			// specify normal Point3D at that point (as you see, it does not have to be accurate :)
			var n:Point3D = new Point3D (0.707, 0.707, 0); n.crossWith (t);
			tentacle.n.push (n);
			// specify profile scale at that point (arbitrary formula, again)
			tentacle.s.push (0.1 * i);
		}

		// create extrusion
		ext = new Extrusion ("kraken", profile, tentacle.toSections (), false, false); scene.root.addChild (ext);
		// add some material
		var material:BitmapMaterial = new BitmapMaterial(getLibBitmap("Tentacle").bitmapData,
			new MaterialAttributes ([new MediumAttributes (0xFFFFFFFF, new Point3D (0, 0, 310), new Point3D (0, 0, 310))]));
		material.setTiling (1, 15);
		ext.appearance = new Appearance (material);

		// show it
		scene.render ();
	}
	
	static function getLibBitmap( name : String ) : Bitmap
	{
		var mc : MovieClip = Lib.attach( name );
		var bitmap : Bitmap = new Bitmap( new BitmapData( Std.int( mc.width ), Std.int( mc.height ), true ) );
		bitmap.bitmapData.draw( mc );
		return bitmap;
	}
}
