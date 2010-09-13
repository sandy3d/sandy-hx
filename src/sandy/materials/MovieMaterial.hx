
package sandy.materials;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
#if flash
import flash.events.TimerEvent;
#end
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
#if flash
import flash.utils.Timer;
#elseif (neko || cpp)
import nme.Timer;
#else
import haxe.Timer;
#end

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.materials.attributes.MaterialAttributes;
import sandy.math.ColorMath;
import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* Displays a MovieClip on the faces of a 3D shape.
*
* <p>Based on the AS2 class VideoSkin made by kiroukou and zeusprod</p>
*
* @author		Xavier Martin - zeflasher
* @author		Thomas PFEIFFER - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* 				this should be add directly in the bitmap material I reckon
* @date 		11.11.2007
*/
class MovieMaterial extends BitmapMaterial
{
	/**
	 * Default color used to draw the bitmapdata content.
	 * In case you need a specific color, change this value at your application initialization.
	 */
	public static inline var DEFAULT_FILL_COLOR:Int = 0;

	private var m_oTimer:Timer;
	private var m_oMovie:Sprite;
	private var m_bUpdate:Bool;
	private var m_oAlpha:ColorTransform;

	/**
	 * Creates a new MovieMaterial.
	 *
	 * <p>The MovieClip used for the material may contain animation.<br/>
	 * It is converted to a bitmap to give it a perspective distortion.<br/>
	 * To see the animation the bitmap has to be recreated from the MovieClip on a regular basis.</p>
	 *
	 * @param p_oMovie		The Movieclip to be shown by this material.
	 * @param p_nUpdateMS	The update interval.
	 * @param p_oAttr		The material attributes.
	 * @param p_bRemoveTransparentBorder	Remove the transparent border.
	 * @param p_nWidth		Desired width ( chunk the movieclip )
	 * @param p_nHeight		Desired height ( chunk the movieclip )
	 *
	 * @see sandy.materials.attributes.MaterialAttributes
	 */
	public function new( p_oMovie:Sprite, ?p_nUpdateMS:Int = 40, ?p_oAttr:MaterialAttributes, ?p_bRemoveTransparentBorder:Bool = false, ?p_nHeight:Float = 0.0, ?p_nWidth:Float = 0.0 )
	{
		super();
	
		var w : Float;
		var h : Float;

		m_oAlpha = new ColorTransform ();

		var tmpBmp : BitmapData = null;
		var rect : Rectangle;
		if ( p_bRemoveTransparentBorder )
		{
			tmpBmp = new BitmapData(  Std.int(p_oMovie.width), Std.int(p_oMovie.height), true, 0 );
			tmpBmp.draw( p_oMovie );
			#if neko
			rect = tmpBmp.getColorBoundsRect(
				Int32.shl(Int32.ofInt(0xFF), 24),
				Int32.ofInt(0), false );
			#else
			rect = tmpBmp.getColorBoundsRect( 0xFF000000, 0x00000000, false );
			#end
			w = rect.width;
			h = rect.height;
		}
		else
		{
			w = p_nWidth != 0 ? p_nWidth :  p_oMovie.width;
			h = p_nHeight != 0 ? p_nHeight : p_oMovie.height;
		}

		super( new BitmapData( Std.int(w), Std.int(h), true, DEFAULT_FILL_COLOR), p_oAttr );
		m_oMovie = p_oMovie;
		m_oType = MaterialType.MOVIE;
		// --
		m_bUpdate = true;
		#if flash
			m_oTimer = new Timer( p_nUpdateMS );
			m_oTimer.addEventListener(TimerEvent.TIMER, _update );
			m_oTimer.start();
		#else
			m_oTimer = new Timer( p_nUpdateMS );
			m_oTimer.run = callback(_update,null);
		#end

		if( tmpBmp != null )
		{
			tmpBmp.dispose();
			tmpBmp = null;
		}
		rect = null;
		//w = null;
		//h = null;
	}

	override public function dispose():Void
	{
		super.dispose();
		stop();
		m_oTimer = null;
		m_oMovie = null;
	}

	/**
	 * Renders this material on the face it dresses.
	 *
	 * @param p_oScene		The current scene
	 * @param p_oPolygon	The face to be rendered
	 * @param p_mcContainer	The container to draw on
	 */
	public override function renderPolygon ( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ) : Void
	{
		m_bUpdate = true;
		super.renderPolygon( p_oScene, p_oPolygon, p_mcContainer );
	}

	/**
	 * Changes the transparency of the texture.
	 *
	 * <p>The passed value is the percentage of opacity.</p>
	 *
	 * @param p_nValue 	A value between 0 and 1. (automatically constrained)
	 */
	public override function setTransparency( p_nValue:Float ):Void
	{
		m_oAlpha.alphaMultiplier = NumberUtil.constrain( p_nValue, 0, 1 );
	}


	/**
	 * Updates this material each internal timer cycle.
	 */
	private function _update( p_eEvent:Event ):Void
	{
		if ( m_bUpdate || forceUpdate )
		{
			m_oTexture.fillRect( m_oTexture.rect,
				ColorMath.applyAlpha( DEFAULT_FILL_COLOR, m_oAlpha.alphaMultiplier) );
			// --
			m_oTexture.draw( m_oMovie, null, m_oAlpha, null, null, smooth );
		}
		m_bUpdate = false;
	}

	/**
	 * Call this method when you want to start the material update.
	 * This is automatically called at the material creation so basically it is used only when the MovieMaterial::stop() method has been called
	 */
	public function start():Void
	{
#if flash9
		m_oTimer.start();
#else
		m_oTimer.run = callback(_update,null);
#end
	}

	/**
	 * Call this method is case you would like to stop the automatic MovieMaterial texture update.
	 */
	public function stop():Void
	{
		if(m_oTimer != null)m_oTimer.stop();
	}

	/**
	 * Get the sprite used for the material.
	 */
	public var movie(__getMovie,null) : Sprite;
	private function __getMovie() : Sprite
	{
		return m_oMovie;
	}
}

