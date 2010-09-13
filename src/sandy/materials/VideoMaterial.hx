
package sandy.materials;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.media.Video;
import flash.utils.Timer;
import flash.geom.ColorTransform;

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.materials.attributes.MaterialAttributes;
import sandy.math.ColorMath;
import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* Displays a Flash video ( FLV ) on the faces of a 3D shape.
*
* <p>Based on the AS2 class VideoSkin made by kiroukou and zeusprod</p>
*
* @author		Xavier Martin - zeflasher
* @author		Thomas PFEIFFER - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		26.06.2007
*/
class VideoMaterial extends BitmapMaterial
{
	/**
	* Default color used to draw the bitmapdata content.
	* In case you need a specific color, change this value at your application initialization.
	*/
#if flash
	public static inline var DEFAULT_FILL_COLOR:UInt = 0;
#else
	public static inline var DEFAULT_FILL_COLOR:Int = 0;
#end

	private var m_oTimer:Timer;
	private var m_oVideo:Video;
	private var m_bUpdate:Bool;
	private var m_oAlpha:ColorTransform;

	/**
	* Creates a new VideoMaterial.
	*
	* <p>The video is converted to a bitmap to give it a perspective distortion.<br/>
	* To see the animation, the bitmap has to be recreated from the video on a regular basis.</p>
	*
	* @param p_oVideo		The video to be shown by this material.
	* @param p_nUpdateMS	The update interval.
	* @param p_oAttr		The material attributes.
	*
	* @see sandy.materials.attributes.MaterialAttributes
	*/
	public function new( p_oVideo:Video, p_nUpdateMS:Int = 40, ?p_oAttr:MaterialAttributes )
	{
		super( new BitmapData( Std.int( p_oVideo.width ), Std.int( p_oVideo.height ), true, DEFAULT_FILL_COLOR ), p_oAttr );
		m_oAlpha = new ColorTransform ();
		m_oVideo = p_oVideo;
		m_oType = MaterialType.VIDEO;
		// --
		m_oTimer = new Timer( p_nUpdateMS );
		m_oTimer.addEventListener(TimerEvent.TIMER, update );
		start();
	}

	override public function dispose():Void
	{
		super.dispose();
		stop();
		m_oAlpha = null;
		m_oTimer = null;
		m_oVideo = null;
	}

	/**
	* @private
	*/
	public override function renderPolygon ( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ) : Void
	{
		m_bUpdate = true;
		super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
	}

	/**
	* @private
	*/
	public override function setTransparency( p_nValue:Float ):Void
	{
		m_oAlpha.alphaMultiplier = NumberUtil.constrain( p_nValue, 0, 1 );
	}


	/**
	* Updates this material each internal timer cycle.
	*/
	private function update( p_eEvent:TimerEvent ):Void
	{
		if ( m_bUpdate || forceUpdate )
		{
			m_oTexture.fillRect( m_oTexture.rect,
				ColorMath.applyAlpha( DEFAULT_FILL_COLOR, m_oAlpha.alphaMultiplier) );
			// --
			m_oTexture.draw( m_oVideo, null, m_oAlpha, null, null, smooth );
		}
		m_bUpdate = false;
	}

	/**
	* Call this method when you want to start the material update.
	* This is automatically called at the material creation so basically it is used only when the VideoMaterial::stop() method has been called
	*/
	public function start():Void
	{
		m_oTimer.start();
	}

	/**
	* Call this method is case you would like to stop the automatic video material graphics update.
	*/
	public function stop():Void
	{
		if(m_oTimer != null)m_oTimer.stop();
	}
}
