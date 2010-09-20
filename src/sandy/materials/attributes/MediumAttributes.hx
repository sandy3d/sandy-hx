
package sandy.materials.attributes;

import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.data.Polygon;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.Sprite2D;
import sandy.materials.Material;
import sandy.math.ColorMath;
import sandy.math.VertexMath;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

import sandy.HaxeTypes;
import sandy.util.ArrayUtil;

/**
* This attribute provides very basic simulation of partially opaque medium.
* You can use this attribute to achieve wide range of effects (e.g., fog, Rayleigh scattering, light attached to camera, etc).
*
* @author		makc
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		01.12.2007
*/
class MediumAttributes extends AAttributes
{
	/**
	* Medium color (32-bit value) at the point given by fadeFrom + fadeTo.
	* If this value is transparent, color gradient will be extrapolated beyond that point.
	*/
	private function __setColor (p_nColor:UInt):UInt
	{
		_c = p_nColor & 0xFFFFFF;
		_a = (p_nColor - _c) / 0x1000000 / 255.0;
		return p_nColor;
	}

	/**
	* Medium color (32-bit value) at the point given by fadeFrom + fadeTo.
	* If this value is transparent, color gradient will be extrapolated beyond that point.
	*/
	public var color (__getColor,__setColor):UInt;
	private function __getColor ():UInt
	{
		return _c + Math.floor (0xFF * _a) * 0x1000000;
	}

	/**
	* Attenuation vector. This is the vector from transparent point to opaque point.
	*/
	private function __setFadeTo (p_oW:Point3D):Point3D
	{
		_fadeTo = p_oW;
		_fadeToN2 = p_oW.getNorm (); _fadeToN2 *= _fadeToN2;
		return p_oW;
	}

	/**
	* Attenuation vector. This is the vector from transparent point to opaque point.
	*
	* @see sandy.core.data.Point3D
	*/
	public var fadeTo (__getFadeTo,__setFadeTo):Point3D;
	private function __getFadeTo ():Point3D
	{
		return _fadeTo;
	}

	/**
	* Transparent point in wx, wy and wz coordinates.
	*
	* @see sandy.core.data.Point3D
	*/
	public var fadeFrom:Point3D;

	/**
	* Maximum amount of blur to add. <b>Warning:</b> this feature is very expensive when shape useSingleContainer is false.
	*/
	public var blurAmount:Float;

	/**
	* Creates a new MediumAttributes object.
	*
	* @param p_nColor		Medium color
	* @param p_oFadeTo		Attenuation vector (500 pixels beyond the screen by default).
	* @param p_oFadeFrom	Transparent point (at the screen by default).
	* @param p_nBlurAmount	Maximum amount of blur to add
	*
	* @see sandy.core.data.Point3D
	*/
	public function new (p_nColor:UInt, ?p_oFadeFrom:Point3D, ?p_oFadeTo:Point3D, ?p_nBlurAmount:Float = 0.0)
	{
		// private initializers
		m_bWasNotBlurred = true;
		_m = new Matrix();

		if (p_oFadeFrom == null)
			p_oFadeFrom = new Point3D (0, 0, 0);
		if (p_oFadeTo == null)
			p_oFadeTo = new Point3D (0, 0, 500);
		// --
		super();
		color = p_nColor; fadeTo = p_oFadeTo; fadeFrom = p_oFadeFrom; blurAmount = p_nBlurAmount;
	}

	/**
	* @private
	*/
	override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		var l_points:Array<Vertex> = ((p_oPolygon.isClipped) ? p_oPolygon.cvertices : p_oPolygon.vertices);
		var n:Int = l_points.length; if (n < 3) return;

		var l_ratios:TypedArray<Float> = new #if flash10 TypedArray(n) #else TypedArray() #end;
		for (i in 0...n) l_ratios[i] = ratioFromWorldPoint3D ( l_points[i].getCameraPoint3D());
		
		var zIndices = ArrayUtil.indicesOfSorted(Haxe.toArray(l_ratios),["ratio"],ArrayUtil.SORT_NUMERIC|ArrayUtil.SORT_RETURNINDEXEDARRAY);


		var v0: Vertex = l_points[zIndices[0]];
		var v1: Vertex = l_points[zIndices[1]];
		var v2: Vertex = l_points[zIndices[2]];

		var r0: Float = l_ratios[zIndices[0]], ar0:Float = _a * r0;
		var r1: Float = l_ratios[zIndices[1]];
		var r2: Float = l_ratios[zIndices[2]], ar2:Float = _a * r2;

		if (ar2 > 0)
		{
			if (ar0 < 1)
			{
				// gradient matrix
				VertexMath.linearGradientMatrix (v0, v1, v2, r0, r1, r2, _m);

				p_oGraphics.beginGradientFill (flash.display.GradientType.LINEAR, [_c, _c], [ar0, ar2], [0, 0xFF], _m);
			}
			else
			{
				p_oGraphics.beginFill ( _c, 1 );
			}

			// --
			p_oGraphics.moveTo (l_points[0].sx, l_points[0].sy);
			for (l_oVertex in l_points)
			{
				p_oGraphics.lineTo (l_oVertex.sx, l_oVertex.sy);
			}
			p_oGraphics.endFill();
		}

		blurDisplayObjectBy (
			p_oPolygon.shape.useSingleContainer ? p_oPolygon.shape.container : p_oPolygon.container,
			prepareBlurAmount (blurAmount * r0)
		);
	}

	/**
	* @private
	*/
	override public function drawOnSprite( p_oSprite:Sprite2D, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		var l_ratio:Float = Math.max (0, Math.min (1, ratioFromWorldPoint3D (p_oSprite.getPosition (CAMERA)) * _a));
		var l_color:ColorMathRGB = ColorMath.hex2rgb (_c);
		var l_coltr:ColorTransform = p_oSprite.container.transform.colorTransform;
		// --
		l_coltr.redOffset = Math.round (l_color.r * l_ratio);
		l_coltr.greenOffset = Math.round (l_color.g * l_ratio);
		l_coltr.blueOffset = Math.round (l_color.b * l_ratio);
		l_coltr.redMultiplier = l_coltr.greenMultiplier = l_coltr.blueMultiplier = 1 - l_ratio;
		// --
		p_oSprite.container.transform.colorTransform = l_coltr;

		blurDisplayObjectBy (
			p_oSprite.container,
			prepareBlurAmount (blurAmount * l_ratio)
		);
	}

	// --
	private function ratioFromWorldPoint3D (p_oW:Point3D):Float
	{
		p_oW.sub (fadeFrom); return p_oW.dot (_fadeTo) / _fadeToN2;
	}

	private function prepareBlurAmount (p_nBlurAmount:Float):Float
	{
		// a) constrain blur amount according to filter specs
		// b) quantize blur amount to make filter reuse more effective
		return Math.round (10 * Math.min (255, Math.max (0, p_nBlurAmount)) ) * 0.1;
	}

	private var m_bWasNotBlurred:Bool;
	private function blurDisplayObjectBy (p_oDisplayObject:DisplayObject, p_nBlurAmount:Float):Void
	{
		if (m_bWasNotBlurred && (p_nBlurAmount == 0)) return;

		var fs:Array<BlurFilter> = [], changed:Bool = false;
		var i:Int = p_oDisplayObject.filters.length -1;
		while (i > -1)
		{
			if (!changed && Std.is(p_oDisplayObject.filters[i], BlurFilter) && (p_oDisplayObject.filters[i].quality == 1))
			{
				var bf:BlurFilter = p_oDisplayObject.filters[i];

				// hopefully, this check will save some cpu
				if ((bf.blurX == p_nBlurAmount) &&
					(bf.blurY == p_nBlurAmount)) return;

				// assume this is our filter and change it
				bf.blurX = bf.blurY = p_nBlurAmount; fs[i] = bf; changed = true;
			}
			else
			{
				// copy the filter
				fs[i] = p_oDisplayObject.filters[i];
			}
			i--;
		}
		// if filter was not found, add new
		if (!changed)
		{
			fs.push (new BlurFilter (p_nBlurAmount, p_nBlurAmount, 1));
			// once we added blur we have to track it all the time
			m_bWasNotBlurred = false;
		}
		// re-apply all filters
		p_oDisplayObject.filters = fs;
	}

	// --
	private var _m:Matrix;
	private var _c:Int;
	private var _a:Float;
	private var _fadeTo:Point3D;
	private var _fadeToN2:Float;
}
