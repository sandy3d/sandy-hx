package sandy.primitive;

import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.core.data.Point3D;
import sandy.core.data.UVCoord;

import flash.utils.ByteArray;
import flash.utils.Endian;

import sandy.HaxeTypes;

/**
* MD2 primitive.
*
* @author Philippe Ajoux (philippe.ajoux@gmail.com)
* @author Niel Drummond - haXe port
* @author Russell Weir
*/
class MD2 extends KeyFramedShape3D
{


	/**
	* Generates the geometry for MD2. Sandy never actually calls this method,
	* but we still implement it according to Primitive3D, just in case :)
	*
	* @return The geometry object.
	*/
	override public function generate<T>(?arguments:Array<T>):Geometry3D
	{
		var i:Int, j:Int, char:Int;
		var uvs:Array<UVCoord> = [];
		var mesh:Geometry3D = new Geometry3D ();

		// okay, let's read out header 1st
		var data:ByteArray = cast arguments[0];
		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;

		ident = data.readInt();
		version = data.readInt();

		if (ident != 844121161 || version != 8)
			throw "Error loading MD2 file: Not a valid MD2 file/bad version";

		skinwidth = data.readInt();
		skinheight = data.readInt();
		framesize = data.readInt();
		num_skins = data.readInt();
		num_vertices = data.readInt();
		num_st = data.readInt();
		num_tris = data.readInt();
		num_glcmds = data.readInt();
		num_frames = data.readInt();
		offset_skins = data.readInt();
		offset_st = data.readInt();
		offset_tris = data.readInt();
		offset_frames = data.readInt();
		offset_glcmds = data.readInt();
		offset_end = data.readInt();

		// texture name
		data.position = offset_skins;
		texture = "";
		if (num_skins > 0)
			for (i in 0...64)
			{
				char = data.readUnsignedByte ();
				if (char == 0) break; else texture += String.fromCharCode (char);
			}

		// UV coordinates
		data.position = offset_st;
		for (i in 0...num_st)
			uvs.push (new UVCoord (data.readShort() / skinwidth, data.readShort() / skinheight ));

		// Faces
		data.position = offset_tris;
		var j = 0;
		for (i in 0...num_tris)
		{
			var a:Int = data.readUnsignedShort();
			var b:Int = data.readUnsignedShort();
			var c:Int = data.readUnsignedShort();
			var ta:Int = data.readUnsignedShort();
			var tb:Int = data.readUnsignedShort();
			var tc:Int = data.readUnsignedShort();

			// create placeholder vertices (actual coordinates are set later)
			mesh.setVertex (a, 1, 0, 0);
			mesh.setVertex (b, 0, 1, 0);
			mesh.setVertex (c, 0, 0, 1);

			mesh.setUVCoords (j, uvs [ta].u, uvs [ta].v);
			mesh.setUVCoords (j + 1, uvs [tb].u, uvs [tb].v);
			mesh.setUVCoords (j + 2, uvs [tc].u, uvs [tc].v);

			mesh.setFaceVertexIds (i, [a, b, c]);
			mesh.setFaceUVCoordsIds (i, [j, j + 1, j + 2]);
			j+=3;
		}

		// Frame animation data
		for (i in 0...num_frames)
		{
			var sx:Float = data.readFloat();
			var sy:Float = data.readFloat();
			var sz:Float = data.readFloat();

			var tx:Float = data.readFloat();
			var ty:Float = data.readFloat();
			var tz:Float = data.readFloat();

			// store frame names as pointers to frame numbers
			var name:String = "", wasNotZero:Bool = true;
			for (j in 0...16)
			{
				char = data.readUnsignedByte ();
				wasNotZero = wasNotZero && (char != 0);
				if (wasNotZero)
					name += String.fromCharCode (char);
			}
			frames.set(name, i);

			// store vertices for every frame
			var vi:TypedArray<Point3D> = new TypedArray();
			vertices [i] = vi;
			for (j in 0...num_vertices)
			{
				var vec:Point3D = new Point3D ();

				// order of assignment is important here because of data reads...
				vec.x = ((sx * data.readUnsignedByte()) + tx) * scaling;
				vec.z = ((sy * data.readUnsignedByte()) + ty) * scaling;
				vec.y = ((sz * data.readUnsignedByte()) + tz) * scaling;

				vi [j] = vec;

				// ignore "vertex normal index"
				data.readUnsignedByte ();
			}
		}

		return mesh;
	}

	// original Philippe vars
	private var ident:Int;
	private var version:Int;
	private var skinwidth:Int;
	private var skinheight:Int;
	private var framesize:Int;
	private var num_skins:Int;
	private var num_st:Int;
	private var num_tris:Int;
	private var num_glcmds:Int;
	private var offset_skins:Int;
	private var offset_st:Int;
	private var offset_tris:Int;
	private var offset_frames:Int;
	private var offset_glcmds:Int;
	private var offset_end:Int;

	private var texture:String;

	/**
	* Texture file name.
	*/
	public var textureFileName(__getTextureFileName,null):String;
	public function __getTextureFileName():String { return texture; }
}

