
package sandy.core.data;

import sandy.util.BezierUtil;

import sandy.HaxeTypes;

/**
* A 3D Bézier path.
*
* <p>The Bézier path is built form an array of 3D points, by using Bézier equations<br />
* With two points the path is degenereated to a straight line. To get a curved line, you need
* at least three points. The mid point is used as a control point which gives the curvature.<br />
* After that you will have to add three point segments</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		24.08.2007
*/
class BezierPath
{
	/**
	 * Creates a new Bézier path.
	 */
	public function BezierPath( /*pbBoucle:Bool*/ )
	{
		_aContainer = new Array();
		_aSegments = new Array();
		_nCrtSegment = 0;
		_bBoucle = false;
		_bCompiled = false;
	}

	/**
	 * Returns a segment of this path identified by its sequence number.
	 *
	 * <p>The Bézier path is made up of a sequence of segments which are internally numbered.
	 * This method returns the n:th segment, where n is the passed in number.</p>
	 *
	 * @param	p_nId The number of the segment to return
	 * @return	An array containing the bezierCurve points [startPoint, controlPoint, endPoint]
	 */
	public function getSegment( p_nId:Int ):Array<Point3D>
	{
		if( p_nId >= 0 && p_nId < _nNbSegments )
		{
			return _aSegments[ p_nId ];
		}
		else
		{
			return null;
		}
	}

	/**
	 * Returns the position in the 3D space at a specific portion of this path.
	 *
	 * If you regard the whole length of the path as 1.0 (100%),
	 * and you need the position at 10% of the whole path,
	 * you pass 0.1 as an argument.
	 *
	 * @param	p_nP  The portion of the path length ( 0 - 1 )
	 * @return	The 3D position on the path at
	 */
	public function getPosition( p_nP:Float ):Point3D
	{
		var id:Int = Math.floor(p_nP/_nRatio);
		if( id == _nNbSegments )
		{
			id --;
			p_nP = 1.0;
		}
		var seg:Array<Point3D> = getSegment( id );
		return BezierUtil.getPointsOnQuadCurve( (p_nP-id*_nRatio)/_nRatio, seg[0], seg[1], seg[2] );
	}


	/**
	 * Adds a 3D point to this path.
	 *
	 * <p>NOTE: You can't add a point to the path once it has been compiled.</p>
	 * <p>Add at least three point for a a curved segment, then two new points for each segment,<br />
	 * the first a control point, the second an end point.</p>
	 *
	 * @param	p_nX The x coordinate of the 3D point
	 * @param	p_nY The y coordinate of the 3D point
	 * @param	p_nZ The z coordinate of the 3D point
	 * @return 	true if operation succeed, false otherwise.
	 */
	public function addPoint( p_nX:Float, p_nY:Float, p_nZ:Float ):Bool
	{
		if( _bCompiled )
		{
			return false;
		}
		else
		{
			_aContainer.push( new Point3D( p_nX, p_nY, p_nZ ) );
			return true;
		}
	}

	/**
	 * Computes all the control points for this path.
	 *
	 * <p>Must be called after the last point of the path has been added,
	 * and before being used by Sandy's engine.</p>
	 */
	public function compile():Void
	{
		_nNbPoints = _aContainer.length;
		if( _nNbPoints >= 3 &&  _nNbPoints%2 == 1 )
		{
			trace('sandy.core.data.BezierPath ERROR: Number of points incompatible');
			return;
		}
		_bCompiled = true;
		_nNbSegments = 0;
		var a:Point3D, b:Point3D, c:Point3D;
		var i:Int = 0;
		while ( i <= _nNbPoints-2 )
		{
			a = _aContainer[i];
			b = _aContainer[i+1];
			c = _aContainer[i+2];
			_aSegments.push( [ a, b, c ] );
			i+=2;
		}
		if( _bBoucle )
		{
			_aSegments.push([
							_aContainer[ _nNbPoints ],
							BezierUtil.getQuadControlPoints(_aContainer[ _nNbPoints ],_aContainer[ 0 ],_aContainer[ 1 ]),
							_aContainer[ 0 ]
							]);
		}
		// --
		_nNbSegments = _aSegments.length;
		_nRatio = 1 / _nNbSegments;
	}

	/**
	 * Returns the number of segments for this path.
	 *
	 * @return The number of segments
	 */
	public function getNumberOfSegments():Int
	{
		return _nNbSegments;
	}

	/**
	 * Returns a string represntation of the Bezier path.
	 *
	 * @return	A string representing the BezierPath.
	 */
	public function toString():String
	{
		return "sandy.core.data.BezierPath";
	}

	/**
	 * Transformed coordinates in the local frame of the object.
	 */
	private var _aContainer:Array<Point3D>;

	/**
	 * Array of segments.
	 */
	private var _aSegments:Array<Array<Point3D>>;


	/**
	 * Current segment id.
	 */
	private var _nCrtSegment:Int;

	/**
	 * Number of segments of this path.
	 */
	private var _nNbSegments:Int;

	/**
	 * Number of points of this path.
	 */
	private var _nNbPoints:Int;

	/**
	 * Should this path be closed? True if it should false otherwise, default - false
	 */
	private var _bBoucle:Bool;

	/**
	 * Is this path compiled? True if it is, false otherwise.
	 */
	private var _bCompiled:Bool;

	private var _nRatio:Float;

}

