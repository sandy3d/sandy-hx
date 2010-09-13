package sandy.core.scenegraph.mode7;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;

import sandy.core.data.Matrix4;
import sandy.materials.Material;
import sandy.view.Frustum;
import sandy.core.scenegraph.Node;
import sandy.core.scenegraph.IDisplayable;
import sandy.core.scenegraph.Renderable;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.mode7.CameraMode7;

/**
 * This class is very useful to render infinite floor with good rendering quality and perspective correction.
 * This kind of rendering is used in some games like earlier version of MarioKart or other Racing games.
 * It replace successfully a big plane with perspective correction enabled on it.
 * @author Cedric Jules
 * @author Makc
 * @author Niel Drummond
 */
class Mode7 extends Node, implements Renderable, implements IDisplayable
{
	private var _width : Int;
	private var _height : Int;

	private var _container : Sprite;
	private var _numLines : Int;

	private var _camera : CameraMode7;
	private var _fov : Float;
	private var _near : Float;
	private var _far : Float;
	private var _useCameraNearFar : Bool;
	private var _ratioWidthHeight : Float;
	private var _altitude : Float;
	private var _camTiltRadian : Float;

	private var _horizon : Float;

	private var _traceHorizon : Bool;

	private var _colorHorizon : Int;

	private var _widthHorizon : Int;

	private var _mapOriginal : BitmapData;

	private var _scaleMap : Int;

	private var _repeatMap : Bool;

	private var _smooth : Bool;

	private var _centerMapMatrix : Matrix;

	private var _mapMatrix : Matrix;

	private var _lineMatrix : Matrix;

	private var _yMax : Float;

	private var _yMin : Float;

	private var _length : Float;

	private var _yMaxTilted : Float;

	private var _yMinTilted : Float;

	private var _yLength : Float;

	private var _yStep : Float;

	private var _yCurrent : Float;

	private var _zMax : Float;

	private var _zMin : Float;

	private var _zMaxTilted : Float;

	private var _zMinTilted : Float;

	private var _zLength : Float;

	private var _zStep : Float;

	private var _zCurrent : Float;

	private var _t : Float;

	private var _xAmplitude : Float;

	private var _xAmplitudePrev : Float;

	private var _xAmplitudeAvg : Float;

	private var _zAmplitude : Float;

	private var _zProj : Float;

	private var _zProjPrev : Float;

	private var _prevOK : Bool;

	private var _failColor : Int;

	private static inline var PI : Float = Math.PI;

	private static inline var PIon180 : Float = PI / 180;

	private static inline var cos : Float -> Float = Math.cos;

	private static inline var sin : Float -> Float = Math.sin;

	private static inline var tan : Float -> Float = Math.tan;

	private static inline var math : Class<Math> = Math;

	public var precision:Int;

	public function new()
	{
		_container = new Sprite();
		precision = 1;
		m_nDepth = Math.POSITIVE_INFINITY;

		super();

		_useCameraNearFar = true;
		_lineMatrix = new Matrix();
		setHorizon();
	}

	// getters and setters //

	public var smooth(__getSmooth,__setSmooth) : Bool;
	private function __getSmooth() : Bool
	{
		return _smooth;
	}

	private function __setSmooth(value : Bool) : Bool
	{
		_smooth = value;
		return value;
	}

	public var repeatMap(__getRepeatMap,__setRepeatMap) : Bool;
	private function __getRepeatMap() : Bool
	{
		return _repeatMap;
	}

	private function __setRepeatMap(value : Bool) : Bool
	{
		_repeatMap = value;
		return value;
	}

	/**
	 * Set the bitmap to apply as floor.
	 * @param bmp The bitmapdata objet which contains floor texture information
	 */
	public function setBitmap(bmp : BitmapData, scale : Int = 1, repeatMap : Bool = true, smooth : Bool = false) : Void
	{
		_mapOriginal = bmp;
		_scaleMap = scale;
		_repeatMap = repeatMap;
		_smooth = smooth;
		_centerMapMatrix = new Matrix();
		_centerMapMatrix.translate(-bmp.width / 2, -bmp.height / 2);
		_centerMapMatrix.scale(_scaleMap, -_scaleMap);
		_mapMatrix = new Matrix();
		_failColor = bmp.getPixel (0, 0);
	}

	/**
	 * Set the horizontal line display.
	 * you can use this to debug and/or to calibrate your visual elements
	 */
	public function setHorizon(traceHorizon : Bool = true, colorHorizon : Int = 0x000000, horizonWidth : Int = 1) : Void
	{
		_traceHorizon = traceHorizon;
		_colorHorizon = colorHorizon;
		_widthHorizon = horizonWidth;
	}

	/**
	 * Returns the horizon value
	 */
	public function getHorizon() : Float
	{
		return _horizon;
	}

	public function setNearFar(fromCamera : Bool, near : Int = 1 , far : Int = 1000 ) : Void
	{
		_useCameraNearFar = fromCamera;
		if (!_useCameraNearFar)
		{
			_near = near;
			_far = far;
		}
	}
	
	public var material(__getMaterial,__setMaterial):Material;
	public function __getMaterial():Material
	{
		return null;
	}
	public function __setMaterial( mat:Material ):Material
	{
		return mat;
	}
	
	/**
	 * Clears the container information
	 */
	public function clear():Void
	{
		_container.graphics.clear();
	}
	
	/**
	 * Returns the container of that graphical element
	 */
	// The container of this object
	public var container(__getContainer,null):Sprite;
	private function __getContainer():Sprite
	{
		return _container;
	}
	// The depth of this object
	private var m_nDepth:Float;
	public var depth(__getDepth,__setDepth):Float;
	public function __getDepth():Float
	{
		return m_nDepth;
	}
	public function __setDepth(d:Float):Float
	{
		m_nDepth = d;
		return d;
	}

	/**
	 * @inherited
	 */
	public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		super.cull( p_oFrustum, p_oViewMatrix, p_bChanged );
		// check if we need to resize our canvas
		scene.renderer.addToDisplayList( this ); 
	}

	/**
	 * @inherited
	 */
	public function display( p_oContainer:Sprite = null  ):Void
	{
		_prevOK = false;
		var i:Int = 0, di:Int = 1, di_1:Int = 0;
		while (i <= _numLines)
		{
			_yCurrent = _altitude + _yMinTilted + i * _yStep;
			_zCurrent = _zMinTilted + i * _zStep;

			if (_yCurrent - _altitude != 0)
			{
				_t = -_altitude / (_yCurrent - _altitude);
				if (_t >= _near)
				{
					_zProj = _t * _zCurrent;
					_xAmplitude = _t * _ratioWidthHeight * _length;
					if (_prevOK)
					{
						if (_t <= _far)
						{
							// TODO top-down order? for this is fucking backwards.
							if (_xAmplitude - _xAmplitudePrev < precision) {
								i -=di; di++; 
								i += di;
								continue;
							} else {
								if (di > 1) di_1 = di - 1;
							}

							_zAmplitude =  (_zProj - _zProjPrev) / di;
							_xAmplitudeAvg = ( _xAmplitude + _xAmplitudePrev) / 2;
							_lineMatrix.identity();
							_lineMatrix.concat(_mapMatrix);
							_lineMatrix.translate(_xAmplitudeAvg / 2, (i - _height) * _zAmplitude - _zProj);
							_lineMatrix.scale(_width / _xAmplitudeAvg, -1 / _zAmplitude);
							var ls:Float = _lineMatrix.a * _lineMatrix.d - _lineMatrix.b * _lineMatrix.c;
							if ((ls > -2e-7) && (ls < 2e-7))
								_container.graphics.beginFill (_failColor);
							else
								_container.graphics.beginBitmapFill(_mapOriginal, _lineMatrix, _repeatMap, _smooth);

							_container.graphics.drawRect(0, _height - i, _width, di);
							// player will end fill for us
							//_container.graphics.endFill();
							di = di_1;
						}
						else
						{
							break;
						}
					}
					_zProjPrev = _zProj;
					_xAmplitudePrev = _xAmplitude;
					_prevOK = true;
				}
			}
			i += di;
		}

		if (_traceHorizon)
		{
			// end fill here just in case
			_container.graphics.endFill();

			_container.graphics.lineStyle(_widthHorizon, _colorHorizon);
			_container.graphics.moveTo(0, _horizon);
			_container.graphics.lineTo(_width, _horizon);
		}
	}

	/**
	 * @inherited
	 */
	public function render( p_oCamera:Camera3D ):Void
	{
		if( !Std.is(p_oCamera, CameraMode7) )
			return;

		_camera = cast p_oCamera;

		_width = p_oCamera.viewport.width;
		_height = p_oCamera.viewport.height;
		_ratioWidthHeight = _width / _height;
		_numLines = _height;
		// --
		_mapMatrix.identity();
		_mapMatrix.concat(_centerMapMatrix);
		_mapMatrix.translate(-_camera.x, -_camera.z);
		_mapMatrix.rotate(-PIon180 * _camera.rotateY);

		_fov = PIon180 * _camera.fov;
		if (_useCameraNearFar)
		{
			_near = _camera.near;
			_far = _camera.far;
		}
		_altitude = _camera.y;
		_camTiltRadian = PIon180 * _camera.tilt;

		_yMax = 1 / math.tan((PI - _fov) / 2);
		_yMin = -_yMax;
		_length = _yMax - _yMin;
		_zMax = 1;
		_zMin = 1;
		_yMaxTilted = _zMax * math.sin(-_camTiltRadian) + _yMax * math.cos(-_camTiltRadian);
		_zMaxTilted = _zMax * math.cos(-_camTiltRadian) - _yMax * math.sin(-_camTiltRadian);
		_yMinTilted = _zMin * math.sin(-_camTiltRadian) + _yMin * math.cos(-_camTiltRadian);
		_zMinTilted = _zMin * math.cos(-_camTiltRadian) - _yMin * math.sin(-_camTiltRadian);
		_yLength = _yMaxTilted - _yMinTilted;
		_yStep = _yLength / _numLines;
		_zLength = _zMaxTilted - _zMinTilted;
		_zStep = _zLength / _numLines;

		if (_yMaxTilted - _yMinTilted == 0)
		{
			if (_zMinTilted < _zMaxTilted)
			{
				_horizon = math.NEGATIVE_INFINITY;
			}
			else if (_zMinTilted > _zMaxTilted)
			{
				_horizon = math.POSITIVE_INFINITY;
			}
		}
		else
		{
			_horizon = _height * _yMaxTilted / (_yMaxTilted - _yMinTilted);
		}
		_camera.horizon = _horizon;
	}
}



