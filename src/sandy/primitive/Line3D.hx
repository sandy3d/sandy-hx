package sandy.primitive;

import sandy.core.data.Point3D;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;

import sandy.HaxeTypes;

/**
* The Line3D class is used for creating a line in 3D space.
*
* <p>The line is created by passing a comma delimited argument list containing vectors.<br/>
* A Line3D object can only use the WireFrameMaterial[?]</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir
* @version		3.1
* @date 		26.07.2007
*
* @example To create a line between ( x0, y0, z0 ), ( x1, y1, z1 ), ( x2, y2, z3 ),
* use the following statement:
*
* <listing version="3.1">
*     var myLine:Line3D = new Line3D( "aLine", new Point3D(x0, y0, z0), new Point3D( x1, y1, z1 ), new Point3D( x2, y2, z3 ));
*  </listing>
*/
class Line3D extends Shape3D, implements Primitive3D
{
	private var rest_in : Array<Point3D>;
	/**
	* Creates a Line3D primitive.
	*
	* <p>A line is drawn between vectors in the order they are passed. A minimum of two vectors must be passed.</p>
	*
	* @param p_sName	A string identifier for this object.
	* @param ...rest 	A comma delimited list of vectors.
	*
	* @see sandy.core.data.Point3D
	*/
	public function new ( p_sName:String=null, rest : Array<Point3D> )
	{
		super ( p_sName );

		if( rest.length < 2)
		{
			trace('Line3D::Too few arguments');
			// Should throw an exception, frankly
		}
		else
		{
			rest_in = rest;
			geometry = generate( rest );
			enableBackFaceCulling = false;
		}
	}

	public override function clone( ?p_sName:String = "", ?p_bKeepTransform:Bool=false ):Shape3D
	{
		var o = new Line3D( p_sName, rest_in);
		o.copy(this, p_bKeepTransform, false);
		return o;
	}

	/**
	* Generates the geometry for the line.
	*
	* @return The geometry object for the line.
	*
	* @see sandy.core.scenegraph.Geometry3D
	*/
	public function generate <T>( ?arguments:Array<T> ) : Geometry3D
	{
		if ( arguments == null ) arguments = [];

		var l_oGeometry:Geometry3D = new Geometry3D();
		var l_aPoints:Array<Point3D> = cast arguments;
		// --
		var i:Int = 0;
		var l:Int = l_aPoints.length;
		// --
		while( i < l )
		{
			l_oGeometry.setVertex( i, l_aPoints[i].x, l_aPoints[i].y, l_aPoints[i].z );
			i++;
		}
		// -- initialisation
		i = 0;
		while( i < l-1 )
		{
			l_oGeometry.setFaceVertexIds( i, [i, i+1] );
			i++;
		}
		// --
		return l_oGeometry;
	}

	/**
	* @private
	*/
	public override function toString():String
	{
		return "sandy.primitive.Line3D";
	}
}

