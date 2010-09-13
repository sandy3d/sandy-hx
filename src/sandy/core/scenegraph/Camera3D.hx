package sandy.core.scenegraph;
import flash.geom.Rectangle;

import sandy.core.Scene3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.util.NumberUtil;
import sandy.view.Frustum;
import sandy.view.ViewPort;

import sandy.HaxeTypes;

/**
* The Camera3D class is used to create a camera for the Sandy world.
*
* <p>As of this version of Sandy, the camera is added to the object tree,
* which means it is transformed in the same manner as any other object.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class Camera3D extends ATransformable
{
	/**
		* The camera viewport
		*/
	public var viewport:ViewPort;

	/**
		* The frustum of the camera.
		*/
	public var frustrum:Frustum;

	/**
		* Creates a camera for projecting visible objects in the world.
		*
		* <p>By default the camera shows a perspective projection. <br />
		* The camera is at -300 in z axis and look at the world 0,0,0 point.</p>
		*
		* @param p_nWidth	Width of the camera viewport in pixels
		* @param p_nHeight	Height of the camera viewport in pixels
		* @param p_nFov	The vertical angle of view in degrees - Default 45
		* @param p_nNear	The distance from the camera to the near clipping plane - Default 50
		* @param p_nFar	The distance from the camera to the far clipping plane - Default 10000
		*/
	public function new( ?p_nWidth:Int = 550, ?p_nHeight:Int = 400, ?p_nFov:Float = 45.0, ?p_nNear:Float = 50.0, ?p_nFar:Float = 10000.0 )
	{
		//private initializers
		_mp = new Matrix4();
		_mpInv = new Matrix4();
		//public initializers
		viewport = new ViewPort(640,480);
		frustrum = new Frustum();

		super( null );
		viewport.width = p_nWidth;
		viewport.height = p_nHeight;
		// --
		_nFov = p_nFov;
		_nFar = p_nFar;
		_nNear = p_nNear;
		// --
		setPerspectiveProjection( _nFov, viewport.ratio, _nNear, _nFar );
		m_nOffx = viewport.width2;
		m_nOffy = viewport.height2;
		// It's a non visible node
		visible = false;
		z = -300;
		lookAt( 0,0,0 );
	}

	/**
	* The angle of view of this camera in degrees.
	*/
	public var fov(__getFov,__setFov):Float;
	private function __setFov( p_nFov:Float ):Float
	{
		_nFov = p_nFov;
		_perspectiveChanged = true;
		changed = true;
		return p_nFov;
	}

	/**
	* @private
	*/
	private function __getFov():Float
	{return _nFov;}

	/**
	* Focal length of camera.
	*
	* <p>This value is a function of fov angle and viewport dimensions.
	* Writing this value changes fov angle only.</p>
	*/
	public var focalLength(__getFocalLength,__setFocalLength) : Float;
	private function __setFocalLength( f:Float ):Float
	{
		_nFov = Math.atan2 (viewport.height2, f) * 2. * (180. / Math.PI);
		_perspectiveChanged = true;
		changed = true;
		return f;
	}

	/**
		* @private
		*/
	private function __getFocalLength():Float
	{
		return viewport.height2 / Math.tan (_nFov * 0.5 * (Math.PI / 180.) );
	}

	/**
	* Near plane distance for culling/clipping.
	*/
	public var near(__getNear,__setNear):Float;
	private function __setNear( pNear:Float ):Float
	{_nNear = pNear; _perspectiveChanged = true; changed = true;return pNear;}

	/**
		* @private
		*/
	private function __getNear():Float
	{return _nNear;}

	/**
	* Far plane distance for culling/clipping.
	*/
	public var far(__getFar,__setFar) : Float;
	private function __setFar( pFar:Float ):Float
	{_nFar = pFar;_perspectiveChanged = true; changed = true;return pFar;}

	/**
		* @private
		*/
	private function __getFar():Float
	{return _nFar;}

	///////////////////////////////////////
	//// GRAPHICAL ELEMENTS MANAGMENT /////
	///////////////////////////////////////

	/**
	* <p>Project the vertices list given in parameter.
	* The vertices are projected to the screen, as a 2D position.
	* A cache system is used here to prevent multiple projection of the same vertex.
	* In case you want to redo a projection, prefer projectVertex method which doesn't use a cache system.
	* </p>
	*/
	public function projectArray( p_oList:Array<Vertex> ):Void
	{
		var l_nX:Float = viewport.offset.x + m_nOffx;
		var l_nY:Float = viewport.offset.y + m_nOffy;
		var l_nCste:Float;
		var l_mp11_offx:Float = mp11 * m_nOffx;
		var l_mp22_offy:Float = mp22 * m_nOffy;
		for ( l_oVertex in p_oList )
		{
			if( l_oVertex.projected == false )//(l_oVertex.flags & SandyFlags.VERTEX_PROJECTED) == 0)
			{
				l_nCste = 	1 / l_oVertex.wz;
				l_oVertex.sx =  l_nCste * l_oVertex.wx * l_mp11_offx + l_nX;
				l_oVertex.sy = -l_nCste * l_oVertex.wy * l_mp22_offy + l_nY;
				//l_oVertex.flags |= SandyFlags.VERTEX_PROJECTED;
				l_oVertex.projected = true;
			}
		}
	}

	/**
		* <p>Project the vertex passed as parameter.
		* The vertices are projected to the screen, as a 2D position.
		* </p>
		*/
	public function projectVertex( p_oVertex:Vertex ):Void
	{
		var l_nX:Float = (viewport.offset.x + m_nOffx);
		var l_nY:Float = (viewport.offset.y + m_nOffy);
		var l_nCste:Float = 1 / p_oVertex.wz;
		p_oVertex.sx =  l_nCste * p_oVertex.wx * mp11 * m_nOffx + l_nX;
		p_oVertex.sy = -l_nCste * p_oVertex.wy * mp22 * m_nOffy + l_nY;
		//p_oVertex.flags |= SandyFlags.VERTEX_PROJECTED;
		//p_oVertex.projected = true;
	}

	/**
		* Updates the state of the camera transformation.
		*
		* @param p_oModelMatrix The matrix which represents the parent model matrix. Basically it stores the rotation/translation/scale of all the nodes above the current one.
		* @param p_bChanged	A boolean value which specify if the state has changed since the previous rendering. If false, we save some matrix multiplication process.
		*/
	public override function update( p_oModelMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		if( viewport.hasChanged )
		{
			_perspectiveChanged = true;
			// -- update the local values
			m_nOffx = viewport.width2;
			m_nOffy = viewport.height2;
			// -- Apply a scrollRect to the container at the viewport dimension
			if( scene.rectClipping )
				scene.container.scrollRect = new Rectangle( 0, 0, viewport.width, viewport.height );
			else
				scene.container.scrollRect = null;
			// -- we warn the the modification has been taken under account
			viewport.hasChanged = false;
		}
		// --
		if( _perspectiveChanged ) updatePerspective();
		super.update( p_oModelMatrix, p_bChanged );
	}

	/**
		* Nothing to do - the camera can't be culled
		*/
	public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		return;
	}

	/**
	* Returns the projection matrix of this camera.
	*
	* @return 	The projection matrix
	*/
	public var projectionMatrix(__getProjectionMatrix,null) : Matrix4;
	private function __getProjectionMatrix():Matrix4
	{
		return _mp;
	}

	/**
	* Returns the inverse of the projection matrix of this camera.
	*
	* @return 	The inverted projection matrix
	*/
	public var invProjectionMatrix(__getinvProjectionMatrix,null):Matrix4;
	private function __getinvProjectionMatrix():Matrix4
	{
		_mpInv.copy( _mp );
		_mpInv.inverse();

		return _mpInv;
	}

	/**
	* Sets a projection matrix with perspective.
	*
	* <p>This projection allows a natural visual presentation of objects, mimicking 3D perspective.</p>
	*
	* @param p_nFovY 	The angle of view in degrees - Default 45.
	* @param p_nAspectRatio The ratio between vertical and horizontal dimension - Default the viewport ratio (width/height)
	* @param p_nZNear 	The distance betweeen the camera and the near plane - Default 10.
	* @param p_nZFar 	The distance betweeen the camera position and the far plane. Default 10 000.
	*/
	private function setPerspectiveProjection(p_nFovY:Float, p_nAspectRatio:Float, p_nZNear:Float, p_nZFar:Float):Void
	{
		var cotan:Float, Q:Float;
		// --
		frustrum.computePlanes(p_nAspectRatio, p_nZNear, p_nZFar, p_nFovY );
		// --
		p_nFovY = NumberUtil.toRadian( p_nFovY );
		cotan = 1 / Math.tan(p_nFovY / 2);
		Q = p_nZFar/(p_nZFar - p_nZNear);

		_mp.zero();

		_mp.n11 = cotan / p_nAspectRatio;
		_mp.n22 = cotan;
		_mp.n33 = Q;
		_mp.n34 = -Q*p_nZNear;
		_mp.n43 = 1;
		// to optimize later
		mp11 = _mp.n11; mp21 = _mp.n21; mp31 = _mp.n31; mp41 = _mp.n41;
		mp12 = _mp.n12; mp22 = _mp.n22; mp32 = _mp.n32; mp42 = _mp.n42;
		mp13 = _mp.n13; mp23 = _mp.n23; mp33 = _mp.n33; mp43 = _mp.n43;
		mp14 = _mp.n14; mp24 = _mp.n24; mp34 = _mp.n34; mp44 = _mp.n44;

		changed = true;
	}

	/**
		* Updates the perspective projection.
		*/
	private function updatePerspective():Void
	{
		setPerspectiveProjection( _nFov, viewport.ratio, _nNear, _nFar );
		_perspectiveChanged = false;
	}

	/**
		* Delete the camera node and clear its displaylist.
		*
		*/
	public override function destroy():Void
	{
		viewport = null;
		frustrum = null;
		_mp = null;
		_mpInv = null;
		// --
		super.destroy();
	}

	public override function toString():String
	{
		return "sandy.core.scenegraph.Camera3D";
	}

	//////////////////////////
	/// PRIVATE PROPERTIES ///
	//////////////////////////
	private var _perspectiveChanged:Bool;
	private var _mp:Matrix4; // projection Matrix4
	private var _mpInv:Matrix4; // Inverse of the projection matrix
	private var _nFov:Float;
	private var _nFar:Float;
	private var _nNear:Float;

	private var mp11:Float;private var mp21:Float;private var mp31:Float;private var mp41:Float;
	private var mp12:Float;private var mp22:Float;private var mp32:Float;private var mp42:Float;
	private var mp13:Float;private var mp23:Float;private var mp33:Float;private var mp43:Float;
	private var mp14:Float;private var mp24:Float;private var mp34:Float;private var mp44:Float;
	private var	m_nOffx:Float;private var m_nOffy:Float;

}
