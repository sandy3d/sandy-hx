// CustomBSPExample.hx
package ;
import flash.display.Sprite;
import sandy.core.data.BSPNode;
import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.primitive.Box;

class CustomBSPExample extends Sprite {

	private var box:Box;
	private var scene:Scene3D;
	public function new () {
		super ();

        scene = new Scene3D ("scene", this, new Camera3D (), new Group ("root"));
        box = new Box ("box", 10, 10, 10, "quad"); scene.root.addChild (box);
		box.rotateX = 123; box.rotateY = 45; box.rotateZ = 67;
        box.sortingMode = Shape3D.SORT_CUSTOM_BSP;

		// box is actually convex shape, so we can cut it in any order
		box.bsp = new BSPNode ();
		box.bsp.plane = box.aPolygons [0].getPlane ();
		box.bsp.faces = [ box.aPolygons [0] ];

		// any face is behind any other faces
		// I think this means being in negative subspace
		box.bsp.negative = new BSPNode ();
		box.bsp.negative.plane = box.aPolygons [4].getPlane ();
		box.bsp.negative.faces = [ box.aPolygons [4] ];

		box.bsp.negative.negative = new BSPNode ();
		box.bsp.negative.negative.plane = box.aPolygons [5].getPlane ();
		box.bsp.negative.negative.faces = [ box.aPolygons [5] ];

		box.bsp.negative.negative.negative = new BSPNode ();
		box.bsp.negative.negative.negative.plane = box.aPolygons [3].getPlane ();
		box.bsp.negative.negative.negative.faces = [ box.aPolygons [3] ];

		box.bsp.negative.negative.negative.negative = new BSPNode ();
		box.bsp.negative.negative.negative.negative.plane = box.aPolygons [1].getPlane ();
		box.bsp.negative.negative.negative.negative.faces = [ box.aPolygons [1] ];

		box.bsp.negative.negative.negative.negative.negative = new BSPNode ();
		box.bsp.negative.negative.negative.negative.negative.plane = box.aPolygons [2].getPlane ();
		box.bsp.negative.negative.negative.negative.negative.faces = [ box.aPolygons [2] ];

		// render
		scene.camera.z = -123;
		addEventListener ("enterFrame", loop);
	}

	private function loop (e):Void {
		// some motion
		box.rotateX += 1;
		box.rotateY = box.rotateX * box.rotateZ / 360;
		box.rotateZ += 2;

        scene.render();
	}
	
	public static function main () {
		flash.Lib.current.addChild (new CustomBSPExample ());
	}
}