
package sandy.materials.videoex;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.utils.Timer;


import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.data.Matrix4;
import sandy.core.scenegraph.Shape3D;
import sandy.events.BubbleEvent;
import sandy.events.BubbleEventBroadcaster;
import sandy.materials.BitmapMaterial;
import sandy.materials.MaterialType;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.videoex.VideoSource;
import sandy.math.ColorMath;
import sandy.util.NumberUtil;
import sandy.HaxeTypes;



enum PlayStatus {
	DISCONNECTED;
	NET_CONNECT;
	STREAM_CONNECT;
	PLAYING;
	PAUSED;
	STOPPED;
}

/**
* Displays an flv or rtmp stream as a 3D shape material.
*
* Network events are all handled, so that if an rtmp server drops,
* automatic reconnection will be tried.
*
* The events broadcast by this class are BubbleEvent types,
* but do not have a parent to bubble from, so they are dispatched
* directly from the video material.
*
* @author		Russell Weir
* @since		3.2
* @version		3.2
* @date 		2009.04.22
*/
class VideoMaterialEx extends BitmapMaterial, implements IEventDispatcher
{
	// events
	/**
	* Dispatched when a successful connection is made, and the netStream
	* object is valid.
	**/
	public static inline var CONNECT:String = "connect";
	/**
	* Dispatched by the default [clientNetStream] object handler for NetStream when
	* meta data events are received. The event will have it's
	* [info] property set to the object provided by NetStream
 	* If the [clientNetStream] property is changed, you will not receive these events.
	**/
	public static inline var METADATA:String = "metaData";
	/**
	* Dispatched by the default [clientNetStream] object handler for NetStream when
	* cue point events are received. The event will have it's
	* [info] property set to the object provided by NetStream
 	* If the [clientNetStream] property is changed, you will not receive these events.
	**/
	public static inline var CUEPOINT:String = "cuePoint";

	/** Dispatched when video starts a new loop **/
	public static inline var LOOP:String = "loop";
	/** Dispatched when video is complete, with no loops remaining. **/
	public static inline var COMPLETE:String = "complete";

	/**
	* Determines whether the video source url will be displayed on
	* the texture in case of an error. Defaults to false, set to
	* true for more informative textures
	**/
	public static var DEFAULT_ERRORS_SHOW_URL:Bool = false;
	/**
	* Default color used to draw the bitmapdata content.
	* In case you need a specific color, change this value at your application initialization.
	*/
	public static var DEFAULT_FILL_COLOR:Int = 0;
	/**
	* The NetConnection client object
	**/
	public var clientNetConnection:Dynamic;
	/**
	* The NetStream client object
	* @see CLIENTDATA event
	**/
	public var clientNetStream:Dynamic;
	/**
	* Number of loops, default to -1 to repeat continually. Set to 0 for 1 play, 1 for 2 plays etc.
	**/
	public var loops : Int;
	/**
	* The NetConnection object in use.
	**/
	public var netConnection(default,null):NetConnection;
	/**
	* The NetStream object in use.
	**/
	public var netStream(default,null):NetStream;
	/**
	* The url of the current video source, or null
	**/
	public var url(__getUrl,null):String;
	/**
	* Max volume of the sound if camera position is at sound position,
	* multiplied by the volume of the VideoSource to calculate total
	* volume. Defaults to 1.0.
	*/
	public var soundVolume(default,__setSoundVolume):Float;
	/**
	* The radius of the sound. Defaults to 1000
	*/
	public var soundRadius:Float;
	/**
	* Maximal pan is a positive Number from 0-1. If 0, no panning will occur,
	* otherwise panning of the sound is relative to the camera rotation. Defaults
	* to 1.0
	*/
	public var soundMaxPan(default,__setSoundMaxPan):Float;
	/**
	* The current status of the play state.
	**/
	public var status(default,null) : PlayStatus;


	private var m_curLoop : Int; // current play loop number
	private var m_oEB:EventDispatcher;
	private var m_timer:Timer;
	private var m_video:Video;
	private var m_doRedraw:Bool; // set when video needs redrawing
	private var m_alphaTransform:ColorTransform;
	private var m_sPath:String;

	// connection settings
	private var m_autoplay : Bool; // play automatically on connect
	private var m_restartPos: Float; // start time in seconds
	// sound
	private var m_shape3D : Shape3D;
	private var m_soundTransform:SoundTransform;
	private var m_soundCulled:Bool;
	private var m_totalVolume:Float;
	// playlist
	private var m_playlist : Array<VideoSource>;
	private var m_playlistIdx : Int;

	/**
	* Creates a new VideoMaterialEx. The quality of the rendered surface depends
	* on the width and height parameters.
	*
	* @param src An initial video source. May be null, in which case the [play()] method must be called to start the video
	* @param numLoops Number of play loops. -1 is infinite.
	* @param width Width of the rendering BitmapData surface onto which the video data is rendered.
	* @param height Height of the rendering BitmapData surface onto which the video data is rendered.
	* @param updateMS Milliseconds between redrawing BitmapData
	* @param attr Additional material attributes
	**/
	public function new( src:VideoSource, numLoops:Int=-1, width:Int=320, height:Int=240, updateMS:Int = 40, attr:MaterialAttributes=null )
	{
		super( new BitmapData( width, height, true, DEFAULT_FILL_COLOR ), attr );

		status = DISCONNECTED;
		m_oEB = new EventDispatcher(this);

		m_curLoop = 0;
		loops = numLoops;
		m_alphaTransform = new ColorTransform ();
		m_oType = MaterialType.VIDEO;

		// playlist
		m_playlist = new Array();
		m_playlistIdx = -1;
		// connection settings
		m_autoplay = true;
		m_restartPos = 0.;
		// sound
		m_soundTransform = new SoundTransform(1,0);
		m_soundCulled = false;
		soundVolume = 1.0;
		m_totalVolume = 1.0;
		soundRadius = 1000;
		soundMaxPan = 1.;


		// create update timer, which draws video info to bitmapdata m_oTexture
		m_timer = new Timer( updateMS );
		subscribeEvents(m_timer);

		// Setup the default NetStream client object
		clientNetStream = {};
		clientNetStream.onMetaData = __onMetaData;
		clientNetStream.onCuePoint = __onCuePoint;
		clientNetStream.onPlayStatus = __onPlayStatus;

		clientNetConnection = {}
		clientNetConnection.onBWDone = __onBWDone;
		clientNetConnection.onFCSubscribe = __onFCSubscribe;

		forceUpdate = true;
		play(src);
	}

	override public function dispose():Void
	{
		teardown();
		unsubcribeEvents(m_timer);
		m_alphaTransform = null;
		m_timer = null;
		m_video = null;
		m_shape3D = null;
		// Call after we've stopped video playback to the bitmap
		super.dispose();
	}

	/**
	* Pauses playback.
	*/
	public function pause():Void
	{
		#if debug
		trace(here.methodName);
		#end
		m_timer.stop();
		m_autoplay = false;
		var doPause = false;
		status = switch(status) {
		case DISCONNECTED: DISCONNECTED;
		case NET_CONNECT: NET_CONNECT;
		case STREAM_CONNECT: STREAM_CONNECT;
		case PLAYING: doPause = true; PAUSED;
		case PAUSED: doPause = true; PAUSED;
		case STOPPED: STOPPED;
		}

		if(doPause) {
			try {
				netStream.pause();
				m_restartPos = netStream.time;
			} catch(e:Dynamic) {}
		}
	}

	/**
	* Plays the specified video source.
	*
	* @param src Any video source. Set to null with resetPlaylist true will clear the playlist, and stop playback
	* @param resetPlaylist Set to true to wipe playlist and play [src] immediately, false to append [src] to current playlist.
	*/
	public function play(src:VideoSource,resetPlaylist:Bool=false):Void
	{
		#if debug
		trace(here.methodName +  " " + status);
		#end

		if(resetPlaylist) {
			sandy.util.ArrayUtil.truncate(m_playlist);
			m_playlistIdx = -1;
		}

		if(src == null) {
			if(resetPlaylist) {
				stop();
			}
			return;
		}

		m_playlist.push(src);
		m_autoplay = true;

		var reset = resetPlaylist || m_playlist.length == 1;
		var doStart = switch(status) {
		case PLAYING : reset;
		case PAUSED : resetPlaylist;
		case STOPPED : true;
		case DISCONNECTED : true;
		case NET_CONNECT: false;
		case STREAM_CONNECT: false;
		}

		if(doStart) {
			playNext();
		}
	}

	public function resume() : Void
	{
		m_autoplay = true;
		var doResume = false;
		status = switch(status) {
		case DISCONNECTED: DISCONNECTED;
		case NET_CONNECT: NET_CONNECT;
		case STREAM_CONNECT: STREAM_CONNECT;
		case PLAYING: doResume = true; PLAYING;
		case PAUSED: doResume = true; PLAYING;
		case STOPPED: STOPPED;
		}
		try {
			if(doResume)
				netStream.resume();
			m_timer.start();
		} catch(e:Dynamic) {}
	}

	/**
	* Use this method to set the shape this material is attached to.
	* This allows for proper sound transforms in 3D space
	**/
	public function setShape3D(s:Shape3D) : Void
	{
		m_shape3D = s;
	}

	/**
	* Set the playhead position in seconds
	**/
	public function seek(posSeconds:Float) : Void
	{
		if(posSeconds < 0.)
			return;
		m_restartPos = posSeconds;
		pause();
		try netStream.seek(posSeconds) catch(e:Dynamic) {};
		resume();
	}

	/**
	* Stops playback, resetting the playhead to 0.0 seconds. Does not
	* stop download of video data, except in the case of an VST_RTMP server
	* that does not support the pause method.
	*/
	public function stop() : Void
	{
		#if debug
		trace(here.methodName);
		#end
		m_timer.stop();

		m_autoplay = false;
		m_restartPos = 0.;
		m_playlistIdx = -1;
		var doPause = false;
		status = switch(status) {
		case DISCONNECTED: DISCONNECTED;
		case NET_CONNECT: NET_CONNECT;
		case STREAM_CONNECT: STREAM_CONNECT;
		case PLAYING: doPause = true; STOPPED;
		case PAUSED: doPause = true; STOPPED;
		case STOPPED: doPause = true; STOPPED;
		}

		if(doPause) {
			try {
				netStream.pause();
			} catch(e:Dynamic) {}
		}
	}

	public function togglePause() : Void
	{
		switch(status) {
		case PAUSED: resume();
		default: pause();
		}
	}

	///////////////////// IEventDispatcher //////////////////////////////////
	public function addEventListener( type : String, listener : Dynamic -> Void, useCapture : Bool=false, priority : Int=0, useWeakReference : Bool=false ) : Void
	{
		m_oEB.addEventListener( type, listener, useCapture, priority, useWeakReference);
	}

	public function dispatchEvent( event : Event ) : Bool
	{
		return m_oEB.dispatchEvent( event );
	}

 	public function hasEventListener( type : String ) : Bool
	{
		return m_oEB.hasEventListener( type );
	}

	public function removeEventListener( type : String, listener : Dynamic -> Void, useCapture : Bool=false ) : Void
	{
		m_oEB.removeEventListener(type, listener, useCapture);
	}

	public function willTrigger( type : String ) : Bool
	{
		return m_oEB.willTrigger( type );
	}

	/////////////////////  Privates /////////////////////////////////////////

	private function connectStream()
	{
		if(netStream != null)
			teardown(false,true);

		netStream = new NetStream(netConnection);
		netStream.client = clientNetStream;
		netStream.checkPolicyFile = true;
		subscribeEvents(netStream);

		m_video = new Video(m_oTexture.width, m_oTexture.height);
		m_video.attachNetStream(netStream);

		status = STREAM_CONNECT;
		startPlay();
		if(!m_autoplay)
			pause();

		m_oEB.dispatchEvent( new BubbleEvent( CONNECT, this ) );
	}

	private function errorPlayNext(seconds:Float) : Void
	{
		var me = this;
		haxe.Timer.delay(function() {me.playNext();}, Std.int(seconds * 1000));
	}

	private function fatalError(msg:String)
	{
		#if debug
		trace(here.methodName + " " + msg);
		#end
		stop();
		m_oTexture.fillRect(m_oTexture.rect, 0xFF504949);

		var tf:TextField = new TextField();
		var format = tf.getTextFormat();
		format.font = "_sans";
		format.color = 0xFF0000;

		tf.defaultTextFormat = format;
		tf.multiline = true;
		tf.width = m_oTexture.width;
		tf.wordWrap = true;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.text = msg;

		m_oTexture.draw(tf);
	}

	private function __getUrl() : String {
		if(m_playlistIdx < 0 || m_playlistIdx >= m_playlist.length)
			return null;
		return m_playlist[m_playlistIdx].uri;
	}

	/**
	* rtmp server called client method that is not defined.
	**/
	private function __onAyncError(event:AsyncErrorEvent) : Void
	{
	}

	private function __onIoError(e:IOErrorEvent) : Void
	{
		fatalError("IoError for "+url+": " +  e.text);
	}

	private function __onNetStatus(e:NetStatusEvent):Void
	{
		// wait 5 seconds before retry
		var reconnect : Bool = false;
		// try next playlist item immediately, or wait 2 seconds if only 1 item
		var checkPlayNext : Bool = false;
		var url : String = DEFAULT_ERRORS_SHOW_URL ? __getUrl() : "video source";

		#if debug
		if(e.info.code.substr(0,16) != "NetStream.Buffer")
			trace(e.info.code + " " + status + " autoplay: " + m_autoplay);
		#end

		var origAutoplay = m_autoplay;

		switch( e.info.code ) {
		case "NetStream.Play.Start":
			if(m_autoplay) {
				status = PLAYING;
				m_timer.start();
			}
			else {
				m_timer.stop();
				netStream.pause();
				status = PAUSED;
			}

		case "NetStream.Play.Stop":
			// trace("" + m_curLoop + "/" + loops);
			if(m_playlistIdx + 1 < m_playlist.length) {
				playNext();
				return;
			}
			else if(loops < 0 || m_curLoop < loops)
			{
				if(playNext()) {
					m_curLoop++;
					m_oEB.dispatchEvent( new BubbleEvent( LOOP, this ) );
					return;
				}
			}
			stop();
			m_oEB.dispatchEvent( new BubbleEvent( COMPLETE, this ) );

		case "NetStream.Play.Failed": // error has occurred in playback for a reason other than those listed elsewhere, such as the subscriber not having read access.
			fatalError(url + " failed.");
			checkPlayNext = true;

		case "NetStream.Play.StreamNotFound":
			fatalError(url + " not found.");
			checkPlayNext = true;

		case "NetStream.Play.Reset":
			//play list reset

		case "NetStream.Play.FileStructureInvalid": //"error" The application detects an invalid file structure and will not try to play this type of file. For AIR and for Flash Player 9.0.115.0 and later.
			fatalError(url + " file structure invalid.");
			checkPlayNext = true;

		case "NetStream.Play.NoSupportedTrackFound":
			fatalError(e.info.code);
			checkPlayNext = true;

		case "NetStream.Pause.Notify":
			m_timer.stop();
			m_autoplay = false;

		case "NetStream.Unpause.Notify":
			m_timer.start();
			m_autoplay = true;

		case "NetStream.Seek.InvalidTime":
			if(e.info.message != null) {
				if(e.info.message.details != null)
					seek(e.info.message.details);
			}

		case "NetConnection.Connect.Closed":
			var showErr : Bool = false;
			m_timer.stop();
			// this can occur when a file is not found, and the
			// rtmp server disconnects without a NetStream.Play.StreamNotFound
			// or on a network error, like server drop.
			switch(status) {
			case DISCONNECTED:
			case NET_CONNECT: showErr = true; status = DISCONNECTED;
			case STREAM_CONNECT: showErr = true; status = DISCONNECTED;
			case PLAYING, PAUSED, STOPPED:
				m_autoplay = (status == PLAYING);
				m_restartPos = (status == STOPPED) ? 0.0 : netStream.time;
				reconnect = true;
			}
			if(showErr) {
				fatalError("Lost connection for " + url);
			}

		case "NetConnection.Connect.Failed":
			fatalError("Unable to connect to " + url);
			if(m_playlist.length > 1)
				checkPlayNext = true;
			else
				reconnect = true;

		case "NetConnection.Connect.Success":
			connectStream();

		case "NetConnection.Connect.Rejected":
			fatalError("No permission to access " + url);
			checkPlayNext = true;

		case "NetConnection.Connect.AppShutdown":
			reconnect = true;

		case "NetConnection.Connect.InvalidApp": // The application name specified during connect is invalid.
			fatalError("Invalid application for " + url);
			checkPlayNext = true;

		#if debug
		// no traces for these
		case "NetStream.Buffer.Empty","NetStream.Buffer.Full","NetStream.Buffer.Flush":
		default:
				trace(e.info.code);
		#end
		}

		if(checkPlayNext || reconnect)
		{
			teardown();
			m_autoplay = origAutoplay;

			if(m_playlist.length > 0) {
				if(checkPlayNext && m_playlist.length > 1) {
					playNext();
				}
				else if(checkPlayNext) {
					errorPlayNext(2.0);
				}
				else if(reconnect) {
					errorPlayNext(5.0);
				}
			}
			else {
				status = DISCONNECTED;
			}
		}
	}

	private function __onSecurityError(e:SecurityErrorEvent) : Void
	{
		fatalError("SecurityError for "+url+": " + e.text);
	}

	/**
	* Play the next item in the play list. Will handle connecting or switching
	* netConnection sources.
	*
	* @return True if next item is queued, false if there's nothing to play.
	**/
	private function playNext() : Bool
	{
		#if debug
		trace(here.methodName + " idx: " + m_playlistIdx);
		#end
		if( m_playlist.length == 0 )
			return false;

		var me = this;
		var isSameServer = function(c:VideoSource, n:VideoSource) : Bool {
			if(c == null || n == null)
				return false;
			if(me.netStream == null || me.netConnection == null)
				return false;
			switch(c.type) {
			case VST_URI:
				switch(n.type) {
				case VST_URI: return true;
				default: return false;
				}
			case VST_VIDEO:
				switch(n.type) {
				case VST_VIDEO: return true;
				default: return false;
				}
			case VST_RTMP:
				switch(n.type) {
				case VST_RTMP:
					var c1 : VideoUriSource = cast c;
					var n1 : VideoUriSource = cast n;
					if(c1.protocol==n1.protocol && c1.host == n1.host && c1.appName == n1.appName)
						return true;
					return false;
				default: return false;
				}
			}
		}

		var cur = (m_playlistIdx >= 0) ? m_playlist[m_playlistIdx] : null;

		m_playlistIdx++;
		if(m_playlistIdx >= m_playlist.length)
			m_playlistIdx = 0;

		var next = m_playlist[m_playlistIdx];

		if(next == null)
			return false;

		#if debug
		trace(here.methodName + " next idx: " + m_playlistIdx + " " + cur + " "+next);
		#end
		if(cur != null && isSameServer(cur,next)) {
			switch(next.type) {
			case VST_VIDEO:
				var vos : VideoObjectSource = cast next;
				unsubcribeEvents(netStream);
				unsubcribeEvents(netConnection);
				netStream = vos.netStream;
				netConnection = vos.netConnection;
				subscribeEvents(netStream);
				subscribeEvents(netConnection);
				m_video = vos.video;
			case VST_RTMP:
			case VST_URI:
			}

			switch(status) {
			case DISCONNECTED:
			case NET_CONNECT:
			case STREAM_CONNECT:
			case PLAYING,PAUSED,STOPPED:
				startPlay();
			}
		}
		else {
			// have to switch servers/netStream/netConnection
			unsubcribeEvents(netStream);
			unsubcribeEvents(netConnection);
			if(cur != null) {
			switch(cur.type) {
				case VST_VIDEO:
					var vos : VideoObjectSource = cast cur;
					vos.netStream.seek(0.);
					vos.netStream.pause();
				default:
					teardown();
				}
			}

			switch(next.type) {
			case VST_VIDEO:
				var vos : VideoObjectSource = cast next;
				netStream = vos.netStream;
				netConnection = vos.netConnection;
				subscribeEvents(netStream);
				subscribeEvents(netConnection);
				m_video = vos.video;
				startPlay();
			case VST_URI,VST_RTMP:
				status = NET_CONNECT;
				netConnection = new NetConnection();
				netConnection.client = clientNetConnection;
				subscribeEvents(netConnection);
				#if debug
				trace("Connecting to " + next.getNetConnectTarget());
				#end
				netConnection.connect(next.getNetConnectTarget());
			}
		}
		m_totalVolume = soundVolume * next.soundVolume;
		return true;
	}

	/**
	* @private
	*/
	public override function renderPolygon ( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ) : Void
	{
		m_doRedraw = true;
		super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
	}

	/**
	* @private
	*/
	public override function setTransparency( p_nValue:Float ):Void
	{
		m_alphaTransform.alphaMultiplier = NumberUtil.constrain( p_nValue, 0, 1 );
	}

	private function __setSoundMaxPan(v:Float):Float {
		var v2 = Math.abs(v);
		this.soundMaxPan = (v2 > 1.0) ? 1.0 : v2;
		return v;
	}

	private function __setSoundVolume(v:Float):Float {
		this.soundVolume = Math.abs(v);
		if(m_playlistIdx >= 0 && m_playlist[m_playlistIdx] != null)
			m_totalVolume = soundVolume * m_playlist[m_playlistIdx].soundVolume;
		else
			m_totalVolume = soundVolume;
		return v;
	}

	private function startPlay() {
		var src = m_playlist[m_playlistIdx];
		m_timer.stop();
		status = STOPPED;
		if(src == null)
			return;

		status = PLAYING;
		if(src.type == VST_VIDEO) {
			var vos : VideoObjectSource = cast src;
			vos.netStream.seek(vos.startTime);
			vos.netStream.resume();
		}
		else {
			var ooe = flash.net.NetConnection.defaultObjectEncoding;
			if(src.useAmf3)
				NetConnection.defaultObjectEncoding = ObjectEncoding.AMF3;
			else
				NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;
			//--
			try {
				netStream.play(src.getNetStreamPlayTarget(),src.startTime,src.playLength,true);
				m_timer.start();
			} catch(e:Dynamic) {
				m_timer.stop();
				errorPlayNext(2.0);
			}
			//--
			NetConnection.defaultObjectEncoding = ooe;
		}
	}

	private function subscribeEvents(o:Dynamic) {
		if(Std.is(o, NetConnection)) {
			o.addEventListener(NetStatusEvent.NET_STATUS, __onNetStatus,false,0,true);
			o.addEventListener(SecurityErrorEvent.SECURITY_ERROR,__onSecurityError,false,0,true);
		}
		else if(Std.is(o, NetStream)) {
			o.addEventListener(IOErrorEvent.IO_ERROR,__onIoError,false,0,true);
			o.addEventListener(NetStatusEvent.NET_STATUS, __onNetStatus,false,0,true);
			o.addEventListener(AsyncErrorEvent.ASYNC_ERROR, __onAyncError,false,0,true);
		}
		else if(Std.is(o, Timer)) {
			o.addEventListener(TimerEvent.TIMER, update,false,0,true);
		}
	}

	/**
	* Stops the timer, removes event listeners from the Net objects,
	* and sets the netStream and netConnection members to null
	*
	* @param nc Tear down netConnection
	* @param ns Tear down netStream
	*/
	private function teardown(nc:Bool=true,ns:Bool=true) : Void
	{
		if(m_timer != null)
			m_timer.stop();
		if(ns && netStream != null) {
			unsubcribeEvents(netStream);
			try netStream.close() catch(e:Dynamic) {};
			try netStream.client = null catch (e:Dynamic) {};
			netStream = null;
		}
		if(netConnection != null) {
			unsubcribeEvents(netConnection);
			try netConnection.close() catch(e:Dynamic) {};
			try netConnection.client = null catch (e:Dynamic) {};
			netConnection = null;
		}
	}

	private function unsubcribeEvents(o:Dynamic) {
		if(o == null)
			return;
		if(Std.is(o, NetConnection)) {
			o.removeEventListener(NetStatusEvent.NET_STATUS, __onNetStatus);
			o.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,__onSecurityError);
		}
		else if(Std.is(o, NetStream)) {
			o.removeEventListener(IOErrorEvent.IO_ERROR,__onIoError);
			o.removeEventListener(NetStatusEvent.NET_STATUS, __onNetStatus);
			o.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, __onAyncError);
		}
		else if(Std.is(o,Timer)) {
			o.stop();
			o.removeEventListener(TimerEvent.TIMER, update);
		}
	}

	/**
	* Updates this material each internal timer cycle.
	*/
	private function update( p_eEvent:TimerEvent ):Void
	{
		updateSoundTransform();
		if ( m_doRedraw || forceUpdate )
		{
			var src = m_playlist[m_playlistIdx];
			if(src == null)
				return;
			m_oTexture.fillRect( m_oTexture.rect,
				ColorMath.applyAlpha( DEFAULT_FILL_COLOR, m_alphaTransform.alphaMultiplier) );

			if(src.type == VST_RTMP)
				m_video.attachNetStream(null);
			// --
			m_oTexture.draw( m_video, null, m_alphaTransform, null, null, smooth );
			// --
			if(src.type == VST_RTMP)
				m_video.attachNetStream(netStream);
		}
		m_doRedraw = false;
	}

	private function updateSoundTransform() :Void
	{
		if(netStream == null || m_shape3D == null || status != PLAYING)
			return;

		if( m_shape3D.scene == null) {
			m_soundTransform.volume = 0;
			netStream.soundTransform = m_soundTransform;
			return;
		}

		var gv:Matrix4 = m_shape3D.modelMatrix;
		var rv:Matrix4 = m_shape3D.scene.camera.modelMatrix;
		var dx:Float = gv.n14 - rv.n14;
		var dy:Float = gv.n24 - rv.n24;
		var dz:Float = gv.n34 - rv.n34;
		var dist:Float = Math.sqrt(dx*dx + dy*dy + dz*dz);

		if(dist <= 0.001)
		{
			m_soundTransform.volume = m_totalVolume;
			m_soundTransform.pan = 0;
			m_soundCulled = false;
		}
		else if(dist <= soundRadius)
		{
			var pa:Float = 0;
			if(soundMaxPan != 0.)
			{
				var d:Float = dx*rv.n11 + dy*rv.n21 + dz*rv.n31;
				var ang:Float = Math.acos(d/dist) - Math.PI/2;
				pa = - (ang/100 * (100/(Math.PI/2))) * soundMaxPan;
				if(pa < -1) pa = -1;
				else if(pa > 1) pa = 1;
			}
			m_soundTransform.volume = (m_totalVolume/soundRadius) * (soundRadius-dist);
			m_soundTransform.pan = pa;
			m_soundCulled = false;
		}
		else
		{
			if(!m_soundCulled)
			{
				m_soundTransform.volume = 0;
				m_soundTransform.pan = 0;
				m_soundCulled = true;
			}
		}

		netStream.soundTransform = m_soundTransform;
	}

	/////////////////////  NetStream client /////////////////////////////////
	/**
	* The default handler for NetStream.client CuePoint callbacks
	*/
	private function __onCuePoint(o : Dynamic) : Void
	{
		m_oEB.dispatchEvent( new BubbleEvent( CUEPOINT, this, o) );
	}

	/**
	* The default handler for NetStream.client MetaData callbacks
	*/
	private function __onMetaData(o : Dynamic) : Void
	{
		m_oEB.dispatchEvent( new BubbleEvent( METADATA, this, o) );
	}

	private function __onPlayStatus(o : Dynamic) : Void
	{
		#if debug
		trace(here.methodName + " " + Std.string(o));
		#end
	}

	/////////////////////  NetConnection client /////////////////////////////
	private function __onBWCheck() : Void
	{
	}

	private function __onBWDone() : Void
	{
	}

	private function __onFCSubscribe(o : Dynamic) : Void
	{
		#if debug
		trace(o);
		#end
	}
}


