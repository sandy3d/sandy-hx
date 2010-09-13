
package sandy.bounds;

import sandy.core.data.Matrix4;
import sandy.core.data.Pool;
import sandy.core.data.Point3D;
import sandy.core.data.Vertex;

import sandy.HaxeTypes;

/**
* The BBox class is used to quickly and easily clip an object in a 3D scene.
* <p>It creates a bounding box that contains the whole object.</p>
*
* @example 	This example is taken from the Shape3D class. It is used in
* 				the <code>updateBoundingVolumes()</code> method:
*
* <listing version="3.1">
*     _oBBox = BBox.create( m_oGeometry.aVertex );
*  </listing>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Russell Weir (madrok)
* @version		3.1
* @author		Niel Drummond - haXe port
* @date 		22.03.2006
*/
class BBox
{
	/**
	* Specifies if this object's boundaries are up to date with the object it is enclosing.
	* If <code>false</code>, this object's <code>transform()</code> method must be called to get its updated boundaries in the current frame.
	*/
	public var uptodate:Bool;

	/**
	* A Point3D representing the highest point of the cube volume.
	*/
	public var maxEdge:Point3D;

	/**
	* A Point3D representing the lowest point of the cube volume.
	*/
	public var minEdge:Point3D;

	/**
	* Creates a new <code>BBox</code> instance by passing the min and the max <code>Point3D</code>.
	*
	* @param p_min		Min vector, representing the lower point of the cube volume
	* @param p_max		Max vector, representing the upper point of the cube volume
	*/
	public function new( ?p_min:Point3D, ?p_max:Point3D )
	{
		// initializers
		uptodate = false;
		minEdge = (p_min != null) ? p_min : new Point3D();
		maxEdge = (p_max != null) ? p_max : new Point3D();
	}

	public function addInternalPoint(p_oPoint:Point3D):Void
	{
		if(p_oPoint.x > this.maxEdge.x)
		{
			this.maxEdge.x = p_oPoint.x;
		}
		if(p_oPoint.y > this.maxEdge.y)
		{
			this.maxEdge.y = p_oPoint.y;
		}
		if(p_oPoint.z > this.maxEdge.z)
		{
			this.maxEdge.z = p_oPoint.z;
		}
		if(p_oPoint.x < this.minEdge.x)
		{
			this.minEdge.x = p_oPoint.x;
		}
		if(p_oPoint.y < this.minEdge.y)
		{
			this.minEdge.y = p_oPoint.y;
		}
		if(p_oPoint.z < this.minEdge.z)
		{
			this.minEdge.z = p_oPoint.z;
		}
	}

	public function addInternalPointXYZ(x:Float,y:Float,z:Float):Void
	{
		if(x > this.maxEdge.x)
		{
			this.maxEdge.x = x;
		}
		if(y > this.maxEdge.y)
		{
			this.maxEdge.y = y;
		}
		if(z > this.maxEdge.z)
		{
			this.maxEdge.z = z;
		}
		if(x < this.minEdge.x)
		{
			this.minEdge.x = x;
		}
		if(y < this.minEdge.y)
		{
			this.minEdge.y = y;
		}
		if(z < this.minEdge.z)
		{
			this.minEdge.z = z;
		}
	}

	/**
	 * Returns a new BBox object that is a clone of the original instance.
	 *
	 * @return A new BBox object that is identical to the original.
	 */
	public function clone():BBox
	{
		var l_oBBox:BBox = new BBox();
		l_oBBox.maxEdge = maxEdge.clone();
		l_oBBox.minEdge = minEdge.clone();
		return l_oBBox;
	}

	/**
	 * Makes this BBox a copy of the specified BBox.
	 *
	 * <p>All elements of this BBox are set to those of the argument BBox</p>
	 *
	 * @param p_oPoint3D	The vector to copy
	 */
	public function copy( p_oBBox:BBox ):Void
	{
		this.uptodate = p_oBBox.uptodate;
		this.minEdge.copy(p_oBBox.minEdge);
		this.maxEdge.copy(p_oBBox.maxEdge);
	}

	/**
	* Merge the current BoundingBox with the one given in argument
	* @param pBounds The BBox object to merge the current BBox with
	*/
	public function merge(box:BBox):Void
	{
		this.addInternalPointXYZ(box.maxEdge.x, box.maxEdge.y, box.maxEdge.z);
		this.addInternalPointXYZ(box.minEdge.x, box.minEdge.y, box.minEdge.z);

		uptodate = false;
	}

	/**
	* Returns the center of the bounding box volume.
	*
	* @return A Point3D representing the center of the bounding box.
	*/
	public function getCenter():Point3D
	{
		return new Point3D((this.maxEdge.x + this.minEdge.x) / 2, (this.maxEdge.y + this.minEdge.y) / 2, (this.maxEdge.z + this.minEdge.z) / 2);
	}

	public function getEdges(edges:TypedArray<Point3D>):Void
	{
		if (edges == null) return;
		// --
		var centerX:Float = (this.maxEdge.x + this.minEdge.x) / 2;
		var centerY:Float = (this.maxEdge.y + this.minEdge.y) / 2;
		var centerZ:Float = (this.maxEdge.z + this.minEdge.z) / 2;
		var diagX:Float = centerX - this.maxEdge.x;
		var diagY:Float = centerY - this.maxEdge.y;
		var diagZ:Float = centerZ - this.maxEdge.z;

		var _g:Point3D = edges[0];
		_g.x = centerX + diagX;
		_g.y = centerY + diagY;
		_g.z = centerZ + diagZ;

		_g = edges[1];
		_g.x = centerX + diagX;
		_g.y = centerY - diagY;
		_g.z = centerZ + diagZ;

		_g = edges[2];
		_g.x = centerX + diagX;
		_g.y = centerY + diagY;
		_g.z = centerZ - diagZ;

		_g = edges[3];
		_g.x = centerX + diagX;
		_g.y = centerY - diagY;
		_g.z = centerZ - diagZ;

		_g = edges[4];
		_g.x = centerX - diagX;
		_g.y = centerY + diagY;
		_g.z = centerZ + diagZ;

		_g = edges[5];
		_g.x = centerX - diagX;
		_g.y = centerY - diagY;
		_g.z = centerZ + diagZ;

		_g = edges[6];
		_g.x = centerX - diagX;
		_g.y = centerY + diagY;
		_g.z = centerZ - diagZ;

		_g = edges[7];
		_g.x = centerX - diagX;
		_g.y = centerY - diagY;
		_g.z = centerZ - diagZ;
	}

	/**
	* Returns the depth (Z) of this box
	*
	* @return Size in Z direction
	*/
	public inline function getDepth() : Float {
		return Math.abs(maxEdge.z - minEdge.z);
	}

	/**
	* Returns the height (Y) of this box
	*
	* @return Size in Y direction
	*/
	public inline function getHeight() : Float {
		return Math.abs(maxEdge.y - minEdge.y);
	}

	/**
	* Return the size of the Bounding Box.
	*
	* @return 		A <code>Point3D</code> representing the size of the volume in three dimensions.
	*/
	public function getSize():Point3D
	{
		return new Point3D(	Math.abs(maxEdge.x - minEdge.x),
							Math.abs(maxEdge.y - minEdge.y),
							Math.abs(maxEdge.z - minEdge.z));
	}

	/**
	* Returns the width (X) of this box
	*
	* @return Size in X direction
	*/
	public inline function getWidth() : Float {
		return Math.abs(maxEdge.x - minEdge.x);
	}

	public function intersectsBox(box:BBox):Bool
	{
		return (this.minEdge.x <= box.maxEdge.x && this.minEdge.y <= box.maxEdge.y && this.minEdge.z <= box.maxEdge.z && this.maxEdge.x >= box.minEdge.x && this.maxEdge.y >= box.minEdge.y && this.maxEdge.z >= box.minEdge.z);
	}

	public function isPointInsideXYZ(x:Float,y:Float,z:Float):Bool
	{
		return (x >= this.minEdge.x && x <= this.maxEdge.x && y >= this.minEdge.y && y <= this.maxEdge.y && z >= this.minEdge.z && z <= this.maxEdge.z);
	}

	public function isPointTotalInside(p_oPoint:Point3D):Bool
	{
		return (p_oPoint.x > this.minEdge.x && p_oPoint.x < this.maxEdge.x && p_oPoint.y > this.minEdge.y && p_oPoint.y < this.maxEdge.y && p_oPoint.z > this.minEdge.z && p_oPoint.z < this.maxEdge.z);
	}

	/**
	* Returns a new bounding box based on this one that has
	* been 'moved' to the position [pos].
	*
	* @param pos New center position
	* @return new bounding box
	**/
	public function movedTo(pos : Point3D) : BBox {
		var max = maxEdge.clone();
		var min = minEdge.clone();
		var cen = getCenter();
		cen.sub(pos);
		max.sub(cen);
		min.sub(cen);
		//--
		var b = new BBox();
		b.maxEdge = max;
		b.minEdge = min;
		return b;
	}

	/**
	* Returns a new bounding box based on this one that has
	* been 'moved' to the position [pos]
	*
	* @param p_fX New center x position
	* @param p_fY New center y position
	* @param p_fZ New center z position
	* @return new bounding box
	**/
	public function movedToXYZ(p_fX:Float, p_fY:Float, p_fZ:Float) {
		return movedTo(new Point3D(p_fX, p_fY, p_fZ));
	}

	/**
	* Reset the current bounding box to an empoty box with 0,0,0 as max and min values
	*/
	public function reset():Void
	{
		minEdge.reset();
		maxEdge.reset();
		uptodate = false;
	}

	/**
	* Applies a transformation to the bounding box.
	*
	* @param p_oMatrix		The transformation matrix.
	* @return the transformed Bounding box
	*/
	public function transform( p_oMatrix:Matrix4 ):BBox
	{
		var l_oBox:BBox = new BBox();
		var inst = Pool.getInstance();
		var l_aEdges:TypedArray<Point3D> = Haxe.toTypedArray( [
							inst.nextPoint3D, inst.nextPoint3D, inst.nextPoint3D,
							inst.nextPoint3D, inst.nextPoint3D, inst.nextPoint3D,
							inst.nextPoint3D, inst.nextPoint3D] );
		// --
		getEdges( l_aEdges );
		// --
		for( l_oEdge in l_aEdges )
		{
			p_oMatrix.transform( l_oEdge );
			l_oBox.addInternalPoint( l_oEdge );
		}
		// --
		return l_oBox;
	}

	/**
	* Returns a <code>String</code> representation of the <code>BBox</code>.
	*
	* @return 	A String representing the bounding box
	*/
	public function toString():String
	{
		return "sandy.bounds.BBox "+minEdge.toString()+" "+maxEdge.toString();
	}

	/**
	* Creates a bounding box that encloses a 3D from an Array of the object's vertices.
	*
	* @param p_aVertices		The vertices of the 3D object the bounding box will contain.
	*
	* @return The BBox instance.
	*/
	public static function create( p_aVertices:Array<Vertex> ):BBox
	{
		if(p_aVertices.length == 0) return null;

		var l_oBox:BBox = new BBox();
		var l_oVertex:Vertex = p_aVertices [0];
		l_oBox.minEdge.reset ( l_oVertex.x, l_oVertex.y, l_oVertex.z );
		l_oBox.maxEdge.reset ( l_oVertex.x, l_oVertex.y, l_oVertex.z );
		for( l_oVertex in p_aVertices )
		{
			l_oBox.addInternalPointXYZ( l_oVertex.x, l_oVertex.y, l_oVertex.z );
		}
		return l_oBox;
	}
}

