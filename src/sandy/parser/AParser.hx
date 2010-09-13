
package sandy.parser;

import sandy.core.scenegraph.Group;
import sandy.events.QueueEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.util.ArrayUtil;
import sandy.util.LoaderQueue;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import sandy.HaxeTypes;

/**
* ABSTRACT CLASS - super class for all parser objects.
*
* <p>This class should not be directly instatiated, but sub classed.<br/>
* The AParser class is responsible for creating the root Group, loading files
* and handling the corresponding events.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		26.07.2007
*/
class AParser extends EventDispatcher, implements IParser, implements IEventDispatcher
{
	private static var NextID:Int = 0;

	private var m_oLoader:URLLoader;
	private var m_oGroup:Group;
	private var m_oFile:Dynamic;
	private var m_oFileLoader:URLLoader;
	private var m_sDataFormat:URLLoaderDataFormat;
	private var m_nScale:Float;
	private var m_oStandardAppearance : Appearance;

	private var m_sUrl:String;
	public var m_sName:String;

	private var m_sTextureExtension:String;
	private var m_aShapes:Array<Dynamic>;
	private var m_aTextures:Array<String>;
	private var m_oQueue:LoaderQueue;
	
	public var m_nId:Int;

	/**
	* Default path for images.
	*/
	public var RELATIVE_TEXTURE_PATH:String;

	/**
	* Creates a parser object. Creates a root Group, default appearance
	* and sets up an URLLoader.
	*
	* @param p_sFile		Must be either a text string containing the location
	* 						to a file or an embedded object
	* @param p_nScale		The scale amount
	*/
	public function new( p_sFile:Dynamic, ?p_nScale:Float = 1.0, ?p_sTextureExtension:String)
	{
		m_nId = AParser.NextID++;
	
		m_oLoader = new URLLoader();
		RELATIVE_TEXTURE_PATH = ".";

		super( this );
		m_oGroup = new Group('parser');
		m_nScale = p_nScale;
		m_sTextureExtension = p_sTextureExtension;
		if( Std.is( p_sFile, String ) )
		{
			m_sUrl = cast p_sFile;
			m_oFileLoader = new URLLoader();
			m_sDataFormat = URLLoaderDataFormat.TEXT;

			// assume that textures are in same folder with model itself
			if (~/[\/\\]/.match(m_sUrl))
				RELATIVE_TEXTURE_PATH = ~/(.*)[\/\\][^\/\\]+/.replace(m_sUrl,"$1");
		}
		else
		{
			m_oFile = p_sFile;
		}

		standardAppearance = new Appearance( new ColorMaterial( 0xFF, 100, new MaterialAttributes( [new LineAttributes()] ) ) );
	}

	/**
	* Set the standard appearance for all the parsed objects.
	*
	* @param p_oAppearance		The standard appearance
	*/
	public var standardAppearance( null, __setStandardAppearance ):Appearance;
	private function __setStandardAppearance( p_oAppearance:Appearance ):Appearance
	{
		m_oStandardAppearance = p_oAppearance;
		return p_oAppearance;
	}

	/**
	* Called when an I/O error occurs.
	*
	* @param	e	The error event
	*/
	private function _io_error( e:IOErrorEvent ):Void
	{
		dispatchEvent( new ParserEvent( ParserEvent.FAIL ) );
	}

	/**
	* This method is called when all files are loaded and initialized
	*
	* @param e		The event object
	*/
	private function parseData( ?e:Event ):Void
	{
		if( e != null )
		{
			m_oFileLoader = e.target; //URLLoader( e.target );
			m_oFile = m_oFileLoader.data;
		}
	}

	private function onProgress( p_oEvt:ProgressEvent ):Void
	{
		var event:ParserEvent = new ParserEvent( ParserEvent.PROGRESS );
		event.percent = 100 * p_oEvt.bytesLoaded / p_oEvt.bytesTotal;
		dispatchEvent( event );
	}

	/**
		* @private
		*/
	private function dispatchInitEvent():Void
	{
		// -- load textures, if any
		if (m_aTextures != null)
		{
			m_oQueue = new LoaderQueue();
			for(i in 0... m_aTextures.length)
			{
				m_oQueue.add(Std.string(i), new URLRequest(RELATIVE_TEXTURE_PATH + "/" + m_aTextures[i]));
			}
			m_oQueue.addEventListener(QueueEvent.QUEUE_COMPLETE, onTexturesloadComplete);
			m_oQueue.addEventListener(QueueEvent.QUEUE_LOADER_ERROR, onTexturesloadError);
			m_oQueue.start();
		}
		else
		{
			var l_eOnInit:ParserEvent = new ParserEvent(ParserEvent.INIT);
			l_eOnInit.group = m_oGroup;
			dispatchEvent(l_eOnInit);
		}
	}

	private function onTexturesloadError(e:Event = null):Void
	{
		trace("Parser can't load automatically the texture(s), check RELATIVE_TEXTURE_PATH property in documentation");
	}

	private function onTexturesloadComplete(e:QueueEvent):Void
	{
		for (i in 0...m_aShapes.length)
		{
			var si = Std.string(i);
			// set successfully loaded materials
			if (m_oQueue.data.exists(si))
			{
				var shapes :Array<Dynamic> = m_aShapes[i];
				var mat:Appearance = new Appearance(new BitmapMaterial(untyped m_oQueue.data.get(si).bitmapData));
				for (j in 0...shapes.length)
				{
					// whatever is in m_aShapes must have appearance property or be dynamic class
					shapes[j].m_oAppearance = mat;
				}
			}
		}

		m_oQueue.removeEventListener(QueueEvent.QUEUE_COMPLETE, onTexturesloadComplete);

		// this is called even if there were errors loading textures... perfect!
		m_aShapes = null;
		m_aTextures = null;
		dispatchInitEvent();
	}

	/**
		* @private used internally to load textures
		*/
	private function applyTextureToShape(shape:Dynamic, texture:String):Void
	{
		var texName:String = changeExt(texture);
		var texId:Int = -1;

		if (m_aTextures == null)
		{
			// there was no textures enqueued so far
			m_aTextures = [];
			m_aShapes = [];
		}
		else
		{
			// look up texture, maybe we have it enqueued
			texId = ArrayUtil.indexOf(m_aTextures, texName);
		}

		if (texId < 0)
		{
			// this texture is not enqueued yet
			m_aTextures.push(texName);
			m_aShapes.push([shape]);
		}
		else
		{
			// this texture is enqueued, just add shape to the list
			m_aShapes[texId].push(shape);
		}
	}

	/**
	* @private Collada parser already loads textures on its own, so it needs this protected
	*/
	private function changeExt(s:String):String
	{
		if (m_sTextureExtension != null)
		{
			var tmp = s.split(".");
			if (tmp.length > 1)
			{
				tmp[tmp.length - 1] = m_sTextureExtension;
				s = tmp.join(".");
			}
			else
			{
				// leave as is?
				s += "." + m_sTextureExtension;
			}
		}
		return s;
	}

	/**
	* Load the file that needs to be parsed. When done, call the parseData method.
	*/
	public function parse():Void
	{
		switch ( Type.typeof( m_sUrl ) ) {
		case TClass( String ):
			// Construction d'un objet URLRequest qui encapsule le chemin d'acces
			var urlRequest:URLRequest = new URLRequest( m_sUrl );
			// Ecoute de l'evennement COMPLETE
			m_oFileLoader.addEventListener( Event.COMPLETE, parseData );
			m_oFileLoader.addEventListener( ProgressEvent.PROGRESS, onProgress );
			m_oFileLoader.addEventListener( IOErrorEvent.IO_ERROR , _io_error );
			// Lancer le chargement
			m_oFileLoader.dataFormat = m_sDataFormat;
			m_oFileLoader.load(urlRequest);
		default:
			parseData();
		}
	}
}

