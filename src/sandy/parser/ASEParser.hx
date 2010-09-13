
package sandy.parser;

import flash.events.Event;

import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;

import sandy.HaxeTypes;

/**
 * Transforms an ASE file into Sandy geometries.
 * <p>Creates a Group as rootnode which appends all geometries it finds.
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		Niel Drummond - haXe port
 * @author		Russell Weir - haXe port
 * @since		1.0
 * @version		3.1
 * @date 		04.03.2009
 *
 *
 * @example To parse an ASE file at runtime:
 *
 * <listing version="3.0">
 *     var parser:IParser = Parser.create( "/path/to/my/asefile.ase", Parser.ASE );
 * </listing>
 *
 * @example To parse an embedded ASE object:
 *
 * <listing version="3.0">
 *     [Embed( source="/path/to/my/asefile.ase", mimeType="application/octet-stream" )]
 *     private var MyASE:Class;
 *
 *     ...
 *
 *     var parser:IParser = Parser.create( new MyASE(), Parser.ASE );
 * </listing>
 */

class ASEParser extends AParser, implements IParser
{
	/**
	 * Creates a new ASEParser instance
	 *
	 * @param p_sUrl		This can be either a String containing an URL or a
	 * 						an embedded object
	 * @param p_nScale		The scale factor
	 */
	public function new<URL>( p_sUrl:URL, p_nScale:Float = 1., p_sTextureExtension:String = null )
	{
		super( p_sUrl, p_nScale, p_sTextureExtension );
	}

	/**
	 * Starts the parsing process
	 *
	 * @param e				The Event object
	 */
	private override function parseData( ?e:Event ):Void
	{
		super.parseData( e );

		m_oFile = m_oFile.toString ();

		// --
		//var lines:Array = unescapeMultiByte( String( m_oFile ) ).split( '\n' );
		var lines:Array<String> = m_oFile.split( '\n' );
		var lineLength:Int = lines.length;
		var id:Int;
		// -- local vars
		var line:String;
		var content:String;
		var chunk:String;
		var l_oAppearance:Appearance = null;
		var l_oGeometry:Geometry3D = null;
		var l_oShape:Shape3D = null;
		// --
		while( lines.length > 0 )
		{
			var event:ParserEvent = new ParserEvent( ParserEvent.PARSING );
			event.percent = ( 100 - ( lines.length * 100 / lineLength ) );
			dispatchEvent( event );
			//-- parsing
			line = lines.shift();
			//-- clear white space from begin
			line = line.substr( line.indexOf( '*' ) + 1 );
			//-- clear closing brackets
			if( line.indexOf( '}' ) >= 0 ) line = '';
			//-- get chunk description
			chunk = line.substr( 0, line.indexOf( ' ' ) );
			//--
			switch( chunk )
			{
				case 'MESH_NUMFACES':
				{
					//var num: Number =  Number(line.split( ' ' )[1]);
					if( l_oGeometry != null )
					{
						l_oShape = new Shape3D( null, l_oGeometry, m_oStandardAppearance );
						m_oGroup.addChild( l_oShape );
					}
					// -
					l_oGeometry = new Geometry3D();
				}
				case 'MESH_VERTEX_LIST':
				{
					while( ( content = lines.shift() ).indexOf( '}' ) < 0 )
					{
						content = content.substr( content.indexOf( '*' ) + 1 );
						var vertexReg:EReg = ~/MESH_VERTEX\s*(\d+)\s*([\d-.]+)\s*([\d-.]+)\s*([\d-.]+)/;
						id = Std.parseInt( vertexReg.replace( content, "$1" ) );
						var v1:Float = Std.parseFloat(vertexReg.replace(content, "$2"));
						var v2:Float = Std.parseFloat(vertexReg.replace(content, "$4"));
						var v3:Float = Std.parseFloat(vertexReg.replace(content, "$3"));

						l_oGeometry.setVertex(id, v1*m_nScale, v2*m_nScale, v3*m_nScale );
					}
				}
				case 'MESH_FACE_LIST':
				{
					while( ( content = lines.shift() ).indexOf( '}'  ) < 0 )
					{
						content = content.substr( content.indexOf( '*' ) + 1 );
						var mfl:String = content.split(  '*' )[0]; // ignore: [MESH_SMOOTHING,MESH_MTLID]
						//"MESH_FACE    0:    A:    777 B:    221 C:    122 AB:    1 BC:    1 CA:    1"
						var faceReg:EReg = ~/MESH_FACE\s*(\d+):\s*A:\s*(\d+)\s*B:\s*(\d+)\s*C:\s*(\d+)\s*AB:\s*(\d+)\s*BC:\s*(\d+)\s*CA:\s*(\d+)\s*/;
						id = Std.parseInt( faceReg.replace(mfl, "$1") );
						var p1:Int = Std.parseInt(faceReg.replace(mfl, "$2"));
						var p2:Int = Std.parseInt(faceReg.replace(mfl, "$3"));
						var p3:Int = Std.parseInt(faceReg.replace(mfl, "$4"));

						l_oGeometry.setFaceVertexIds(id, [p1, p2, p3] );
					}
				}
				case 'MESH_TVERTLIST':
				{
					while( ( content = lines.shift() ).indexOf( '}' ) < 0 )
					{
						content = content.substr( content.indexOf( '*' ) + 1 );
						var vertexReg:EReg = ~/MESH_TVERT\s*(\d+)\s*([\d-.]+)\s*([\d-.]+)\s*([\d-.]+)/;
						id = Std.parseInt(vertexReg.replace(content, "$1"));
						var v1:Float = Std.parseFloat(vertexReg.replace(content, "$2"));
						var v2:Float = Std.parseFloat(vertexReg.replace(content, "$3"));
						//var v3 = (vertexReg.replace(content, "$2"));
						l_oGeometry.setUVCoords(id, v1, 1-v2 );
					}
				}
				//TODO: there are ASE file without MESH_TFACELIST, what then
				case 'MESH_TFACELIST':
				{
					while( ( content = lines.shift() ).indexOf( '}' ) < 0 )
					{
						content = content.substr( content.indexOf( '*' ) + 1 );
						var faceReg:EReg = ~/MESH_TFACE\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)/;
						id = Std.parseInt(faceReg.replace(content, "$1"));
						var f1:Int = Std.parseInt(faceReg.replace(content, "$2"));
						var f2:Int = Std.parseInt(faceReg.replace(content, "$3"));
						var f3:Int = Std.parseInt(faceReg.replace(content, "$4"));
						l_oGeometry.setFaceUVCoordsIds( id, [f1, f2, f3] );
					}
				}
			}
		}
		// --
		l_oShape = new Shape3D( null, l_oGeometry, m_oStandardAppearance );
		m_oGroup.addChild( l_oShape );
		// -- Parsing is finished
		var l_eOnInit:ParserEvent = new ParserEvent( ParserEvent.INIT );
		l_eOnInit.group = m_oGroup;
		dispatchEvent( l_eOnInit );
	}
}// -- end AseParser

