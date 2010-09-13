package sandy.primitive;

import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Vertex;
import sandy.core.data.UVCoord;
import sandy.materials.Appearance;
import sandy.primitive.Primitive3D;

import flash.utils.ByteArray;
import flash.utils.Endian;

import sandy.HaxeTypes;


/**
* MD3 primitive.
*
* @author Russell Weir (madrok)
* @date 03.15.2009
* @version 3.2
*/
class MD3 extends KeyFramedShape3D, implements Primitive3D
{
	/** Little endian magic number **/
	public static inline var MAGIC : Int = 0x33504449;
	/** Version this class reads **/
	public static inline var VERSION : Int = 15;
	/** Max length of strings **/
	public static inline var MAX_QPATH:Int = 64;
	/** Max number of Frame objects **/
	public static inline var MAX_FRAMES:Int = 1024;
	/** Max number of Tag entries **/
	public static inline var MAX_TAGS:Int = 16;
	/** Maximum number of surfaces **/
	public static inline var MAX_SURFACES:Int = 32;
	/** Maximum number of Shader objects **/
	public static inline var MAX_SHADERS:Int = 256;
	/** Maximum number of Vertex objects per surface */
	public static inline var MAX_VERTS:Int = 4096;
	/** Maximum number of Triangle objects **/
	public static inline var MAX_TRIANGLES:Int = 8192;
	/** Multiply vertices by this value when reading **/
	public static inline var XYZ_SCALE:Float = 1.0/64;

	public static var ANIMATIONS_PLAYER : Array<String> = [
		"Death 1", "Dead 1", "Death 2", "Dead 2", "Death 3", "Dead 3",
		"Gesture", "Shoot", "Hit", "Drop Weapon", "Raise Weapon", "Stand With Weapon", "Stand",
		"Crouched Walk", "Walk", "Run", "Backpedal", "Swim",
		"Jump Forward", "Land Forward", "Jump Backward", "Land Backward",
		"Stand Idle", "Crouched Idle", "Turn"];

	public static var ANIMATIONS_PLAYER_TYPES : Array<String> = [
		"both", "both", "both", "both", "both", "both",
		"torso", "torso", "torso", "torso", "torso", "torso", "torso",
		"legs", "legs", "legs", "legs","legs",
		"legs", "legs", "legs", "legs",
		"legs", "legs", "legs",
	];

	/**
	* Creates MD3 primitive.
	*
	* @param p_sName Shape instance name.
	* @param data MD3 binary data.
	* @param offSurfaces offset in binary data for start of surfaces info. Required for internal offsets
	* @param scale Adjusts model scale.
	*/
	public function new( p_sName:String="", data:Bytes=null, scale:Float=1.0, p_oAppearance:Appearance=null, p_bUseSingleContainer:Bool=true)
	{
		super( p_sName, data, scale, p_oAppearance, p_bUseSingleContainer);
	}

	/**
	* Generates the geometry for MD3.
	* @param arguments
	* @return The geometry object.
	*/
	override public function generate<T>(?arguments:Array<T>):Geometry3D
	{

		var uvs:Array<UVCoord> = [];
		var mesh:Geometry3D = new Geometry3D ();

		var data:Bytes = null;
		try
		{
			data = cast(arguments[0],Bytes);
		} catch(e:Dynamic) {
			return mesh;
		}

		var offset_begin = data.position;
		data.endian = Endian.LITTLE_ENDIAN;

#if neko
		var ident:Int = I32.toInt(data.readInt());
		if (ident != MD3.MAGIC)
			throw "Error loading MD3 file: Magic number error loading surface. " + Std.string(ident);
		name = KeyFramedShape3D.readCString(data, 64);
		var flags = data.readInt();
		num_frames = I32.toInt(data.readInt());
		var num_shaders = I32.toInt(data.readInt());
		num_vertices = I32.toInt(data.readInt());
		var num_tris = I32.toInt(data.readInt());
		var offset_tris = I32.toInt(data.readInt());
		var offset_shaders = I32.toInt(data.readInt());
		var offset_st = I32.toInt(data.readInt());
		var offset_verts = I32.toInt(data.readInt());
		var offset_surface_end = I32.toInt(data.readInt());
#else
		var ident:Int = data.readInt();
		if (ident != MD3.MAGIC)
			throw "Error loading MD3 file: Magic number error loading surface. " + Std.string(ident);
		name = KeyFramedShape3D.readCString(data, 64);
		var flags = data.readInt();
		num_frames = data.readInt();
		var num_shaders = data.readInt();
		num_vertices = data.readInt();
		var num_tris = data.readInt();
		var offset_tris = data.readInt();
		var offset_shaders = data.readInt();
		var offset_st = data.readInt();
		var offset_verts = data.readInt();
		var offset_surface_end = data.readInt();
#end

		#if debug
			trace("*** MD3: Found surface named " + name);
		#end
		/*
		trace("Data len: " + data.length);
		trace("offset_begin: " + offset_begin);
		trace("num_frames: " + num_frames);
		trace("num_shaders: " + num_shaders);
		trace("num_vertices: " + num_vertices);
		trace("num_tris: " + num_tris);
		trace("offset_tris (12): " + offset_tris);
		trace("offset_shaders (68): " + offset_shaders);
		trace("offset_st (8): " + offset_st);
		trace("offset_verts (8): " + offset_verts);
		trace("offset_surface_end: " + offset_surface_end);
		*/

		/*
		// read shader information
		data.position = offset_shaders + offset_begin;
		for(i in 0...num_shaders) {
			var sName = readCString(data, 64);
			var sIdx = data.readInt();
			trace("Found shader name " + sName + " idx: " + sIdx);
		}
		*/

		// Load all UV coordinates. 1 for evey vertex per frame
		data.position = offset_st + offset_begin;
		uvs = new Array();
		for (i in 0...num_vertices) {
			uvs.push (new UVCoord (data.readFloat(), /*1.0 -*/ data.readFloat() ));
			mesh.setUVCoords (i, uvs[i].u, uvs[i].v);
		}

		// Load vertex information for each frame
		data.position = offset_verts + offset_begin;
		var ts = XYZ_SCALE * scaling;
		for(f in 0...num_frames) {
			var va:TypedArray<Point3D> = new TypedArray();
			for(i in 0...num_vertices) {
				var p = new Point3D();
				// translate to Sandy's orientation
				p.z = - data.readShort() * ts;
				p.x = data.readShort() * ts;
				p.y = data.readShort() * ts;

				va[i] = p;

				var lat = data.readUnsignedByte();
				var lon = data.readUnsignedByte();
			}
			vertices[f] = va;
		}

		// Create triangles
		data.position = offset_tris + offset_begin;

		// List of offset values into the array of Vertex objects that
		// constitute the corners of the Triangle object. These are only
		// placeholders that are replaced during __setFrame()
		for(i in 0...num_tris) {
			// clockwise in md3.
#if neko
			var a = I32.toInt(data.readInt());
			var c = I32.toInt(data.readInt());
			var b = I32.toInt(data.readInt());
#else
			var a = data.readInt();
			var c = data.readInt();
			var b = data.readInt();
#end

			mesh.setVertex (a, 1, 0, 0);
			mesh.setVertex (b, 0, 1, 0);
			mesh.setVertex (c, 0, 0, 1);
			mesh.setFaceVertexIds(i, [a, b, c]);

			mesh.setFaceUVCoordsIds (i, [a, b, c]);
		}

		data.position = offset_begin + offset_surface_end;
		return mesh;
	}


}
