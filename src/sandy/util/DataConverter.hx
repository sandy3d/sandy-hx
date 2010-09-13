package sandy.util;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Quaternion;

/**
 * Tools for converting data formats
 *
 * @author		Russell Weir (madrok)
 * @date		03.21.2009
 * @version		3.2
 **/
class DataConverter {

	/**
	* Convert a 3x3 rotation matrix from an arbitrary data format to Sandy
	*
	* @param matrix The matrix to convert
	* @dataOrder The order of the data in the matrix
	**/
	public static function rotationMatrix3x3ToSandy(matrix:Matrix4, dataOrder:DataOrder) : Matrix4 {
		switch(dataOrder) {
		case DATA_SANDY:
			return matrix;
		case DATA_MD3:
			var nm = new Matrix4();
			// m3d basis  (read in lines) ( a b c   d e f   g h i )
			// sandy basis should be ( e f d   h i g   b c a )
			nm.n33 = matrix.n11; // a
			nm.n31 = matrix.n12; // b
			nm.n32 = matrix.n13; // c
			nm.n13 = matrix.n21; // d
			nm.n11 = matrix.n22; // e
			nm.n12 = matrix.n23; // f
			nm.n23 = matrix.n31; // g
			nm.n21 = matrix.n32; // h
			nm.n22 = matrix.n33; // i
			// x rotation is reverse of Sandy
			var q = sandy.math.QuaternionMath.setByMatrix(nm);
			q.x = -q.x;
			nm = sandy.math.QuaternionMath.getRotationMatrix(q);
			return nm;
		}
	}

	public static function point3DToSandy(point:Point3D, dataOrder:DataOrder) : Point3D {
		switch(dataOrder) {
		case DATA_SANDY:
			return point;
		case DATA_MD3:
			// quake MD3->Sandy == x->z y->x z->y
			var p = new Point3D();
			p.x = point.y;
			p.y = point.z;
			p.z = point.x;
			return p;
		}
	}

}