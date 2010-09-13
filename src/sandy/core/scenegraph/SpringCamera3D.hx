package sandy.core.scenegraph;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.math.Matrix4Math;
import sandy.view.Frustum;

/**
* @author	b at turbulent dot carbulent.ca - http://agit8.tu
* @author	Russell Weir (haXe port)
* @date 2009-01-21
*/
class SpringCamera3D extends Camera3D
{
	/**
	* [optional] Target object3d that camera should follow. If target is null, camera behaves just like a normal Camera3D.
	*/
	public var target(__getTarget,__setTarget) : Shape3D;


	/**
	* Stiffness of the spring, how hard is it to extend. The higher it is, the more "fixed" the cam will be.
	* A number between 1 and 20 is recommended.
	*/
	public var stiffness:Float;

	/**
	* Damping is the spring internal friction, or how much it resists the "boinggggg" effect. Too high and you'll lose it!
	* A number between 1 and 20 is recommended.
	*/
	public var damping:Float;

	/**
	* Mass of the camera, if over 120 and it'll be very heavy to move.
	*/
	public var mass:Float;

	/**
	* Offset of spring center from target in target object space, ie: Where the camera should ideally be in the target object space.
	*/
	public var positionOffset:Point3D;

	/**
	* Rotation in degrees along the camera Z vector to apply to the camera after it turns towards the target .
	*/
	public var zrot(__getZRot, __setZRot) : Float;

	/**
	* offset of facing in target object space, ie: where in the target object space should the camera look.
	*/
	public var lookOffset:Point3D;

	private var _camTarget:Shape3D;
	//zrot to apply to the cam
	private var _zrot:Float;

	//private physics members
	private var _velocity:Point3D;
	private var _dv:Point3D;
	private var _stretch:Point3D;
	private var _force:Point3D;
	private var _acceleration:Point3D;

	//private target members
	private var _desiredPosition:Point3D;
	private var _lookAtPosition:Point3D;
	private var _targetTransform:Matrix4;

	//private transformed members
	private var _xPositionOffset:Point3D;
	private var _xLookOffset:Point3D;
	private var _xPosition:Point3D;
	private var _xLookAtObject:Shape3D;


	/**
		* Constructor.
		*
		* @param   fov     This value is the vertical Field Of View (FOV) in degrees.
		* @param   near    Distance to the near clipping plane.
		* @param   far     Distance to the far clipping plane.
		*/
	public function new( p_nWidth:Int = 550, p_nHeight:Int = 400, fov:Float=60., near:Float=10., far:Float=5000.)
	{
		// initializers
		stiffness = 1;
		damping = 4;
		mass = 40;
		positionOffset = new Point3D(0,5,-50);
		lookOffset = new Point3D(0,2,10);
		_zrot = 0.;
		//private physics members
		_velocity = new Point3D();
		_dv = new Point3D();
		_stretch = new Point3D();
		_force = new Point3D();
		_acceleration = new Point3D();

		//private target members
		_desiredPosition = new Point3D();
		_lookAtPosition = new Point3D();
		_targetTransform = new Matrix4();

		//private transformed members
		_xPositionOffset = new Point3D();
		_xLookOffset = new Point3D();
		_xPosition = new Point3D();
		_xLookAtObject = new Shape3D();

		super( p_nWidth, p_nHeight, fov, near, far );
	}

	public override function updateTransform():Void
	{
		if( _camTarget != null )
		{
			_targetTransform.n31 = _camTarget.matrix.n31;
			_targetTransform.n32 = _camTarget.matrix.n32;
			_targetTransform.n33 = _camTarget.matrix.n33;

			_targetTransform.n21 = _camTarget.matrix.n21;
			_targetTransform.n22 = _camTarget.matrix.n22;
			_targetTransform.n23 = _camTarget.matrix.n23;

			_targetTransform.n11 = _camTarget.matrix.n11;
			_targetTransform.n12 = _camTarget.matrix.n12;
			_targetTransform.n13 = _camTarget.matrix.n13;

			_xPositionOffset.x = positionOffset.x;
			_xPositionOffset.y = positionOffset.y;
			_xPositionOffset.z = positionOffset.z;

			Matrix4Math.transform( _targetTransform, _xPositionOffset);

			_xLookOffset.x = lookOffset.x;
			_xLookOffset.y = lookOffset.y;
			_xLookOffset.z = lookOffset.z;

			Matrix4Math.transform( _targetTransform, _xLookOffset);

			_desiredPosition.x = _camTarget.x + _xPositionOffset.x;
			_desiredPosition.y = _camTarget.y + _xPositionOffset.y;
			_desiredPosition.z = _camTarget.z + _xPositionOffset.z;

			_lookAtPosition.x = _camTarget.x + _xLookOffset.x;
			_lookAtPosition.y = _camTarget.y + _xLookOffset.y;
			_lookAtPosition.z = _camTarget.z + _xLookOffset.z;


			_stretch.x = (x - _desiredPosition.x) * -stiffness;
			_stretch.y = (y - _desiredPosition.y) * -stiffness;
			_stretch.z = (z - _desiredPosition.z) * -stiffness;

			_dv.x = _velocity.x * damping;
			_dv.y = _velocity.y * damping;
			_dv.z = _velocity.z * damping;

			_force.x = _stretch.x - _dv.x;
			_force.y = _stretch.y - _dv.y;
			_force.z = _stretch.z - _dv.z;

			_acceleration.x = _force.x * (1 / mass);
			_acceleration.y = _force.y * (1 / mass);
			_acceleration.z = _force.z * (1 / mass);

			_velocity.add(_acceleration);


			_xPosition.x = x + _velocity.x;
			_xPosition.y = y + _velocity.y;
			_xPosition.z = z + _velocity.z;

			x = _xPosition.x;
			y = _xPosition.y;
			z = _xPosition.z;

			_xLookAtObject.x = _lookAtPosition.x;
			_xLookAtObject.y = _lookAtPosition.y;
			_xLookAtObject.z = _lookAtPosition.z;

			lookAt(_xLookAtObject.x, _xLookAtObject.y, _xLookAtObject.z );

			if(Math.abs(_zrot) > 0)
				this.rotateZ = _zrot;
		}

		super.updateTransform();
	}

	public override function toString():String
	{
		return "sandy.core.scenegraph.SpringCamera3D";
	}

	//////////////// Getters/Setters /////////////////////////////////
	public function __getTarget():Shape3D
	{
		return _camTarget;
	}

	public function __setTarget(object:Shape3D):Shape3D
	{
		return _camTarget = object;
	}

	public function __getZRot():Float
	{
		return _zrot;
	}

	public function __setZRot(n:Float):Float
	{
		_zrot = n;
		if(_zrot < 0.001) _zrot = 0.;
		return n;
	}




}
