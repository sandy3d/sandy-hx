
package sandy.core.data;

import sandy.HaxeTypes;

/**
* <p>The Edge3D class stores two related Vertex objects that make an edge.
* Multiple polygons can share similar vertices, which are considered edges.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @since		1.0
* @version		3.1
* @date 		24.08.2007
*
* @see sandy.core.data.Polygon
* @see sandy.core.scenegraph.Geometry3D
*/

class Edge3D
{
	/**
	 * [READ-ONLY]
	 * First ID of the vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
	 */
	public var vertexId1:Int;
	/**
	 * [READ-ONLY]
	 * Second ID of the vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
	 */
	public var vertexId2:Int;

	/**
	 * [READ-ONLY]
	 * First vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
	 */
	public var vertex1:Vertex;

	/**
	 * [READ-ONLY]
	 * Second vertex which compose the EDGE. The ID correspond to the Geometry3D aVertex list
	 */
	public var vertex2:Vertex;

	/**
	 * Creates an Edge3D from two vertices.
	 *
	 */
	public function new( p_nVertexId1:Int, p_nVertexId2:Int )
	{
		vertexId1 = p_nVertexId1;
		vertexId2 = p_nVertexId2;
	}

	public function clone():Edge3D
	{
		var l_oEdge:Edge3D = new Edge3D( vertexId1, vertexId2 );
		return l_oEdge;
	}

}

