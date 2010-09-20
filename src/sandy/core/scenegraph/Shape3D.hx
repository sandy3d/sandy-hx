
package sandy.core.scenegraph;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

#if js
import Html5Dom;
#end

import sandy.bounds.BBox;
import sandy.bounds.BSphere;
import sandy.core.Scene3D;
import sandy.core.data.BSPNode;
import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Polygon;
import sandy.core.data.UVCoord;
import sandy.core.data.Vertex;
import sandy.events.BubbleEvent;
import sandy.events.Shape3DEvent;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.WireFrameMaterial;
import sandy.math.IntersectionMath;
import sandy.view.CullingState;
import sandy.view.Frustum;
import sandy.util.ArrayUtil;

import sandy.HaxeTypes;

/**
* The Shape3D class is the base class of all true 3D shapes.
*
* <p>It represents a node in the object tree of the world.<br/>
* A Shape3D is a leaf node and can not have any child nodes.</p>
* <p>It must be the child of a branch group or a transform group,
* but transformations can be applied to the Shape directly.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author Niel Drummond - haXe port
* @author Russell Weir - haXe port
*
*/
class Shape3D extends ATransformable, implements IDisplayable
{
	/**
	* Animated flag.
	* <p>If the geometry vertices are dynamically modified by some animation engine or mathematic function, some polygon may disapear with no reason.
	* The normal Point3D is used to compute the polygon visibility, and if you don't update the normal Point3D after the vertices modifications, there's an error.
	* To fix that problem, Sandy3D offers that new property appeared in 3.0.3 release, which once set to true, automatically update the normal Point3Ds for you.
	* As a performance warning, don't set this value to true if your model geometry isn't animated.</p>
	*/
	public var animated:Bool;
	/**
	* The array of polygons building this object.
	*/
	public var aPolygons:Array<Polygon>;
	/**
	* Array containing the visible polygons of that shape.
	* Contente is available after the SCENE_RENDER_DISPLAYLIST
	* event of the current scene has been dispatched
	*/
	public var aVisiblePolygons(default,null) : Array<Polygon>;
	/**
	* The container for this object.
	* This container property exist if the useSingleContainer is set to true.
	* It is a direct access to the Shape3D container to, for example, apply nice effects such as filters etc.
	*/
	public var container(__getContainer,null):Sprite;
	/**
	* The depth of this object.
	* In case the useSingleContainer mode is enabled (default mode), this
	* value returns the means depth of the Shape in the camera frame.
	* This value is mainly used as a z-sorting value.
	*/
	public var depth(__getDepth,__setDepth):Float;
	/**
	* <p>
	* Enable the Frustum clipping on the visible polygons.
	* Enable this when you need a perfect intersection between the camera and some object shapes.
	* In case you need to make the camera look inside and outide a box, or other immerssive things.</p>
	*
	* <p>Important: Enable the clipping makes process a bit slower, especially with big scenes.</p>
	*
	* <p>Specify if this object polygons should be clipped against the camera frustum planes.</p>
	*/
	public var enableClipping(__getEnableClipping,__setEnableClipping):Bool;
	/**
	* Should forced depth be enable for this object?.
	*
	* <p>If true it is possible to force this object to be drawn at a specific depth,<br/>
	* if false the normal Z-sorting algorithm is applied.</p>
	* <p>When correctly used, this feature allows you to aVoid some Z-sorting problems.</p>
	*/
	public var enableForcedDepth:Bool;
	/**
	* <p>
	* Enable the Frustum near plane clipping on the visible polygons.
	* Enable this when you need a perfect intersection between the front camera plane.
	* This is mainly used when you need the camera to move on a long plane.</p>
	*
	* <p>Important: Enable the clipping makes process a bit slower, especially with big scenes.</p>
	*/
	public var enableNearClipping:Bool;
	/**
	* The forced depth for this object.
	*
	* <p>To make this feature work, you must enable the ForcedDepth system too.<br/>
	* The higher the depth is, the sooner the more far the object will be represented.</p>
	*/
	public var forcedDepth:Float;
	/**
	* The geometry of this object.
	*/
	public var geometry(__getGeometry,__setGeometry):Geometry3D;
	/**
	* Change the geometryCenter of the Shape3D.
	* To change the geometryCenter point of a shape, simply set this geometryCenter property.
	* The geometryCenter property requires a Point3D. This Point3D is an position offset relative to the original geometry one.
	* For example, a Sphere primitive creates automatically a geometry which center is the 0,0,0 position. If you rotate this sphere as this,
	* it will rotate around its center.
	* Now if you set the geometryCenter property, this rotation center will change.
	*
	* The updateBoundingVolumes method which does update the bounding volumes to enable a correct frustum culling is automatically called.
	*
	* @example To change the geometryCenter center at runtime
	* <listing version="3.1">
	*    var l_oSphere:Sphere = new Sphere("mySphere", 50, 3 );
	*    // Change the rotation reference to -50 offset in Y direction from the orinal one
	*    // and that corresponds to the bottom of the sphere
	*    l_oSphere.geometryCenter = new Point3D( 0, -50, 0 );
	*    l_oSphere.rotateZ = 45;
	* </listing>
	*/
	public var geometryCenter(__getGeometryCenter,__setGeometryCenter):Point3D;
	/**
	* Returns the material currently used by the renderer
	* @return Material the material used to render
	*/
	public var material(__getMaterial,__setMaterial):Material;

	/**
	 * No sorting.
	 * Only convex shapes are guaranteed to display correctly in this mode.
	 */
	public static inline var SORT_NONE:Int = 0;

	/**
	 * Average distance sorting.
	 * Default sorting mode.
	 * Carefully designed models will display just fine, but ordering problems are common.
	 * This is also the only possible sorting mode with <code>useSingleContainer</code> set to <code>false</code>.
	 */
	public static inline var SORT_AVGZ:Int = 1;

	/**
	 * In this mode mesh is sorted using BSP tree, but no faces are split for you (means sorting problems are still possible).
	 * Experimental.
	 */
	public static inline var SORT_LAZY_BSP:Int = 2;

	/**
	 * In this mode mesh is sorted using BSP tree, but no tree is built for you (you need to set <code>bsp</code> property yourself).
	 * Experimental.
	 */
	public static inline var SORT_CUSTOM_BSP:Int = 3;

	/**
	 * Root node of BSP tree.
	 */
	public var bsp:BSPNode;

	#if (js && SANDY_WEBGL)
	public var vertexPositionBuffer(default,null):WebGLBuffer;
	public var texCoordBuffer(default,null):WebGLBuffer;
	public var indicesBuffer(default,null):WebGLBuffer;
	public var shaderProgram(default,null):WebGLProgram;
	#end

	/**
	* Creates a 3D object
	*
	* <p>This creates a new 3D geometry object. That object will handle the rendering of a static Geometry3D object into a real 3D object and finally to the 2D camera representation.</p>
	*
	* @param p_sName		A string identifier for this object
	* @param p_oGeometry		The geometry of this object
	* @param p_oAppearance		The appearance of this object. If no apperance is given, the DEFAULT_APPEARANCE will be applied.
	* @param p_bUseSingleContainer	Whether tis object should use a single container to draw on
	*/
	public function new( ?p_sName:String = "", ?p_oGeometry:Geometry3D, ?p_oAppearance:Appearance, ?p_bUseSingleContainer:Bool=true )
	{
		// public initializers
		aPolygons = new Array();
		enableNearClipping = false;
		enableClipping = false;
		enableForcedDepth = false;
		forcedDepth = 0;
		animated = false;
		aVisiblePolygons = new Array();
		// private initializers
		m_bEv = false;
		m_oGeomCenter = new Point3D();
		m_bBackFaceCulling = true;
		m_bWasOver = false;
		m_bUseSingleContainer = true;
		m_nDepth = 0;
		m_bMouseInteractivity = false;
		m_bForcedSingleContainer = false;
		m_nSortingMode = SORT_AVGZ;

		super( p_sName );
		// -- Add this graphical object to the World display list
		m_oContainer = new Sprite();
		m_oContainer.name = name;
		// --
		geometry = p_oGeometry;
		// -- HACK to make sure that the correct container system will be applied
		m_bUseSingleContainer = !p_bUseSingleContainer;
		#if (js && SANDY_WEBGL)
		// -- useSingleContainer is forced on openGL, because polygon-based occlusion is not yet implemented here
		if (Lib.mOpenGL)
		{
			useSingleContainer = true;
		} else
		#end
		useSingleContainer = p_bUseSingleContainer;
		// --
		appearance = ( p_oAppearance != null ) ? p_oAppearance : new Appearance( new WireFrameMaterial() );
		// --
		updateBoundingVolumes();
	}


	/**
	* Clears the graphics object of this object's container.
	*
	* <p>The the graphics that were drawn on the Graphics object is erased,
	* and the fill and line style settings are reset.</p>
	*/
	public function clear():Void
	{
		if( m_oContainer != null )
			m_oContainer.graphics.clear();
		changed = true;
	}

	/**
	* This method returns a clone of this Shape3D.
	* The current appearance will be applied, and the geometry is cloned (not referenced to curent one).
	*
	* @param p_sName The name of the new shape you are going to create
	* @param p_bKeepTransform Boolean value which, if set to true, applies the current local transformations to the cloned shape. Default value is false.
	*
	* @return 	The clone
	*/
	public function clone( ?p_sName:String = "", ?p_bKeepTransform:Bool=false ):Shape3D
	{
		var o = new Shape3D( p_sName, null, appearance, m_bUseSingleContainer);
		o.copy(this, p_bKeepTransform);
		return o;
	}

	/**
	* Tests this node against the camera frustum to get its visibility.
	*
	* <p>If this node and its children are not within the frustum,
	* the node is set to cull and it would not be displayed.<p/>
	* <p>The method also updates the bounding volumes to make the more accurate culling system possible.<br/>
	* First the bounding sphere is updated, and if intersecting,
	* the bounding box is updated to perform the more precise culling.</p>
	* <p><b>[MANDATORY] The update method must be called first!</b></p>
	*
	* @param p_oScene The current scene
	* @param p_oFrustum	The frustum of the current camera
	* @param p_oViewMatrix	The view martix of the curren camera
	* @param p_bChanged
	*/
	public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		super.cull( p_oFrustum, p_oViewMatrix, p_bChanged );
		if( culled == Frustum.OUTSIDE ) return;
		/////////////////////////
		//// BOUNDING SPHERE ////
		/////////////////////////
		boundingSphere.transform( viewMatrix );
		culled = p_oFrustum.sphereInFrustum( boundingSphere );
		// --
		if( culled == Frustum.INTERSECT )
		{
			////////////////////////
			////  BOUNDING BOX  ////
			////////////////////////
			culled = p_oFrustum.boxInFrustum( boundingBox.transform( viewMatrix ) );
		}
		// --
		if( culled != CullingState.OUTSIDE && m_oAppearance != null )
		{
			scene.renderer.addToDisplayList(this);
		}
		if( m_bEv || m_bMouseInteractivity )
		{
			if( m_bWasOver == true && m_oLastContainer.hitTestPoint(m_oLastContainer.mouseX, m_oLastContainer.mouseY) == false )
			{
				m_oEB.dispatchEvent( new Shape3DEvent( MouseEvent.MOUSE_OUT, this, m_oLastEvent.polygon, m_oLastEvent.uv, m_oLastEvent.point, m_oLastEvent.event ) );
				m_bWasOver = false;
				if( m_oLastContainer != m_oContainer )
				{
					m_oLastEvent.polygon._onTextureInteraction( m_oLastEvent.event );
					m_oLastEvent.polygon._stopMouseInteraction();
				}
			}
		}
	}

	/**
	* Performs a z-sorting and renders the objects visible polygons.
	*
	* <p>The method is called only if the object renders on a single container<br/>
	* - ( useSingleContainer = true ).</p>
	*
	* @param p_oScene The current scene
	* @param p_oContainer	The container to draw on
	*/
	public function display( ?p_oContainer:Sprite  ):Void
	{

		#if (js && SANDY_WEBGL)
		if (Lib.mOpenGL) 
		{
			var gl : WebGLRenderingContext = jeash.Lib.canvas.getContext(jeash.Lib.context);

			m_oContainer.graphics.mShaderGL = m_oAppearance.frontMaterial.m_oShaderGL;
			var _v = scene.camera.invModelMatrix.clone();
			var _m = invModelMatrix.clone();
			_v.multiply( _m );

			m_oContainer.viewMatrix = _v.toGL();

		} else
		#end

		// -- 

		// not using static consts here for speed
		if (m_nSortingMode < SORT_LAZY_BSP ) {
			// old sorting methods
			if ((m_nSortingMode == SORT_AVGZ ) || (m_bBackFaceCulling == false)) {
				ArrayUtil.sortOnLite(aVisiblePolygons,["m_nDepth"],ArrayUtil.SORT_NUMERIC | ArrayUtil.SORT_DESCENDING);
			}
			
			for (l_oFace in aVisiblePolygons)
				l_oFace.display (m_oContainer);
		} else {
			// new experimental BSP sorting
			var camPt:Point3D = new Point3D (
				scene.camera.modelMatrix.n14,
				scene.camera.modelMatrix.n24,
				scene.camera.modelMatrix.n34
			); // cam -> world
			invModelMatrix.transform (camPt); // world -> local
			displayBSPTree (bsp, camPt);
		}

	}

	private function displayBSPTree (tree:BSPNode, camPt:Point3D):Void {
		var face:Polygon;
		var dist:Float = tree.plane.a * camPt.x + tree.plane.b * camPt.y + tree.plane.c * camPt.z + tree.plane.d;
		if (dist > 0) {
			// display negative, this, positive
			if (tree.negative != null)
				displayBSPTree (tree.negative, camPt);
			for (face in tree.faces)
				if (face.visible) // aVisiblePolygons.indexOf?
					face.display (m_oContainer);
			if (tree.positive != null)
				displayBSPTree (tree.positive, camPt);
		} else {
			// display positive, this, negative
			if (tree.positive != null)
				displayBSPTree (tree.positive, camPt);
			for (face in tree.faces)
				if (face.visible) // aVisiblePolygons.indexOf?
					face.display (m_oContainer);
			if (tree.negative != null)
				displayBSPTree (tree.negative, camPt);
		}
	}

	/**
	* Destroy this object and all its faces
	* container object is removed, and graphics cleared.  All polygons have their
	*/
	public override function destroy():Void
	{
		// 	FIXME Fix it - it should be more like
		if( m_oGeometry != null ) m_oGeometry.dispose();
		if( m_oAppearance != null ) m_oAppearance.dispose();
		// --
		clear();
		if( m_oContainer != null )
		{
			if( m_oContainer.parent != null ) m_oContainer.parent.removeChild( m_oContainer );
			m_oContainer = null;
		}
		// --
		__destroyPolygons();
		m_oGeometry = null;
		aVisiblePolygons = null;
		aPolygons = null;
		boundingBox = null;
		boundingSphere = null;
		// --
		super.destroy();
	}

	/**
	 * Sets SORT_NONE or SORT_AVGZ sorting mode. Deprecated.
	 * @internal this is now here for backward compatibility only.
	*/
	public function setConvexFlag (convex:Bool):Void
	{
		sortingMode = convex ? SORT_NONE : SORT_AVGZ;
	}

	/**
	* Changes the backface culling side.
	*
	* When you want to display a cube and you are outside the cube, you see its external faces.<br/>
	* The internal faces are not drawn due to back face culling
	*
	* In case you are inside the cube, by default Sandy's engine still doesn't draw the internal faces
	* (because you should not be in there).
	*
	* If you need to be only inside the cube, you can call this method to change which side is culled.
	* The faces will be visible only from the interior of the cube.
	*
	* If you want to be both on the inside and the outside, you want to make the faces visible from on both sides.
	* In that case you just have to set enableBackFaceCulling to false.
	*/
	public function swapCulling():Void
	{
		for( v in aPolygons )
		{
			v.swapCulling();
		}
		changed = true;
	}

	/**
	* Returns a string representation of this object
	*
	* @return	The fully qualified name of this object and its geometry
	*/
	public override function toString ():String
	{
		return "sandy.core.scenegraph.Shape3D" + " " +  m_oGeometry.toString();
	}

	/**
	* Updates the bounding volumes of this object.
	*/
	public override function updateBoundingVolumes():Void
	{
		if( m_oGeometry != null )
		{
			boundingBox	= BBox.create( m_oGeometry.aVertex );
			boundingSphere.resetFromBox(boundingBox);
			if( parent != null )
				parent.onChildBoundsChanged(this);
		}
	}

	/////////////////////////////////////////////////////////////////////
	/////                     Getters / Setters                     /////
	/////////////////////////////////////////////////////////////////////

	// appearance
	private override function __getAppearance():Appearance
	{
		return m_oAppearance;
	}
	private override function __setAppearance( p_oApp:Appearance ):Appearance
	{
		// Now we register to the update event
		m_oAppearance = p_oApp;
		// --

		if( m_oGeometry != null )
		{
			for ( v in aPolygons )
				v.appearance = m_oAppearance;
		}

		changed = true;
		return p_oApp;
	}

	// container
	private function __getContainer():Sprite
	{
		return m_oContainer;
	}

	// depth
	private function __getDepth():Float
	{
		return m_nDepth;
	}
	private function __setDepth( p_nDepth:Float ):Float
	{
		m_nDepth = p_nDepth;
		changed = true;
		return p_nDepth;
	}

	// enableBackFaceCulling
	private override function __getEnableBackFaceCulling():Bool
	{
		return m_bBackFaceCulling;
	}
	private override function __setEnableBackFaceCulling( b:Bool ):Bool
	{
		if( b != m_bBackFaceCulling )
		{
			m_bBackFaceCulling = b;
			changed = true;
		}
		return b;
	}

	// enableClipping
	private function __getEnableClipping():Bool
	{
		return m_bClipping;
	}
	private override function __setEnableClipping( p_bClippingValue:Bool ):Bool
	{
		m_bClipping = p_bClippingValue;
		return p_bClippingValue;
	}

	// enableEvents (override from Node.hx)
	private override function __getEnableEvents():Bool
	{
		return m_bEv;
	}
	private override function __setEnableEvents( b:Bool ):Bool
	{
		// no change
		if( b == m_bEv )
			return b;

		if( b )
			subscribeEvents();
		else
			unsubscribeEvents();
		m_bEv = b;
		return b;
	}

	// enableInteractivity (from Node.hx)
	private override function __getEnableInteractivity():Bool
	{
		return m_bMouseInteractivity;
	}
	private override function __setEnableInteractivity( p_bState:Bool ):Bool
	{
		if( p_bState != m_bMouseInteractivity )
		{
			changed = true;
			// --
			if( p_bState )
			{
				if( m_bUseSingleContainer == true )
				{
					useSingleContainer = false;
					m_bForcedSingleContainer = true;
				}
			}
			else
			{
				if( m_bForcedSingleContainer == true )
				{
					useSingleContainer = true;
					m_bForcedSingleContainer = false;
				}
			}
			// --
			for ( l_oPolygon in aPolygons )
			{
				l_oPolygon.enableInteractivity = p_bState;
			}

			m_bMouseInteractivity = p_bState;
		}
		return p_bState;
	}

	// geometry
	private function __getGeometry():Geometry3D
	{
		return m_oGeometry;
	}
	private function __setGeometry( p_geometry:Geometry3D ):Geometry3D
	{
		if( p_geometry == null ) return null;
		// TODO shall we clone the geometry?
		m_oGeometry = p_geometry;
		updateBoundingVolumes();
		// -- we generate the possible missing normals
		m_oGeometry.generateFaceNormals();//Must be called first
		m_oGeometry.generateVertexNormals();//must be called second

		// --

		#if (js && SANDY_WEBGL)
		if (Lib.mOpenGL)
		{
			container.mVertices = this.m_oGeometry.glVertices();
			container.mTextureCoords = this.m_oGeometry.glTexCoords();
			container.mIndices = this.m_oGeometry.glIndices();

			container.SetBuffers();
		}
		#end

		__destroyPolygons();
		__generatePolygons( m_oGeometry );
		changed = true;
		return p_geometry;
	}

	// geometryCenter
	private function __getGeometryCenter():Point3D
	{
		return m_oGeomCenter;
	}
	private function __setGeometryCenter( p_oGeomCenter:Point3D ):Point3D
	{
		var l_oDiff:Point3D = p_oGeomCenter.clone();
		l_oDiff.sub( m_oGeomCenter );
		// --
		if( m_oGeometry != null )
		{
			for ( l_oVertex in m_oGeometry.aVertex )
			{
				l_oVertex.x += l_oDiff.x;
				l_oVertex.y += l_oDiff.y;
				l_oVertex.z += l_oDiff.z;
			}
		}
		// --
		m_oGeomCenter.copy( p_oGeomCenter );
		// --
		updateBoundingVolumes();
		changed = true;
		return p_oGeomCenter;
	}

	// material
	public function __getMaterial():Material
	{
		return ( aPolygons[0].visible ) ? m_oAppearance.frontMaterial : m_oAppearance.backMaterial;
	}
	public function __setMaterial(v):Material
	{
		return throw "not implemented";
	}

	// scene (from Node.hx)
	private override function __setScene( p_oScene:Scene3D )
	{
		super.__setScene(p_oScene);
		if(aPolygons != null) {
			for( l_oPoly in aPolygons )
			{
				l_oPoly.scene = null;
				l_oPoly.scene = p_oScene;
			}
		}
		return p_oScene;
	}

	// useSingleContainer (from Node.hx)
	private override function __getUseSingleContainer ():Bool
	{
		return m_bUseSingleContainer;
	}
	private override function __setUseSingleContainer( p_bUseSingleContainer:Bool ):Bool
	{
		var l_oFace:Polygon;
		// No change
		if( p_bUseSingleContainer == m_bUseSingleContainer )
			return p_bUseSingleContainer;

		// update enableEvents that relies on useSingleContainer
		var useEvents = enableEvents;
		unsubscribeEvents();

		// --
		if( p_bUseSingleContainer )
		{
			for ( l_oFace in aPolygons )
			{
				if( l_oFace.container.parent != null )
				{
					l_oFace.container.graphics.clear();
					l_oFace.container.parent.removeChild( l_oFace.container );
					this.broadcaster.removeChild( l_oFace.broadcaster );
				}
			}
		}
		else
		{
			if( m_oContainer.parent != null )
			{
				m_oContainer.graphics.clear();
				m_oContainer.parent.removeChild( m_oContainer );
			}
			// --
			for ( l_oFace in aPolygons )
			{
				this.broadcaster.addChild( l_oFace.broadcaster );
				// we reset the polygon container to the original one, and add it to the world container
				l_oFace.container.graphics.clear();
			}
		}
		m_bUseSingleContainer = p_bUseSingleContainer;
		// reapply events
		if(useEvents)
			subscribeEvents();
		//--
		changed = true;
		return p_bUseSingleContainer;
	}

	/**
	 * Faces sorting method.
	 * With <code>useSingleContainer</code> set to <code>false</code> only <code>SORT_AVGZ</code> is possible.
	 */
	public var sortingMode(__getSortingMode,__setSortingMode):Int;
	private inline function __getSortingMode ():Int {
		return m_bUseSingleContainer ? m_nSortingMode : SORT_AVGZ;
	}

	private inline function __setSortingMode (mode:Int):Int {
		if (m_bUseSingleContainer) {

			if (mode == SORT_LAZY_BSP) {
				bsp = BSPNode.makeLazyBSP (aPolygons, 0.01 * boundingSphere.radius);
			}
			m_nSortingMode = mode; 
			changed = true;
		}
		return mode;
	}

	/////////////////////////////////////////////////////////////////////
	/////                   PRIVATE                                 /////
	/////////////////////////////////////////////////////////////////////
	private override function copy( src:sandy.core.scenegraph.Node, includeTransforms:Bool=false, includeGeometry:Bool=true ) : Void
	{
		if(!Std.is(src,Shape3D))
			throw "Invalid src";
		var o:Shape3D = cast src;

		var finalEvents = o.enableEvents;
		super.copy( src, includeTransforms );

		if(includeGeometry)
			geometry = o.geometry.clone();
		animated = o.animated;
		// aPolygons - set by geometry
		// aVisiblePolygons - ignore
		enableForcedDepth = o.enableForcedDepth;
		enableNearClipping = o.enableNearClipping;
		forcedDepth = o.forcedDepth;
		//m_oAppearance
		appearance = o.m_oAppearance;
		//m_bEv = o.m_bEv;
		//enableEvents (in Node.hx)
		//m_oGeomCenter
		geometryCenter = o.m_oGeomCenter.clone();
		//m_bBackFaceCulling (in Node.hx)
		m_bWasOver = false;
		m_oLastEvent = null;
		m_oLastContainer = null;
		//m_oGeometry - above
		//m_bUseSingleContainer (Node.hx)
		//m_oContainer - don't set
		//m_bMouseInteractivity (enableInteractivity) (in Node.hx)
		m_nDepth = o.m_nDepth;

		unsubscribeEvents();
		if(finalEvents)
			subscribeEvents();
	}

	private function __destroyPolygons():Void
	{
		if( aPolygons != null && aPolygons.length > 0 )
		{
			var i:Int = 0, l:Int = aPolygons.length;
			while( i<l )
			{
				if( broadcaster != null ) broadcaster.removeChild( aPolygons[i].broadcaster );
				if( aPolygons[i] != null ) aPolygons[i].destroy();
				// --
				aPolygons[i] = null;
				// --
				i ++;
			}
		}
		aPolygons.splice(0,aPolygons.length);
	}

	private function __generatePolygons( p_oGeometry:Geometry3D ):Void
	{
		var i:Int = 0, j:Int = 0, l:Int = p_oGeometry.aFacesVertexID.length;
		aPolygons = new Array();
		// --
		for( i in 0...l )
		{
			aPolygons[i] = new Polygon( this, p_oGeometry, p_oGeometry.aFacesVertexID[i], p_oGeometry.aFacesUVCoordsID[i], i, i );
			if( m_oAppearance != null ) aPolygons[i].appearance = m_oAppearance;
			this.broadcaster.addChild( aPolygons[i].broadcaster );
		}
	}

	private function _onInteraction( p_oEvt:Event ):Void
	{
		// we need to get the polygon which has been clicked.
		var l_oClick:Point = new Point( m_oContainer.mouseX, m_oContainer.mouseY );
		var l_oA:Point = new Point(), l_oB:Point = new Point(), l_oC:Point = new Point();
		var l_oPoly:Polygon;
		
		var l_aSId:Array<Int> = ArrayUtil.indicesOfSorted(aPolygons, ['m_nDepth'] , ArrayUtil.SORT_NUMERIC);
		
		var l:Int = aPolygons.length, j:Int;
		for( j in 0...l )
		{
			l_oPoly = aPolygons[ l_aSId[ j ] ];
			if( !l_oPoly.visible && m_bBackFaceCulling ) continue;
			// --
			var l_nSize:Int = l_oPoly.vertices.length;
			var l_nTriangles:Int = l_nSize - 2;
			for( i in 0...l_nTriangles )
			{
				l_oA.x = l_oPoly.vertices[i].sx; l_oA.y = l_oPoly.vertices[i].sy;
				l_oB.x = l_oPoly.vertices[i+1].sx; l_oB.y = l_oPoly.vertices[i+1].sy;
				l_oC.x = l_oPoly.vertices[(i+2)%l_nSize].sx; l_oC.y = l_oPoly.vertices[(i+2)%l_nSize].sy;
				// --
				if( IntersectionMath.isPointInTriangle2D( l_oClick, l_oA, l_oB, l_oC ) )
				{
					var l_oUV:UVCoord = l_oPoly.getUVFrom2D( l_oClick );
					var l_oPt3d:Point3D = l_oPoly.get3DFrom2D( l_oClick );
					m_oLastContainer = m_oContainer;
					m_oLastEvent = new Shape3DEvent( p_oEvt.type, this, l_oPoly, l_oUV, l_oPt3d, p_oEvt );
					m_oEB.dispatchEvent( m_oLastEvent );
					// to be able to dispatch mouse out event
					if( p_oEvt.type == MouseEvent.MOUSE_OVER )
						m_bWasOver = true;
					return;
				}
			}
		}
	}

	private function subscribeEvents()
	{
		if( m_bUseSingleContainer == false )
		{
			for ( v in aPolygons )
			{
				v.enableEvents = true;
			}
		}
		else
		{
			m_oContainer.addEventListener(MouseEvent.CLICK, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.MOUSE_UP, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.MOUSE_DOWN, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.ROLL_OVER, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.ROLL_OUT, _onInteraction,false,0,true);

			m_oContainer.addEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.MOUSE_MOVE, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.MOUSE_OVER, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.MOUSE_OUT, _onInteraction,false,0,true);
			m_oContainer.addEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction,false,0,true);
		}
	}

	private function unsubscribeEvents()
	{
		for ( v in aPolygons )
		{
			v.enableEvents = false;
		}

		m_oContainer.removeEventListener(MouseEvent.CLICK, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);

		m_oContainer.removeEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
		m_oContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
	}

	/**
	* Updates polygons, face and vertex normals when geometry vertex values have changed.
	* Do not call if the geometry has been modified in any way other than
	* when the x,y,z positions of some vertices have changed. If the provided
	* geometry is not the same as the existing geometry, this will have the
	* same effect as assigning a new geometry.
	*
	* @param p_oGeometry Geometry object which must be the same size as existing geometry
	*/
	private function updateForGeometryChange( p_oGeometry:Geometry3D, updateNormals:Bool=true, updateBounds:Bool=true ) : Void
	{
		if(m_oGeometry == null || m_oGeometry.aFacesVertexID.length != p_oGeometry.aFacesVertexID.length) {
			__setGeometry( p_oGeometry );
			return;
		}
		m_oGeometry = p_oGeometry;
		if(updateBounds)
			updateBoundingVolumes();
		if(updateNormals)
			m_oGeometry.updateFaceNormals(); // Must be called first
		//m_oGeometry.updateVertexNormals(); // Vertex normals already tied to face normals

		var l:Int = m_oGeometry.aFacesVertexID.length;
		// --
		for( i in 0...l )
		{
			aPolygons[i].update( m_oGeometry.aFacesVertexID[i] );
		}

		changed = true;
	}



	// ______________
	// [PRIVATE] DATA________________________________________________
	private var m_oAppearance:Appearance ; // The Appearance of this Shape3D
	private var m_bEv:Bool; // The event system state (enable or not)
	private var m_oGeomCenter:Point3D;
	private var m_bBackFaceCulling:Bool;
	private var m_bClipping:Bool;

	// interaction
	public var m_bWasOver:Bool;
	public var m_oLastEvent:Shape3DEvent;
	public var m_oLastContainer:Sprite;

	/** Geometry of this object */
	private var m_oGeometry:Geometry3D;

	private var m_bUseSingleContainer:Bool;
	public var m_nDepth:Float;
	private var m_oContainer:Sprite;
	private var m_bMouseInteractivity:Bool;
	private var m_bForcedSingleContainer:Bool;

	private var m_nSortingMode:Int;
}

