import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;


import sandy.primitive.TerrainGenerator;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.WireFrameMaterial;
import sandy.view.BasicView;


class Terrain extends BasicView
{
	private var terrainIdx : Int;
	private var terrain:Array<TerrainGenerator>;
	private var pic:Bitmap;

	private var waterAlpha : BitmapData;
	private var waterTexture : BitmapData;
	private var waterRect : Rectangle;

	public function new()
	{
		super();
		flash.Lib.current.addChild(this);

		init( 400, 550 );

		camera.z = -8000;
		camera.y = 4000;
		camera.lookAt(0,0,0);
		rootNode.addChild(camera);

		terrain = new Array();

		var i = 0;
		//
		terrain[i] = new TerrainGenerator("Mountainous", 30, 128, 3, 6000, 6000, 15,100,100, false,false, 10, 7, true);
		terrain[i].appearance = new Appearance( new WireFrameMaterial(1, 0x11EE22) );
		//
		i++;
		terrain[i] = new TerrainGenerator("Water", 1000000,
		128, 9, 6000, 6000, 10,60,60, false,false, 15,
		BitmapDataChannel.BLUE, false);
		terrain[i].appearance = new Appearance( new BitmapMaterial(terrain[1].perlin) );
		//
		i++;
		terrain[i] = new TerrainGenerator("Water 2", 1000000,
		128, 9, 6000, 6000, 10,60,60, false,false, 15,
		BitmapDataChannel.BLUE, false);
		waterAlpha = new BitmapData(60, 60, true, 0x03000000);
		waterTexture = new BitmapData(60, 60, true, 0xFFFF00FF);
		waterRect = new Rectangle(0,0,60, 60);
		terrain[i].appearance = new Appearance( new BitmapMaterial(waterTexture) );
		//
		i++;
		terrain[i] = new TerrainGenerator("Gentle Hills", 10, 128, 9,
		6000, 6000, 10,120,120, false,false, 15, 7, true);
		terrain[i].appearance = new Appearance( new WireFrameMaterial(1, 0x11EE22) );
		//
		i++;
		terrain[i] = new TerrainGenerator("Smooth Hills", 10, 128, 9,
		6000, 6000, 10,120,120, true,true, 30, 7, true);
		terrain[i].appearance = new Appearance( new WireFrameMaterial(1, 0x11EE22) );

		for(x in 1...terrain.length)
			terrain[x].visible = false;

		for(x in 0...terrain.length)
			rootNode.addChild(terrain[x]);

		pic = new Bitmap(terrain[0].perlin);
		addChild(pic);

		terrainIdx = 0;
		render();

		stage.addEventListener(flash.events.MouseEvent.CLICK, onClick);
	}


	public static function main() {
		new Terrain();
	}

	public override function simpleRender( pEvt:Event = null ):Void
	{
		terrain[terrainIdx].moveMap(0, 2);
		var p = new Point(0,0);
		pic.bitmapData = terrain[terrainIdx].perlin;
		if(terrain[terrainIdx].name == "Water 2") {
			waterTexture.copyPixels(
				terrain[terrainIdx].perlin,
				waterRect,
				p,
				waterAlpha,
				p,
				false
			);
		}

		super.simpleRender( pEvt );
	}

	private function onClick(_) {
		terrain[terrainIdx].visible = false;
		terrainIdx++;
		if(terrainIdx >= terrain.length)
			terrainIdx = 0;
		terrain[terrainIdx].visible = true;
	}
}
