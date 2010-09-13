
package sandy.core.data;

import sandy.HaxeTypes;

/**
* A plane in 3D space.
*
* <p>This class is used primarily to represent the frustrum planes of the camera.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		0.1
* @version		3.1
* @date 		24.08.2007
*
* @see sandy.view.Frustum
*/
class Plane
{
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;

	/**
	* Creates a new Plane instance.
	*
	* @param	p_nA	the first plane coordinate
	* @param	p_nB	the second plane coordinate
	* @param	p_nC	the third plane coordinate
	* @param	p_nd	the forth plane coordinate
	*/
	public function new( ?p_nA:Float, ?p_nB:Float, ?p_nC:Float, ?p_nd:Float )
	{
		p_nA = (p_nA != null)?p_nA:0.0;
		p_nB = (p_nB != null)?p_nB:0.0;
		p_nC = (p_nC != null)?p_nC:0.0;
		p_nd = (p_nd != null)?p_nd:0.0;

		this.a = p_nA;
		this.b = p_nB;
		this.c = p_nC;
		this.d = p_nd;
	}


	/**
	 * Returns a string represntation of this plane.
	 *
	 * @return	The string representing this plane.
	 */
	public function toString():String
	{
		return "sandy.core.data.Plane" + "(a:"+a+", b:"+b+", c:"+c+", d:"+d+")";
	}
}

