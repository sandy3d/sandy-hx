
package sandy.core.scenegraph;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;

import sandy.HaxeTypes;

/**
* ABSTRACT CLASS - super class for all movable objects in the object tree.
*
* <p> This class should not be directly instatiated, but sub classed.<br/>
* The Atransformable class is resposible for scaling, rotation and translation of objects in 3D space.</p>
*
* <p>Rotations and translations are performed in one of three coordinate systems or reference frames:<br/>
* - The local frame which is the objects own coordinate system<br />
* - The parent frame which is the coordinate system of the object's parent, normally a TransformGroup<br/>
* - The world frame which is the coordinate system of the world, the global system.</p>
* <p>Positions, directions, translations and rotations of an ATransformable object are performed in its parent frame.<br />
* Tilt, pan and roll, are rotations around the local axes, and moveForward, moveUpwards and moveSideways are translations along local axes.</p>
*
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		16.03.2007
**/
class ATransformable extends Node
{

	/**
	* Disable the local transformations applied to this Node if set to false.
	* They will be applied again when set back to true.
	*/
	public var disable:Bool;
	/**
	* <p>Inverse of the model matrix
	* The matrix is inverted in comparison of the real model matrix.<br/>
	* For example, this allows replacement of the objects in the correct camera frame before projection</p>
	*/
	public var invModelMatrix:Matrix4;
	/**
	* This property allows you to directly set the matrix you want to a transformable object.
	* But be careful with its use. It modifies the rotation AND the position.
	* WARNING : Please remove any scale from this matrix. This is not managed yet.
	* WARNING : Please think about call initFrame before changing this frame. Without calling this method first, the frame will stay local, and the transformation will be applied
	* locally.
	* @param p_oMatrix The new local matrix for this node
	*/
	public var matrix(__getMatrix, __setMatrix):Matrix4;
	/**
	* Forward direction ( local z ) in parent coordinates.
	*/
	public var out(__getOut,null):Point3D;
	/**
	* Pans this object around the local y axis.
	*
	* <p>The pan angle interval is 0 to 360 degrees<br/>
	* Directions within the parent frame are: North = 0, East = 90, South = 180 nad West = 270 degrees.</p>
	*
	* @param p_nAngle 	The pan angle in degrees.
	*/
	public var pan(__getPan,__setPan):Float;
	/**
	* Rolls this object around the local z axis.
	*
	* <p>The roll angle interval is -180 to +180 degrees<br/>
	* At 0 degrees the local x axis is aligned with the horizon of its parent<br/>
	* Full roll right = 180 and full roll left = -180 degrees ( upside down ).</p>
	*
	* @param p_nAngle 	The roll angle in degrees.
	*/
	public var roll(__getRoll,__setRoll):Float;
	/**
	* Rotates this object around an axis parallel to the parents x axis.
	*
	* <p>The object rotates a specified angle ( degrees ) around an axis through the
	* objects reference point, paralell to the x axis of the parent frame.</p>
	*/
	public var rotateX(__getRotateX,__setRotateX):Float;
	/**
	* Rotates this object around an axis parallel to the parents y axis.
	*
	* <p>The object rotates a specified angle ( degrees ) around an axis through the
	* objects reference point, parallel to the y axis of the parent frame.</p>
	*/
	public var rotateY(__getRotateY,__setRotateY):Float;
	/**
	* Rotates this object around an axis paralell to the parents z axis.
	*
	* <p>The object rotates a specified angle ( degrees ) around an axis through the
	* objects reference point, paralell to the z axis of the parent frame.</p>
	*/
	public var rotateZ(__getRotateZ,__setRotateZ):Float;
	/**
	* x scale of this object.
	*
	* <p>A value of 1 scales to the original x scale, a value of 2 doubles the x scale.<br/>
	* NOTE : This value does not affect the camera object.</p>
	*/
	public var scaleX(__getScaleX,__setScaleX):Float;
	/**
	* y scale of this object.
	*
	* <p>A value of 1 scales to the original y scale, a value of 2 doubles the y scale.<br/>
	* NOTE : This value does not affect the camera object.</p>
	*/
	public var scaleY(__getScaleY,__setScaleY):Float;
	/**
	* z scale of this object.
	*
	* <p>A value of 1 scales to the original z scale, a value of 2 doubles the z scale.<br/>
	* NOTE : This value does not affect the camera object.</p>
	*/
	public var scaleZ(__getScaleZ,__setScaleZ):Float;
	/**
	* Side direction ( local x ) in parent coordinates.
	*/
	public var side(__getSide,null):Point3D;

	/**
	* Tilts this object around the local x axis.
	*
	* <p>The tilt angle interval is -90 to +90 degrees<br/>
	* At 0 degrees the local z axis is paralell to the zx plane of its parent coordinate system.<br/>
	* Straight up = +90 and stright down = -90 degrees.</p>
	*
	* @param p_nAngle 	The tilt angle in degrees.
	*/
	public var tilt(__getTilt,__setTilt):Float;
	/**
	* Up direction ( local y ) in parent coordinates.
	*/
	public var up(__getUp,null):Point3D;
	/**
	* x position of this object in its parent frame.
	*/
	public var x(__getX,__setX):Float;
	/**
	* y position of this object in its parent frame.
	*/
	public var y(__getY,__setY):Float;
	/**
	* z position of the node in its parent frame.
	*/
	public var z(__getZ,__setZ):Float;

	/**
	* Creates a transformable node in the object tree of the world.
	*
	* <p>This constructor should normally not be called directly, but from a sub class.</p>
	*
	* @param p_sName	A string identifier for this object
	*/
	public function new ( ?p_sName:String="" )
	{
		super( p_sName );

		disable = false;
		invModelMatrix = new Matrix4();

		resetCoords();
	}

	/**
	* Resets the coordinate system for this object. Useful for returning to known state.
	*/
	public function resetCoords (): Void
	{
		// --
		initFrame();
		// --
		_p 		= new Point3D();
		_oScale = new Point3D( 1, 1, 1 );
		_vRotation = new Point3D(0,0,0);
		// --
		_vLookatDown = new Point3D(0.00000000001, -1, 0);// value to avoid some colinearity problems.;
		// --
		_nRoll 	= 0;
		_nTilt 	= 0;
		_nYaw  	= 0;
		// --
		m_tmpMt = new Matrix4();
		m_oMatrix = new Matrix4();
		// --
		changed = true;
	}


	/**
	* Initiates the local coordinate system for this object.
	*
	* <p>The local coordinate system for this object is set parallell the parent system.</p>
	*/
	public function initFrame():Void
	{
		_vSide 	= new Point3D( 1, 0, 0 );
		_vUp 	= new Point3D( 0, 1 ,0 );
		_vOut 	= new Point3D( 0, 0, 1 );
		_vRotation = new Point3D(0,0,0);
		changed = true;
	}

	private function __getMatrix():Matrix4
	{
		return m_oMatrix;
	}

	private function __setMatrix( p_oMatrix:Matrix4 ):Matrix4
	{
		m_oMatrix = p_oMatrix;
		// --
		m_oMatrix.transform3x3(_vSide);
		m_oMatrix.transform3x3(_vUp);
		m_oMatrix.transform3x3(_vOut);
		// --
		_vSide.normalize();
		_vUp.normalize();
		_vOut.normalize();
		// --
		_p.x = p_oMatrix.n14;
		_p.y = p_oMatrix.n24;
		_p.z = p_oMatrix.n34;
		// --
		changed = true;
		return p_oMatrix;
	}

	private function __setX( p_nX:Float ):Float
	{
		if( p_nX == _p.x ) return p_nX;
		_p.x = p_nX;
		changed = true;
		return p_nX;
	}

	private function __getX():Float
	{
		return _p.x;
	}

	private function __setY( p_nY:Float ):Float
	{
		if( p_nY == _p.y ) return p_nY;
		_p.y = p_nY;
		changed = true;
		return p_nY;
	}

	private function __getY():Float
	{
		return _p.y;
	}

	private function __setZ( p_nZ:Float ):Float
	{
		if( p_nZ == _p.z ) return p_nZ;
		_p.z = p_nZ;
		changed = true;
		return p_nZ;
	}

	private function __getZ():Float
	{
		return _p.z;
	}

	/**
		* getLookAt - obtain last value set via lookAt() method; may not be valid if other camera movement has occurred since then.
		*/
	public function getLookAt():Point3D
	{
		return _vLookAt;
	}

	private function __getOut():Point3D
	{
		return _vOut;
	}

	private function __getSide():Point3D
	{
		return _vSide;
	}

	private function __getUp():Point3D
	{
		return _vUp;
	}

	private function __setScaleX( p_nScaleX:Float ):Float
	{
		if( _oScale.x == p_nScaleX ) return p_nScaleX;
		_oScale.x = p_nScaleX;
		changed = true;
		return p_nScaleX;
	}

	private function __getScaleX():Float
	{
		return _oScale.x;
	}

	private function __setScaleY( p_nScaleY:Float ):Float
	{
		if( _oScale.y == p_nScaleY ) return p_nScaleY;
		_oScale.y = p_nScaleY;
		changed = true;
		return p_nScaleY;
	}

	private function __getScaleY():Float
	{
		return _oScale.y;
	}

	public function __setScaleZ( p_nScaleZ:Float ):Float
	{
		if( _oScale.z == p_nScaleZ ) return p_nScaleZ;
		_oScale.z = p_nScaleZ;
		changed = true;
		return p_nScaleZ;
	}

	public function __getScaleZ():Float
	{
		return _oScale.z;
	}

	/**
	* Translates this object along its side vector ( local x ) in the parent frame.
	*
	* <p>If you imagine yourself in the world, it would be a step to your right or to your left</p>
	*
	* @param p_nD	How far to move
	*/
	public function moveSideways( p_nD : Float ) : Void
	{
		changed = true;
		_p.x += _vSide.x * p_nD;
		_p.y += _vSide.y * p_nD;
		_p.z += _vSide.z * p_nD;
	}

	/**
	* Translates this object along its up vector ( local y ) in the parent frame.
	*
	* <p>If you imagine yourself in the world, it would be a step up or down<br/>
	* in the direction of your body, not always vertically!</p>
	*
	* @param p_nD	How far to move
	*/
	public function moveUpwards( p_nD : Float ) : Void
	{
		changed = true;
		_p.x += _vUp.x * p_nD;
		_p.y += _vUp.y * p_nD;
		_p.z += _vUp.z * p_nD;
	}

	/**
	* Translates this object along its forward vector ( local z ) in the parent frame.
	*
	* <p>If you imagine yourself in the world, it would be a step forward<br/>
	* in the direction you look, not always horizontally!</p>
	*
	* @param p_nD	How far to move
	*/
	public function moveForward( p_nD : Float ) : Void
	{
		changed = true;
		_p.x += _vOut.x * p_nD;
		_p.y += _vOut.y * p_nD;
		_p.z += _vOut.z * p_nD;
	}

	/**
	* Translates this object parallel to its parent zx plane and in its forward direction.
	*
	* <p>If you imagine yourself in the world, it would be a step in the forward direction,
	* but without changing your altitude ( constant global z ).</p>
	*
	* @param p_nD	How far to move
	*/
	public function moveHorizontally( p_nD:Float ) : Void
	{
		changed = true;
		_p.x += _vOut.x * p_nD;
		_p.z += _vOut.z * p_nD;
	}

	/**
	* Translates this object vertically in ots parent frame.
	*
	* <p>If you imagine yourself in the world, it would be a strictly vertical step,
	* ( in the global y direction )</p>
	*
	* @param p_nD	How far to move
	*/
	public function moveVertically( p_nD:Float ) : Void
	{
		changed = true;
		_p.y += p_nD;
	}

	/**
	* Translates this object laterally in its parent frame.
	*
	* <p>This is a translation in the parents x direction.</p>
	*
	* @param p_nD	How far to move
	*/
	public function moveLateraly( p_nD:Float ) : Void
	{
		changed = true;
		_p.x += p_nD;
	}

	/**
	* Translate this object from it's current position with the specified offsets.
	*
	* @param p_nX 	Offset that will be added to the x coordinate of the object
	* @param p_nY 	Offset that will be added to the y coordinate of the object
	* @param p_nZ 	Offset that will be added to the z coordinate of the object
	*/
	public function translate( p_nX:Float, p_nY:Float, p_nZ:Float ) : Void
	{
		changed = true;
		_p.x += p_nX;
		_p.y += p_nY;
		_p.z += p_nZ;
	}


	/**
	* Rotate this object around the specified axis in the parent frame by the specified angle.
	*
	* <p>NOTE : The axis will be normalized automatically.</p>
	*
	* @param p_nX		The x coordinate of the axis
	* @param p_nY		The y coordinate of the axis
	* @param p_nZ		The z coordinate of the axis
	* @param p_nAngle	The angle of rotation in degrees.
	*/
	public function rotateAxis( p_nX : Float, p_nY : Float, p_nZ : Float, p_nAngle : Float ):Void
	{
		changed = true;
		p_nAngle = (p_nAngle + 360)%360;
		var n:Float = Math.sqrt( p_nX*p_nX + p_nY*p_nY + p_nZ*p_nZ );
		// --
		m_tmpMt.axisRotation( p_nX/n, p_nY/n, p_nZ/n, p_nAngle );
		// --
		m_tmpMt.transform3x3(_vSide);
		m_tmpMt.transform3x3(_vUp);
		m_tmpMt.transform3x3(_vOut);
	}

	/**
	* Makes this object "look at" the specified position in the parent frame.
	*
	* <p>Useful for following a moving object or a static object while this object is moving.<br/>
	* Normally used when this object is a camera</p>
	*
	* @param	p_nX	Number	The x position to look at
	* @param	p_nY	Number	The y position to look at
	* @param	p_nZ	Number	The z position to look at
	*/
	public function lookAt( p_nX:Float, p_nY:Float, p_nZ:Float ):Void
	{
		changed = true;
		_vLookAt = new Point3D(p_nX, p_nY, p_nZ);

		//
		_vOut.x = p_nX; _vOut.y = p_nY; _vOut.z = p_nZ;
		//
		_vOut.sub( _p );
		_vOut.normalize();
		// -- the vOut vector should not be colinear with the reference down vector!
		_vSide = null;
		_vSide = _vOut.cross( _vLookatDown );
		_vSide.normalize();
		//
		_vUp = null;
		_vUp = _vOut.cross(_vSide );
		_vUp.normalize();
	}

	/**
	* Makes this object "look at" the specified position in the parent frame.
	*
	* <p>Useful for following a moving object or a static object while this object is moving.<br/>
	* Normally used when this object is a camera</p>
	*
	* @param p_oTarget The point to look at.
	*/
	public function lookAtPoint( p_oTarget : Point3D ) : Void
	{
		lookAt( p_oTarget.x, p_oTarget.y, p_oTarget.z );
	}

	private function __setRotateX ( p_nAngle:Float ):Float
	{
		var l_nAngle:Float = (p_nAngle - _vRotation.x);
		if(l_nAngle == 0 ) return p_nAngle;
		changed = true;
		// --
		m_tmpMt.rotationX( l_nAngle );
		m_tmpMt.transform3x3(_vSide);
		m_tmpMt.transform3x3(_vUp);
		m_tmpMt.transform3x3(_vOut);
		// --
		_vRotation.x = p_nAngle;
		return p_nAngle;
	}

	private function __getRotateX():Float
	{
		return _vRotation.x;
	}

	private function __setRotateY ( p_nAngle:Float ):Float
	{
		var l_nAngle:Float = (p_nAngle - _vRotation.y);
		if(l_nAngle == 0 ) return p_nAngle;
		changed = true;
		// --
		m_tmpMt.rotationY( l_nAngle );
		m_tmpMt.transform3x3(_vSide);
		m_tmpMt.transform3x3(_vUp);
		m_tmpMt.transform3x3(_vOut);
		// --
		_vRotation.y = p_nAngle;
		return p_nAngle;
	}

	private function __getRotateY():Float
	{
		return _vRotation.y;
	}

	private function __setRotateZ ( p_nAngle:Float ):Float
	{
		var l_nAngle:Float = (p_nAngle - _vRotation.z );
		if(l_nAngle == 0 ) return p_nAngle;
		changed = true;
		// --
		m_tmpMt.rotationZ( l_nAngle );
		m_tmpMt.transform3x3(_vSide);
		m_tmpMt.transform3x3(_vUp);
		m_tmpMt.transform3x3(_vOut);
		// --
		_vRotation.z = p_nAngle;
		return p_nAngle;
	}

	private function __getRotateZ():Float
	{
		return _vRotation.z;
	}

	private function __setRoll ( p_nAngle:Float ):Float
	{
		var l_nAngle:Float = (p_nAngle - _nRoll);
		if(l_nAngle == 0 ) return p_nAngle;
		changed = true;
		// --
		m_tmpMt.axisRotation ( _vOut.x, _vOut.y, _vOut.z, l_nAngle );
		m_tmpMt.transform3x3(_vSide);
		m_tmpMt.transform3x3(_vUp);
		// --
		_nRoll = p_nAngle;
		return p_nAngle;
	}
	private function __getRoll():Float
	{
		return _nRoll;
	}


	private function __setTilt ( p_nAngle:Float ):Float
	{
		var l_nAngle:Float = (p_nAngle - _nTilt);
		if(l_nAngle == 0 ) return p_nAngle;
		changed = true;
		// --
		m_tmpMt.axisRotation ( _vSide.x, _vSide.y, _vSide.z, l_nAngle );
		m_tmpMt.transform3x3(_vOut);
		m_tmpMt.transform3x3(_vUp);
		// --
		_nTilt = p_nAngle;
		return p_nAngle;
	}
	private function __getTilt():Float
	{
		return _nTilt;
	}

	private function __setPan ( p_nAngle:Float ):Float
	{
		var l_nAngle:Float = (p_nAngle - _nYaw);
		if(l_nAngle == 0 ) return p_nAngle;
		changed = true;
		// --
		m_tmpMt.axisRotation ( _vUp.x, _vUp.y, _vUp.z, l_nAngle );
		m_tmpMt.transform3x3(_vOut);
		m_tmpMt.transform3x3(_vSide);
		// --
		_nYaw = p_nAngle;
		return p_nAngle;
	}

	private function __getPan():Float
	{
		return _nYaw;
	}

	/**
	* Sets the position of this object in coordinates of its parent frame.
	*
	* @param p_nX 	The x coordinate
	* @param p_nY 	The y coordiante
	* @param p_nZ 	The z coordiante
	*/
	public function setPosition( p_nX:Float, p_nY:Float, p_nZ:Float ):Void
	{
		changed = true;
		_p.x = p_nX;
		_p.y = p_nY;
		_p.z = p_nZ;
	}

	/**
	* Sets the position of this object in coordinates of its parent frame.
	*
	* @param p_nX 	The x coordinate
	* @param p_nY 	The y coordiante
	* @param p_nZ 	The z coordiante
	*/
	public function setPositionPoint( p_oPoint : Point3D ):Void
	{
		changed = true;
		_p.x = p_oPoint.x;
		_p.y = p_oPoint.y;
		_p.z = p_oPoint.z;
	}

	/**
	* Updates this node or object.
	*
	* <p>For node's with transformation, this method updates the transformation taking into account the matrix cache system.<br/>
	* <b>FIXME<b>: Transformable nodes shall upate their transform if necessary before calling this method.</p>
	*
	* @param p_oScene The current scene
	* @param p_oModelMatrix The matrix which represents the parent model matrix. Basically it stores the rotation/translation/scale of all the nodes above the current one.
	* @param p_bChanged	A boolean value which specify if the state has changed since the previous rendering. If false, we save some matrix multiplication process.
	*/
	public override function update( p_oModelMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		updateTransform();
		// --
		if( p_bChanged || changed )
		{
			if( p_oModelMatrix != null && !disable )
			{
				modelMatrix.copy(p_oModelMatrix);
				modelMatrix.multiply4x3( m_oMatrix );
			}
			else
			{
				modelMatrix.copy( m_oMatrix );
			}
			// -- fast model matrix inverssion
			invModelMatrix.n11 = modelMatrix.n11;
			invModelMatrix.n12 = modelMatrix.n21;
			invModelMatrix.n13 = modelMatrix.n31;
			invModelMatrix.n21 = modelMatrix.n12;
			invModelMatrix.n22 = modelMatrix.n22;
			invModelMatrix.n23 = modelMatrix.n32;
			invModelMatrix.n31 = modelMatrix.n13;
			invModelMatrix.n32 = modelMatrix.n23;
			invModelMatrix.n33 = modelMatrix.n33;
			invModelMatrix.n14 = -(modelMatrix.n11 * modelMatrix.n14 + modelMatrix.n21 * modelMatrix.n24 + modelMatrix.n31 * modelMatrix.n34);
			invModelMatrix.n24 = -(modelMatrix.n12 * modelMatrix.n14 + modelMatrix.n22 * modelMatrix.n24 + modelMatrix.n32 * modelMatrix.n34);
			invModelMatrix.n34 = -(modelMatrix.n13 * modelMatrix.n14 + modelMatrix.n23 * modelMatrix.n24 + modelMatrix.n33 * modelMatrix.n34);
		}
		// --
		super.update( modelMatrix, p_bChanged );
	}

	/**
	* Updates the transform matrix of the current object/node before it is rendered.
	*/
	public function updateTransform():Void
	{
		if( changed )
		{
			m_oMatrix.n11 = _vSide.x * _oScale.x;
			m_oMatrix.n12 = _vUp.x * _oScale.y;
			m_oMatrix.n13 = _vOut.x * _oScale.z;
			m_oMatrix.n14 = _p.x;

			m_oMatrix.n21 = _vSide.y * _oScale.x;
			m_oMatrix.n22 = _vUp.y * _oScale.y;
			m_oMatrix.n23 = _vOut.y * _oScale.z;
			m_oMatrix.n24 = _p.y;

			m_oMatrix.n31 = _vSide.z * _oScale.x;
			m_oMatrix.n32 = _vUp.z * _oScale.y;
			m_oMatrix.n33 = _vOut.z * _oScale.z;
			m_oMatrix.n34 = _p.z;
			// -- normalization of the frame to make sure the rotation error will not become too big.
			_vOut.normalize();
			_vSide.normalize();
			_vUp.normalize();
		}
	}

	/**
	* Returns the position of this group or object.
	*
	* <p>Choose which coordinate system the returned position refers to, by passing a mode string:<br/>
	* The position is returned as a vector in one of the following:<br/>
	* If LOCAL, the position is coordinates of the parent frame.
	* If ABSOLUTE the position is in world coordinates
	* If CAMERA the position is relative to the camera's coordinate system.
	* Default value is LOCAL
	*
	* @return 	The position of the group or object
	*/
	public function getPosition( ?p_eMode:CoordinateSystem ):Point3D
	{
		var l_oPos:Point3D;
		if(p_eMode == null) p_eMode = LOCAL;
		switch( p_eMode ) {
		case LOCAL: l_oPos = new Point3D( _p.x, _p.y, _p.z );
		case CAMERA: l_oPos = new Point3D( viewMatrix.n14, viewMatrix.n24, viewMatrix.n34 );
		case ABSOLUTE: l_oPos = new Point3D( modelMatrix.n14, modelMatrix.n24, modelMatrix.n34 );
		}
		return l_oPos;
	}

	/**
	* Returns a string representation of this object
	*
	* @return	The fully qualified name of this class
	*/
	public override function toString():String
	{
			return "sandy.core.scenegraph.ATransformable";
	}

	private override function copy( src:Node, includeTransforms:Bool=false, includeGeometry:Bool=true ) : Void
	{
		if(!Std.is(src,ATransformable))
			throw "Invalid src";
		super.copy( src );
		var o:ATransformable = cast src;
		//--
		disable = o.disable;
		if(includeTransforms) {
			invModelMatrix = o.invModelMatrix.clone();
			m_oMatrix = o.m_oMatrix.clone();
			_vSide = o._vSide.clone();
			_vOut = o._vOut.clone();
			_vUp = o._vUp.clone();
			_nTilt = o._nTilt;
			_nYaw = o._nYaw;
			_nRoll = o._nRoll;
			_vRotation = (o._vRotation != null) ? o._vRotation.clone() : null;
			_vLookatDown = (o._vLookatDown != null) ? o._vLookatDown.clone() : null;
			_vLookAt = (o._vLookAt != null) ? o._vLookAt.clone() : null;
			_p = o._p.clone();
			_oScale = o._oScale.clone();
			m_tmpMt = o.m_tmpMt.clone();
		}
	}

	//
	private var m_oMatrix:Matrix4;
	// Side Orientation Point3D
	private var _vSide:Point3D;
	// view Orientation Point3D
	private var _vOut:Point3D;
	// up Orientation Point3D
	private var _vUp:Point3D;
	// current tilt value
	private var _nTilt:Float;
	// current yaw value
	private var _nYaw:Float;
	// current roll value
	private var _nRoll:Float;
	private var _vRotation:Point3D;
	private var _vLookatDown:Point3D; // Private absolute down vector
	private var _vLookAt:Point3D; // Last set value via lookAt() method; may not be valid if other camera movement has occurred since then.
	private var _p:Point3D;
	private var _oScale:Point3D;
	private var m_tmpMt:Matrix4; // temporary transform matrix used at updateTransform
// 	private var m_oPreviousOffsetRotation:Point3D;
}

