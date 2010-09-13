
package sandy.primitive;

import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;

import sandy.core.scenegraph.Geometry3D;
import sandy.core.data.Vertex;

/**
* A Plane3D which is generated from pseudo-random perlin noise.
* @author Collin Cusce
* @author Russell Weir
**/
class TerrainGenerator extends Plane3D
{

	public var perlin:BitmapData;
	public var magnitude:Float;
	/** set to false to disable normals from being updated on each update. Default is true **/
	public var updateNormals:Bool;
	/** set to true to update bounding volumes on each update. Default is false **/
	public var updateBounds:Bool;

	private var sampleX:Int;
	private var sampleY:Int;
	private var quality:Int;
	private var oct:Int;
	private var seed:Int;
	private var stitch:Bool;
	private var fractals:Bool;
	private var bitChan:UInt;
	private var length:Int;
	private var height:Int;
	private var sampleRate:Int;
	private var gs:Bool;
	private var a:Array<Point>;

	/**
	* Generates terrain using Perlin noise.
	* <pre>
	* //Water
	* ter = new TerrainGenerator("MyTerrain", 1000000,
	* 128, 9, 6000, 6000, 10,60,60, false,false, 15,
	* BitmapDataChannel.BLUE, false);
	*
	* //Gentle Hills
	* ter = new TerrainGenerator("MyTerrain", 10, 128, 9,
	* 6000, 6000, 10,120,120, false,false, 15, 7, true);
	*
	* //Smooth Hills
	* ter = new TerrainGenerator("MyTerrain", 10, 128, 9,
	* 6000, 6000, 10,120,120, true,true, 30, 7, true);
	*
	* //Mountainous
	* ter = new TerrainGenerator("MyTerrain", 30, 128, 3,
	* 6000, 6000, 15,100,100, false,false, 10, 7, true);
	* </pre>
	*
	* The only rule to remember is, the hex value of the pixels times the
	* magnitude time .00001 (keeps the required magnitude to y-scale for
	* greyscale images) is equal to the y-value of the vertex. This means
	* that if you use this class and nothing shows up, it's probably
	* because the plane has gone much too high, lower the magnitude.
	* Conversely, if all you see is a flat plane, you may need to increase
	* the magnitude. When it comes to BitmapDataChannel, remember, greyscale
	* is low's (around 10-20 magnitude should work) red is next
	* (try around the 1000 range), greens after that
	* (something like a magnitude of 10,0000-50,000) and blues require
	* a very high magnitude (1,000,000 in the example above).
	*
	*
	* @param name - A string name representing your terrain.
	* @param mag - A value multiplied by each point to make it go higher.
	* This coefficient is evenly applied across all points. For darker images, higher
	* numbers are needed to see an effect. For greyscale images, something
	* around 10 is all that's needed.
	* @param seed - Uniquely creates a Perlin Noise map. If you put the same
	* seed in twice, the same transform will come up.
	* @param octaves Each successive noise function you add is known as an octave.
	* @param h - Height of the plane
	* @param lg - Width of the plane
	* @param q - Number of polygon divisions on the plane surface. For simplicity
	* sake, this number squared = number of faces on TerrainGenerator plane.
	* @param perlinWidth - Width of the BitMapData used in the calculations.
	* The bigger, the more detailed, but more slow.
	* @param perlinHeight - Height of the BitMapData used in the calculations.
	* Same limitations as perlinWidth apply.
	* @param smooth - Smooths out the perlin function a bit more. May impact some terrains.
	* @param hilly - Increases the contrast between points on the perlin function
	* via fractals. Can make more deep valleys and hills depending on the size
	* of the Perlin BitMapData.
	* @param sample - When testing the Perlin BitMapData, the average of a this
	* number of pixels around the point. The sample is (2 * SampleSize)^2 extra
	* calculations, so make sparing use of this, keep it small.
	* @param bitmapChannel BitmapDataChannel value param for BitmapData.perlinNoise,
	* which can change the color of the Perlin Bitmap.
	* Normally, keep this null as it will drastically change magnitude values.
	* For instance, making the image blue will change the size your magnitude
	* needs to be by something like a factor of 1,000,000. Only use this if
	* you plan to use the Perlin Bitmap graphically.
	* @param greyScale - if you override the BitmapChannel and want the color
	* to change, make this false. Otherwise, keep it true.
	*/
	public function new(name:String = null, mag:Float = 1, seed:Int = 128, octaves:Int = 9, h:Int=1000,lg:Int=1000,q:Int = 10, perlinWidth:Int = 200, perlinHeight:Int = 200, smooth:Bool = false, hilly:Bool=true, sample:Int = 10, bitmapChannel:UInt = 7, greyScale:Bool = true)
	{
		super(name, h, lg, q, q, Plane3D.ZX_ALIGNED, PrimitiveMode.TRI);
		updateNormals = true;
		updateBounds = false;
		perlin = new BitmapData(perlinWidth , perlinHeight , false, 0x000000);
		perlin.perlinNoise(perlinWidth / 2, perlinHeight / 2 , octaves, seed, smooth, hilly, bitmapChannel, greyScale);
		sampleX = Std.int(q / perlin.width);
		sampleY = Std.int(q / perlin.height);
		quality = q;
		enableBackFaceCulling = false;
		oct = octaves;
		length = lg;
		height = h;
		stitch = smooth;
		fractals = hilly;
		bitChan = bitmapChannel;
		gs = greyScale;
		sampleRate = sample;
		a = new Array<Point>();
		a.push(new Point());
		magnitude = mag;
		parseBMD();
	}

	private function parseBMD() : Void
	{
		var myGeometry:Geometry3D = geometry;
		var i:Int = 0;
		for(myVertex in geometry.aVertex) {
			var new3DY:Int = 0;
			var coordY:Int = i % quality;
			var coordX:Int = Std.int((i - coordY ) / quality);
			coordX = Std.int( (coordX * ( perlin.width / quality )) );
			coordY = Std.int( (coordY * ( perlin.height / quality )) );
			//perlin.setPixel(coordX, coordY, 0xFF0000);
			new3DY = Std.int(getAVG(coordX, coordY, sampleRate));
			myVertex.y = new3DY * magnitude * .00001;
			i++;
			//trace(coordX, coordY);
		}
		updateForGeometryChange(myGeometry, updateNormals, updateBounds);
	}

	private inline function getAVG(coordX:Int, coordY:Int, spread:Int) : Float
	{
		var avg:Float = perlin.getPixel(coordX,
										coordY);

		var i:Int = coordX - spread;
		var m1 = coordX + spread;
		while( i < m1)
		{
			var j:Int = Std.int(coordY - spread);
			var m2 = coordY + spread;
			while( j < m2 )
			{
				if(i >= 0 && i <= perlin.width && j >= 0 && j <= perlin.height)
					avg += perlin.getPixel(i, j);
				j++;
			}
			i++;
		}
		return avg / (spread * spread * 4.);
	}


	/**
	* Updates the perlin noise source and the geometry.
	*
	*/
	public function updateTerrain() : Void
	{
		perlin.perlinNoise(perlin.width / 2, perlin.height / 2, oct, seed, stitch, fractals,bitChan , gs, a);
		parseBMD();
	}

	/**
	* This function will shift the map by the X and Y coordinate passed in.
	* If you want to move the map forward by 5, moveMap(0,5). If you want
	* to move diagonally by 3, moveMap(3,3). And if you want to move backwards
	* by 6... moveMap(0, -6).
	*
	* @param xval X move amount
	* @param yval Y move amount
	*/
	public function moveMap(xval:Int = 1, yval:Int = 1) : Void
	{
		a[0].x += xval;
		a[0].y += yval;
		updateTerrain();
	}
}