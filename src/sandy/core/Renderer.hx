package sandy.core;
import flash.display.Sprite;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Polygon;
import sandy.core.data.Pool;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.IDisplayable;
import sandy.core.scenegraph.Renderable;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.Sprite2D;
import sandy.util.ArrayUtil;
import sandy.view.CullingState;
import sandy.view.Frustum;

import sandy.HaxeTypes;

/**
* This class is design to handle the rendering processing of a Sandy3D scene.
* Basically, it collects elemens to render, prepare their matrix, project vertices.
*
* It also manage the cache system. It means it handle the fact that any non moving object isn't rendered.
*
* @author thomas
* @author Russell Weir - haXe port
* @version 3.1
*/
class Renderer
{
	private var m_aDisplayList:Array<IDisplayable>;
	private var m_nDisplayListCount:Int;
	private var m_aCamera:Camera3D;

	private var m_aRenderingList:Array<IDisplayable>;
	private var m_nRenderingListCount:Int;
	private var pool:Pool;

	private var m_bGlobalRedraw:Bool;

	/**
	* Default renderer.
	*/
	public function new()
	{
		//private initializers
		m_aDisplayList = new Array();
		m_aRenderingList = new Array();
		pool = Pool.getInstance();

		m_nRenderingListCount = 0;
		m_nDisplayListCount = 0;
	}

	/**
	* Init the renderer internal data
	*/
	public function init():Void
	{
		m_nDisplayListCount = 0;
		m_bGlobalRedraw = false;
	}

	/**
	* Process the rendering of the scene.
	* The camera has all the information needed about the objects to render.
	*
	* The camera stores all the visible shape/polygons into an array, and loop through it calling their display method.
	* Before the display call, the container graphics is cleared.
	*
	* @param p_oScene The Scene3D object to render
	*/
	public function renderDisplayList( p_oScene:Scene3D ):Void
	{
		var l_mcContainer:Sprite = p_oScene.container;
		// --
		ArrayUtil.sortOnLite(m_aRenderingList,["m_nDepth"], ArrayUtil.SORT_NUMERIC | ArrayUtil.SORT_DESCENDING);

		// -- This is the new list to be displayed.
		var l_oFace:IDisplayable;
		for( i in 0 ... m_nRenderingListCount )
		{
			l_oFace = m_aRenderingList[i];
			if( l_oFace.changed || ((l_oFace.material != null)?l_oFace.material.modified:false) || p_oScene.camera.changed )
			{
				l_oFace.display();
			}
			// --
			if( i < l_mcContainer.numChildren )
			{
				if( l_mcContainer.getChildAt(i) != l_oFace.container )
				{
					l_mcContainer.addChildAt( l_oFace.container, i );
				}
			}
			else
			{
				l_mcContainer.addChildAt( l_oFace.container, i );
			}
		}
	}

	public function addToDisplayList( p_oObject:IDisplayable ):Void
	{
		m_aDisplayList[m_nDisplayListCount++] = p_oObject;
		m_bGlobalRedraw = m_bGlobalRedraw || p_oObject.changed || ((p_oObject.material != null)?p_oObject.material.modified:false);
	}

	public function removeFromDisplayList( p_oObject:IDisplayable ):Void
	{
		p_oObject.clear();
		var l_nKey : Int = -1;
		Lambda.mapi( m_aDisplayList, function (i, v) { l_nKey = ( p_oObject == v ) ? i : l_nKey; return null;} );
		if( l_nKey > -1 )
			m_aDisplayList.splice( l_nKey, 1 );
	}

	/**
	* Render the given scene.
	* Objects are transformed, clipped and projected into that function.
	*
	* @param p_bUseCache Bool value, default to true, use a cache system to aVoid unnecessary computation
	*/
	public function render( p_oScene:Scene3D, p_bUseCache:Bool = true ):Bool
	{
		var 	m11:Float, m21:Float, m31:Float,
				m12:Float, m22:Float, m32:Float,
				m13:Float, m23:Float, m33:Float,
				m14:Float, m24:Float, m34:Float,
				x:Float, y:Float, z:Float;
		var		l_oCamera:Camera3D = p_oScene.camera;
		var  	l_nZNear:Float = l_oCamera.near, l_oCamPos:Point3D = pool.nextPoint3D, l_nPolyFlags:Int = 0,
				l_oMatrix:Matrix4, l_oFrustum:Frustum = l_oCamera.frustrum,
				l_oVertex:Vertex, l_aVertices:Array<Vertex>, l_oFace:Polygon, l_nMinZ:Float, l_nFlags:Int;
		var 	l_nVisiblePolyCount:Int = 0;

		var l_bForceRedraw:Bool = p_oScene.camera.changed || !p_bUseCache || p_oScene.light.changed;

		m_bGlobalRedraw = m_bGlobalRedraw || (m_aRenderingList.length == m_aDisplayList.length);
		// -- return false because we do not even need to refresh display
		if( m_bGlobalRedraw == false && l_bForceRedraw == false )
			return false;
		// -- this is the displayed list from the previous iteration, but all flags are updated

		for( l_oObj in m_aRenderingList )
		{
			if( l_oObj != null )
			{
				if( l_bForceRedraw == true || ((l_oObj.material != null)?l_oObj.material.modified:false) || l_oObj.changed == true )
				{
					l_oObj.clear();
				}
			}
		}

		// --
		m_nRenderingListCount = 0;
		ArrayUtil.truncate(m_aRenderingList);
		// --
		for( i in 0...m_nDisplayListCount )
		{
			if( Std.is(m_aDisplayList[i], Shape3D) )
			{
				var l_oShape:Shape3D = cast m_aDisplayList[i];
				var l_oShapeSingleContainer:Bool = l_oShape.useSingleContainer;
				// if no change for that object, directly go to the draw level
				if( l_oShape.changed == false && l_bForceRedraw == false )
				{
					if( l_oShapeSingleContainer )
						m_aRenderingList[m_nRenderingListCount++] = l_oShape;
					else
					{
						for( l_oFace in l_oShape.aVisiblePolygons )
							m_aRenderingList[m_nRenderingListCount++] = l_oFace;
					}
					continue;
				}
				// --
				l_nFlags = l_oShape.appearance.flags;
				l_oShape.depth = 0;
				ArrayUtil.truncate(l_oShape.aVisiblePolygons);
				l_oCamPos.reset(l_oCamera.modelMatrix.n14, l_oCamera.modelMatrix.n24, l_oCamera.modelMatrix.n34);
				l_oShape.invModelMatrix.transform( l_oCamPos );
				// --
				l_oMatrix = l_oShape.viewMatrix;
				m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31;
				m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32;
				m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33;
				m14 = l_oMatrix.n14; m24 = l_oMatrix.n24; m34 = l_oMatrix.n34;
				// --
				var l_bClipped:Bool = ((l_oShape.culled == CullingState.INTERSECT) && ( l_oShape.enableClipping || l_oShape.enableNearClipping ));
				// --
				for ( l_oVertex in l_oShape.geometry.aVertex )
				{
					l_oVertex.projected = l_oVertex.transformed = false;
				}
				// --
				for ( l_oFace in l_oShape.aPolygons )
				{
					if( l_oShape.animated )
						l_oFace.updateNormal();
					// -- visibility test
					l_oVertex = l_oFace.normal;
					x = l_oFace.a.x; y = l_oFace.a.y; z = l_oFace.a.z;
					l_oFace.visible = (l_oVertex.x*( l_oCamPos.x - x) + l_oVertex.y*( l_oCamPos.y - y) + l_oVertex.z*( l_oCamPos.z - z)) > 0;
					// --
					if( l_oShape.enableBackFaceCulling )
					{
						if( l_oFace.visible == false )
							continue;
					}
					// --
					l_oVertex = l_oFace.a;
					if( l_oVertex.transformed == false )// (l_oVertex.flags & SandyFlags.VERTEX_CAMERA) == 0)
					{
						l_oVertex.wx = (x) * m11 + (y) * m12 + (z) * m13 + m14;
						l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
						l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
						//l_oVertex.flags |= SandyFlags.VERTEX_CAMERA;
						l_oVertex.transformed = true;
					}

					l_oVertex = l_oFace.b;
					if( l_oVertex.transformed == false )// (l_oVertex.flags & SandyFlags.VERTEX_CAMERA) == 0)
					{
						l_oVertex.wx = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13 + m14;
						l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
						l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
						//l_oVertex.flags |= SandyFlags.VERTEX_CAMERA;
						l_oVertex.transformed = true;
					}

					l_oVertex = l_oFace.c;
					if( l_oVertex != null )
					{
						if( l_oVertex.transformed == false )//(l_oVertex.flags & SandyFlags.VERTEX_CAMERA) == 0)
						{
							l_oVertex.wx = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13 + m14;
							l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
							l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
							//l_oVertex.flags |= SandyFlags.VERTEX_CAMERA;
							l_oVertex.transformed = true;
						}
					}

					l_oVertex = l_oFace.d;
					if( l_oVertex != null )
					{
						if( l_oVertex.transformed == false )
						{
							l_oVertex.wx = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13 + m14;
							l_oVertex.wy = x * m21 + y * m22 + z * m23 + m24;
							l_oVertex.wz = x * m31 + y * m32 + z * m33 + m34;
							l_oVertex.transformed = true;
						}
					}

					// --
					l_oFace.precompute();
					l_nMinZ = l_oFace.minZ;
					// -- culling/clipping phasis
					if( l_bClipped )
					{
						if( l_oShape.enableClipping ) // NEED COMPLETE CLIPPING
						{
							l_oFace.clip( l_oFrustum );
						}
						else if( l_oShape.enableNearClipping && l_nMinZ < l_nZNear ) // PARTIALLY VISIBLE
						{
							l_oFace.clipFrontPlane( l_oFrustum );
						}
						else if( l_nMinZ < l_nZNear )
						{
							continue;
						}
					}
					else if( l_nMinZ < l_nZNear )
					{
						continue;
					}
					// --
					var l_bIsClipped = l_oFace.isClipped;
					l_aVertices = l_bIsClipped ? l_oFace.cvertices : l_oFace.vertices;
					if( l_aVertices.length > 1 )
					{
						l_oCamera.projectArray( l_aVertices );
						// Fix for clipped triangles incorrectly reporting vertices position during interaction events
						if ( l_bIsClipped && l_oFace.enableEvents )
							l_oCamera.projectArray( l_oFace.vertices );

						if (l_oShape.enableForcedDepth) {
							if (l_oShapeSingleContainer == false)
								l_oFace.depth = l_oShape.forcedDepth;
						} else
							l_oShape.depth += l_oFace.depth;
						// --
						l_nVisiblePolyCount++;
						l_oShape.aVisiblePolygons[l_oShape.aVisiblePolygons.length] = l_oFace;
						// --
						l_nPolyFlags |= l_nFlags;
						// --
						if( l_oShapeSingleContainer == false )
						{
						    m_aRenderingList[m_nRenderingListCount++] = l_oFace;
						}
					}
				}
				// --
				if( l_oShape.aVisiblePolygons.length > 0 )
				{
					if( l_oShape.useSingleContainer == true )
					{
						if(l_oShape.enableForcedDepth)
							l_oShape.depth = l_oShape.forcedDepth;
						else
							l_oShape.depth /= l_oShape.aVisiblePolygons.length;
						// --
						m_aRenderingList[m_nRenderingListCount++] = l_oShape;
					}
					else
					{
						if (l_oShape.enableForcedDepth == false)
							l_oShape.depth /= l_oShape.aVisiblePolygons.length;
					}
					// --
					if( l_nFlags != 0 || l_nPolyFlags != 0 )
					{
						if( ((l_nFlags | l_nPolyFlags) & SandyFlags.POLYGON_NORMAL_WORLD) != 0 )
						{
							l_oMatrix = l_oShape.modelMatrix;
							m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31;
							m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32;
							m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33;
							// -- Now we transform the normals.
							for ( l_oFace in l_oShape.aVisiblePolygons )
							{
								l_oVertex = l_oFace.normal;
								l_oVertex.wx  = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13;
								l_oVertex.wy  = x * m21 + y * m22 + z * m23;
								l_oVertex.wz  = x * m31 + y * m32 + z * m33;
							}
						}
						if( ((l_nFlags | l_nPolyFlags) & SandyFlags.VERTEX_NORMAL_WORLD) != 0 )
						{
							l_oMatrix = l_oShape.modelMatrix;
							m11 = l_oMatrix.n11; m21 = l_oMatrix.n21; m31 = l_oMatrix.n31;
							m12 = l_oMatrix.n12; m22 = l_oMatrix.n22; m32 = l_oMatrix.n32;
							m13 = l_oMatrix.n13; m23 = l_oMatrix.n23; m33 = l_oMatrix.n33;
							// -- Now we transform the normals.
							for ( l_oVertex in l_oShape.geometry.aVertexNormals )
							{
								l_oVertex.wx  = (x=l_oVertex.x) * m11 + (y=l_oVertex.y) * m12 + (z=l_oVertex.z) * m13;
								l_oVertex.wy  = x * m21 + y * m22 + z * m23;
								l_oVertex.wz  = x * m31 + y * m32 + z * m33;
							}
						}
					}
				}
			}
			else if( Std.is(m_aDisplayList[i], Sprite2D) )
			{
				var l_oSprite2D:Sprite2D = cast m_aDisplayList[i];
				l_oSprite2D.v.projected = false;
				l_oSprite2D.vx.projected = false;
				l_oSprite2D.vy.projected = false;

				l_oVertex = l_oSprite2D.v;
				l_oMatrix = l_oSprite2D.viewMatrix;
				l_oVertex.wx = l_oVertex.x * l_oMatrix.n11 + l_oVertex.y * l_oMatrix.n12 + l_oVertex.z * l_oMatrix.n13 + l_oMatrix.n14;
				l_oVertex.wy = l_oVertex.x * l_oMatrix.n21 + l_oVertex.y * l_oMatrix.n22 + l_oVertex.z * l_oMatrix.n23 + l_oMatrix.n24;
				l_oVertex.wz = l_oVertex.x * l_oMatrix.n31 + l_oVertex.y * l_oMatrix.n32 + l_oVertex.z * l_oMatrix.n33 + l_oMatrix.n34;

				l_oSprite2D.depth = l_oSprite2D.enableForcedDepth ? l_oSprite2D.forcedDepth : l_oVertex.wz;

				l_oCamera.projectVertex( l_oVertex );
				m_aRenderingList[m_nRenderingListCount++] = l_oSprite2D;

				l_oSprite2D.vx.copy (l_oVertex); l_oSprite2D.vx.wx++; l_oCamera.projectVertex (l_oSprite2D.vx);
				l_oSprite2D.vy.copy (l_oVertex); l_oSprite2D.vy.wy++; l_oCamera.projectVertex (l_oSprite2D.vy);
			}
			else if( Std.is(m_aDisplayList[i], Renderable) )
			{
				var r:Renderable = cast m_aDisplayList[i];
				r.render(l_oCamera);
				m_aRenderingList[m_nRenderingListCount++] = m_aDisplayList[i];
			}
		}
		// true because need need to refresh display
		return true;
	}
}
