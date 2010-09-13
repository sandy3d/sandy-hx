package;

import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Point;
import flash.Lib;

import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.extrusion.Extrusion;
import sandy.extrusion.data.Lathe;
import sandy.extrusion.data.Polygon2D;
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.GouraudAttributes;

class LatheExample extends Sprite
{
	private var scene:Scene3D;
	private var ext1:Extrusion;
	private var ext2:Extrusion;

	static function main() : Void
	{
		Lib.current.addChild( new LatheExample() );
	}
	
	public function new():Void
	{
		super();
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		// minimal sandy setup
		scene = new Scene3D ("scene", this, new Camera3D (300, 300), new Group("root"));

		// profiles
		var p1:Polygon2D = new Polygon2D ([
			new Point (35, 2), new Point (65, 2), new Point (65, -18), new Point (35, -18)
		]);

		var p2:Polygon2D = new Polygon2D ([
			new Point (8, -43), new Point (8, 27), new Point (43, 27), new Point (43, 8), new Point (27, 8), new Point (27, -25), new Point (42, -25), new Point (42, -43)
		]);

		// curves
		var lathe1:Lathe = new Lathe (new Point3D(), new Point3D (1, 1, 1), new Point3D (1, 0, 0), -1);
		var lathe2:Lathe = new Lathe (new Point3D(), new Point3D (1, 1, 1), new Point3D (1, 0, 0), 0, 5);

		// extrusions
		ext1 = new Extrusion ("ext0", p1, lathe1.toSections ());
		ext1.useSingleContainer = false; scene.root.addChild (ext1);

		ext2 = new Extrusion ("ext1", p2, lathe2.toSections ());
		ext2.useSingleContainer = false; scene.root.addChild (ext2);

		// add some materials
		ext1.appearance = new Appearance (new ColorMaterial (0x7F0000, 1,
			new MaterialAttributes ([ new LightAttributes(false, 0.6), new GouraudAttributes(false, 0.6) ])));
		ext1.appearance.frontMaterial.lightingEnable = true;

		ext2.appearance = new Appearance (new ColorMaterial (0x7F00, 1,
			new MaterialAttributes ([ new LightAttributes(false, 0.6), new GouraudAttributes(false, 0.6) ])));
		ext2.appearance.frontMaterial.lightingEnable = true;

		// show it
		Lib.current.addEventListener( Event.ENTER_FRAME, render );
	}

	private function render (e):Void {
		ext1.rotateY += 3; ext2.rotateY += 3; scene.render ();
	}
}
