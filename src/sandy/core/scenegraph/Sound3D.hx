
package sandy.core.scenegraph;

import flash.display.Stage;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;

import sandy.core.Scene3D;
import sandy.events.BubbleEvent;
import sandy.core.data.Matrix4;
import sandy.view.Frustum;

/**
* Transform audio volume and pan relative to the Camera3D
*
* @author		Daniel Reitterer - Delta 9
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		14.12.2007
*/

enum SoundMode {
	SOUND;
	CHANNEL;
	URL;
}

enum SoundType {
	SPEECH;
	NOISE;
}

class Sound3D extends ATransformable
{
	// events
	/** Dispatched when sound starts a new loop **/
	public static inline var LOOP:String = "loop";
	/** Dispatched when sound is complete. **/
	public static inline var COMPLETE:String = "complete";
	/** Dispatched when sound starts playing, either from an initial start, or resume when in range **/
	public static inline var CULL_PLAY:String = "cullPlay";
	/** Dispatched when sound gets culled (out of range) **/
	public static inline var CULL_STOP:String = "cullStop";

	/**
	* Max volume of the sound if camera position is at sound position
	*/
	public var soundVolume:Float;
	/**
	* The radius of the sound
	*/
	public var soundRadius:Float;
	/**
	* If pan is true the panning of the sound is relative to the camera rotation
	*/
	public var soundPan:Bool;
	/**
	* Maximal pan is a positive Number from 0-1 or higher
	*/
	public var maxPan:Float;
	/**
	* If the sound contains two channels, stereo have to be set to true in order to mix left and right channels correctly
	*/
	public var stereo:Bool;
	/**
	* If flipPan is true the left and right channels of the sound are mirrored if the camera is facing away from the sound
	*/
	public var flipPan:Bool;
	/**
	* Type is either SPEECH or NOISE, SPEECH will start the sound at the last position if the camera enters the sphere of the sound
	*/
	public var type:SoundType;
	/**
	* The start time to play the audio from
	*/
	public var startTime:Float;
	/**
	* Number of loops before the sound stops
	*/
	public var loops:Int;
	/**
	* Start time to play the audio from if the sound loops
	*/
	public var loopStartTime:Float;
	/**
	* Returns true if the stereo panorama is mirrored, flipPan have to be true to enable stereo flipping
	*/
	public var isFlipped (__getIsFlipped,null):Bool;
	private function __getIsFlipped ():Bool{return _isFlipped;}

	private var _isFlipped:Bool;
	private var _isPlaying:Bool;
	private var soundCulled:Bool;
	private var m_oSoundTransform:SoundTransform;
	private var sMode:SoundMode;
	private var urlReq:URLRequest;
	private var channelRef:SoundChannel;
	private var soundRef:Sound;
	private var lastPosition:Float;
	private var lastStopTime:Float;
	private var cPlaying:Bool;
	private var duration:Float;
	private var cLoop:Int;

	/**
	* Creates a 3D sound object wich can be placed in the 3d scene. Set stereo to true if the sound source is in stereo.
	* If stereo is true, both channels are at the same position in 3d space, but the stereo panorama is kept and mirrored if required.
	* To create a true stereo effect, take two Sound3D instances and two mono sound sources on different locations in 3d space.
	*
	* @param 	p_sName				A string identifier for this object
	* @param	p_oSoundSource		The sound source, a String, UrlRequest, Sound or a SoundChannel object
	* @param	p_nVolume			Volume of the sound
	* @param	p_nMaxPan			Max pan of the sound, if zero panning is disabled
	* @param	p_nRadius			Radius of the sound in 3d units
	* @param	p_bStereo			If the sound contains two different channels
	*/
	public function new( p_sName:String = "", ?p_oSoundSource:Dynamic, p_nVolume:Float = 1.,
							p_nMaxPan:Float = 0., p_nRadius:Float = 1., p_bStereo:Bool = false )
	{
		soundPan=true;
		maxPan = 1;
		stereo = false;
		flipPan=true;
		type = SPEECH;
		startTime = 0;
		loops = 0xffffff;
		loopStartTime=0;

		_isFlipped=false;
		_isPlaying=false;
		soundCulled=false;
		m_oSoundTransform = new SoundTransform(1,0);
		sMode = null; // sound, channel or url
		lastPosition=0;
		lastStopTime=0;
		cPlaying=false;
		duration=0;
		cLoop=0;

		super( p_sName );

		soundVolume = p_nVolume;
		soundRadius = p_nRadius;
		soundSource = p_oSoundSource;
		stereo = p_bStereo;

		if(p_nMaxPan == 0)
		{
			soundPan = false;
		}
		else
		{
			soundPan = true;
			maxPan = p_nMaxPan;
		}
	}

	/**
	* Start Sound sources of type Sound or UrlRequest.
	* Sound sources of type SoundChannel don't support the play method
	* @param	p_nStartTime
	* @param	p_iLoops
	*/
	public function play (?p_nStartTime:Float=-1, ?p_iLoops:Int=-1, ?p_nLoopStartTime:Float=-1, ?p_bResume:Bool) :Void
	{
		if(!_isPlaying && sMode != CHANNEL)
		{

			if(p_nStartTime != -1) lastPosition = p_nStartTime;
			if(p_iLoops != -1) loops = p_iLoops;
			if(p_nLoopStartTime != -1) loopStartTime = p_nLoopStartTime;

			if(!p_bResume)
			{
				lastPosition = startTime;
				lastStopTime = flash.Lib.getTimer();
			}
			cLoop = 0;
			_isPlaying = true;
			cPlaying = false;
		}
	}

	/**
	* Stop the sound source and SoundChannel
	*/
	public function stop () :Void
	{
		if(_isPlaying && sMode != CHANNEL)
		{
			if(cPlaying) cStop();
			_isPlaying = false;
			cPlaying = false;
		}
	}

	public var currentLoop (__getCurrentLoop,null) :Int;
	private function __getCurrentLoop () :Int
	{
		return cLoop;
	}

	/**
	* Set the sound source, the sound source can be a String, URLRequest, Sound or SoundChannel object
	*/
	private function __setSoundSource (s:Dynamic) :Dynamic
	{
		if(Std.is(s, Sound))
		{
			sMode = SOUND;
			soundRef = cast s;
			if(soundRef.length > 0) duration = soundRef.length;
		}
		else if(Std.is(s, SoundChannel))
		{
			sMode = CHANNEL;
			_isPlaying = true;
			channelRef = cast s;
		}
		else if(Std.is(s, String))
		{
			sMode = URL;
			urlReq = new URLRequest(cast s);
		}
		else
		{
			sMode = URL;
			urlReq = cast s;
		}
		return s;
	}

	/**
	* Set or return the sound source, the sound source may be a URLRequest, Sound or SoundChannel object
	*/
	public var soundSource (__getSoundSource,__setSoundSource) :Dynamic;
	private function __getSoundSource () :Dynamic
	{
		switch (sMode)
		{
			case SOUND:
				return cast soundRef;
			case CHANNEL:
				return cast channelRef;
			case URL:
				return cast urlReq;
			default:
				return null;
		}
	}

	public var soundMode (__getSoundMode,null) :SoundMode;
	public function __getSoundMode () :SoundMode
	{
		return sMode;
	}

	private function updateSoundTransform () :Void
	{
		var gv:Matrix4 = modelMatrix;
		var rv:Matrix4 = scene.camera.modelMatrix;
		var dx:Float = gv.n14 - rv.n14;
		var dy:Float = gv.n24 - rv.n24;
		var dz:Float = gv.n34 - rv.n34;
		var dist:Float = Math.sqrt(dx*dx + dy*dy + dz*dz);

		if(dist <= 0.001)
		{
			m_oSoundTransform.volume = soundVolume;
			m_oSoundTransform.pan = 0;
			soundCulled = false;
		}
		else if(dist <= soundRadius)
		{
			var pa:Float = 0;
			if(soundPan)
			{
				var d:Float = dx*rv.n11 + dy*rv.n21 + dz*rv.n31;
				var ang:Float = Math.acos(d/dist) - Math.PI/2;
				pa = - (ang/100 * (100/(Math.PI/2))) * maxPan;
				if(pa < -1) pa = -1;
				else if(pa > 1) pa = 1;
			}
			m_oSoundTransform.volume = (soundVolume/soundRadius) * (soundRadius-dist);
			m_oSoundTransform.pan = pa;
			soundCulled = false;
		}
		else
		{
			if(!soundCulled)
			{
				m_oSoundTransform.volume = 0;
				m_oSoundTransform.pan = 0;
				soundCulled = true;
			}
		}
	}

	// updates the sound channel and also set stereo panning in sound transform
	private function updateChannelRef () :Void
	{
		if(stereo)
		{
			var span:Float = m_oSoundTransform.pan;
			var pa:Float;

			if(span<0)
			{
				pa = (span < -1) ? 1:-span;
				m_oSoundTransform.leftToLeft = 1;
				m_oSoundTransform.leftToRight = 0;
				m_oSoundTransform.rightToLeft = pa;
				m_oSoundTransform.rightToRight = 1-pa;
			}
			else
			{
				pa = (span > 1 ? 1:span);
				m_oSoundTransform.leftToLeft = 1-pa;
				m_oSoundTransform.leftToRight = pa;
				m_oSoundTransform.rightToLeft = 0;
				m_oSoundTransform.rightToRight = 1;
			}

			if(flipPan)
			{

				var x2:Float = modelMatrix.n11;
				var y2:Float = modelMatrix.n21;
				var z2:Float = modelMatrix.n31;

				var gv:Matrix4 = scene.camera.modelMatrix;
				var mz:Float = -(x2*gv.n11 + y2*gv.n21 + z2*gv.n31);

				if(mz > 0)
				{

					var l2l:Float = m_oSoundTransform.leftToLeft;
					var l2r:Float = m_oSoundTransform.leftToRight;
					var r2l:Float = m_oSoundTransform.rightToLeft;
					var r2r:Float = m_oSoundTransform.rightToRight;

					m_oSoundTransform.leftToLeft = l2l+(l2r-l2l)*mz;
					m_oSoundTransform.leftToRight = l2r+(l2l-l2r)*mz;
					m_oSoundTransform.rightToLeft = r2l+(r2r-r2l)*mz;
					m_oSoundTransform.rightToRight = r2r+(r2l-r2r)*mz;
					_isFlipped = true;
				}
				else
				{
					_isFlipped = false;
				}
			}
		}

		channelRef.soundTransform = m_oSoundTransform;
	}

	private function soundCompleteHandler (e:Event) :Void
	{
		if(cLoop < loops)
		{
			cLoop++;
			cPlaying = false;
			lastPosition = loopStartTime;
			lastStopTime = flash.Lib.getTimer();
			cPlay();
			m_oEB.dispatchEvent( new BubbleEvent( LOOP, this ) );
		}
		else
		{
			if(sMode != CHANNEL)
			{
				_isPlaying = false;
				cStop();
			}
			m_oEB.dispatchEvent( new BubbleEvent( COMPLETE, this ) );
		}

	}

	private function completeHandler (e:Event) :Void
	{
		duration = soundRef.length;
	}

	/**
	* Play the sound if the camera enters the culling sphere with the sound radius.
	* This method should not be called if mode is "channel"
	*
	* @param	isUrl true if thr urlReq should be loaded
	*/
	private function cPlay (?isUrl:Bool=false) :Void
	{
		if(!cPlaying)
		{
			cPlaying = true;

			if(channelRef != null) channelRef.stop();

			if(isUrl)
			{
				soundRef = new Sound();
				soundRef.addEventListener(Event.COMPLETE, completeHandler);
				soundRef.load(urlReq);
			}

			switch(type) {
			case SPEECH:
				var len:Float = duration;
				var time:Float = startTime;

				if(len > 0)
				{
					time = lastPosition + (flash.Lib.getTimer()-lastStopTime);
					if(time > len)
					{
						var fn:Float = time/len;
						var f:Int = Std.int(fn);
						cLoop += f;
						if(cLoop>loops)
						{
							stop();
							m_oEB.dispatchEvent( new BubbleEvent( COMPLETE, this ) );
							return;
						}
						time = fn-f == 0 ? len : time - (len*f);
					}
				}
				channelRef = soundRef.play(time, 0);
			case NOISE:
				channelRef = soundRef.play(startTime, 0);
			}
			if(!channelRef.hasEventListener(Event.SOUND_COMPLETE))
				channelRef.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
		}
	}

	private function cStop (?isUrl:Bool=false) :Void
	{
		if(cPlaying)
		{
			cPlaying = false;
			if(channelRef != null)
			{
				lastPosition = channelRef.position;
				lastStopTime = flash.Lib.getTimer();
				channelRef.stop();
				channelRef.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			}
		}
	}

	public override function cull ( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool) :Void
	{
		if(_isPlaying)
		{
			updateSoundTransform();

			var isUrl:Bool = sMode == URL;

			if(isUrl || sMode == SOUND)
			{
				if(!soundCulled)
				{
					if(!cPlaying)
					{
						cPlay(isUrl);
						m_oEB.dispatchEvent( new BubbleEvent( CULL_PLAY, this ) );
					}
				}
				else
				{
					if(cPlaying)
					{
						cStop(isUrl);
						m_oEB.dispatchEvent( new BubbleEvent( CULL_STOP, this ) );
					}
				}
			}

			updateChannelRef();
		}
	}

	public var soundChannel (__getSoundChannel,null) :SoundChannel;
	public function __getSoundChannel () :SoundChannel
	{
		return channelRef;
	}

	public override function toString () :String
	{
		return "sandy.core.scenegraph.Sound3D";
	}

}

