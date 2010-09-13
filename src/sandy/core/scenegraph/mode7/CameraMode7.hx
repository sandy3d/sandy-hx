package sandy.core.scenegraph.mode7;

import sandy.core.scenegraph.Camera3D;

/**
 * CameraMode7 behaves like Camera3D, but with
 * some constraints:
 * - rotations are available only
 * by the rotateY and tilt methods (other are
 * desactivated)
 * - the lookAt method is
 * overrided to respect the available rotations
 *
 * @author Cedric Jules
 * @author Niel Drummond (haXe port)	 */

class CameraMode7 extends Camera3D
{
	private var _horizon : Float;
	private static inline var PI : Float = Math.PI;
	private static inline var PIon180 : Float = Math.PI / 180;
	private static inline var sin : Float -> Float = Math.sin;
	private static inline var cos : Float -> Float = Math.cos;
	private static inline var aTan2 : Float -> Float -> Float = Math.atan2;
	private static inline var math : Class<Math> = Math;

	// some useful variables to make some computations
	private var _xTarget : Float;
	private var _yTarget : Float;
	private var _zTarget : Float;
	private var _yAngle : Float;
	private var _zTargetBis : Float;
	private var _tiltAngle : Float;

	public function new(p_nWidth : Int, p_nHeight : Int, p_nFov : Float = 45.0, p_nNear : Float = 50.0, p_nFar : Float = 10000.0	)
	{
		super(p_nWidth, p_nHeight, p_nFov, p_nNear, p_nFar);
	}
	public var horizon( __getHorizon, __setHorizon ) : Float;

	public function __getHorizon() : Float
	{
		return _horizon;
	}
	public function __setHorizon(value : Float) : Float
	{
		_horizon = value;
		return value;
	}

	// deactivate some setters methods
	private override function __setRotateX(p_nAngle : Float) : Float { return 0.; }
	private override function __setRotateZ(p_nAngle : Float) : Float { return 0.; }
	private override function __setPan(p_nAngle : Float) : Float { return 0.; }
	private override function __setRoll(p_nAngle : Float) : Float { return 0.; }
	public override function rotateAxis(p_nX : Float, p_nY : Float, p_nZ : Float, p_nAngle : Float) : Void {}

	public override function lookAt(p_nX : Float, p_nY : Float, p_nZ : Float) : Void
	{
		_xTarget = p_nX - x;
		_yTarget = p_nY - y;
		_zTarget = p_nZ - z;

		_yAngle = -math.atan2(_xTarget, _zTarget);
		rotateY = _yAngle / PIon180;

		_zTargetBis = _xTarget * math.sin(-_yAngle) + _zTarget * math.cos(-_yAngle);
		_tiltAngle = -math.atan2(_yTarget, _zTargetBis);
		tilt = _tiltAngle / PIon180;
	}

}
