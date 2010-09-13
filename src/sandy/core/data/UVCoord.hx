
package sandy.core.data;

import sandy.HaxeTypes;

/**
* A 2D coordinate point on a texture that corresponds to a vertex of a polygon.
*
* <p>The UVCoord represents the position of a vertex on the Bitmap used to &quot;dress&quot; a polygon.<br />
* It is the 2D texture coordinate, used in the BitmapMaterial and VideoMaterial.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		0.3
* @version		3.1
* @date 		24.08.2007
*
* @see http://en.wikipedia.org/wiki/UV_mapping
*/
class UVCoord
{
	/**
	 * The u coordinate.
	 */
	public var v: Float;

	/**
	 * The v coordinate.
	 */
	public var u: Float;

	/**
	* Creates a new UV coordinate.
	*
	* @param p_nU Float the x texture position  in the bitmap
	* @param p_nV Float the y texture position in the bitmap.
	*/
	public function new( ?p_nU: Float, ?p_nV: Float )
	{
		p_nU = (p_nU != null)?p_nU:0;
		p_nV = (p_nV != null)?p_nV:0;

		u = p_nU;
		v = p_nV;
	}

	/**
	* The length.
	*/
	public function length():Float
	{
		return Math.sqrt( u*u + v*v );
	}

	/**
	* Normalizes this UV coordinate.
	*
	* <p>A UV coordinate is normalized when its components are divided by its length.
	* The length is calculated by <code>Math.sqrt( u*u + v*v )</code>.</p>
	*/
	public function normalize():Void
	{
		var l_nLength:Float = length();
		u /= l_nLength;
		v /= l_nLength;
	}

	/**
	 * Substract the UVCoord passed as parameter to the current UVCoord.
	 * @param p_oUVCoord The UVCoord to substract
	 */
	public function sub( p_oUV:UVCoord ):Void
	{
		u -= p_oUV.u;
		v -= p_oUV.v;
	}

	/**
	* Adds the specified UV coordinate from this UV coordinate.
	*
	* @param p_oUV The UVCoord to add.
	*/
	public function add( p_oUV:UVCoord ):Void
	{
		u += p_oUV.u;
		v += p_oUV.v;
	}
	/**
	* Scales the texture coordinates by a factor.
	*
	* @param p_nFactor The factor.
	*/
	public function scale( p_nFactor:Float ):Void
	{
		u *= p_nFactor;
		v *= p_nFactor;
	}

	/**
	* Returns a string representation of this object.
	*
	* @return The fully qualified name of this object.
	*/
	public function toString(): String
	{
		return "sandy.core.data.UVCoord" + "(u:" + u+", v:" + v + ")";
	}

	/**
	* Returns a new UVCoord object that is a clone of the original instance.
	*
	* @return A new UVCoord object that is identical to the original.
	*/
	public function clone():UVCoord
	{
		return new UVCoord(u, v);
	}

	/**
	* Makes this UV coordinate a copy of the specified UV coordinate.
	*
	* <p>All components of the specified UV coordinate are copied to this UV coordinate.</p>
	*
	* @param p_oUV	The vertex to copy.
	*/
	public function copy( p_oUV:UVCoord ):Void
	{
		u = p_oUV.u;
		v = p_oUV.v;
	}
}

