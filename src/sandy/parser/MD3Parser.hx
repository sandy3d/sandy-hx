
package sandy.parser;

import sandy.animation.IKeyFramed;
import sandy.animation.Tag;
import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.KeyFramedTransformGroup;
import sandy.core.scenegraph.TagCollection;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.primitive.KeyFramedShape3D;
import sandy.primitive.MD3;
import sandy.util.DataOrder;
import sandy.util.LoaderQueue;

import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.utils.ByteArray;
import flash.utils.Endian;

import sandy.HaxeTypes;

/**
* Transforms an MD3 file into Sandy MD3 primitive.
* <p>Creates a KeyFramedTransformGroup as rootnode with MD3 primitives as it's children.
*
* @author		Russell Weir (madrok)
* @version		3.1
* @date 		03.06.2008
*
* @example To parse an MD3 file at runtime:
*
* <listing version="3.1">
*     var parser:IParser = Parser.create( "/path/to/my/md3file.md3", Parser.MD3 );
* </listing>
*
* @example To parse an embedded MD3 object:
*
* <listing version="3.1">
*     [Embed( source="/path/to/my/md3file.md3", mimeType="application/octet-stream" )]
*     private var MyMD3:Class;
*
*     ...
*
*     var parser:IParser = Parser.create( new MyMD3(), Parser.MD3 );
* </listing>
*/

class MD3Parser extends AParser, implements IParser
{
	public static var defaultOrientation : DataOrder = DATA_MD3;

	private var m_eDataOrder : DataOrder;
	private var m_oTextureQueue : LoaderQueue;
	private var m_sDefaultName : String;

	/**
	* Creates a new MD3Parser instance
	*
	* @param p_sUrl		This can be either a String containing an URL or a
	* 						an embedded object
	* @param defaultName The name of the part. If set to null, the name from the md3 header will be used, which is often empty
	* @param p_nScale		The scale factor
	* @param p_oTextureData A loader queue with all related textures loaded
	* @param p_sTextureExtension	Overrides texture extension. You might want to use it for models that
	* specify PCX textures.
	*/
	public function new<URL>( p_sUrl:URL, p_sDefaultName:String, p_oTextureData : LoaderQueue, ?p_nScale:Float = 1.0, ?p_sTextureExtension:String )
	{
		m_eDataOrder = defaultOrientation;
		m_sDefaultName = p_sDefaultName;
		super( p_sUrl, p_nScale, p_sTextureExtension );
		m_sDataFormat = URLLoaderDataFormat.BINARY;
		m_oTextureQueue = p_oTextureData;
	}

	/**
	* @private
	* Starts the parsing process
	*
	* @param e				The Event object
	*/
	private override function parseData( ?e:Event ):Void
	{
		super.parseData( e );

		var data:ByteArray = cast m_oFile;

		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;

		// we are not quite done yet, so we dispatch less than 100% :)
		var event:ParserEvent = new ParserEvent( ParserEvent.PARSING );
		event.percent = 80;
		dispatchEvent( event );

#if neko
		ident = I32.toInt(data.readInt());
		version = I32.toInt(data.readInt());
#else
		ident = data.readInt();
		version = data.readInt();
#end
		if (ident != MD3.MAGIC || version != 15)
			throw "Error loading MD3 file: Not a valid MD3 file/bad version";
		var fname = KeyFramedShape3D.readCString(data, MD3.MAX_QPATH);
		if(m_sDefaultName != null)
			this.name = m_sDefaultName;
		else
			this.name = fname;
#if neko
		var flags = I32.toInt(data.readInt());
		num_frames = I32.toInt(data.readInt());
		num_tags = I32.toInt(data.readInt());
		num_surfaces = I32.toInt(data.readInt());
		num_skins = I32.toInt(data.readInt());
		offset_frames = I32.toInt(data.readInt());
		offset_tags = I32.toInt(data.readInt());
		offset_surfaces = I32.toInt(data.readInt());
		offset_end = I32.toInt(data.readInt());
#else
		var flags = data.readInt();
		num_frames = data.readInt();
		num_tags = data.readInt();
		num_surfaces = data.readInt();
		num_skins = data.readInt();
		offset_frames = data.readInt();
		offset_tags = data.readInt();
		offset_surfaces = data.readInt();
		offset_end = data.readInt();
#end

		#if debug
		trace("MD3Parser '" + name + "'");
		trace("flags: " + flags);
		trace("num_frames: " + num_frames);
		trace("num_tags: " + num_tags);
		trace("num_surfaces: " + num_surfaces);
		trace("num_skins: " + num_skins);
		trace("offset_frames: " + offset_frames);
		trace("offset_tags: " + offset_tags);
		trace("offset_surfaces: " + offset_surfaces);
		trace("offset_end: " + offset_end);
		trace("data.length: " + data.length);
		trace("--------------------");
		#end

		data.position = offset_frames;
		frames = new Hash();
		// Frame data
		for (i in 0...num_frames)
		{
			/*
			VEC3 	MIN_BOUNDS 	First corner of the bounding box.
			VEC3 	MAX_BOUNDS 	Second corner of the bounding box.
			VEC3 	LOCAL_ORIGIN 	Local origin, usually (0, 0, 0).
			F32 	RADIUS 	Radius of bounding sphere.
			U8 * 16 	NAME 	Name of Frame. ASCII character string, NUL-terminated (C-style)
			*/
			var minx:Float = data.readFloat();
			var miny:Float = data.readFloat();
			var minz:Float = data.readFloat();

			var maxx:Float = data.readFloat();
			var maxy:Float = data.readFloat();
			var maxz:Float = data.readFloat();

			var originX:Float = data.readFloat();
			var originY:Float = data.readFloat();
			var originZ:Float = data.readFloat();

			var bSpherRadius:Float = data.readFloat();
			var name:String = KeyFramedShape3D.readCString(data,16);
			frames.set(name, i);
		}

		// local group
		var tg = new KeyFramedTransformGroup(this.name);
		m_oGroup.addChild( tg );

		// load tag information
		if(num_tags > 0) {
			data.position = offset_tags;
			var tags:Hash<TypedArray<Tag>> = Tag.read(data, num_frames, num_tags, m_eDataOrder);
			tg.addChild(new TagCollection(tags));
			#if debug
			{
				var m = "*** MD3Parser: Tags on " + name;
				for(k in tags.keys()) {
					m += " " + k;
				}
				trace(m);
			}
			#end
		}

		// load surfaces
		if(num_surfaces > 0) {
			data.position = offset_surfaces;
			for(i in 0...num_surfaces) {
				// make MD3 object.
				var md3:MD3 = new MD3 ( name.length > 0 ? name : null, m_oFile, m_nScale );

				if(md3.frameCount != num_frames)
					throw "Error loading MD3 file: Frame count mismatch loading surface " + Std.string(i) + ". Expected " + num_frames + " got " + md3.frameCount;

				// Apply textures to the meshes by part name
				if(md3.name != null && m_oTextureQueue != null && m_oTextureQueue.data.exists(md3.name) ) {
					try {
						var mat:BitmapMaterial = new BitmapMaterial( cast Reflect.field( m_oTextureQueue.data.get(md3.name), 'bitmapData' ) );
						md3.appearance = new Appearance(mat);
					} catch(e : Dynamic) {
						md3.appearance = m_oStandardAppearance;
						md3.visible = false;
					}
				}
				else {
					md3.appearance = m_oStandardAppearance;
					md3.visible = false;
				}
				md3.frame = 0;

				tg.addChild( md3 );
				var event:ParserEvent = new ParserEvent( ParserEvent.PARSING );
				event.percent = 80 + Std.int((i*1.)/num_surfaces*20.);
				dispatchEvent( event );
			}
		}
		// reset all frame counters
		for(c in tg.children)
			cast(c, IKeyFramed).frame = 0;
		// --
		dispatchInitEvent ();
	}

	// header
	private var ident:Int;
	private var version:Int;
	private var name : String; // often empty
// 	private var flags:Int; // not used
	private var num_frames:Int;
	private var num_tags:Int;
	private var num_surfaces:Int;
	private var num_skins:Int; // apparently not used
	private var offset_frames:Int;
	private var offset_tags:Int;
	private var offset_surfaces:Int;
	private var offset_end:Int;
	private var frames:Hash<Int>;

}


