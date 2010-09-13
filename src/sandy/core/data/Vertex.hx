
package sandy.core.data;

import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* A vertex is the point of intersection of edges the of a polygon.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		24.08.2007
*/
class Vertex
{
	private static var ID:Int = 0;

	/**
	* Vertex flags that can be SandyFlags.VERTEX_WORLD, SandyFlags.VERTEX_CAMERA or SandyFlags.VERTEX_PROJECTED
	* Need to aVoid unecessary computations
	*/
	public var flags:Int;

	public var projected:Bool;
	public var transformed:Bool;

	public var id:Int;

	public var x:Float;
	public var y:Float;
	public var z:Float;

	/**
	* properties used to store transformed positions in the World coordinates
	*/
	public var wx:Float;
	public var wy:Float;
	public var wz:Float;

	/**
	* properties used to store transformed coordinates in screen World.
	*/
	public var sx:Float;
	public var sy:Float;

	/**
	* Float of polygons this vertex belongs to.
	* <p>Default value is 0.</p>
	*/
	public var nbFaces:Int;

	/**
	* An array of faces.
	*
	* <p>List of polygons that actually use that vertex</p>
	*/
	public var aFaces:Array<Int>;


	/**
	* Creates a new vertex.
	*
	* @param p_nx 	The x position
	* @param p_ny 	The y position
	* @param p_nz 	The z position
	* @param ...rest	optional values for wx, wy, wz
	*/
	public function new( ?p_nx:Float=0.0, ?p_ny:Float=0.0, ?p_nz:Float=0.0, ?restx:Float, ?resty:Float, ?restz:Float )
	{
		//initializers
		flags = 0;
		projected = false;
		transformed = false;
		id = ID ++;
		nbFaces = 0;
		aFaces = new Array();
		//private initializers
		m_oCamera = new Point3D();
		m_oLocal = new Point3D();

		x = p_nx;
		y = p_ny;
		z = p_nz;
		// --
		wx = (restx != null)?restx:x;
		wy = (resty != null)?resty:y;
		wz = (restz != null)?restz:z;
		// --
		sy = sx = 0;
	}

	/**
	* Reset the values of that vertex.
	* This allows to change all the values of that vertex in one method call instead of acessing to each public property.
	*  @param p_nX Value for x and wx properties
	*  @param p_nY Value for y and wy properties
	*  @param p_nZ Value for z and wz properties
	*/
	public function reset( p_nX:Float, p_nY:Float, p_nZ:Float ):Void
	{
		x = p_nX;
		y = p_nY;
		z = p_nZ;
		wx = x;
		wy = y;
		wz = z;
	}

	/**
	* Returns the 2D position of this vertex.
	* This 2D position is the position on the screen after the camera projection.
	* WARNING: There's actually a third value (the z one) which correspond to the depth screen position.
	* @return Point3D The 2D position of this vertex once projected.
	*/
	public function getScreenPoint():Point3D
	{
		return new Point3D( sx, sy, wz );
	}

	/**
	* Returns a Point3D of the transformed vertex.
	*
	* @return A Point3D of the transformed vertex.
	*/
	public function getCameraPoint3D():Point3D
	{
		m_oCamera.x = wx;
		m_oCamera.y = wy;
		m_oCamera.z = wz;
		return m_oCamera;
	}

	/**
	* Returns a Point3D representing the original x, y, z coordinates.
	*
	* @return A Point3D representing the original x, y, z coordinates.
	*/
	public function getPoint3D():Point3D
	{
		m_oLocal.x = x;
		m_oLocal.y = y;
		m_oLocal.z = z;
		return m_oLocal;
	}

	/**
	* Returns a new Vertex object that is a clone of the original instance.
	*
	* @return A new Vertex object that is identical to the original.
	*/
	public function clone():Vertex
	{
		var l_oV:Vertex = new Vertex( x, y, z );
		l_oV.wx = wx;    l_oV.sx = sx;
		l_oV.wy = wy;    l_oV.sy = sy;
		l_oV.wz = wz;
		l_oV.nbFaces = nbFaces;
		l_oV.aFaces = aFaces.concat([]);
		return l_oV;
	}

	/**
	* Returns a new vertex build on the transformed values of this vertex.
	*
	* <p>A new vertex is created with this vertex's transformed coordinates as start position.<br />
	* So ( x, y, z ) of the new vertex is the ( wx, wy, wz ) of this vertex.</p>
	* <p>[<strong>ToDo</strong>: What can this one be used for? - Explain! ]</p>
	*
	* @return 	The new vertex
	*/
	public function clone2():Vertex
	{
		return new Vertex( wx, wy, wz );
	}

	/**
	* Creates and returns a new vertex from the specified vector.
	*
	* @param p_v	The vertex position vector
	* @return 	The new vertex
	*/
	static public function createFromPoint3D( p_v:Point3D ):Vertex
	{
		return new Vertex( p_v.x, p_v.y, p_v.z );
	}

	/**
	* Is this vertex equal to the specified vertex?.
	*
	* <p>This vertex is compared to the argument vertex, component by component.<br />
	* If all components of the two vertices are equal, a true value is returned.
	*
	* @return 	true if the vertices are considered equal, false otherwise
	*/
	public function equals(p_vertex:Vertex):Bool
	{
		return ( p_vertex.x  ==  x && p_vertex.y  ==  y && p_vertex.z  ==  z &&
				p_vertex.wx == wx && p_vertex.wy == wy && p_vertex.wz == wz &&
				p_vertex.sx == wx && p_vertex.sy == sy);
	}

	/**
	* Makes this vertex equal to the specified vertex.
	*
	* <p>All components of the argument vertex are copied to this vertex.</p>
	*
	* @param 	The vertex to copy to this
	*/
	public function copy( p_oPoint3D:Vertex ):Void
	{
		x = p_oPoint3D.x;
		y = p_oPoint3D.y;
		z = p_oPoint3D.z;
		wx = p_oPoint3D.wx;
		wy = p_oPoint3D.wy;
		wz = p_oPoint3D.wz;
		sx = p_oPoint3D.sx;
		sy = p_oPoint3D.sy;
	}

	/**
	* Returns the norm of this vertex.
	*
	* <p>The norm of the vertex is calculated as the length of its position vector.<br />
	* That is sqrt( x*x + y*y + z*z )</p>
	*
	* @return 	The norm
	*/
	public function getNorm():Float
	{
		return Math.sqrt( x*x + y*y + z*z );
	}

	/**
	* Return the invers of this vertex.
	*
	* <p>A new vertex is created with the negative of all values in this vertex.</p>
	*
	* @return 	The invers
	*/
	public function negate( /*v:Vertex*/ ): Void
	{
		// The argument is commented out, as it is not used - Petit
		x = -x;
		y = -y;
		z = -z;
		wx = -wx;
		wy = -wy;
		wz = -wz;
		//return new Vertex( -x, -y, -z, -wx, -wy, -wz);
	}

	/**
	* Adds a specified vertex to this vertex.
	*
	* @param v 	The vertex to add to this vertex
	*/
	public function add( v:Vertex ):Void
	{
		x += v.x;
		y += v.y;
		z += v.z;

		wx += v.wx;
		wy += v.wy;
		wz += v.wz;
	}

	/**
	* Substracts a specified vertex from this vertex.
	*
	* @param v 	The vertex to subtract from this vertex
	*/
	public function sub( v:Vertex ):Void
	{
		x -= v.x;
		y -= v.y;
		z -= v.z;
		wx -= v.wx;
		wy -= v.wy;
		wz -= v.wz;
	}

	/**
	* Raises the vertex to the specified power.
	*
	* <p>All components of this vertex is raised to the power specified in the argument.</p>
	*
	* @param {@code pow} a {@code Float}.
	*/
	public function pow( pow:Float ):Void
	{
		x = Math.pow( x, pow );
		y = Math.pow( y, pow );
		z = Math.pow( z, pow );
		wx = Math.pow( wx, pow );
		wy = Math.pow( wy, pow );
		wz = Math.pow( wz, pow );
	}

	/**
	* Multiplies this vertex by the specified scalar value.
	*
	* <p>All components of the vertex are multiplied by the specified value</p>
	*
	* @param n 	The number to multiply with
	*/
	public function scale( n:Float ):Void
	{
		x *= n;
		y *= n;
		z *= n;
		wx *= n;
		wy *= n;
		wz *= n;
	}

	/**
	* Returns the dot product between this vertex and a specified vertex.
	*
	* <p>Only the original positions values are used for this dot product.</p>
	*
	* @param w 	The vertex to make a dot product with
	* @return 	The dot product
	*/
	public function dot( w: Vertex):Float
	{
		return ( x * w.x + y * w.y + z * w.z );
	}

	/**
	* Returns the cross product between this vertex and the specified vertex.
	*
	* <p>Only the original positions values are used for this cross product.</p>
	*
	* @param v 	The vertex to make a cross product with
	* @return 	the resulting vertex of the cross product.
	*/
	public function cross( v:Vertex):Vertex
	{
		// cross product vector that will be returned
			// calculate the components of the cross product
		return new Vertex( 	(y * v.z) - (z * v.y) ,
							(z * v.x) - (x * v.z) ,
							(x * v.y) - (y * v.x) );
	}

	/**
	* Normalizes this vertex.
	*
	* <p>Normalization means that all components of the vertex are divided by its norm.<br />
	* The norm is calculated as the sqrt(x*x + y*y + z*z), that is the length of the position vector.</p>
	*/
	public function normalize():Void
	{
		// -- We get the norm of the vector
		var norm:Float = getNorm();
		// -- We escape the process is norm is null or equal to 1
		if( norm == 0 || norm == 1) return;
		x = x / norm;
		y = y / norm;
		z = z / norm;

		wx /= norm;
		wy /= norm;
		wz /= norm;

	}

	/**
	* Returns the angle between this vertex and the specified vertex.
	*
	* @param w	The vertex making an angle with this one
	* @return 	The angle in radians
	*/
	public function getAngle ( w:Vertex ):Float
	{
		var ncos:Float = dot( w ) / ( getNorm() * w.getNorm() );
		var sin2:Float = 1 - ncos * ncos;
		if (sin2<0)
		{
			trace(" wrong "+ncos);
			sin2 = 0;
		}
		//I took long time to find this bug. Who can guess that (1-cos*cos) is negative ?!
		//sqrt returns a NaN for a negative value !
		return  Math.atan2( Math.sqrt(sin2), ncos );
	}


	/**
	* Returns a string representing this vertex.
	*
	* @param decPlaces	Float of decimals
	* @return	The representation
	*/
	public function toString():String
	{
		var decPlaces = 0.01;
		
		// Round display to two decimals places
		// Returns "{x, y, z}"
		return "{" + 	NumberUtil.roundTo(x, decPlaces) + ", " +
				NumberUtil.roundTo(y, decPlaces) + ", " +
				NumberUtil.roundTo(z, decPlaces) + ", " +
				NumberUtil.roundTo(wx, decPlaces) + ", " +
				NumberUtil.roundTo(wy, decPlaces) + ", " +
				NumberUtil.roundTo(wz, decPlaces) + ", " +
				NumberUtil.roundTo(sx, decPlaces) + ", " +
				NumberUtil.roundTo(sy, decPlaces) + "}";
	}


	// Useful for XML output
	/**
	* Returns a string representation of this vertex with rounded values.
	*
	* <p>[<strong>ToDo</strong>: Explain why this is good for XML output! ]</p>
	*
	* @param decPlaces	Float of decimals
	* @return 		The specific serialize string
	*/
	public function serialize(?decPlaces:Float):String
	{
		decPlaces = (decPlaces != null)?decPlaces:0;

		if (decPlaces == 0)
		{
			decPlaces = .01;
		}
		//returns x,y,x
		return  (NumberUtil.roundTo(x, decPlaces) + "," +
				NumberUtil.roundTo(y, decPlaces) + "," +
				NumberUtil.roundTo(z, decPlaces) + "," +
				NumberUtil.roundTo(wx, decPlaces) + "," +
				NumberUtil.roundTo(wy, decPlaces) + "," +
				NumberUtil.roundTo(wz, decPlaces) + "," +
				NumberUtil.roundTo(sx, decPlaces) + "," +
				NumberUtil.roundTo(sy, decPlaces));
	}

	// Useful for XML output
	/**
	* Sets the elements of this vertex from a string representation.
	*
	* <p>[<strong>ToDo</strong>: Explain why this is good for XML intput! ]</p>
	*
	* @param 	A string representing the vertex ( specific serialize format )
	*/
	public function deserialize(convertFrom:String):Void
	{
		var tmp:Array<String> = convertFrom.split(",");
		if (tmp.length != 9)
		{
			trace ("Unexpected length of string to deserialize into a vector " + convertFrom);
		}

		x = Std.parseFloat(tmp[0]);
		y = Std.parseFloat(tmp[1]);
		z = Std.parseFloat(tmp[2]);

		wx = Std.parseFloat(tmp[3]);
		wy = Std.parseFloat(tmp[4]);
		wz = Std.parseFloat(tmp[5]);

		sx = Std.parseFloat(tmp[6]);
		sy = Std.parseFloat(tmp[7]);
	}

	private var m_oCamera:Point3D;
	private var m_oLocal:Point3D;
}

