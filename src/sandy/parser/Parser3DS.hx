
package sandy.parser;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Quaternion;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;

import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.utils.ByteArray;
import flash.utils.Endian;

import sandy.HaxeTypes;

/**
* Transforms a 3DS file into Sandy geometries.
* <p>Creates a Group as rootnode which appends all geometries it finds.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		26.07.2007
*
* @example To parse a 3DS file at runtime:
*
* <listing version="3.1">
*     var parser:IParser = Parser.create( "/path/to/my/3dsfile.3ds", Parser.MAX_3DS );
* </listing>
*
*/

class Parser3DS extends AParser, implements IParser
{
	private var currentObjectName:String;
	private var data:ByteArray;
	/*private var _animation:Hash<Keyframer>;*/
	private var startFrame:Int;
	private var endFrame:Int;
	private var lastRotation:Quaternion;

	private var textureFileNames:Hash<String>;
	private var currentMaterialName:String;
	private var currentMeshMaterialName:String;
	private var currentMeshMaterialsMap:Array<haxe.FastList<String>>;

	/**
	* Creates a new Parser3DS instance.
	*
	* @param p_sUrl		A String pointing to the location of the 3DS file
	* @param p_nScale		The scale factor
	*/
	public function new<URL>( p_sUrl:URL, p_nScale:Float, ?p_sTextureExtension:String)
	{
		super( p_sUrl, p_nScale, p_sTextureExtension );
		m_sDataFormat = URLLoaderDataFormat.BINARY;
		textureFileNames = new Hash();
	}

	/**
	* Starts the parsing process
	* @param e				The Event object
	*/
	private override function parseData( ?e:Event ):Void
	{
		super.parseData( e );
		// --
		currentMeshMaterialsMap = new Array();
		if (m_oFileLoader != null)
			data = m_oFileLoader.data;
		else
			data = cast m_oFile;
		data.endian = Endian.LITTLE_ENDIAN;
		// --
		var currentObjectName:String = null;
		/* var ad:Array = new Array(); */
		var pi180:Float = 180 / Math.PI;
		// --
		var l_oAppearance:Appearance = m_oStandardAppearance;
		var l_oGeometry:Geometry3D = null;
		var l_oShape:Shape3D = null;
		var l_oMatrix:Matrix4 = null;
		// --
		var x:Float, y:Float, z:Float;
		var l_qty:Int;
		// --
		#if flash
		while( data.bytesAvailable > 0 )
		#else
		while( data.length - data.position > 0)
		#end
		{
			var id:Int = data.readUnsignedShort();
			var l_chunk_length:Int = data.readUnsignedInt();

			switch( id )
			{
				case Parser3DSChunkTypes.MAIN3DS:

				case Parser3DSChunkTypes.EDIT3DS:

				case Parser3DSChunkTypes.KEYF3DS:

				case Parser3DSChunkTypes.EDIT_MATERIAL:
					// wait for Parser3DSChunkTypes.MAT_TEXMAP

				case Parser3DSChunkTypes.MAT_TEXMAP:
					// wait for Parser3DSChunkTypes.MAT_TEXFLNM

				case Parser3DSChunkTypes.MAT_NAME:
					// material name
					currentMaterialName = readString ();

				case Parser3DSChunkTypes.MAT_TEXFLNM:
					// texture file name
					textureFileNames.set(currentMaterialName, readString ());
//trace ("texture (currentMaterialName = " + currentMaterialName + ") " + textureFileNames [currentMaterialName]);

				case Parser3DSChunkTypes.TRI_MATERIAL:
					// what material to use
					currentMeshMaterialName = readString ();
//trace ("currentMeshMaterialName <- " + currentMeshMaterialName);
					// this chunk has face list
					var faceList:haxe.FastList<String> = new haxe.FastList<String>();
					faceList.add( currentMeshMaterialName );
					var numFaces:Int = data.readUnsignedShort();
					for (f in 0...numFaces) {
						faceList.add (Std.string(data.readUnsignedShort()));
					}
					currentMeshMaterialsMap.push (faceList);

				case Parser3DSChunkTypes.EDIT_OBJECT:

					if( l_oGeometry != null )
					{
						l_oShape = new Shape3D( currentObjectName, l_oGeometry, l_oAppearance );
						if( l_oMatrix != null ) _applyMatrixToShape( l_oShape, l_oMatrix );
						m_oGroup.addChild( l_oShape );
						// untested, may not work... but should
//trace ("making shape (1), currentMeshMaterialName = " + currentMeshMaterialName);
						if (currentMeshMaterialsMap.length < 2) {
							// 1 or less materials
							if (textureFileNames.exists(currentMeshMaterialName))
								applyTextureToShape(l_oShape, textureFileNames.get(currentMeshMaterialName));
						} else {
							// multiple materials per shape
							for (faceList1 in currentMeshMaterialsMap) {
								if(textureFileNames.exists(faceList1.first())) {
									faceList1.pop();
									for (p1 in faceList1) {
										applyTextureToShape(l_oShape.aPolygons[Std.parseInt(p1)], textureFileNames.get(faceList1.first()));
									}
								}
							}
						}
						currentMeshMaterialsMap = [];
					}
					// --
					var str:String = readString();
					currentObjectName = str;
					l_oGeometry = new Geometry3D();
// 					l_oAppearance = l_oAppearance;

				case Parser3DSChunkTypes.OBJ_TRIMESH:

				case Parser3DSChunkTypes.TRI_VERTEXL:        //vertices

					l_qty = data.readUnsignedShort();
					for (i in 0...l_qty)
					{
						x = data.readFloat();
						z = data.readFloat();
						y = data.readFloat();
						l_oGeometry.setVertex( i, x*m_nScale, y*m_nScale, z*m_nScale );
					}

				case Parser3DSChunkTypes.TRI_TEXCOORD:		// texture coords

				//  trace("0x4140  texture coords");
					l_qty = data.readUnsignedShort();
					for (i in 0...l_qty)
					{
						var u:Float = data.readFloat();
						var v:Float = data.readFloat();
						l_oGeometry.setUVCoords( i, u, 1-v );
					}

				case Parser3DSChunkTypes.TRI_FACEL1:		// faces

					//trace("0x4120  faces");
					l_qty = data.readUnsignedShort();
					for (i in  0...l_qty)
					{
						var vertex_a:Int = data.readUnsignedShort();
						var vertex_b:Int = data.readUnsignedShort();
						var vertex_c:Int = data.readUnsignedShort();

						// should we ignore invisible faces?
						var visible:Bool = (data.readUnsignedShort() == 0 ? false : true);

						l_oGeometry.setFaceVertexIds(i, [vertex_a, vertex_b, vertex_c] );
						l_oGeometry.setFaceUVCoordsIds(i, [vertex_a, vertex_b, vertex_c] );
					}

				case Parser3DSChunkTypes.TRI_LOCAL:		//ParseLocalCoordinateSystem
					//trace("0x4160 TRI_LOCAL");

					var localX:Point3D = readPoint3D();
					var localZ:Point3D = readPoint3D();
					var localY:Point3D = readPoint3D();
					var origin:Point3D = readPoint3D();


					l_oMatrix = new Matrix4(	localX.x, localX.y, localX.z, origin.x,
												localY.x, localY.y, localY.z, origin.y,
												localZ.x, localZ.y, localZ.z, origin.z,
												0,0,0,1 );

				case Parser3DSChunkTypes.OBJ_LIGHT:		//Lights

				case Parser3DSChunkTypes.LIT_SPOT:			//Light Spot

				case Parser3DSChunkTypes.COL_TRU:			//RGB color

				case Parser3DSChunkTypes.COL_RGB:			//RGB color

				case Parser3DSChunkTypes.OBJ_CAMERA:		//Cameras

				// animation
				case Parser3DSChunkTypes.KEYF_FRAMES:

				case Parser3DSChunkTypes.KEYF_OBJDES:

				case Parser3DSChunkTypes.NODE_ID:

				case Parser3DSChunkTypes.NODE_HDR:

				case Parser3DSChunkTypes.PIVOT:

				case Parser3DSChunkTypes.POS_TRACK_TAG:

				case Parser3DSChunkTypes.ROT_TRACK_TAG:

				case Parser3DSChunkTypes.SCL_TRACK_TAG:

				default:
					data.position += l_chunk_length-6;
					if (l_chunk_length-6 < 0) {
						data.position = data.length;
						trace ("Parser3DS.parseData(): WARNING! There were errors parsing your file.");
					}
			}
		}
		// occasionally parser creates empty shapes here
		if (l_oGeometry.aFacesVertexID.length > 0) {
			l_oShape = new Shape3D( currentObjectName, l_oGeometry, l_oAppearance);

			// AS3 <-> haXe discrepency, fix for maxcar demo
			//if( l_oMatrix != null) _applyMatrixToShape( l_oShape, l_oMatrix );

			m_oGroup.addChild( l_oShape );
			if (currentMeshMaterialsMap.length < 2) {
				// 1 or less materials
				if (textureFileNames.exists(currentMeshMaterialName))
					applyTextureToShape (l_oShape, textureFileNames.get(currentMeshMaterialName));
			} else {
				// multiple materials per shape
				for(faceList2 in currentMeshMaterialsMap) {
					if (textureFileNames.exists(faceList2.first())) {
						faceList2.pop();
						for (p2 in faceList2) {
							applyTextureToShape(l_oShape.aPolygons[Std.parseInt(p2)], textureFileNames.get(Std.string(faceList2.first())));
						}
					}
				}
			}
			currentMeshMaterialsMap = [];
		}
		// -- Parsing is finished
		dispatchInitEvent ();
	}

	private function _applyMatrixToShape( p_oShape:Shape3D, p_oMatrix:Matrix4 ):Void
	{
		p_oShape.matrix = p_oMatrix;
	}

	/**
	* Reads a vector from a ByteArray
	*
	* @return	A vector containing the x, y, z values
	*/
	private function readPoint3D():Point3D
	{
		var x:Float = data.readFloat();
		var y:Float = data.readFloat();
		var z:Float = data.readFloat();
		return new Point3D(x, z, y);
	}

	/**
	* Reads a byte from a ByteArray
	*
	* @return 	A byte
	*/
	private function readByte():Int
	{
		return data.readByte();
	}

	/**
	* Reads a character (unsigned byte) from a ByteArray
	*
	* @return A character
	*/
	private function readChar():Int
	{
		return data.readUnsignedByte();
	}

	/**
	* Reads an integer from a ByteArray
	*
	* @return	An integer
	*/
	private function readInt():Int
	{
		var temp:Int = readChar();
		return ( temp | (readChar() << 8));
	}

	/**
	* Reads a string from a ByteArray
	*
	* @return 	A String
	*/
	private function readString():String
	{
		var name:String = "";
		var ch:Int;
		while((ch = readChar()) != 0)
		{
			if (ch == 0)
			{
				break;
			}
			name += String.fromCharCode(ch);
		}
		return name;
	}
}

