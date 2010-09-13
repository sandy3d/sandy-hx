
package sandy.bounds;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Vertex;

import sandy.HaxeTypes;

/**
* The BSphere class is used to quickly and easily clip an object in a 3D scene.
* <p>It creates a bounding sphere that contains the whole object</p>
*
* @example 	This example is taken from the Shape3D class. It is used in
* 				the <code>updateBoundingVolumes()</code> method:
*
* <listing version="3.1">
*     _oBSphere = BSphere.create( m_oGeometry.aVertex );
*  </listing>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Russell Weir
* @version		3.1
* @author		Niel Drummond - haXe port
* @date 		22.03.2006
*/
class BSphere
{
	/**
	* Specify if this object is up to date or not.
	* If false, you need to call its transform method to get its correct bounds in the desired frame.
	*/
	public var uptodate:Bool;

	public var center:Point3D;
	public var radius:Float;
	// -----------------------------
	//    [TRANSFORMED]  -----------
	public var position:Point3D;

	/**
	* <p>Create a new <code>BSphere</code> instance.</p>
	*/
	public function new()
	{
		uptodate = false;
		center = new Point3D();
		radius = 1;
		position = new Point3D();
	}

	/**
	 * Returns a new BSphere object that is a clone of the original instance.
	 *
	 * @return A new BSphere object that is identical to the original.
	 */
	public function clone() : BSphere {
		var s = new BSphere();
		s.uptodate = this.uptodate;
		s.center = this.center.clone();
		s.radius = this.radius;
		s.position = this.position.clone();
		return s;
	}

	/**
	* Performs the actual computing of the bounding sphere's center and radius
	*
	* @param p_aVertices		The vertices of the 3D object
	*/
	public function compute( p_aVertices:Array<Vertex> ):Void
	{
		if(p_aVertices.length == 0) return;
		var x:Float, y:Float, z:Float, d:Float, i:Int = 0, j:Int = 0, l:Int = p_aVertices.length;
		var p1:Vertex = p_aVertices[0].clone();
		var p2:Vertex = p_aVertices[0].clone();
		// find the farthest couple of points
		var dmax:Float = 0.0;
		var pA:Vertex, pB:Vertex;
		while( i < l )
		{
			j = i + 1;
			while( j < l )
			{
				pA = p_aVertices[i];
				pB = p_aVertices[j];
				x = pB.x - pA.x;
				y = pB.y - pA.y;
				z = pB.z - pA.z;
				d = x * x + y * y + z * z;
				if(d > dmax)
				{
					dmax = d;
					p1.copy( pA );
					p2.copy( pB );
				}
				j += 1;
			}
			i += 1;
		}
		// --
		center = new Point3D((p1.x + p2.x) / 2, (p1.y + p2.y) / 2, (p1.z + p2.z) / 2);
		radius = Math.sqrt(dmax) / 2;
	}

	/**
	* Computes the bounding sphere's radius
	*
	* @param p_aPoints		An array containing the sphere's points
	* @return 				The bounding sphere's radius
	*/
	private function computeRadius(p_aPoints:Array<Vertex>):Float
	{
		var x:Float, y:Float, z:Float, d:Float, dmax:Float = 0;
		var i:Int = 0, l:Int = p_aPoints.length;
		while( i < l )
		{
			x = p_aPoints[(i)].x - center.x;
			y = p_aPoints[(i)].x - center.x;
			z = p_aPoints[(i)].x - center.x;
			d = x * x + y * y + z * z;
			if(d > dmax) dmax = d;
			i++;
		}
		return Math.sqrt(dmax);
	}

	/**
	 * Makes this BSphere a copy of the specified BSphere.
	 *
	 * All elements of this BSphere are set to those of the argument BSphere
	 *
	 * @param p_oBBox	The BSphere to copy
	 */
	public function copy( p_oBSphere:BSphere ):Void
	{
		this.uptodate = p_oBSphere.uptodate;
		this.center.copy(p_oBSphere.center);
		this.radius = p_oBSphere.radius;
		this.position.copy(p_oBSphere.position);
	}

	/**
	* Returns the distance of a point from the surface.
	*
	* @return 	>0 if position is outside the sphere, <0 if inside, =0 if on the surface of the sphere
	*/
	public function distance(p_oPoint:Point3D):Float
	{
		var x:Float = p_oPoint.x - center.x;
		var y:Float = p_oPoint.y - center.y;
		var z:Float = p_oPoint.z - center.z;
		return  Math.sqrt(x * x + y * y + z * z) - radius;
	}

	/**
	* Return the positions of the array of Position p that are outside the BoundingSphere.
	*
	* @param 	An array containing the points to test
	* @return 	An array of points containing those that are outside. The array has a length
	* 			of 0 if all the points are inside or on the surface.
	*/
	private function pointsOutofSphere(p_aPoints:Array<Point3D>):Array<Point3D>
	{
		var r:Array<Point3D> = new Array();
		var i:Int = 0, l:Int = p_aPoints.length;

		while( i < l )
		{
			if(distance(p_aPoints[(i)]) > 0)
			{
				r.push( p_aPoints[(i)] );
			}

			i++;
		}
		return r;
	}

	/**
	* Reset the current bounding box to an empoty box with 0,0,0 as max and min values
	*/
	public function reset():Void
	{
		center.reset();
		radius = 0;
		position.reset();
		uptodate = false;
	}

	public function resetFromBox(box:BBox):Void
	{
		this.center.copy( box.getCenter() );
		this.radius = Math.sqrt(((box.maxEdge.x - this.center.x) * (box.maxEdge.x - this.center.x)) + ((box.maxEdge.y - this.center.y) * (box.maxEdge.y - this.center.y)) + ((box.maxEdge.z - this.center.z) * (box.maxEdge.z - this.center.z)));
	}

	/**
	* Returns a <code>String</code> represntation of the <code>BSphere</code>.
	*
	* @return	A String representing the bounding sphere
	*/
	public function toString():String
	{
		return "sandy.bounds.BSphere (center : "+center+", radius : "+radius + ")";
	}

	/**
	* Applies the transformation that is specified in the <code>Matrix4</code> parameter.
	*
	* @param p_oMatrix		The transformation matrix
	*/
	public function transform( p_oMatrix:Matrix4 ):Void
	{
		position.copy( center );
		p_oMatrix.transform( position );
		uptodate = true;
	}

	//////////////////// STATICS ////////////////////////////////////
	/**
	* Creates a bounding sphere that encloses a 3D object. This object's vertices are passed
	* to the <code>create</code> method in the form of an <code>Array</code>. Very useful
	* for clipping and thus performance!
	*
	* @param p_aVertices		The vertices of the 3D object
	* @return 					A <code>BSphere</code> instance
	*/
	public static function create( p_aVertices:Array<Vertex> ):BSphere
	{
		var l_sphere:BSphere = new BSphere();
		l_sphere.compute( p_aVertices );
		return l_sphere;
	}

}

