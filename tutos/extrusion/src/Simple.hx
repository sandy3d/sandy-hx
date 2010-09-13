package ;

import flash.Lib;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Point;

import sandy.core.Scene3D;
import sandy.core.data.Matrix4;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.extrusion.Extrusion;
import sandy.extrusion.data.Polygon2D;

class Simple extends Sprite
{
	private var scene:Scene3D;
	private var ext:Extrusion;

	static function main() : Void
	{
		#if js
			haxe.Firebug.redirectTraces();
			neash.Lib.Init("Container", 400, 400);
			neash.Lib.Run();
		#end
		Lib.current.addChild( new Simple() );
	}
	
	public function new() : Void
	{
		super();
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		// minimal sandy setup
		scene = new Scene3D ("scene", this, new Camera3D (150, 150), new Group("root"));

		// letter Q profile
		var q:Polygon2D = new Polygon2D ([
			new Point (-24, 78), new Point (42, 78), new Point (73, 46), new Point (73, -10), 
				// two points along the cut:
				new Point (65, -17), new Point (58, -10), 
			new Point (57, 45), new Point (41, 62), new Point (-23, 63), new Point (-39, 45), new Point (-40, -8), new Point (-23, -24), new Point (40, -24), new Point (32, -19), new Point (48, -2), 
				// same two points along the cut again:
				new Point (58, -10), new Point (65, -17), 
			new Point (81, -33), new Point (65, -50), new Point (49, -34), new Point (41, -42), new Point (-23, -43), new Point (-57, -11), new Point (-56, 47)
		]);

		// first matrix does not transform profile at all
		var m0:Matrix4 = new Matrix4(); m0.identity ();

		// second matrix pushes profile 50 pixels backwards
		var m1:Matrix4 = new Matrix4(); m1.translation (0, 0, 50);

		// create extrusion
		var matrices : Array<Matrix4> = [m0, m1];
		ext = new Extrusion("q", q, matrices); scene.root.addChild (ext);

		// add some material
		ext.appearance = new Appearance (new ColorMaterial (0xFFAF00, 1,
			new MaterialAttributes ([new LightAttributes(false, 0.3)])));
		ext.appearance.frontMaterial.lightingEnable = true;

		// show it
		Lib.current.stage.addEventListener (Event.ENTER_FRAME, render);
	}

	private function render (e) : Void {
		ext.rotateY += 3; scene.render ();
	}
}
