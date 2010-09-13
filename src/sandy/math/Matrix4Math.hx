package sandy.math;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* Math functions for Matrix4 calculations.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Russell Weir - haXe port
* @since		0.1
* @version		3.1
* @date 		26.07.2007
*
* @see sandy.core.data.Matrix4
*/
class Matrix4Math
{
	/**
		* Computes the multiplication of two Matrix4 matrices, as if they were 3x3.
		*
		* @param m1 	The first matrix.
		* @param m2	The second matrix.
		*
		* @return The resulting matrix.
		*/
	public static function multiply3x3(m1:Matrix4, m2:Matrix4) : Matrix4
	{
		var m111:Float = m1.n11, m211:Float = m2.n11,
		m121:Float = m1.n21, m221:Float = m2.n21,
		m131:Float = m1.n31, m231:Float = m2.n31,
		m112:Float = m1.n12, m212:Float = m2.n12,
		m122:Float = m1.n22, m222:Float = m2.n22,
		m132:Float = m1.n32, m232:Float = m2.n32,
		m113:Float = m1.n13, m213:Float = m2.n13,
		m123:Float = m1.n23, m223:Float = m2.n23,
		m133:Float = m1.n33, m233:Float = m2.n33;

		return new Matrix4
		(
			m111 * m211 + m112 * m221 + m113 * m231,
			m111 * m212 + m112 * m222 + m113 * m232,
			m111 * m213 + m112 * m223 + m113 * m233,
			0,
			m121 * m211 + m122 * m221 + m123 * m231,
			m121 * m212 + m122 * m222 + m123 * m232,
			m121 * m213 + m122 * m223 + m123 * m233,
			0,
			m131 * m211 + m132 * m221 + m133 * m231,
			m131 * m212 + m132 * m222 + m133 * m232,
			m131 * m213 + m132 * m223 + m133 * m233,
			0,
			0,0,0,1
		);
	}


	/**
		* Computes the multiplication of two Matrix4 matrices.
		*
		* <p>[<strong>ToDo</strong>: Explain this multiplication ]</p>
		*
		* @param m1 	The first matrix.
		* @param m2	The second matrix.
		*
		* @return The resulting matrix.
		*/
	public static function multiply4x3( m1:Matrix4, m2:Matrix4 ):Matrix4
	{
		var m111:Float = m1.n11, m211:Float = m2.n11,
			m121:Float = m1.n21, m221:Float = m2.n21,
			m131:Float = m1.n31, m231:Float = m2.n31,
			m112:Float = m1.n12, m212:Float = m2.n12,
			m122:Float = m1.n22, m222:Float = m2.n22,
			m132:Float = m1.n32, m232:Float = m2.n32,
			m113:Float = m1.n13, m213:Float = m2.n13,
			m123:Float = m1.n23, m223:Float = m2.n23,
			m133:Float = m1.n33, m233:Float = m2.n33,
			m214:Float = m2.n14, m224:Float = m2.n24,	m234:Float = m2.n34;

		return new Matrix4
		(
			m111 * m211 + m112 * m221 + m113 * m231,
			m111 * m212 + m112 * m222 + m113 * m232,
			m111 * m213 + m112 * m223 + m113 * m233,
			m214 * m111 + m224 * m112 + m234 * m113 + m1.n14,

			m121 * m211 + m122 * m221 + m123 * m231,
			m121 * m212 + m122 * m222 + m123 * m232,
			m121 * m213 + m122 * m223 + m123 * m233,
			m214 * m121 + m224 * m122 + m234 * m123 + m1.n24,

			m131 * m211 + m132 * m221 + m133 * m231,
			m131 * m212 + m132 * m222 + m133 * m232,
			m131 * m213 + m132 * m223 + m133 * m233,
			m214 * m131 + m224 * m132 + m234 * m133 + m1.n34,

			0, 0, 0, 1
		);
	}

	/**
		* Computes the multiplication of two Matrix4 matrices.
		*
		* <p>[<strong>ToDo</strong>: Explain this multiplication ]</p>
		*
		* @param m1 	The first matrix.
		* @param m2	The second matrix.
		*
		* @return The resulting matrix.
		*/
	public static function multiply(m1:Matrix4, m2:Matrix4) : Matrix4
	{
		var m111:Float = m1.n11, m121:Float = m1.n21, m131:Float = m1.n31, m141:Float = m1.n41,
			m112:Float = m1.n12, m122:Float = m1.n22, m132:Float = m1.n32, m142:Float = m1.n42,
			m113:Float = m1.n13, m123:Float = m1.n23, m133:Float = m1.n33, m143:Float = m1.n43,
			m114:Float = m1.n14, m124:Float = m1.n24, m134:Float = m1.n34, m144:Float = m1.n44,
			m211:Float = m2.n11, m221:Float = m2.n21, m231:Float = m2.n31, m241:Float = m2.n41,
			m212:Float = m2.n12, m222:Float = m2.n22, m232:Float = m2.n32, m242:Float = m2.n42,
			m213:Float = m2.n13, m223:Float = m2.n23, m233:Float = m2.n33, m243:Float = m2.n43,
			m214:Float = m2.n14, m224:Float = m2.n24, m234:Float = m2.n34, m244:Float = m2.n44;

		return new Matrix4
		(
			m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241,
			m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242,
			m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243,
			m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244,

			m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241,
			m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242,
			m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243,
			m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244,

			m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241,
			m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242,
			m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243,
			m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244,

			m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241,
			m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242,
			m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243,
			m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244
		);
	}

	/**
		* Computes the addition of two Matrix4 matrices.
		*
		* @param m1 	The first matrix.
		* @param m2	The second matrix.
		*
		* @return The resulting matrix.
		*/
	public static function addMatrix4(m1:Matrix4, m2:Matrix4): Matrix4
	{
		return new Matrix4
		(
			m1.n11 + m2.n11, m1.n12 + m2.n12, m1.n13 + m2.n13, m1.n14 + m2.n14,
			m1.n21 + m2.n21, m1.n22 + m2.n22, m1.n23 + m2.n23, m1.n24 + m2.n24,
			m1.n31 + m2.n31, m1.n32 + m2.n32, m1.n33 + m2.n33, m1.n34 + m2.n34,
			m1.n41 + m2.n41, m1.n42 + m2.n42, m1.n43 + m2.n43, m1.n44 + m2.n44
		);
	}

	/**
		* Returns the clone of a Matrix4 matrix.
		*
		* @param m1	The matrix to clone.
		*
		* @return The resulting matrix.
		*/
	public static function clone(m:Matrix4):Matrix4
	{
		return new Matrix4
		(
			m.n11,m.n12,m.n13,m.n14,
			m.n21,m.n22,m.n23,m.n24,
			m.n31,m.n32,m.n33,m.n34,
			m.n41,m.n42,m.n43,m.n44
		);
	}

	/**
		* Multiplies a 3D vertex by a Matrix4 matrix.
		*
		* @param m		The matrix.
		* @param pv	The vertex.
		*
		* @return The resulting Point3D.
		*/
	public static function transform( m:Matrix4, pv:Point3D ): Point3D
	{
		var x:Float=pv.x, y:Float=pv.y, z:Float=pv.z;
		return  new Point3D( 	(x * m.n11 + y * m.n12 + z * m.n13 + m.n14),
					(x * m.n21 + y * m.n22 + z * m.n23 + m.n24),
					(x * m.n31 + y * m.n32 + z * m.n33 + m.n34)
				);
	}

	/**
		* Multiplies a 3D Point3D by a Matrix4 matrix as a 3x3 matrix.
		*
		* <p>Uses the upper left 3 by 3 elements</p>
		*
		* @param m	The matrix.
		* @param v	The Point3D.
		*
		* @return The resulting Point3D.
		*/
	public static function transform3x3( m:Matrix4, pv:Point3D ):Point3D
	{
		var x:Float=pv.x, y:Float=pv.y, z:Float=pv.z;
		return  new Point3D( 	(x * m.n11 + y * m.n12 + z * m.n13),
					(x * m.n21 + y * m.n22 + z * m.n23),
					(x * m.n31 + y * m.n32 + z * m.n33)
				);
	}

	/**
		* Computes a rotation Matrix4 matrix from the Euler angle in degrees.
		*
		* @param ax	Angle of rotation around X axis in degrees.
		* @param ay	Angle of rotation around Y axis in degrees.
		* @param az	Angle of rotation around Z axis in degrees.
		*
		* @return The resulting matrix.
		*/
	public static function eulerRotation ( ax:Float, ay:Float, az:Float ) : Matrix4
	{
		var m:Matrix4 = new Matrix4();
		ax = - NumberUtil.toRadian(ax);
		ay =   NumberUtil.toRadian(ay);
		az = - NumberUtil.toRadian(az);
		// --
		var a:Float = TRIG.cos(ax);
		var b:Float = TRIG.sin(ax);
		var c:Float = TRIG.cos(ay);
		var d:Float = TRIG.sin(ay);
		var e:Float = TRIG.cos(az);
		var f:Float = TRIG.sin(az);
		var ad:Float = a * d	;
		var bd:Float = b * d	;

		m.n11 =   c  * e         ;
		m.n12 =   c  * f         ;
		m.n13 = - d              ;
		m.n21 =   bd * e - a * f ;
		m.n22 =   bd * f + a * e ;
		m.n23 =   b  * c 	 ;
		m.n31 =   ad * e + b * f ;
		m.n32 =   ad * f - b * e ;
		m.n33 =   a  * c         ;

		return m;
	}

	/**
		* Computes a rotation Matrix4 matrix for an x axis rotation.
		*
		* @param angle	Angle of rotation.
		*
		* @return The resulting matrix.
		*/
	public static function rotationX ( angle:Float ):Matrix4
	{
		var m:Matrix4 = new Matrix4();
		angle = NumberUtil.toRadian(angle);
		var c:Float = TRIG.cos( angle );
		var s:Float = TRIG.sin( angle );

		m.n22 =  c;
		m.n23 =  s;
		m.n32 = -s;
		m.n33 =  c;
		return m;
	}

	/**
		* Computes a rotation Matrix4 matrix for an y axis rotation.
		*
		* @param angle	Angle of rotation.
		*
		* @return The resulting matrix.
		*/
	public static function rotationY ( angle:Float ):Matrix4
	{
		var m:Matrix4 = new Matrix4();
		angle = NumberUtil.toRadian(angle);
		var c:Float = TRIG.cos( angle );
		var s:Float = TRIG.sin( angle );
		// --
		m.n11 =  c;
		m.n13 = -s;
		m.n31 =  s;
		m.n33 =  c;
		return m;
	}

	/**
		* Computes a rotation Matrix4 matrix for an z axis rotation.
		*
		* @param angle	Angle of rotation.
		*
		* @return The resulting matrix.
		*/
	public static function rotationZ ( angle:Float ):Matrix4
	{
		var m:Matrix4 = new Matrix4();
		angle = NumberUtil.toRadian(angle);
		var c:Float = TRIG.cos( angle );
		var s:Float = TRIG.sin( angle );
		// --
		m.n11 =  c;
		m.n12 =  s;
		m.n21 = -s;
		m.n22 =  c;
		return m;
	}

	/**
		* Computes a rotation Matrix4 matrix for a general axis of rotation.
		*
		* @param v 	The axis of rotation.
		* @param angle The angle of rotation in degrees.
		*
		* @return The resulting matrix.
		*/
	public static function axisRotationPoint3D ( v:Point3D, angle:Float ) : Matrix4
	{
		return Matrix4Math.axisRotation( v.x, v.y, v.z, angle );
	}

	/**
		* Computes a rotation Matrix4 matrix for a general axis of rotation.
		*
		* <p>[<strong>ToDo</strong>: My gosh! Explain this Thomas ;-) ]</p>
		*
		* @param u 	rotation X.
		* @param v 	rotation Y.
		* @param w		rotation Z.
		* @param angle	The angle of rotation in degrees.
		*
		* @return The resulting matrix.
		*/
	public static function axisRotation ( u:Float, v:Float, w:Float, angle:Float ) : Matrix4
	{
		var m:Matrix4 = new Matrix4();
		angle = NumberUtil.toRadian( angle );
		// -- modification pour verifier qu'il n'y ai pas un probleme de precision avec la camera
		var c:Float = TRIG.cos( angle );
		var s:Float = TRIG.sin( angle );
		var scos:Float	= 1 - c ;
		// --
		var suv	:Float = u * v * scos ;
		var svw	:Float = v * w * scos ;
		var suw	:Float = u * w * scos ;
		var sw	:Float = s * w ;
		var sv	:Float = s * v ;
		var su	:Float = s * u ;

		m.n11  =   c + u * u * scos	;
		m.n12  = - sw 	+ suv 			;
		m.n13  =   sv 	+ suw			;

		m.n21  =   sw 	+ suv 			;
		m.n22  =   c + v * v * scos 	;
		m.n23  = - su 	+ svw			;

		m.n31  = - sv	+ suw 			;
		m.n32  =   su	+ svw 			;
		m.n33  =   c	+ w * w * scos	;

		return m;
	}

	/**
		* Computes a translation Matrix4 matrix.
		*
		* <pre>
		* |1  0  0  0|
		* |0  1  0  0|
		* |0  0  1  0|
		* |Tx Ty Tz 1|
		* </pre>
		*
		* @param nTx 	Translation in the x direction.
		* @param nTy 	Translation in the y direction.
		* @param nTz 	Translation in the z direction.
		*
		* @return The resulting matrix.
		*/
	public static function translation(nTx:Float, nTy:Float, nTz:Float) : Matrix4
	{
		var m:Matrix4 = new Matrix4();
		m.n14 = nTx;
		m.n24 = nTy;
		m.n34 = nTz;
		return m;
	}

	/**
		* Computes a translation Matrix4 matrix from a Point3D.
		*
		* <pre>
		* |1  0  0  0|
		* |0  1  0  0|
		* |0  0  1  0|
		* |Tx Ty Tz 1|
		* </pre>
		*
		* @param v		Translation Point3D.
		*
		* @return The resulting matrix.
		*/
	public static function translationPoint3D( v:Point3D ) : Matrix4
	{
		var m:Matrix4 = new Matrix4();
		m.n14 = v.x;
		m.n24 = v.y;
		m.n34 = v.z;
		return m;
	}

	/**
		* Computes a scale Matrix4 matrix.
		*
		* <pre>
		* |Sx 0  0  0|
		* |0  Sy 0  0|
		* |0  0  Sz 0|
		* |0  0  0  1|
		* </pre>
		*
		* @param nXScale 	Scale factor in the x direction.
		* @param nYScale 	Scale factor in the y direction.
		* @param nZScale 	Scale factor in the z direction.
		*
		* @return The resulting matrix.
		*/
	public static function scale(nXScale:Float, nYScale:Float, nZScale:Float) : Matrix4
	{
		var matScale : Matrix4 = new Matrix4();
		matScale.n11 = nXScale;
		matScale.n22 = nYScale;
		matScale.n33 = nZScale;
		return matScale;
	}

	/**
		* Computes a scale Matrix4 matrix from a scale Point3D.
		*
		* <pre>
		* |Sx 0  0  0|
		* |0  Sy 0  0|
		* |0  0  Sz 0|
		* |0  0  0  1|
		* </pre>
		*
		* @param v	The Point3D containing the scale values.
		*
		* @return The resulting matrix.
		*/
	public static function scalePoint3D( v:Point3D) : Matrix4
	{
		var matScale : Matrix4 = new Matrix4();
		matScale.n11 = v.x;
		matScale.n22 = v.y;
		matScale.n33 = v.z;
		return matScale;
	}

	/**
		* Computes the determinant of a Matrix4 matrix.
		*
		* @param m 	The matrix.
		*
		* @return The determinant.
		*/
	public static function det( m:Matrix4 ):Float
	{
		return		(m.n11 * m.n22 - m.n21 * m.n12) * (m.n33 * m.n44 - m.n43 * m.n34)- (m.n11 * m.n32 - m.n31 * m.n12) * (m.n23 * m.n44 - m.n43 * m.n24)
					+ 	(m.n11 * m.n42 - m.n41 * m.n12) * (m.n23 * m.n34 - m.n33 * m.n24)+ (m.n21 * m.n32 - m.n31 * m.n22) * (m.n13 * m.n44 - m.n43 * m.n14)
					- 	(m.n21 * m.n42 - m.n41 * m.n22) * (m.n13 * m.n34 - m.n33 * m.n14)+ (m.n31 * m.n42 - m.n41 * m.n32) * (m.n13 * m.n24 - m.n23 * m.n14);

	}

	/**
		* Computes the 3x3 determinant of a Matrix4 matrix.
		*
		* <p>Uses the upper left 3 by 3 elements.</p>
		*
		* @param m		The matrix.
		*
		* @return The determinant.
		*/
	public static function det3x3( m:Matrix4 ):Float
	{
		return m.n11 * ( m.n22 * m.n33 - m.n23 * m.n32 ) + m.n21 * ( m.n32 * m.n13 - m.n12 * m.n33 ) + m.n31 * ( m.n12 * m.n23 - m.n22 * m.n13 );
	}

	/**
		* Computes the trace of a Matrix4 matrix.
		*
		* <p>The trace value is the sum of the element on the diagonal of the matrix.</p>
		*
		* @param m		The matrix we want to compute the trace.
		*
		* @return The trace value.
		*/
	public static function getTrace( m:Matrix4 ):Float
	{
		return m.n11 + m.n22 + m.n33 + m.n44;
	}

	/**
	* Returns the inverse of a Matrix4 matrix.
	*
	* @param m	The matrix to invert.
	*
	* @return 	The inverse Matrix4 matrix.
	*/
	public static function getInverse( m:Matrix4 ):Matrix4
	{
		//take the determinant
		var d:Float = Matrix4Math.det( m );
		if( Math.abs(d) < 0.001 )
		{
			//We cannot invert a Matrix4 with a null determinant
			return null;
		}
		//We use Cramer formula, so we need to devide by the determinant. We prefer multiply by the inverse
		d = 1/d;
		var m11:Float = m.n11;var m21:Float = m.n21;var m31:Float = m.n31;var m41:Float = m.n41;
		var m12:Float = m.n12;var m22:Float = m.n22;var m32:Float = m.n32;var m42:Float = m.n42;
		var m13:Float = m.n13;var m23:Float = m.n23;var m33:Float = m.n33;var m43:Float = m.n43;
		var m14:Float = m.n14;var m24:Float = m.n24;var m34:Float = m.n34;var m44:Float = m.n44;
		return new Matrix4 (
		d * ( m22*(m33*m44 - m43*m34) - m32*(m23*m44 - m43*m24) + m42*(m23*m34 - m33*m24) ),
		-d* ( m12*(m33*m44 - m43*m34) - m32*(m13*m44 - m43*m14) + m42*(m13*m34 - m33*m14) ),
		d * ( m12*(m23*m44 - m43*m24) - m22*(m13*m44 - m43*m14) + m42*(m13*m24 - m23*m14) ),
		-d* ( m12*(m23*m34 - m33*m24) - m22*(m13*m34 - m33*m14) + m32*(m13*m24 - m23*m14) ),
		-d* ( m21*(m33*m44 - m43*m34) - m31*(m23*m44 - m43*m24) + m41*(m23*m34 - m33*m24) ),
		d * ( m11*(m33*m44 - m43*m34) - m31*(m13*m44 - m43*m14) + m41*(m13*m34 - m33*m14) ),
		-d* ( m11*(m23*m44 - m43*m24) - m21*(m13*m44 - m43*m14) + m41*(m13*m24 - m23*m14) ),
		d * ( m11*(m23*m34 - m33*m24) - m21*(m13*m34 - m33*m14) + m31*(m13*m24 - m23*m14) ),
		d * ( m21*(m32*m44 - m42*m34) - m31*(m22*m44 - m42*m24) + m41*(m22*m34 - m32*m24) ),
		-d* ( m11*(m32*m44 - m42*m34) - m31*(m12*m44 - m42*m14) + m41*(m12*m34 - m32*m14) ),
		d * ( m11*(m22*m44 - m42*m24) - m21*(m12*m44 - m42*m14) + m41*(m12*m24 - m22*m14) ),
		-d* ( m11*(m22*m34 - m32*m24) - m21*(m12*m34 - m32*m14) + m31*(m12*m24 - m22*m14) ),
		-d* ( m21*(m32*m43 - m42*m33) - m31*(m22*m43 - m42*m23) + m41*(m22*m33 - m32*m23) ),
		d * ( m11*(m32*m43 - m42*m33) - m31*(m12*m43 - m42*m13) + m41*(m12*m33 - m32*m13) ),
		-d* ( m11*(m22*m43 - m42*m23) - m21*(m12*m43 - m42*m13) + m41*(m12*m23 - m22*m13) ),
		d * ( m11*(m22*m33 - m32*m23) - m21*(m12*m33 - m32*m13) + m31*(m12*m23 - m22*m13) )
		);
	}

	/**
		* Computes a Matrix4 matrix for a rotation around a specific axis through a specific point.
		*
		* <p>NOTE - The axis must be normalized!</p>
		*
		* @param axis 		A Point3D representing the axis of rotation.
		* @param ref 		The center of rotation.
		* @param pAngle	The angle of rotation in degrees.
		*
		* @return The resulting matrix.
		*/
	public static function axisRotationWithReference( axis:Point3D, ref:Point3D, pAngle:Float ):Matrix4
	{
		var angle:Float = ( pAngle + 360 ) % 360;
		var m:Matrix4 = Matrix4Math.translation ( ref.x, ref.y, ref.z );
		m = Matrix4Math.multiply ( m, Matrix4Math.axisRotation( axis.x, axis.y, axis.z, angle ));
		m = Matrix4Math.multiply ( m, Matrix4Math.translation ( -ref.x, -ref.y, -ref.z ));
		return m;
	}
}