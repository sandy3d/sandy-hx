
package sandy.util;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
#if flash
import flash.net.URLVariables;
#end
import flash.utils.ByteArray;

import sandy.events.QueueEvent;
import sandy.events.SandyEvent;

import sandy.HaxeTypes;

/**
* Asset types for LoaderQueues.
*
* BIN Binary file
*
* IMAGE png or jpeg files
*
* SWF swf files
*
* SOUND mp3 asset
**/
enum AssetType {
	BIN;
	TEXT;
#if flash
	VARIABLES;
#end
	IMAGE;
	SWF;
	SOUND;
}

/*
[Event(name="queueComplete", type="sandy.events.QueueEvent")]
[Event(name="queueResourceLoaded", type="sandy.events.QueueEvent")]
[Event(name="queueLoaderError", type="sandy.events.QueueEvent")]
*/
/**
* Utility class for loading resources.
*
* <p>A LoaderQueue allows you to queue up requests for loading external resources.</p>
*
* @author		Thomas Pfeiffer - kiroukou /Max Pellizzaro
* @author		Russell Weir
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		07.16.2008
*/
class LoaderQueue extends EventDispatcher
{
	private var m_oLoaders : Hash<QueueElement>;
	private var m_nLoaders : Int;
	private var m_oQueueCompleteEvent : QueueEvent;
	private var m_oQueueResourceLoadedEvent : QueueEvent;
	private var m_oQueueLoaderError : QueueEvent;

	public var data:Hash<Dynamic>;
	public var clips:Hash<LoaderInfo>;

	/**
	 * Creates a new loader queue.
	 *
	 */
	public function new()
	{
		data = new Hash();
		clips = new Hash();
		super();
		m_oLoaders = new Hash();
		m_oQueueCompleteEvent 		= new QueueEvent ( QueueEvent.QUEUE_COMPLETE );
		m_oQueueResourceLoadedEvent = new QueueEvent ( QueueEvent.QUEUE_RESOURCE_LOADED );
		m_oQueueLoaderError 		= new QueueEvent ( QueueEvent.QUEUE_LOADER_ERROR );
		m_nLoaders = 0;
	}

	/**
	 * Adds a new request to this loader queue. The request may either be a string
	 * URL or a URLRequest instance. If not specified, the method will try to figure
	 * out the correct content type from the extension on the p_dRequest url.
	 *
	 * Loading does not commence until the start() method is called.
	 *
	 * @param p_sID		A string identifier for this request
	 * @param p_dRequest A URLRequest or string url
	 * @param type An optional asset type specifier. Most types can be automatically determined
	 *  from the url.
	 * @throws String if content type can not be determined
	 */
	public function add( p_sID : String, p_dRequest : Dynamic, type:AssetType = null ) : Void
	{
		var p_oURLRequest : URLRequest = null;
		if(Std.is(p_dRequest, URLRequest)) {
			p_oURLRequest = cast p_dRequest;
		}
		else if(Std.is(p_dRequest, String)) {
			p_oURLRequest = new URLRequest(cast p_dRequest);
		}
		else {
			throw "Invalid request type";
		}

		if(type == null) {
			var parts = p_oURLRequest.url.split(".");
			if(parts.length == 0) {
				type = BIN;
			}
			else {
				type = switch(parts[parts.length-1].toLowerCase()) {
				case "jpg", "jpeg", "png", "gif": IMAGE;
				case "mp3": SOUND;
				case "swf": SWF;
				default:
					throw "Unknown asset type " + parts[parts.length-1].toLowerCase();
				}
			}
		}

		var qe = new QueueElement(p_sID, type, p_oURLRequest);
		switch(type) {
		case BIN, TEXT #if flash ,VARIABLES #end:
			var ldr = new URLLoader ();
			ldr.dataFormat = switch(type) {
				case BIN: URLLoaderDataFormat.BINARY;
				case TEXT: URLLoaderDataFormat.TEXT;
				#if flash
				case VARIABLES: URLLoaderDataFormat.VARIABLES;
				#end
				default: URLLoaderDataFormat.BINARY;
				}
			qe.urlLoader = ldr;
		case IMAGE, SWF:
			qe.loader = new Loader();
		case SOUND:
			qe.sound = new Sound();
		}
		// --
		if(!m_oLoaders.exists(p_sID))
			m_nLoaders++;
		m_oLoaders.set( p_sID, qe);
	}

	private function getIDFromLoader( p_oLoader:Loader ):String
	{
		for ( l_oElement in m_oLoaders )
		{
			if( p_oLoader == l_oElement.loader )
				return l_oElement.name;
		}
		return null;
	}

	private function getIDFromURLLoader( p_oLoader:URLLoader ):String
	{
		for ( l_oElement in m_oLoaders )
		{
			if( p_oLoader == l_oElement.urlLoader )
			{
				return l_oElement.name;
			}
		}
		return null;
	}

	private function getIDFromSoundLoader( p_oLoader:Sound ):String
	{
		for ( l_oElement in m_oLoaders )
		{
			if( p_oLoader == l_oElement.sound )
			{
				return l_oElement.name;
			}
		}
		return null;
	}

	/**
	 * Starts the loading of all resources in the queue.
	 *
	 * <p>All loaders in the queue are started and IOErrorEvent and the COMPLETE event are subscribed too.</p>
	 */
	public function start() : Void
	{
		var noLoaders = true;
		for ( l_oLoader in m_oLoaders )
		{
			noLoaders = false;
			if (l_oLoader.loader != null) {
				l_oLoader.loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeHandler );
				l_oLoader.loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				l_oLoader.loader.load( l_oLoader.urlRequest );
			}
			else if(l_oLoader.urlLoader != null) {
				l_oLoader.urlLoader.addEventListener( Event.COMPLETE, completeHandler );
	            l_oLoader.urlLoader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				l_oLoader.urlLoader.load( l_oLoader.urlRequest );
			}
			else if(l_oLoader.sound != null) {
				l_oLoader.sound.addEventListener( Event.COMPLETE, completeHandler );
	            l_oLoader.sound.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				l_oLoader.sound.load( l_oLoader.urlRequest );
			}
		}
		if (noLoaders) {
			// still need to dispatch complete event
			m_oQueueCompleteEvent.loaders = m_oLoaders;
			dispatchEvent( m_oQueueCompleteEvent );
		}
	}

	/**
	 * Fires a QueueEvent, once all requested resources are loaded.
	 * Type QUEUE_COMPLETE
	 */
	private function completeHandler( p_oEvent:Event ) : Void
	{
		var l_sName:String = null;

		if (Std.is(p_oEvent.target, flash.net.URLLoader)) {
			// BIN, TEXT, VARIABLES
			var l_oLoader:URLLoader = p_oEvent.target;
			l_sName = getIDFromURLLoader( l_oLoader );

			var qe : QueueElement = m_oLoaders.get(l_sName);
			if(qe != null) {
				switch(qe.assetType) {
				case BIN:
					qe.binaryData = l_oLoader.data;
				case TEXT:
					qe.text = l_oLoader.data;
				#if flash
				case VARIABLES:
					qe.variables = new URLVariables(l_oLoader.data);
				#end
				default:
					trace("Bad type " + qe.assetType + " for " + qe.name);
				}
			}
			data.set( l_sName, l_oLoader.data);
			clips.set( l_sName, p_oEvent.target);
		}
		else if(Std.is(p_oEvent.target, flash.display.LoaderInfo)) {
			// IMAGE, SWF
			var l_oLoaderInfos:LoaderInfo = p_oEvent.target;
			var l_oLoader:Loader = l_oLoaderInfos.loader;
			l_sName = getIDFromLoader( l_oLoader );

			var qe : QueueElement = m_oLoaders.get(l_sName);
			if(qe != null) {
				switch(qe.assetType) {
				case IMAGE:
					if(Reflect.hasField( l_oLoader.content, "bitmapData" ))
						qe.bitmapData = Reflect.field( l_oLoader.content, "bitmapData");
				case SWF:
					qe.swf = l_oLoaderInfos.content;
				default:
					trace("Bad type " + qe.assetType + " for " + qe.name);
				}
			}
			data.set( l_sName, l_oLoaderInfos.content );
			clips.set( l_sName, l_oLoaderInfos);
		}
		else if(Std.is(p_oEvent.target, Sound)) {
			// SOUND
			try {
				var l_sound:Sound = p_oEvent.target;
				l_sName = getIDFromSoundLoader(l_sound);
				data.set( l_sName, l_sound);
			} catch(e:Dynamic) {
				trace(e);
				trace(Type.getClassName(Type.getClass(p_oEvent.target)));
			}
		}
		else {
			throw "Internal error. Unexpected " + Type.getClassName(Type.getClass(p_oEvent.target));
		}
		// Fire an event to indicate that a single resource loading was completed (needs to be enhanced to provide more info)
		dispatchEvent( m_oQueueResourceLoadedEvent );
		// --
		m_nLoaders--;
		// --
		if( m_nLoaders == 0 )
		{
			m_oQueueCompleteEvent.loaders = m_oLoaders;
			dispatchEvent( m_oQueueCompleteEvent );
		}
	}

	/**
	 * Fires an error event if any of the loaders didn't succeed
	 *
	 */
	private function ioErrorHandler( p_oEvent : IOErrorEvent ) : Void
	{
		// Fire an event to indicate that a single resource loading failed (needs to be enhanced to provide more info)
		dispatchEvent( m_oQueueLoaderError );

		m_nLoaders--;

		if( m_nLoaders == 0 )
		{
			m_oQueueCompleteEvent.loaders = m_oLoaders;
			dispatchEvent( m_oQueueCompleteEvent );
		}
	}

	public function getBytesLoaded():Int {
		var bytes:Int=0;
		for (l_oLoader in m_oLoaders) {
			if (l_oLoader.loader!=null){
				bytes+=l_oLoader.loader.contentLoaderInfo.bytesLoaded;
			} else {
				bytes+=l_oLoader.urlLoader.bytesLoaded;
			}
		}
		return bytes;
	}

	public function getBytesTotal():Int{
		var bytes:Int=0;
		for (l_oLoader in m_oLoaders) {
			if (l_oLoader.loader!=null){
				bytes+=l_oLoader.loader.contentLoaderInfo.bytesTotal;
			} else {
				bytes+=l_oLoader.urlLoader.bytesTotal;
			}
		}
		return bytes;
	}
}

class QueueElement
{
	public var name:String;
	public var assetType : AssetType;
	public var urlRequest:URLRequest;

	/** Valid from assetTypes SWF and IMAGE **/
	public var loader:Loader;
	/** Valid for assetType BIN **/
	public var urlLoader:URLLoader;

	/** Valid for assetType BINARY **/
	public var binaryData : ByteArray;
	/** Valid for assetType TEXT **/
	public var text : String;
	#if flash
	/** Valid for assetType VARIABLES **/
	public var variables : URLVariables;
	#end
	/** Valid for assetType IMAGE **/
	public var bitmapData : BitmapData;
	/** Valid for assetType SWF **/
	public var swf : DisplayObject;
	/** Valid for assetType SOUND **/
	public var sound : Sound;

	public function new( p_sName:String, type:AssetType, p_oURLRequest : URLRequest )
	{
		name = p_sName;
		assetType = type;
		urlRequest = p_oURLRequest;
	}

}
