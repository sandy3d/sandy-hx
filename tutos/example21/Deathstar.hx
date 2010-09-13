import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.Plane3D;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.Lib;

class Deathstar extends Sprite {
		private var world:Scene3D;
		
		private var dsMat1:BitmapMaterial;
		private var dsMat2:BitmapMaterial;
		private var dsMat3:BitmapMaterial;

		private var offset:Float;

		public function new () { 

				world = new Scene3D ("scene", this, new Camera3D (600, 300), new Group ("root"));
				offset = 0;

				super(); 

			dsMat1 = new BitmapMaterial (new ImageDS1 (1, 1), null, 5);
			dsMat1.repeat = true;
			dsMat1.maxRecurssionDepth = 10;
			
			dsMat2 = new BitmapMaterial (new ImageDS2 (1, 1), null, 5);
			dsMat2.repeat = true;
			dsMat2.maxRecurssionDepth = 8;
			
			dsMat3 = new BitmapMaterial (new ImageDS3 (1, 1), null, 5);
			dsMat3.repeat = true;
			dsMat3.maxRecurssionDepth = 7;

			var pLeft:Plane3D = new Plane3D ("p_left", 10000, 10000, 1, 1, Plane3D.ZX_ALIGNED);
			pLeft.appearance = new Appearance (dsMat1);
			pLeft.enableClipping = true;
			pLeft.x = -5000 -200; pLeft.y = -200; pLeft.z = 4000;

			var pRiht:Plane3D = new Plane3D ("p_riht", 10000, 10000, 1, 1, Plane3D.ZX_ALIGNED);
			pRiht.appearance = new Appearance (dsMat1);
			pRiht.enableClipping = true;
			pRiht.x = 5000 +200; pRiht.y = -200; pRiht.z = 4000;
			
			var pSidL:Plane3D = new Plane3D ("p_sidL", 10000, 400, 1, 1, Plane3D.YZ_ALIGNED);
			pSidL.appearance = new Appearance (dsMat2);
			pSidL.enableClipping = true;

			pSidL.x = -200; pSidL.y = -400; pSidL.z = 4000;

			pSidL.enableBackFaceCulling = false;

			var pSidR:Plane3D = new Plane3D ("p_sidR", 10000, 400, 1, 1, Plane3D.YZ_ALIGNED);
			pSidR.appearance = new Appearance (dsMat2);
			pSidR.enableClipping = true;
			pSidR.x = 200; pSidR.y = -400; pSidR.z = 4000;

			var pBott:Plane3D = new Plane3D ("p_bott", 10000, 400, 1, 1, Plane3D.ZX_ALIGNED);
			pBott.appearance = new Appearance (dsMat3);
			pBott.enableClipping = true;
			pBott.y = -600; pBott.z = 4000;

			var scene:Group = new Group ("root");

			scene.addChild (pLeft);
			scene.addChild (pRiht);
			scene.addChild (pSidL);
			scene.addChild (pSidR);
			scene.addChild (pBott);

			scene.addChild (world.camera);

			world.root = scene;

			addEventListener (Event.ENTER_FRAME, onEnterFrame);
			
			addEventListener (Event.ADDED_TO_STAGE, onAddedToStage);
			Lib.current.stage.addChild(this);
		}

		private function onAddedToStage (e:Event):Void
		{
			stage.quality = StageQuality.LOW; removeEventListener (Event.ADDED_TO_STAGE, onAddedToStage);
		}


		function onEnterFrame( event:Event ):Void {

			dsMat1.setTiling (20, 20, 0, -2 * offset);
			dsMat2.setTiling ( 1, 20, 0, -2 * offset);
			dsMat3.setTiling ( 1, 10, 0, -1 * offset);

			offset += 2e-2 + 2e-4 * (300 - mouseY);
			if (offset > 1) offset--;
			world.camera.x = mouseX - 300;
			world.camera.y = mouseY;

			world.camera.lookAt (0, -200, 0);
			world.render ();
		}

		static function main() {
				new Deathstar();
		}
}

class ImageDS1 extends BitmapData {
		public function new (a:Int,b:Int) {
				super (0,0);
		}
}

class ImageDS2 extends BitmapData {
		public function new (a:Int,b:Int) {
				super (0,0);
		}
}

class ImageDS3 extends BitmapData {
		public function new (a:Int,b:Int) {
				super (0,0);
		}
}

