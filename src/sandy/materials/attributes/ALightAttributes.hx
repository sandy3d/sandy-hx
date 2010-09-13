
package sandy.materials.attributes;

import sandy.core.Scene3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Polygon;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.Sprite2D;
import sandy.materials.Material;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.geom.ColorTransform;

import sandy.HaxeTypes;

/**
* ABSTRACT CLASS - super class for all light attributes.
*
* <p>This class should not be directly instatiated, but sub classed.<br/>
* The ALightAttributes class implements Blinn flavor of Phong reflection model.</p>
*
* @author		makc
* @author		Niel Drummond - haXe port
* @author 		Russell Weir - haXe port
* @version		3.1
* @date 		13.12.2007
**/
class ALightAttributes implements IAttributes
{
	public function new () {
		//private initializers
		m_nFlags = 0;
		_ambient = 0.3;
		_diffuse = 1.0;
		_specular = 0.0;
		_gloss = 5.0;
// 		_scenes = new Hash();
		m_oH = new Point3D();
		m_oCurrentL = new Point3D ();
		m_oCurrentV = new Point3D ();
		m_oCurrentH = new Point3D ();
	}

	/**
	* Ambient reflection factor.
	*
	* <p>Note that since geometry of sprites is unknown, this is going to
	* be the only lighting setting affecting them, so you would typically
	* need to set it to bigger value than you would for shapes.</p>
	* @default 0.3
	*/
	public var ambient (__getAmbient,__setAmbient):Float;
	private function __getAmbient ():Float
	{
		return _ambient;
	}

	/**
	* @private
	*/
	private function __setAmbient (p_nAmbient:Float):Float
	{
		_ambient = p_nAmbient; onPropertyChange (); return p_nAmbient;
	}

	/**
	* Diffuse reflection factor.
	* @default 1.0
	*/
	public var diffuse (__getDiffuse,__setDiffuse):Float;
	private function __getDiffuse ():Float
	{
		return _diffuse;
	}

	/**
	* @private
	*/
	private function __setDiffuse (p_nDiffuse:Float):Float
	{
		_diffuse = p_nDiffuse; onPropertyChange (); return p_nDiffuse;
	}

	/**
	* Specular reflection factor.
	* @default 0.0
	*/
	public var specular (__getSpecular,__setSpecular):Float;
	private function __getSpecular ():Float
	{
		return _specular;
	}

	/**
	* @private
	*/
	private function __setSpecular (p_nSpecular:Float):Float
	{
		_specular = p_nSpecular; onPropertyChange (); return p_nSpecular;
	}

	/**
	* Specular exponent.
	* @default 5.0
	*/
	public var gloss (__getGloss,__setGloss):Float;
	private function __getGloss ():Float
	{
		return _gloss;
	}

	/**
	* @private
	*/
	private function __setGloss (p_nGloss:Float):Float
	{
		_gloss = p_nGloss; onPropertyChange (); return p_nGloss;
	}

	/**
	* Override this to respond to property changes.
	*/
	private function onPropertyChange ():Void
	{
	}

	/**
	* Latest light power.
	*/
	private var m_nI:Float;

	/**
	* Latest light direction vector.
	*/
	private var m_oL:Point3D;

	/**
	* Latest camera direction vector.
	*/
	private var m_oV:Point3D;

	/**
	* Latest Blinn halfway vector between camera and light.
	*/
	private var m_oH:Point3D;

	/**
	* Calculates the reflection for given normal.
	*/
	private function calculate (p_oNormal:Point3D, p_bFrontside:Bool, p_bIgnoreSpecular:Bool = false ):Float
	{
		var l_n:Int = p_bFrontside ? -1 : 1;
		var l_k:Float = l_n * m_oCurrentL.dot (p_oNormal); if (l_k < 0) l_k = 0; l_k = _ambient + _diffuse * l_k;
		if (!p_bIgnoreSpecular && (specular > 0))
		{
			var l_s:Float = l_n * m_oCurrentH.dot (p_oNormal); if (l_s < 0) l_s = 0;
			l_k += _specular * Math.pow (l_s, _gloss);
		}
		return l_k * m_nI;
	}

	/**
	* @private
	*/
	private var m_oCurrentL:Point3D;
	/**
	* @private
	*/
	private var m_oCurrentV:Point3D;
	/**
	* @private
	*/
	private var m_oCurrentH:Point3D;
	/**
	* @private
	*/
	private var m_oCurrentShape:Shape3D;

	/**
		* Draws light on shape.
	*/
	public function draw(p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D):Void
	{
		if (p_oMaterial.lightingEnable)
		{
			applyColorToDisplayObject (
				p_oPolygon.shape.useSingleContainer ? p_oPolygon.shape.container : p_oPolygon.container,
				p_oScene.light.color, 1
			);

			// compute local versions of vectors
			if (m_oCurrentShape != p_oPolygon.shape)
			{
				m_oCurrentShape = p_oPolygon.shape;

				var invModelMatrix:Matrix4 = m_oCurrentShape.invModelMatrix;

				if(m_oL != null) {
					m_oCurrentL.copy (m_oL);
					invModelMatrix.transform3x3 (m_oCurrentL);
					m_oCurrentL.normalize ();
				}

				if(m_oV != null) {
					m_oCurrentV.copy (m_oV);
					invModelMatrix.transform3x3 (m_oCurrentV);
					m_oCurrentV.normalize ();
				}

				if(m_oH != null) {
					m_oCurrentH.copy (m_oH);
					invModelMatrix.transform3x3 (m_oCurrentH);
					m_oCurrentH.normalize ();
				}
			}
		}
	}

	/**
	* Draws light on sprite.
	*/
	public function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		if (p_oMaterial.lightingEnable)
		{
			applyColorToDisplayObject (p_oSprite.container, p_oScene.light.color,
				ambient * p_oScene.light.getNormalizedPower ()
			);
		}
	}

	private function applyColorToDisplayObject (s:DisplayObject, c:Int, b:Float):Void
	{
		// to avoid color darkening, we will normalize color; pitch-black is "normalized" to white
		if ((c < 1) || (c > 0xFFFFFF))
		{
			c = 0xFFFFFF;
		}
		var rgb_r_t:Int = (0xFF0000 & c) >> 16;
		var rgb_g_t:Int = (0x00FF00 & c) >> 8;
		var rgb_b_t:Int = (0x0000FF & c);

		var bY:Float = b * 1.7321 /*Math.sqrt (3)*/ / Math.sqrt (rgb_r_t * rgb_r_t + rgb_g_t * rgb_g_t + rgb_b_t * rgb_b_t);
		var rgb_r:Float = rgb_r_t * bY; var rgb_g:Float = rgb_r_t * bY; var rgb_b:Float = rgb_r_t * bY;
		var ct:ColorTransform = s.transform.colorTransform;
		if ((ct.redMultiplier != rgb_r) || (ct.greenMultiplier != rgb_g) || (ct.blueMultiplier != rgb_b))
		{
			ct.redMultiplier = rgb_r; ct.greenMultiplier = rgb_g; ct.blueMultiplier = rgb_b;
			s.transform.colorTransform = ct;
		}
	}

	/**
	* Method called before the display list rendering.
	* This is the common place for this attribute to precompute things
	*/
	public function begin( p_oScene:Scene3D ):Void
	{
		// fetch light power
		m_nI = p_oScene.light.getNormalizedPower ();

		// fetch light direction vector
		m_oL = p_oScene.light.getDirectionPoint3D ();

		// fetch camera vector
		m_oV = p_oScene.camera.getPosition (ABSOLUTE); m_oV.scale (-1); m_oV.normalize ();

		// compute Blinn halfway vector
		m_oH.copy( m_oL ); m_oH.add (m_oV); m_oH.normalize ();

		// clear current shape reference
		m_oCurrentShape = null;

		// init local vectors to any valid values
		m_oCurrentL.copy (m_oL); m_oCurrentV.copy (m_oV); m_oCurrentH.copy (m_oH);
	}

	/**
	* Method called right after the display list rendering
	* This is the place to remove and dispose memory if necessary.
	*/
	public function finish( p_oScene:Scene3D ):Void
	{
	}

	/**
	* Allows to proceed to an initialization
	* to know when the polyon isn't lined to the material, look at #unlink
	*/
	public function init( p_oPolygon:Polygon ):Void
	{
	}

	/**
	* Remove all the initialization
	* opposite of init
	*/
	public function unlink( p_oPolygon:Polygon ):Void
	{
		if (m_oCurrentShape == p_oPolygon.shape)
		{
			m_oCurrentShape = null;
		}
	}

	/**
	* Flags for the attribute.
	*/
	public var flags(__getFlags,null):Int;
	private function __getFlags():Int
	{
		return m_nFlags;
	}

	private var m_nFlags:Int;

	// --
	private var _ambient:Float;
	private var _diffuse:Float;
	private var _specular:Float;
	private var _gloss:Float;

	//private var _scenes:Hash<>;
}

