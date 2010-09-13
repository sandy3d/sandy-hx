
package sandy.math;

import flash.geom.Matrix;

import sandy.core.data.Vertex;
import sandy.errors.SingletonError;

import sandy.HaxeTypes;

/**
* Math functions for vertex manipulation.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		0.2
* @version		3.1
* @date 		26.07.2007
*/
class VertexMath extends Point3DMath
{
	private static var instance:VertexMath;
	private static var create:Bool;

	/**
	 * Creates a VertexMath object.
	 *
	 * <p>This is a singleton constructor, and should not be called directly.<br />
	 * If called from outside the ColorMath class, it throws a SingletonError.</p>
	 * [<strong>ToDo</strong>: Why instantiate this at all? - all methods are class methods! ]
	 */
	private function new(){
		if ( !create )
		{
			throw new SingletonError();
		}
	}

	/**
	 * Returns an instance of this class.
	 *
	 * <p>Call this method to get an instance of VertexMath</p>
	 */
	public static function getInstance():VertexMath
	{
		if (instance == null)
		{
			create = true;
			instance = new VertexMath();
			create = false;
		}

		return instance;
	}

	/**
	 * Computes the opposite of a vertex.
	 *
	 * <p>The "opposite" vertex is a vertex where all components are multiplied by -1</p>
	 *
	 * @param p_oV 	The vertex.
	 * @return 	The opposite vertex.
	 */
	public static function negate( p_oV:Vertex ): Vertex
	{
		return new Vertex (
					- p_oV.x,
                      			- p_oV.y,
               				- p_oV.z
               			);
	}

	/**
	 * Computes the dot product of the two vertices.
	 *
	 * @param p_oV 	The first vertex
	 * @param p_oW 	The second vertex
	 * @return 	The dot procuct
	 */
	public static function dot( p_oV: Vertex, p_oW: Vertex):Float
	{
		return ( p_oV.wx * p_oW.wx + p_oV.wy * p_oW.wy + p_oW.wz * p_oV.wz );
	}

	/**
	 * Adds the two vertices.
	 *
	 * <p>[<strong>ToDo</strong>: Check here! We should add all the properties of the vertices! ]</p>
	 *
	 * @param p_oV 	The first vertex
	 * @param p_oW 	The second vertex
	 * @return 	The resulting vertex
	 */
	public static function addVertex( p_oV:Vertex, p_oW:Vertex ): Vertex
	{
		return new Vertex(	p_oV.x + p_oW.x ,
                	        p_oV.y + p_oW.y ,
                	        p_oV.z + p_oW.z,
                	        p_oV.wx + p_oW.wx ,
                	        p_oV.wy + p_oW.wy ,
                	        p_oV.wz + p_oW.wz );
	}

	/**
	 * Substracts one vertices from another
	 *
	 * @param p_oV 	The vertex to subtract from
	 * @param p_oW	The vertex to subtract
	 * @return 	The resulting vertex
	 */
	public static function sub( p_oV:Vertex, p_oW:Vertex ): Vertex
	{
		return new Vertex(
					p_oV.x - p_oW.x ,
					p_oV.y - p_oW.y ,
					p_oV.z - p_oW.z ,
					p_oV.wx - p_oW.wx ,
					p_oV.wy - p_oW.wy ,
					p_oV.wz - p_oW.wz
				);
	}

	/**
	 * Computes the cross product the two vertices.
	 *
	 * @param p_oV 	The first vertex
	 * @param p_oW 	The second vertex
	 * @return 	The resulting cross product
	 */
	public static function cross(p_oW:Vertex, p_oV:Vertex):Vertex
	{
		// cross product vector that will be returned
		return new Vertex (	(p_oW.y * p_oV.z) - (p_oW.z * p_oV.y) ,
					(p_oW.z * p_oV.x) - (p_oW.x * p_oV.z) ,
					(p_oW.x * p_oV.y) - (p_oW.y * p_oV.x)
				);
	}

	/**
	 * Clones a vertex.
	 *
	 * @param p_oV	A vertex to clone.
	 * @return 	The clone
	 */
	public static function clone( p_oV:Vertex ): Vertex
	{
		return new Vertex( p_oV.x, p_oV.y, p_oV.z );
	}

	/**
	 * Calculates linear gradient matrix from three vertices and ratios
	 *
	 * <p>This function expects vertices to be ordered in such a way that p_nR0 &lt; p_nR1 &lt; p_n2.
	 * Ratios can be scaled by any positive factor;
	 * see beginGradientFill documentation for ratios meaning.</p>
	 *
	 * @param p_oV0 Left-most vertex in a gradient.
	 * @param p_oV1 Inner vertex in a gradient.
	 * @param p_oV2 Right-most vertex in a gradient.
	 * @param p_nR0 Ratio for p_oV0.
	 * @param p_nR1 Ratio for p_oV1.
	 * @param p_nR2 Ratio for p_oV2.
	 * @param p_oMatrix (Optional) matrix object to use.
	 * @return 	The matrix to use with beginGradientFill, GradientType.LINEAR.
	 */
	public static function linearGradientMatrix (p_oV0:Vertex, p_oV1:Vertex, p_oV2:Vertex,
		p_nR0:Float, p_nR1:Float, p_nR2:Float, ?p_oMatrix:Matrix):Matrix
	{
		var coef:Float = (p_nR1 - p_nR0) / (p_nR2 - p_nR0);
		var p3x:Float = p_oV0.sx + coef * (p_oV2.sx - p_oV0.sx);
		var p3y:Float = p_oV0.sy + coef * (p_oV2.sy - p_oV0.sy);
		var p4x:Float = p_oV2.sx - p_oV0.sx;
		var p4y:Float = p_oV2.sy - p_oV0.sy;
		var p4len:Float = Math.sqrt (p4x*p4x + p4y*p4y);
		var d:Float = Math.atan2 (p3x - p_oV1.sx, -(p3y - p_oV1.sy));

		if (p_oMatrix != null)
			p_oMatrix.identity ();
		else
			p_oMatrix = new Matrix ();

		p_oMatrix.a = Math.cos (Math.atan2 (p4y, p4x) - d) * p4len / (32768 * 0.05);
		p_oMatrix.rotate (d);
		p_oMatrix.translate ((p_oV2.sx + p_oV0.sx) / 2, (p_oV2.sy + p_oV0.sy) / 2);

		return p_oMatrix;
	}
}

