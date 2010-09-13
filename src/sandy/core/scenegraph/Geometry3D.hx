
package sandy.core.scenegraph;

import sandy.core.data.Edge3D;
import sandy.core.data.Point3D;
import sandy.core.data.UVCoord;
import sandy.core.data.Vertex;
import sandy.util.ArrayUtil;

import sandy.HaxeTypes;
import Type;

/**
* 	The Geometry3D class holds a complete description of the geometry of a Shape3D.
*
* 	It contains points, faces, normals and uv coordinates.
*
* 	NOTE: 	For best performance, Geometry should be created in offline mode,
* 		especially all faces, as createFace() validates all points
* 		if these points exist in points array.
*
* 	NOTE: 	This object is going to work well _ONLY_ if arrays
* 		wont be changed directlly [ie. push()] but _ONLY_ via accessor methods:
* 		createFace, createFaceByIds, addFace, addFaces.
* 		In the future we can make these Arrays PRIVATE but then the only
* 		way to make them safe is to deliver additionall accessors like
* 		getPoint(index:Int), getFace(index:Int) what could potentially slow
* 		affect performance of this structure (well, we need to test it, and
* 		if there is no problem, make arrays private and provide accessors for
* 		_SINGLE_ array's elements to make them safe ).
*
* <p>[<b>ToDo</b>: Revise this and adopt tp ASDoc]</p>
*
* @author	Mirek Mencel
* @author	Thomas PFEIFFER
* @author	Niel Drummond - haXe port
* @author	Russell Weir - haXe port
* @version		3.1
* @date	07.04.2007
*/
class Geometry3D
{
// ______
// PUBLIC________________________________________________________

	private var EDGES_DICO:Hash<Int>;

	/** Array of vertices */
	public var aVertex:Array<Vertex>;
	/** Array of faces composed from vertices */
	public var aFacesVertexID:Array<Array<Int>>;
	public var aFacesUVCoordsID:Array<Array<Int>>;
	/** Array ov normals */
	public var aFacesNormals:Array<Vertex>;
	public var aVertexNormals:Array<Vertex>;
	public var aEdges:Array<Edge3D>;
	// Array of face edges
	public var aFaceEdges:Array<Array<Int>>;
	/** UV Coords for faces */
	public var aUVCoords:Array<UVCoord>;
	private var m_nLastVertexId:Int;
	private var m_nLastNormalId:Int;
	private var m_nLastFaceId:Int;
	private var m_nLastFaceUVId:Int;
	private var m_nLastUVId:Int;
	private var m_nLastVertexNormalId:Int;
	private var m_aVertexFaces:Array<Array<Dynamic>>;
// ___________
// CONSTRUCTOR___________________________________________________

	/**
	* Creates a 3D geometry.
	*
	* @param p_points	Not used in this version
	*/
	public function new(?p_points:Array<Dynamic>)
	{

		EDGES_DICO = new Hash();
		aVertex = new Array();
		aFacesVertexID = new Array();
		aFacesUVCoordsID = new Array();
		aFacesNormals = new Array();
		aVertexNormals = new Array();
		aEdges = new Array();
		aFaceEdges = new Array();
		aUVCoords = new Array();
		m_nLastVertexId = 0;
		m_nLastNormalId = 0;
		m_nLastFaceId = 0;
		m_nLastFaceUVId = 0;
		m_nLastUVId = 0;
		m_nLastVertexNormalId = 0;
		m_aVertexFaces = new Array();

		init();
	}
	/**
	* Not used in this version.
	*/
	public function init():Void
	{
	}

	/**
	* Adds a face to the geometry object, given 3 vertices points
	* and their corresponding uv coordinates.
	*
	*/
	public function addFace(v0:Point3D, v1:Point3D, v2:Point3D, uv0:UVCoord, uv1:UVCoord, uv2:UVCoord)
	{
		var vid = getNextVertexID();
		setVertex(vid++, v0.x, v0.y, v0.z );
		setVertex(vid++, v1.x, v1.y, v1.z );
		setVertex(vid, v2.x, v2.y, v2.z );

		var ucid = getNextUVCoordID();
		setUVCoords( ucid++, uv0.u, uv0.v );
		setUVCoords( ucid++, uv1.u, uv1.v );
		setUVCoords( ucid, uv2.u, uv2.v );

		setFaceVertexIds( getNextFaceID(), [vid-2, vid-1, vid] );
		setFaceUVCoordsIds( getNextFaceUVCoordID(), [ucid-2, ucid-1, ucid] );
	}

	/**
	* Adds new point at the specified index of the vertex list.
	*
	* @param p_nVertexID	Index at which to save the vertex
	* @param p_nX		x coordinate of the vertex
	* @param p_nY		y coordinate of the vertex
	* @param p_nZ		z coordinate of the vertex
	* @return 		The next free index or -1 it the index is already occupied
	*/
	public function setVertex( p_nVertexID:Int, p_nX:Float, p_nY:Float, p_nZ:Float ):Int
	{
		if( aVertex[p_nVertexID] != null )
			return -1;
		else
		{
			aVertex[p_nVertexID] = new Vertex(p_nX, p_nY, p_nZ);
			return ++m_nLastVertexId - 1;
		}
	}

	/**
	* Returns the next unused vertex id.
	*
	* <p>this is the next free index in the verex list, and used by setVertex</p>
	*
	* @return 	The vertex id
	*/
	public function getNextVertexID():Int
	{
		return m_nLastVertexId;
	}

	/**
	* Adds new normal at the specified index of the face normal list.
	*
	* @param p_nNormalID	Index at which to save the normal
	* @param p_nX		The x component of the normal
	* @param p_nY		The y component of the normal
	* @param p_nZ		The z component of the normal
	* @return 		The next free index or -1 it the index is already occupied
	*/
	public function setFaceNormal( p_nNormalID:Int, p_nX:Float, p_nY:Float, p_nZ:Float ):Int
	{
		if( aFacesNormals[p_nNormalID] != null )
			return -1;
		else
		{
			aFacesNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ);
			return ++m_nLastNormalId - 1;
		}
	}

	/**
	* Returns the next unused normal id.
	*
	* <p>This is the next free index in the normal list, and used by setFaceNormal</p>
	*
	* @return 	The normal id
	*/
	public function getNextFaceNormalID():Int
	{
		return m_nLastNormalId;
	}

	/**
	* Add new point the specified index of the vertex normal list.
	*
	* @param p_nNormalID	Index at which to save the vertex normal
	* @param p_nX		x coordinate of the vertex normal
	* @param p_nY		y coordinate of the vertex normal
	* @param p_nZ		z coordinate of the vertex normal
	* @return 		The next free index or -1 it the index is already occupied
	*/
	public function setVertexNormal( p_nNormalID:Int, p_nX:Float, p_nY:Float, p_nZ:Float ):Float
	{
		if( aVertexNormals[p_nNormalID] != null )
			return -1;
		else
		{
			aVertexNormals[p_nNormalID] = new Vertex(p_nX, p_nY, p_nZ);
			return ++m_nLastVertexNormalId - 1;
		}
	}

	/**
	* Returns the next unused vertex normal id.
	*
	* <p>This is the next free index in the vertex normal list, and used by setVertexNormal</p>
	*
	* @return 	The vertex normal id
	*/
	public function getNextVertexNormalID():Int
	{
		return m_nLastVertexNormalId;
	}

	/**
	* Sets the ID's of the face vertices.
	*
	* @param p_nFaceID	Id of the face
	* @param...rest 	An array of data containing the ID's of the vertex list for the face
	* @return 		The next free index or -1 it the index is already occupied
	*/
	public function setFaceVertexIds( p_nFaceID:Int, ?arguments:Array<Int> ):Int
	{
		if (arguments == null) arguments = [];

		if( aFacesVertexID[p_nFaceID] != null )
		{
			return -1;
		}
		else
		{
			var rest:Array<Int> = arguments;

			aFacesVertexID[p_nFaceID] = rest;

			// Time to check if edges allready exist or if we shall create them
			for( lId in 0...rest.length )
			{
				var lId1:Int = rest[lId];
				var lId2:Int = rest[ (lId+1)%rest.length ];
				var lEdgeID:Int;
				var lString:String;
				// --
				if( isEdgeExist( lId1, lId2 ) == false )
				{
					lEdgeID = aEdges.push( new Edge3D( lId1, lId2 ) ) - 1;
					// --
					if( lId1 < lId2 ) lString = lId1+"_"+lId2;
					else lString = lId2+"_"+lId1;
					// --
					EDGES_DICO.set(lString, lEdgeID);
				}
				else
				{
					if( lId1 < lId2 ) lString = lId1+"_"+lId2;
					else lString = lId2+"_"+lId1;
					lEdgeID = EDGES_DICO.get(lString);
				}

				if( null == aFaceEdges[p_nFaceID] )
					aFaceEdges[p_nFaceID] = new Array();
				aFaceEdges[p_nFaceID].push( lEdgeID );
			}

			return ++m_nLastFaceId - 1;
		}
	}

	private function isEdgeExist( p_nVertexId1:Int, p_nVertexId2:Int ):Bool
	{
		var lString:String;
		// --
		if( p_nVertexId1 < p_nVertexId2 ) lString = p_nVertexId1+"_"+p_nVertexId2;
		else lString = p_nVertexId2+"_"+p_nVertexId1;
		// --
		if( EDGES_DICO.get(lString) == null ) return false;
		else return true;
	}

	/**
	* Returns the next unused face id.
	*
	* <p>This is the next free index in the faces list, and used by setFaceVertexIds</p>
	*
	* @return 	The index
	*/
	public function getNextFaceID():Int
	{
		return m_nLastFaceId;
	}

	/**
	* Set the ID's of face UV coordinates.
	*
	* @param p_nFaceID	The id of the face
	* @param ...rest 	An array of data containing the ID's of the UV coords list for the face
	* @return 		The next free index or -1 it the index is already occupied
	*/
	public function setFaceUVCoordsIds( p_nFaceID:Int, ?arguments:Array<Int> ):Int
	{
		if (arguments == null) arguments = [];

		if( aFacesUVCoordsID[p_nFaceID] != null )
		{
			return -1;
		}
		else
		{
			aFacesUVCoordsID[p_nFaceID] = arguments;
			return ++m_nLastFaceUVId - 1;
		}
	}

	/**
	* Returns the next unused face UV coordinates id.
	*
	* <p>This is the next free index in the UV coordinate id list, and used by setFaceUVCoords</p>
	*
	* @return 	The index
	*/
	public function getNextFaceUVCoordID():Int
	{
		return m_nLastFaceUVId;
	}

	/**
	* Returns the index of a specified point in the vertex list.
	*
	* @return 	The index
	*/
	public function getVertexId( p_point:Vertex ):Int
	{
		return ArrayUtil.indexOf(aVertex, p_point);
	}

	/**
	* Adds UV coordinates for single face.
	*
	* [<b>ToDo</b>: Explain this ]
	* @param p_nID		The id of the face
	* @param p_UValue	The u component of the UV coordinate
	* @param p_nVValue	The v component of the UV coordinate
	* @return 		The next free index or -1 it the index is already occupied
	*/
	public function setUVCoords( p_nID:Int, p_UValue:Float, p_nVValue:Float ):Int
	{
		if ( aUVCoords[p_nID] != null )
		{
			return -1;
		}
		else
		{
			aUVCoords[p_nID] = new UVCoord( p_UValue, p_nVValue );
			return ++m_nLastUVId - 1;
		}
	}

	/**
	* Returns the next unused UV coordinates id.
	*
	* <p>This is the next free index in the UV coordinates list, and used by setUVCoords</p>
	*
	* @return 	The index
	*/
	public function getNextUVCoordID():Int
	{
		return m_nLastUVId;
	}


	public function generateFaceNormals():Void
	{
		if( aFacesNormals.length > 0 )  return;
		else
		{
			for ( a in aFacesVertexID )
			{
				// If face is linear, as Line3D, no face normal to process
				if( a.length < 3 ) continue;
				// --
				var lA:Vertex, lB:Vertex, lC:Vertex;
				lA = aVertex[a[0]];
				lB = aVertex[a[1]];
				lC = aVertex[a[2]];
				// --
				var lV:Point3D = new Point3D( lB.wx - lA.wx, lB.wy - lA.wy, lB.wz - lA.wz );
				var lW:Point3D = new Point3D( lB.wx - lC.wx, lB.wy - lC.wy, lB.wz - lC.wz );
				// we compute de cross product
				var lNormal:Point3D = lV.cross( lW );
				// we normalize the resulting vector
				lNormal.normalize();
				// --
				setFaceNormal( getNextFaceNormalID(), lNormal.x, lNormal.y, lNormal.z );
			}
		}
	}

	/**
	* @todo Review behaviour of section "We update the number of faces these vertex belongs to". The indexOf being 0 means the index 0, not the "not found" which is -1
	*/
	public function generateVertexNormals():Void
	{
		if( aVertexNormals.length > 0 )  return;
		else
		{
			var lId:Int = 0;
			for( lId in 0...aFacesVertexID.length )
			{
				var l_aList:Array<Int> = aFacesVertexID[ lId ];
				// -- get the normal of that face
				var l_oNormal:Vertex = aFacesNormals[ lId ];
				// for some reason, no normal has been set up here.
				if( l_oNormal == null )
					continue;
				// -- add it to the corresponding vertex normals
				if( null == aVertexNormals[l_aList[0]] )
				{
					m_nLastVertexNormalId++;
					aVertexNormals[l_aList[0]] = new Vertex();
				}
				aVertexNormals[l_aList[0]].add( l_oNormal );

				if( null == aVertexNormals[l_aList[1]] )
				{
					m_nLastVertexNormalId++;
					aVertexNormals[l_aList[1]] = new Vertex();
				}
				aVertexNormals[l_aList[1]].add( l_oNormal );

				if( null == aVertexNormals[l_aList[2]] )
				{
					m_nLastVertexNormalId++;
					aVertexNormals[l_aList[2]] = new Vertex();
				}
				aVertexNormals[l_aList[2]].add( l_oNormal );

				// -- We update the number of faces these vertex belongs to
				/*
				if( ArrayUtil.indexOf( aVertex[l_aList[0]].aFaces, lId ) == 0 )
					aVertex[l_aList[0]].aFaces.push( lId );

				if( ArrayUtil.indexOf( aVertex[l_aList[1]].aFaces, lId ) == 0 )
					aVertex[l_aList[1]].aFaces.push( lId );

				if( ArrayUtil.indexOf( aVertex[l_aList[2]].aFaces, lId ) == 0 )
					aVertex[l_aList[2]].aFaces.push( lId );
				*/
				if( aVertex[l_aList[0]].aFaces[0] == lId )
					aVertex[l_aList[0]].aFaces.push( lId );

				if( aVertex[l_aList[1]].aFaces[0] == lId )
					aVertex[l_aList[1]].aFaces.push( lId );

				if( aVertex[l_aList[2]].aFaces[0] == lId )
					aVertex[l_aList[2]].aFaces.push( lId );


				aVertex[l_aList[0]].nbFaces++;
				aVertex[l_aList[1]].nbFaces++;
				aVertex[l_aList[2]].nbFaces++;
			}

			for( lId in 0...aVertexNormals.length )
			{
				var l_oVertex:Vertex = aVertex[ lId ];
				if ( l_oVertex.nbFaces == 0 ) continue;
				if( l_oVertex.nbFaces > 0 ) aVertexNormals[ lId ].scale( 1 / l_oVertex.nbFaces );
			}
		}
	}

	/**
	* Returns a clone of this Geometry3D.
	*
	* <p>NOTE: Because polygons also stores instance-specific data like Appearance
	* on the Geometry level, we are considering it only as a set of connections between points,
	* so only coordinates and normals are copied in the clone process.
	*
	* @return A copy of this geometry
	*/
	public function clone():Geometry3D
	{
		var l_result:Geometry3D = new Geometry3D();
		var i:Int = 0, l_oVertex:Vertex;
		// Points
		for ( l_oVertex in aVertex )
		{
			l_result.aVertex[i] = l_oVertex.clone();
			i++;
		}

		// Faces
		i = 0;
		for ( a in aFacesVertexID )
		{
			l_result.aFacesVertexID[i] = a.copy();
			i++;
		}

		// Normals
		i = 0;
		for ( l_oVertex in aFacesNormals )
		{
			l_result.aFacesNormals[i] = l_oVertex.clone();
			i++;
		}

		// Normals
		i = 0;
		for ( l_oVertex in aVertexNormals )
		{
			if ( l_oVertex != null ) {
			l_result.aVertexNormals[i] = l_oVertex.clone();
			} else {
			l_result.aVertexNormals[i] = null;
			}

			i++;
		}

		// UVs face
		i = 0;
		for ( b in aFacesUVCoordsID )
		{
			l_result.aFacesUVCoordsID[i] = b.copy();
			i++;
		}

		// UVs coords
		i = 0;
		for ( u in aUVCoords )
		{
			l_result.aUVCoords[i] = u.clone();
			i++;
		}

		i=0;
		for ( l_oEdge in aEdges )
		{
			l_result.aEdges[i] = l_oEdge.clone();
			i++;
		}

		i = 0;
		for ( l_oEdges in aFaceEdges )
		{
			l_result.aFaceEdges[i] = l_oEdges.copy();
			i++;
		}

		return l_result;
	}


	/**
	* Dispose all the geometry ressources.
	* Arrays data is removed, arrays are set to null value to make garbage collection possible
	*/
	public function dispose():Void
	{
		var a:Array<Int>, l_oVertex:Vertex;
		var l:Int;
		var u:UVCoord;
		// Points
		l = aVertex.length;
		for(i in 0...l)
		{
			l_oVertex = aVertex[i];
			l_oVertex.aFaces = null;
			l_oVertex = null;
		}
		aVertex = null;
		// Faces
		l = aFacesVertexID.length;
		for( i in 0...l)
		{
			aFacesVertexID[i] = null;
		}
		aFacesVertexID = null;
		// Normals
		l = aFacesNormals.length;
		for(i in 0...l)
		{
			l_oVertex = aFacesNormals[i];
			l_oVertex.aFaces = null;
			l_oVertex = null;
		}
		aFacesNormals = null;
		// Normals
		l = aVertexNormals.length;
		for(i in 0...l)
		{
			l_oVertex = aVertexNormals[i];
			if ( l_oVertex != null ) 
			{
				l_oVertex.aFaces = null;
				l_oVertex = null;
			}
		}
		aVertexNormals = null;
		// UVs face
		l = aFacesUVCoordsID.length;
		for(i in 0...l)
		{
			aFacesUVCoordsID[i] = null;
		}
		aFacesUVCoordsID = null;
		// UVs coords
		l = aUVCoords.length;
		for(i in 0...l)
		{
			aUVCoords[i] = null;
		}
		aUVCoords = null;
		// Edges
		for( l_sEdgeName in EDGES_DICO.keys() )
		{
			EDGES_DICO.remove(l_sEdgeName);
		}
		EDGES_DICO = null;
	}

	public function updateFaceNormals():Void
	{
		var idx : Int = 0;
		for ( a in aFacesVertexID )
		{
			// If face is linear, as Line3D, no face normal to process
			if( a.length < 3 ) continue;
			// --
			var lA:Vertex, lB:Vertex, lC:Vertex;
			lA = aVertex[a[0]];
			lB = aVertex[a[1]];
			lC = aVertex[a[2]];
			// --
			var lV:Point3D = new Point3D( lB.wx - lA.wx, lB.wy - lA.wy, lB.wz - lA.wz );
			var lW:Point3D = new Point3D( lB.wx - lC.wx, lB.wy - lC.wy, lB.wz - lC.wz );
			// we compute de cross product
			var lNormal:Point3D = lV.cross( lW );
			// we normalize the resulting vector
			lNormal.normalize();
			// --
			setFaceNormal( idx, lNormal.x, lNormal.y, lNormal.z );
			idx ++;
		}
	}

	/**
	* Returns a string representation of this geometry.
	*
	* <p>The string contins the lengths of the arrays of data defining this geometry.</p>
	* <p>[<b>ToDo</b>: Decide if this is the best representation ]</p>
	*
	* @return The string representation
	*/
	public function toString():String
	{
		return "[Geometry: " + 	aFacesVertexID.length + " faces, " +
				aVertex.length + " points, " +
				aFacesNormals.length + " normals, " +
				aUVCoords.length + " uv coords]";
	}

	/*public function debug():Void
	{
		trace("Faces: [" + faces.length + "] " + faces);
		trace("Points: [" + points.length + "] " + points);
		trace("Unique directions: [" + uniqueDirections.length + "] " + uniqueDirections);
		trace("Normals: [" + normals.length + "] " + normals);
		trace("UVs: [" + uv.length + "] " + uv);
	}*/

}

