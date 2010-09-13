
package sandy.materials.videoex;

import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.system.Security;

enum VideoSourceType {
	VST_URI;
	VST_RTMP;
	VST_VIDEO;
}

/**
* The base abstract class for video sources for VideoMaterialEx
*
* @author		Russell Weir
* @since		3.2
* @version		3.2
* @date 		2009.04.22
*/
class VideoSource {
	/**
	* Set to true to use AMF3 when using VST_RTMP sources. Defaults to
	* [false] which causes rtmp connections to use AMF0
	*/
	public static var DEFAULT_USE_AMF3 : Bool = false;

	public var soundVolume(default,__setSoundVolume) : Float;
	public var startTime(default,__setStartTime) : Float;
	public var type(default,null) : VideoSourceType;
	public var uri(default,null):String;
	/** Number of seconds of stream to play. Defaults to -1 (all of stream) **/
	public var playLength(default,__setPlayLength):Float;

	// rtmp specific
	public var appName(default,null) : String;
	public var host(default,null) : String;
	public var instanceName(default,null) : String;
	public var protocol(default,null) : String;
	public var useAmf3(default,null) : Bool;

	private var m_path : String;

	private function new(uri:String,volume:Float=1.0)
	{
		this.uri = uri;
		this.soundVolume = volume;
		this.startTime = 0.;
		this.playLength = -1;
	}

	/**
	* Returns the target for a NetConnection.connect() call
	*/
	public function getNetConnectTarget() : String
	{
		return throw "Invalid";
	}

	/**
	* Returns the uri or uri fragment to use for
	* NetStream.play() calls
	*/
	public function getNetStreamPlayTarget() : String
	{
		return throw "Invalid";
	}

	private function __setPlayLength(v:Float) : Float
	{
		if(v < 0)
			this.playLength = -1;
		else
			this.playLength = v;
		return v;
	}

	private function __setSoundVolume(v:Float):Float
	{
		var v2 = Math.abs(v);
		this.soundVolume = (v2 > 1.0) ? 1.0 : v2;
		return v;
	}

	private function __setStartTime(v:Float):Float
	{
		this.startTime = (v < 0.0) ? 0.0 : v;
		return v;
	}
}

/**
* A VideoSource from a uri, which may be an absolute or relative path,
* an rtmp source, or a file:// source. This class is able to create
* rtmp sources, but there is a VideoRtmpSource class that has more
* options.
*
* @author		Russell Weir
* @since		3.2
* @version		3.2
* @date 		2009.04.22
*/
class VideoUriSource extends VideoSource
{
	/**
	* @param uri Full uri to source
	* @param volume Playback volume, 0-1. Defaults to 1.0 (full volume)
	*/
	public function new(uri:String,volume:Float=1.0)
	{
		super(uri,volume);
		type = VST_URI;
		parseUri();
	}


	/**
	* Returns the target for a NetConnection.connect() call
	*/
	override public function getNetConnectTarget() : String
	{
		return switch(type) {
		case VST_URI:
			null;
		case VST_RTMP:
			protocol+"://" + host + (appName.length > 0 ? "/" : "") + appName;
		case VST_VIDEO: throw "Internal error";
		}
	}

	/**
	* Returns the uri or uri fragment to use for
	* NetStream.play() calls
	*/
	override public function getNetStreamPlayTarget() : String
	{
		return switch(type) {
		case VST_URI: m_path;
		case VST_RTMP: instanceName;
		case VST_VIDEO: throw "Internal error";
		}
	}

	private function parseUri() : Void {
		if(this.uri == null || this.uri == "")
			throw "Null uri";

		var isPath : Bool = false;
		var isFile : Bool = false;
		var rtmp = ~/^(rtmp(w|s|t|te|fp)?:\/\/)(.*)/;
		var file = ~/^(file:\/\/)(.*)/;
		var http = ~/^(http(s)?:\/\/)(.*)/;
		if(rtmp.match(uri)) {
			type = VST_RTMP;
			protocol = rtmp.matched(2);
			protocol = (protocol == null) ? "rtmp" : "rtmp" + protocol;
			if(rtmp.matched(3) == null)
				throw "Null path";
			var parts = new Array<String>();
			for(p in rtmp.matched(3).split("/")) {
				if(p != "")
					parts.push(p);
			}
			if(parts.length < 2) {
				throw "Null path";
			}
			host = parts.shift();
			instanceName = parts.pop();
			appName = (parts.length == 0) ? "" : parts.join("/");
		}
		else if(file.match(uri)) {
			isPath = true;
			m_path = file.matched(2);
			if(m_path == null)
				throw "Null path";
		}
		else if(http.match(uri)) {
			if(http.matched(2) != null) {
				if(Security.sandboxType == Security.LOCAL_WITH_FILE) {
					// translate http://host.org/path to local
					// filesystem path
					m_path = http.matched(2);
					var idx = m_path.indexOf("/");
					if(idx > 0) {
						m_path = m_path.substr(idx+1);
						if(m_path.length > 0)
							uri = m_path;
					}
					isPath = true;
				}
			}
		}
		else { // just a path (one hopes)
			isPath = true;
			m_path = uri;
		}

		// add "./" to local paths, if relative in local/file sandbox
		if(isPath && Security.sandboxType == Security.LOCAL_WITH_FILE) {
			if(m_path.charAt(0) != "/" && m_path.substr(0,2) != "./") {
				m_path = "./" + m_path;
			}
		}
	}
}

/**
* An rtmp server video source.
*
* @author		Russell Weir
* @since		3.2
* @version		3.2
* @date 		2009.04.22
*/
class VideoRtmpSource extends VideoUriSource
{
	/** Will only connect to an existing live stream **/
	public static inline var LIVE_ONLY : Float = -1.;
	/** Connect to live stream, if it exists, then tries recorded stream **/
	public static inline var LIVE_OR_RECORDED : Float = -2.;
	/** Connect to a recorded stream at 0.0 seconds **/
	public static inline var RECORDED : Float = 0.;
	/**
	* Creates an rtmp video source. Refer to NetStream.play() for documentation
	* regarding the [start] parameter.
	*
	* @param uri Full rtmp uri
	* @param volume Playback volume, 0-1. Defaults to 1.0 (full volume)
	* @param start Playback start time in stream. Defaults to 0 (beginning of recorded stream)
	* @param useAmf3 Sets whether to use AMF0 (false), AMF3(true) or VideoSource.DEFAULT_USE_AMF3 (null)
	**/
	public function new(uri:String,volume:Float=1.0,start:Float=0.0,useAmf3:Null<Bool>=null)
	{
		super(uri,volume);
		if(type != VST_RTMP)
			throw "Invalid uri";
		if(useAmf3 == null)
			this.useAmf3 = VideoSource.DEFAULT_USE_AMF3;
		else
			this.useAmf3 = useAmf3;
		this.startTime = start;
	}

	override private function __setStartTime(v:Float):Float
	{
		if(v < 0.) {
			if(v <= -2.)
				this.startTime = -2.;
			else
				this.startTime = -1.;
		}
		else
			this.startTime = v;
		return v;
	}
}

/**
* If you have created an external Video source, the
* uri from which it is loaded, as well as the NetStream and NetConnection
* objects must be passed in. Event handlers are added to these objects,
* as internal methods rely on them, and for methods like stop() to work,
* this class requires the objects. Keep in mind that on reconnects.
*
* The NetConnection and NetStream clients should be setup on the
* provided objects to avoid exceptions. If your application does not
* require clients, use the VideoMaterialEx clients.
*
* <pre>
* var source = new VideoObjectSource("http://foo/bar.flv",myVideo,myNetStream,myNetCon);
* var videoMaterial = new VideoMaterialEx(source);
* myNetCon.client = videoMaterial.clientNetConnection;
* myNetStream.client = videoMaterial.clientNetStream;
* </pre>
*
* @author		Russell Weir
* @since		3.2
* @version		3.2
* @date 		2009.04.22
*/
class VideoObjectSource extends VideoSource
{
	public var video(default,null) : Video;
	public var netStream(default,null) : NetStream;
	public var netConnection(default,null) : NetConnection;


	/**
	* Creates a new VideoSource from an existing Video/NetStream/NetConnection
	* chain.
	*
	* @param video Existing Video object, connected to a NetStream
	* @param ns Existing NetStream connected to a NetConnection
	* @param nc Existing NetConnection connected to a server or null connect
	* @param volume Playback volume, 0-1. Defaults to 1.0 (full volume)
	* @param start Playback start time in stream. Defaults to 0 (beginning of stream)
	**/
	public function new(uri:String,video:Video,ns:NetStream,nc:NetConnection,volume:Float=1.0,start:Float=0.0)
	{
		super(uri,volume);
		this.video = video;
		this.netStream = ns;
		this.netConnection = nc;

		if(video == null)
			throw "Invalid video object";
		if(netStream == null)
			throw "Invalid NetStream object";
		if(netConnection == null)
			throw "Invalid NetConnection object";
	}
}
