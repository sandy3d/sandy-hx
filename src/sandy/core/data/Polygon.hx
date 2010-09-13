
package sandy.core.data;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import sandy.math.PlaneMath;

import sandy.core.Scene3D;
#if !(cpp || neko) //TODO
import sandy.core.interaction.VirtualMouse;
#end
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.IDisplayable;
import sandy.core.scenegraph.Shape3D;
import sandy.events.BubbleEventBroadcaster;
import sandy.events.SandyEvent;
import sandy.events.Shape3DEvent;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.math.IntersectionMath;
import sandy.math.Point3DMath;
import sandy.view.CullingState;
import sandy.view.Frustum;

import sandy.HaxeTypes;

/**
* Polygon's are the building blocks of visible 3D shapes.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Mirek Mencel
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		24.08.2007
*
* @see sandy.core.scenegraph.Shape3D
*/
class Polygon implements IDisplayable
{
// _______
// STATICS_______________________________________________________
	private static var _ID_:Int = 0;

	/**
	* This property lists all the polygons.
	* This is an helping property since it allows to retrieve a polygon instance from its unique ID.
	* Polygon objects have an unique ID with myPolygon.id.
	* Using : Polygon.POLYGON_MAP[myPolygon.id] returns myPolygon (for sure this example has no interesst except showing the use of the property.
	*/
	public static var POLYGON_MAP:IntHash<Polygon> = new IntHash();
// ______
// PUBLIC________________________________________________________
	/**
	* [READ-ONLY] property
	* Unique polygon ID Number.
	*/
	public var id:Int;

	/**
	* [READ-ONLY] property.
	* Link to the Shape3D instance this polygon is related too.
	*/
	public var shape:Shape3D;

	/**
	* [READ-ONLY] property.
	* Specify if the polygon has been clipped
	*/
	public var isClipped:Bool;
	/**
	* An array of clipped vertices. Check the <code>isClipped</code> property first to see if this array will contain the useful data.
	*/
	public var cvertices:Array<Vertex>;
	/**
	* Array of original vertices.
	*/
	public var vertices:Array<Vertex>;
	/**
	* An array of the polygon's vertex normals.
	*/
	public var vertexNormals:Array<Vertex>;

	public var aUVCoord:Array<UVCoord>;

	/**
	* An array of the polygon's edges.
	*/
	public var aEdges:Array<Edge3D>;

	public var caUVCoord:Array<UVCoord>;

	/**
	* The texture bounds.
	*/
	public var uvBounds:Rectangle;

	/**
	* An array of polygons that share an edge with this polygon.
	*/
	public var aNeighboors:Array<Polygon>;

	/**
	* Specifies whether the face of the polygon is visible.
	*/
	public var visible:Bool;

	/**
	* Minimum depth value of that polygon in the camera space
	*/
	public var minZ:Float;

	public var a:Vertex;
	public var b:Vertex;
	public var c:Vertex;
	public var d:Vertex;

	private var _area:Float;
	public var area(__getArea,null):Float;
	private inline function __getArea ():Float {
		if (Math.isNaN (_area)) {
			// triangle area is 1/2 of sides cross product
			var ab:Vertex = b.clone (); ab.sub (a);
			var ac:Vertex = c.clone (); ac.sub (a);
			_area = 0.5 * ab.cross (ac).getNorm ();
			if (d != null) {
				var ad:Vertex = d.clone (); ad.sub (a);
				_area += 0.5 * ac.cross (ad).getNorm ();
			}
		}
		return _area;
	}

	/**
	* Creates a new polygon.
	*
	* @param p_oShape		    The shape this polygon belongs to
	* @param p_geometry		The geometry this polygon is part of
	* @param p_aVertexID		The vertexID array of this polygon
	* @param p_aUVCoordsID		The UVCoordsID array of this polygon
	* @param p_nFaceNormalID	The faceNormalID of this polygon
	* @param p_nEdgesID		The edgesID of this polygon
	*/
	public function new( p_oOwner:Shape3D, p_geometry:Geometry3D, p_aVertexID:Array<Int>, ?p_aUVCoordsID:Array<Int>, ?p_nFaceNormalID:Int=0, ?p_nEdgesID:Int=0 )
	{
		// public initializers
		id = _ID_++;
		isClipped = false;
		aNeighboors = new Array();
		//private initializers
		mouseEvents = false;
		mouseInteractivity = false;

		shape = p_oOwner;
		m_oGeometry = p_geometry;
		// --
		__create( p_aVertexID, p_aUVCoordsID, p_nFaceNormalID, p_nEdgesID );
		m_oContainer = new Sprite();
		// --
		POLYGON_MAP.set( id, this );
		m_oEB = new BubbleEventBroadcaster(this);
	}

	public function update( p_aVertexID:Array<Int> ):Void
	{
		var i:Int=0;
		// --
		for ( id in p_aVertexID )
		{
			vertices[i] = m_oGeometry.aVertex[ id ];
			vertexNormals[i] = m_oGeometry.aVertexNormals[ id ];
			i++;
		}
		// --
		a = vertices[0];
		b = vertices[1];
		c = vertices[2];
		d = vertices[3];
	}

	public var changed(__getChanged, __setChanged) : Bool;
	private function __getChanged():Bool {
		return shape.changed;
	}
	private function __setChanged(v:Bool): Bool {
		shape.changed = v;
		return v;
	}

	/**
	* A reference to the Scene3D object this polygon is in.
	*/
	public var scene(__getScene, __setScene) : Scene3D;
	private var m_oScene : Scene3D;
	public function __setScene(p_oScene:Scene3D):Scene3D
	{
		if( p_oScene == null ) return null;
		if( m_oScene != null )
		{
			m_oScene.removeEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
			m_oScene.removeEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
		}
		// --
		m_oScene = p_oScene;
		// --
		m_oScene.addEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
		m_oScene.addEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
		return p_oScene;
	}
	public function __getScene():Scene3D
	{
		return m_oScene;
	}

	/**
	* Creates the vertices and normals for this polygon.
	*
	* <p>Calling this method make the polygon gets its vertice and normals by reference
	* instead of accessing them by their ID.<br/>
	* This method shall be called once the geometry created.</p>
	*
	* @param p_aVertexID		The vertexID array of this polygon
	* @param p_aUVCoordsID		The UVCoordsID array of this polygon
	* @param p_nFaceNormalID	The faceNormalID of this polygon
	* @param p_nEdgesID		The edgesID of this polygon
	*/
	private function __create( p_aVertexID:Array<Int>, p_aUVCoordsID:Array<Int>, p_nFaceNormalID:Int, p_nEdgeListID:Int ):Void
	{
		var i:Int=0, l:Int;
		// --
		vertexNormals = new Array();
		vertices = new Array();
		for ( o in p_aVertexID )
		{
			vertices[i] = m_oGeometry.aVertex[ p_aVertexID[i] ];
			vertexNormals[i] = m_oGeometry.aVertexNormals[ p_aVertexID[i] ];
			i++;
		}
		// --
		a = vertices[0];
		b = vertices[1];
		c = vertices[2];
		d = vertices[3];
		// -- every polygon does not have some texture coordinates
		if( p_aUVCoordsID != null )
		{
			var l_nMinU:Float = Math.POSITIVE_INFINITY, l_nMinV:Float = Math.POSITIVE_INFINITY,
								l_nMaxU:Float = Math.NEGATIVE_INFINITY, l_nMaxV:Float = Math.NEGATIVE_INFINITY;
			// --
			aUVCoord = new Array();
			i = 0;
			if( p_aUVCoordsID != null) {
				for ( p in p_aUVCoordsID )
				{
					var l_oUV:UVCoord = m_oGeometry.aUVCoords[ p_aUVCoordsID[i] ];
					aUVCoord[i] = l_oUV;
					if( l_oUV.u < l_nMinU ) l_nMinU = l_oUV.u;
					else if( l_oUV.u > l_nMaxU ) l_nMaxU = l_oUV.u;
					// --
					if( l_oUV.v < l_nMinV ) l_nMinV = l_oUV.v;
					else if( l_oUV.v > l_nMaxV ) l_nMaxV = l_oUV.v;
					// --
					i++;
				}
				// --
				uvBounds = new Rectangle( l_nMinU, l_nMinV, l_nMaxU-l_nMinU, l_nMaxV-l_nMinV );
			}
			else
			{
				aUVCoord = [new UVCoord(), new UVCoord(), new UVCoord()];
				uvBounds = new Rectangle(0,0,0,0);
			}
		}
		// --
		m_nNormalId = p_nFaceNormalID;
		normal = m_oGeometry.aFacesNormals[ p_nFaceNormalID ];
		// If no normal has been given, we create it ourself.
		if( normal == null )
		{
			var l_oNormal:Point3D = createNormal();
			m_nNormalId = m_oGeometry.setFaceNormal( m_oGeometry.getNextFaceNormalID(), l_oNormal.x, l_oNormal.y, l_oNormal.z );
		}
		// --
		aEdges = new Array();
		for ( l_nEdgeId in m_oGeometry.aFaceEdges[p_nEdgeListID] )
		{
			var l_oEdge:Edge3D = m_oGeometry.aEdges[ l_nEdgeId ];
			l_oEdge.vertex1 = m_oGeometry.aVertex[ l_oEdge.vertexId1 ];
			l_oEdge.vertex2 = m_oGeometry.aVertex[ l_oEdge.vertexId2 ];
			aEdges.push( l_oEdge );
		}
	}

	public var normal(__getNormal,__setNormal) : Vertex;
	private function __getNormal():Vertex
	{
		return m_oGeometry.aFacesNormals[ m_nNormalId ];
	}

	public function __setNormal( p_oVertex:Vertex ):Vertex
	{
		if( p_oVertex != null )
			m_oGeometry.aFacesNormals[ m_nNormalId ].copy( p_oVertex );
		return p_oVertex;
	}

	public function updateNormal():Void
	{
		var x:Float = 	((a.y - b.y) * (c.z - b.z)) - ((a.z - b.z) * (c.y - b.y)) ;
		var y:Float =	((a.z - b.z) * (c.x - b.x)) - ((a.x - b.x) * (c.z - b.z)) ;
		var z:Float = 	((a.x - b.x) * (c.y - b.y)) - ((a.y - b.y) * (c.x - b.x)) ;
		normal.reset( x, y, z );
		if (normal.getNorm () > 0) normal.normalize(); else normal.y = 1;
	}

	/**
	* The depth of the polygon.
	*/
	public var depth(__getDepth,__setDepth):Float;
	private function __getDepth():Float{ return m_nDepth; }
	private function __setDepth( p_nDepth:Float ):Float{ m_nDepth = p_nDepth; return p_nDepth; }

	/**
	* The broadcaster property.
	*
	* <p>The broadcaster is the property used to send events to listeners.</p>
	*/
	public var broadcaster(__getBroadcaster,null):BubbleEventBroadcaster;
	private function __getBroadcaster():BubbleEventBroadcaster
	{
		return m_oEB;
	}

	/**
	* Adds a listener for specifical event.
	*
	* @param p_sEvent 	Name of the Event.
	* @param oL 		Listener object.
	*/
	public function addEventListener(p_sEvent:String, oL:Dynamic, arguments:Array<Dynamic> ) : Void
	{
		Reflect.callMethod( m_oEB.addEventListener, m_oEB, arguments );
	}

	/**
	* Removes a listener for specifical event.
	*
	* @param p_sEvent 	Name of the Event.
	* @param oL 		Listener object.
	*/
	public function removeEventListener(p_sEvent:String, oL:Dynamic) : Void
	{
		m_oEB.removeEventListener(p_sEvent, oL);
	}

	/**
	* Computes several properties of the polygon.
	* <p>The computed properties are listed below:</p>
	* <ul>
	*  <li><code>visible</code></li>
	*  <li><code>minZ</code></li>
	*  <li><code>depth</code></li>
	* </ul>
	*/
	public function precompute():Void
	{
		isClipped = false;
		// --
		minZ = a.wz;
		if (b.wz < minZ) minZ = b.wz;
		m_nDepth = a.wz + b.wz;
		// --
		if (c != null)
		{
			if (c.wz < minZ) minZ = c.wz;
			m_nDepth += c.wz;
		}
		if (d != null)
		{
			if (d.wz < minZ) minZ = d.wz;
			m_nDepth += d.wz;
		}
		m_nDepth /= vertices.length;
	}


	/**
	* Returns a Point3D (3D position) on the polygon relative to the specified point on the 2D screen.
	*
	* @example	Below is an example of how to get the 3D coordinate of the polygon under the position of the mouse:
	* <listing version="3.1">
	* var screenPoint:Point = new Point(myPolygon.container.mouseX, myPolygon.container.mouseY);
	* var scenePosition:Point3D = myPolygon.get3DFrom2D(screenPoint);
	* </listing>
	*
	* @return A Point3D that corresponds to the specified point.
	*/
	public function get3DFrom2D( p_oScreenPoint:Point ):Point3D
	{
		/// NEW CODE ADDED BY MAX with the help of makc ///

		var m1:Matrix= new Matrix(
					vertices[1].sx-vertices[0].sx,
					vertices[2].sx-vertices[0].sx,
					vertices[1].sy-vertices[0].sy,
					vertices[2].sy-vertices[0].sy,
					0,
					0);
		m1.invert();

		var capA:Float = m1.a *(p_oScreenPoint.x-vertices[0].sx) + m1.b * (p_oScreenPoint.y -vertices[0].sy);
		var capB:Float = m1.c *(p_oScreenPoint.x-vertices[0].sx) + m1.d * (p_oScreenPoint.y -vertices[0].sy);

		var l_oPoint:Point3D = new Point3D(
			vertices[0].x + capA*(vertices[1].x -vertices[0].x) + capB *(vertices[2].x - vertices[0].x),
			vertices[0].y + capA*(vertices[1].y -vertices[0].y) + capB *(vertices[2].y - vertices[0].y),
			vertices[0].z + capA*(vertices[1].z -vertices[0].z) + capB *(vertices[2].z - vertices[0].z)
			);

		// transform the vertex with the model Matrix
		this.shape.matrix.transform( l_oPoint );
		return l_oPoint;
	}

	/**
	* Returns a UV coordinate elative to the specified point on the 2D screen.
	*
	* @example	Below is an example of how to get the UV coordinate under the position of the mouse:
	* <listing version="3.1">
	* var screenPoint:Point = new Point(myPolygon.container.mouseX, myPolygon.container.mouseY);
	* var scenePosition:Point3D = myPolygon.getUVFrom2D(screenPoint);
	* </listing>
	*
	* @return A the UV coordinate that corresponds to the specified point.
	*/
	public function getUVFrom2D( p_oScreenPoint:Point ):UVCoord
	{
		var p0:Point = new Point(vertices[0].sx, vertices[0].sy);
		var p1:Point = new Point(vertices[1].sx, vertices[1].sy);
		var p2:Point = new Point(vertices[2].sx, vertices[2].sy);

		var u0:UVCoord = aUVCoord[0];
		var u1:UVCoord = aUVCoord[1];
		var u2:UVCoord = aUVCoord[2];

		var v01:Point = new Point(p1.x - p0.x, p1.y - p0.y );

		var vn01:Point = v01.clone();
		vn01.normalize(1);

		var v02:Point = new Point(p2.x - p0.x, p2.y - p0.y );
		var vn02:Point = v02.clone(); vn02.normalize(1);

		// sub that from click point
		var v4:Point = new Point( p_oScreenPoint.x - v01.x, p_oScreenPoint.y - v01.y );

		// we now have everything to find 1 intersection
		var l_oInter:Point = IntersectionMath.intersectionLine2D( p0, p2, p_oScreenPoint, v4 );

		// find Point3Ds to intersection
		var vi02:Point = new Point( l_oInter.x - p0.x, l_oInter.y - p0.y );
		var vi01:Point = new Point( p_oScreenPoint.x - l_oInter.x , p_oScreenPoint.y - l_oInter.y );

		// interpolation coeffs
		var d1:Float = vi01.length / v01.length ;
		var d2:Float = vi02.length / v02.length;

		// -- on interpole linéairement pour trouver la position du point dans repere de la texture (normalisé)
		return new UVCoord( u0.u + d1*(u1.u - u0.u) + d2*(u2.u - u0.u),
							u0.v + d1*(u1.v - u0.v) + d2*(u2.v - u0.v));
	}

	/**
	* Clips the polygon.
	*
	* @return An array of vertices clipped by the camera frustum.
	*/
	public function clip( p_oFrustum:Frustum ):Array<Vertex>
	{
		cvertices = null;
		caUVCoord = null;
		// --
		var l_oCull:Int = p_oFrustum.polygonInFrustum( this );
		if( l_oCull == CullingState.INSIDE )
			return vertices;
		else if( l_oCull == CullingState.OUTSIDE )
			return null;
		// For lines we only apply front plane clipping
		if( vertices.length < 3 )
		{
			clipFrontPlane( p_oFrustum );
		}
		else
		{
			cvertices = vertices.copy();
			caUVCoord = aUVCoord.copy();
			// --
			isClipped = p_oFrustum.clipFrustum( cvertices, caUVCoord );
		}
		return cvertices;
	}

	/**
	* Perform a clipping against the near frustum plane.
	*
	* @return 	The array of clipped vertices
	*/
	public function clipFrontPlane( p_oFrustum:Frustum ):Array<Vertex>
	{
		cvertices = vertices.copy();
		// If line
		if( vertices.length < 3 )
		{
			isClipped = p_oFrustum.clipLineFrontPlane( cvertices );
		}
		else
		{
			caUVCoord = aUVCoord.copy();
			isClipped = p_oFrustum.clipFrontPlane( cvertices, caUVCoord );
		}
		return cvertices;
	}

	/**
	* Clears the polygon's container.
	*/
	public function clear():Void
	{
		if (m_oContainer != null) m_oContainer.graphics.clear();
	}

	/**
	* Draws the polygon on its container if visible.
	*
	* @param p_oScene		The scene this polygon is rendered in.
	* @param p_oContainer	The container to draw on.
	*/
	public function display( ?p_oContainer:Sprite ):Void
	{
		// --
		var lCont:Sprite = (p_oContainer != null)?p_oContainer:m_oContainer;
		if( material != null )
			material.renderPolygon( scene, this, lCont );
	}

	/**
	* Returns the material currently used by the renderer
	* @return Material the material used to render
	*/
	public var material(__getMaterial,__setMaterial) : Material;
	private function __getMaterial():Material
	{
		if( m_oAppearance == null ) return null;
		return ( visible ) ? m_oAppearance.frontMaterial : m_oAppearance.backMaterial;
	}
	private function __setMaterial(v:Material) : Material
	{
		return throw "unimplemented";
	}

	/**
	* The container for this polygon.
	*/
	public var container(__getContainer,null):Sprite;
	private function __getContainer():Sprite
	{
		return m_oContainer;
	}

	/**
	* Returns a string representing of this polygon.
	*
	* @return	The string representation.
	*/
	public function toString():String
	{
		return "sandy.core.data.Polygon::id=" +id+ " [Points: " + vertices.length + "]";
	}

	/**
	* Specifies whether mouse events are enabled for this polygon.
	*
	* <p>To apply events to a polygon, listeners must be added with the <code>addEventListener()</code> method.</p>
	*
	* @see #addEventListener()
	*/
	public var enableEvents(__getEnableEvents,__setEnableEvents):Bool;
	private function __getEnableEvents():Bool { return mouseEvents; }
	private function __setEnableEvents( b:Bool ):Bool
	{
		if( b && !mouseEvents )
		{
			container.addEventListener(MouseEvent.CLICK, _onInteraction);
			container.addEventListener(MouseEvent.MOUSE_UP, _onInteraction);
			container.addEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
			container.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);
			container.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);

			container.addEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
			container.addEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
			container.addEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
			container.addEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
			container.addEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);

		}
		else if( !b && mouseEvents )
		{
			container.removeEventListener(MouseEvent.CLICK, _onInteraction);
			container.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction);
			container.removeEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
			container.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);
			container.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);

			container.removeEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
			container.removeEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
			container.removeEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
			container.removeEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
			container.removeEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
		}
		mouseEvents = b;
		return b;
	}

	private var m_bWasOver:Bool;
	/**
	* @private
	*/
	private function _onInteraction( p_oEvt:Event ):Void
	{
		var l_oClick:Point = new Point( m_oContainer.mouseX, m_oContainer.mouseY );
		var l_oUV:UVCoord = getUVFrom2D( l_oClick );
		var l_oPt3d:Point3D = get3DFrom2D( l_oClick );
		shape.m_oLastContainer = this.m_oContainer;
		shape.m_oLastEvent = new Shape3DEvent( p_oEvt.type, shape, this, l_oUV, l_oPt3d, p_oEvt );
		m_oEB.dispatchEvent( shape.m_oLastEvent );
		if( p_oEvt.type == MouseEvent.MOUSE_OVER )
			shape.m_bWasOver = true;
	}

	/**
	* @private
	*/
	public function _startMouseInteraction( ?e : MouseEvent ) : Void
	{
		container.addEventListener(MouseEvent.CLICK, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_UP, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_DOWN, _onTextureInteraction);

		container.addEventListener(MouseEvent.DOUBLE_CLICK, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_MOVE, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_OVER, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_OUT, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_WHEEL, _onTextureInteraction);

		container.addEventListener(KeyboardEvent.KEY_DOWN, _onTextureInteraction);
		container.addEventListener(KeyboardEvent.KEY_UP, _onTextureInteraction);

		m_oContainer.addEventListener( Event.ENTER_FRAME, _onTextureInteraction );
	}

	/**
	* @private
	*/
	public function _stopMouseInteraction( ?e : MouseEvent ) : Void
	{
		container.addEventListener(MouseEvent.CLICK, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_UP, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_DOWN, _onTextureInteraction);

		container.addEventListener(MouseEvent.DOUBLE_CLICK, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_MOVE, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_OVER, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_OUT, _onTextureInteraction);
		container.addEventListener(MouseEvent.MOUSE_WHEEL, _onTextureInteraction);

		container.addEventListener(KeyboardEvent.KEY_DOWN, _onTextureInteraction);
		container.addEventListener(KeyboardEvent.KEY_UP, _onTextureInteraction);

		m_oContainer.addEventListener( Event.ENTER_FRAME, _onTextureInteraction );
	}

	/**
	* Specifies whether <code>MouseEvent.ROLL_&#42;</code> events are enabled for this polygon.
	*
	* <p>To apply events to a polygon, listeners must be added with the <code>addEventListener()</code> method.</p>
	*
	* @see #addEventListener()
	*/
	public var enableInteractivity(__getEnableInteractivity,__setEnableInteractivity):Bool;
	private function __getEnableInteractivity():Bool { return mouseInteractivity; }
	private function __setEnableInteractivity( p_bState:Bool ):Bool
	{
		if( p_bState != mouseInteractivity )
		{
			if( p_bState )
			{
				container.addEventListener( MouseEvent.ROLL_OVER, _startMouseInteraction, false );
				container.addEventListener( MouseEvent.ROLL_OUT, _stopMouseInteraction, false );
			}
			else
			{
				_stopMouseInteraction();
			}
			// --
			mouseInteractivity = p_bState;
		}
		return p_bState;
	}

	/**
	* @private
	*/
	public function _onTextureInteraction( ?p_oEvt:Event ) : Void
	{
		var l_oEvt : MouseEvent = null;
		if ( p_oEvt == null || !Std.is( p_oEvt, MouseEvent ) )
		{
			l_oEvt = new MouseEvent( MouseEvent.MOUSE_MOVE, true, false, 0, 0, null, false, false, false, false, 0);
		} else {
			l_oEvt = cast p_oEvt;
		}

		//	get the position of the mouse on the poly
		var pt2D : Point = new Point( scene.container.mouseX, scene.container.mouseY );
		var uv : UVCoord = getUVFrom2D( pt2D );
		
		#if !(cpp || neko) //TODO
		VirtualMouse.getInstance().interactWithTexture( this, uv, l_oEvt );
		#end
		_onInteraction( p_oEvt );
	}

	/**
	* Returns the transformed normal Point3D of the polygon.
	*
	* @return The transformed normal Point3D of the polygon.
	*/
	public function createTransformedNormal():Point3D
	{
		if( vertices.length > 2 )
		{
			var v:Point3D, w:Point3D;
			var a:Vertex = vertices[0], b:Vertex = vertices[1], c:Vertex = vertices[2];
			v = new Point3D( b.wx - a.wx, b.wy - a.wy, b.wz - a.wz );
			w = new Point3D( b.wx - c.wx, b.wy - c.wy, b.wz - c.wz );
			// we compute de cross product
			var l_normal:Point3D = Point3DMath.cross( v, w );
			// we normalize the resulting Point3D
			Point3DMath.normalize( l_normal ) ;
			// we return the resulting vertex
			return l_normal;
		}
		else
		{
			return new Point3D();
		}
	}

	/**
	* Returns the transformed normal Point3D of the polygon.
	*
	* @return The transformed normal Point3D of the polygon.
	*/
	public function createNormal():Point3D
	{
		if( vertices.length > 2 )
		{
			var v:Point3D, w:Point3D;
			var a:Vertex = vertices[0], b:Vertex = vertices[1], c:Vertex = vertices[2];
			v = new Point3D( b.wx - a.wx, b.wy - a.wy, b.wz - a.wz );
			w = new Point3D( b.wx - c.wx, b.wy - c.wy, b.wz - c.wz );
			// we compute de cross product
			var l_normal:Point3D = Point3DMath.cross( v, w );
			// we normalize the resulting vector
			Point3DMath.normalize( l_normal ) ;
			// we return the resulting vertex
			return l_normal;
		}
		else
		{
			return new Point3D();
		}
	}

	/**
	* The appearance of this polygon.
	*/
	public var appearance(__getAppearance,__setAppearance):Appearance;
	private function __getAppearance():Appearance
	{
		return m_oAppearance;
	}
	private function __setAppearance( p_oApp:Appearance ):Appearance
	{
		if( p_oApp == m_oAppearance ) return null;
		// --
		if( m_oAppearance != null && p_oApp != null)
		{
			if( p_oApp.frontMaterial != m_oAppearance.frontMaterial )
			{
				if(m_oAppearance.frontMaterial != null)
					m_oAppearance.frontMaterial.unlink( this );
				p_oApp.frontMaterial.init( this );
			}
			if( m_oAppearance.frontMaterial != m_oAppearance.backMaterial && p_oApp.backMaterial != m_oAppearance.backMaterial )
			{
				m_oAppearance.backMaterial.unlink( this );
			}
			if( p_oApp.frontMaterial != p_oApp.backMaterial	&& p_oApp.backMaterial != m_oAppearance.backMaterial )
			{
				p_oApp.backMaterial.init( this );
			}
			m_oAppearance = p_oApp;
		}
		else if( p_oApp != null )
		{
			m_oAppearance = p_oApp;
			m_oAppearance.frontMaterial.init( this );
			if( m_oAppearance.backMaterial != m_oAppearance.frontMaterial )
				m_oAppearance.backMaterial.init( this );
		}
		else if( m_oAppearance != null )
		{
			if(m_oAppearance.frontMaterial != null)
				m_oAppearance.frontMaterial.unlink( this );
			if( m_oAppearance.backMaterial != m_oAppearance.frontMaterial )
				m_oAppearance.backMaterial.unlink( this );
			m_oAppearance = null;
		}
		return p_oApp;
	}

	private function _finishMaterial( pEvt:SandyEvent ):Void
	{
		if( m_oAppearance == null ) return;
		// --
		if( m_oAppearance.frontMaterial != null )
		{
			m_oAppearance.frontMaterial.finish( m_oScene );
		}
		if(  m_oAppearance.backMaterial != null && m_oAppearance.backMaterial != m_oAppearance.frontMaterial )
		{
			m_oAppearance.backMaterial.finish( m_oScene );
		}
	}

	private function _beginMaterial( pEvt:SandyEvent ):Void
	{
		if( m_oAppearance == null ) return;

		// --
		if( m_oAppearance.frontMaterial != null )
		{
			m_oAppearance.frontMaterial.begin( m_oScene );
		}
		if( m_oAppearance.backMaterial != null && m_oAppearance.backMaterial != m_oAppearance.frontMaterial )
		{
			m_oAppearance.backMaterial.begin( m_oScene );
		}
	}

	/**
	* Changes which side is the "normal" culling side.
	*
	* <p>The method also swaps the front and back skins.</p>
	*/
	public function swapCulling():Void
	{
		normal.negate();
	}

	/**
	* Destroys the sprite attache to this polygon.
	*/
	public function destroy():Void
	{
		clear();
		if(scene != null) {
			scene.removeEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
			scene.removeEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
		}
		// --
		enableEvents = false;
		enableInteractivity = false;
		if( appearance != null )
		{
			//appearance.dispose();
			if( appearance.frontMaterial != null ) appearance.frontMaterial.unlink(this);
			if( appearance.backMaterial != null ) appearance.backMaterial.unlink(this);
			appearance = null;
		}
		if( m_oContainer != null ) {
			if( m_oContainer.parent != null ) m_oContainer.parent.removeChild( m_oContainer );
			m_oContainer = null;
		}
		// --
		cvertices = null;
		vertices = null;
		m_oEB = null;
		m_oGeometry = null;
		shape = null;
		scene = null;
		// -- memory leak fix from nopmb on mediabox forums
		POLYGON_MAP.remove( id );
	}

	public function getPlane (?centered:Bool = true):Plane {
		// calculate center of polygon
		var center:Point3D = a.getPoint3D ();
		if (centered) {
			center.x += b.x; center.y += b.y; center.z += b.z;
			center.x += c.x; center.y += c.y; center.z += c.z;
			if (d != null) {
				center.x += d.x; center.y += d.y; center.z += d.z;
				center.scale (0.25);
			} else {
				center.scale (1/3);
			}
		}
		// return plane
		return PlaneMath.createFromNormalAndPoint (normal.getPoint3D (), center);
	}

// _______
// PRIVATE_______________________________________________________

	/** Reference to its owner geometry */
	private var m_oGeometry:Geometry3D;
	private var m_oAppearance:Appearance;
	private var m_nNormalId:Int;
	private var m_nDepth:Float;
	/**
	* @private
	*/
	private var m_oContainer:Sprite;

	/**
	* @private
	*/
	private var m_oEB:BubbleEventBroadcaster;

	/** Boolean representing the state of the event activation */
	private var mouseEvents:Bool;
	private var mouseInteractivity:Bool;

}

