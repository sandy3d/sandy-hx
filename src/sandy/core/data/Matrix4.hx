
package sandy.core.data;

import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
 * A 4x4 matrix for transformations in 3D space.
 *
 * @author		Thomas Pfeiffer - kiroukou
 * @author		Niel Drummond - haXe port
 * @author		Russell Weir - haXe port
 *
 */
class Matrix4
{

	/**
	 * Matrix4 cell.
	 * <p><code>1 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n11:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 1 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n12:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 1 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n13:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 1 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n14:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          1 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n21:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 1 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n22:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 1 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n23:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 1 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n24:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          1 0 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n31:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 1 0 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n32:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 1 0 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n33:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 1 <br>
	 *          0 0 0 0 </code></p>
	 */
	public var n34:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          1 0 0 0 </code></p>
	 */
	public var n41:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 1 0 0 </code></p>
	 */
	public var n42:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 1 0 </code></p>
	 */
	public var n43:Float;

	/**
	 * Matrix4 cell.
	 * <p><code>0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 0 <br>
	 *          0 0 0 1 </code></p>
	 */
	public var n44:Float;

	/**
	 * Creates a new Matrix4 matrix.
	 *
	 * <p>If 16 arguments are passed to the constructor, it will
	 * create a Matrix4 with the values. Otherwise an identity Matrix4 is created.</p>
	 * <code>var m:Matrix4 = new Matrix4();</code><br>
	 * <code>1 0 0 0 <br>
	 *       0 1 0 0 <br>
	 *       0 0 1 0 <br>
	 *       0 0 0 1 </code><br><br>
	 * <code>var m:Matrix4 = new Matrix4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
	 * 13, 14, 15, 16);</code><br>
	 * <code>1  2  3  4 <br>
	 *       5  6  7  8 <br>
	 *       9  10 11 12 <br>
	 *       13 14 15 16 </code>
	 *
	 * @param pn11 - pn44	Element values to populate the matrix
	 */
	public function new(?pn11:Float, ?pn12:Float , ?pn13:Float , ?pn14:Float,
				?pn21:Float, ?pn22:Float , ?pn23:Float , ?pn24:Float,
				?pn31:Float, ?pn32:Float , ?pn33:Float , ?pn34:Float,
				?pn41:Float, ?pn42:Float , ?pn43:Float , ?pn44:Float )
	{
		if (pn11 == null) pn11=1; if (pn12 == null) pn12=0; if (pn13 == null) pn13=0; if (pn14 == null) pn14=0;
		if (pn21 == null) pn21=0; if (pn22 == null) pn22=1; if (pn23 == null) pn23=0; if (pn24 == null) pn24=0;
		if (pn31 == null) pn31=0; if (pn32 == null) pn32=0; if (pn33 == null) pn33=1; if (pn34 == null) pn34=0;
		if (pn41 == null) pn41=0; if (pn42 == null) pn42=0; if (pn43 == null) pn43=0; if (pn44 == null) pn44=1;

		n11 = pn11 ; n12 = pn12 ; n13 = pn13 ; n14 = pn14 ;
		n21 = pn21 ; n22 = pn22 ; n23 = pn23 ; n24 = pn24 ;
		n31 = pn31 ; n32 = pn32 ; n33 = pn33 ; n34 = pn34 ;
		n41 = pn41 ; n42 = pn42 ; n43 = pn43 ; n44 = pn44 ;
	}

	/**
	 * Makes this matrix into a zero matrix.
	 *
	 * <p>A zero Matrix4 is represented like this :</p>
	 * <code>0 0 0 0 <br>
	 *       0 0 0 0 <br>
	 *       0 0 0 0 <br>
	 *       0 0 0 0 </code>
	 *
	 * @return	The zero matrix
	 */
	public function zero():Void
	{
		n11 = 0 ; n12 = 0 ; n13 = 0 ; n14 = 0;
		n21 = 0 ; n22 = 0 ; n23 = 0 ; n24 = 0;
		n31 = 0 ; n32 = 0 ; n33 = 0 ; n34 = 0;
		n41 = 0 ; n42 = 0 ; n43 = 0 ; n44 = 0;
	}

	/**
	 * Makes this matrix into an identity matrix.
	 *
	 * <p>A zero Matrix4 is represented like this :</p>
	 * <code>1 0 0 0 <br>
	 *       0 1 0 0 <br>
	 *       0 0 1 0 <br>
	 *       0 0 0 1 </code>
	 *
	 * @return	The identity matrix
	 */
	public function identity():Void
	{
		n11 = 1 ; n12 = 0 ; n13 = 0 ; n14 = 0;
		n21 = 0 ; n22 = 1 ; n23 = 0 ; n24 = 0;
		n31 = 0 ; n32 = 0 ; n33 = 1 ; n34 = 0;
		n41 = 0 ; n42 = 0 ; n43 = 0 ; n44 = 1;
	}

	/**
	 * Compute a clonage {@code Matrix4}.
	 *
	 * @return The result of clonage : a {@code Matrix4}.
	 */
	public function clone():Matrix4
	{
		return new Matrix4(	n11,n12,n13,n14,
                            n21,n22,n23,n24,
							n31,n32,n33,n34,
							n41,n42,n43,n44 );
	}

	/**
	 * Makes this matrix a copy of a passed in matrix.
	 *
	 * <p>All elements of the argument matrix are copied into this matrix.</p>
	 *
	 * @param m1 	The matrix to copy.
	 */
	public function copy(m:Matrix4):Void
	{
		n11 = m.n11 ; n12 = m.n12 ; n13 = m.n13 ; n14 = m.n14 ;
		n21 = m.n21 ; n22 = m.n22 ; n23 = m.n23 ; n24 = m.n24 ;
		n31 = m.n31 ; n32 = m.n32 ; n33 = m.n33 ; n34 = m.n34 ;
		n41 = m.n41 ; n42 = m.n42 ; n43 = m.n43 ; n44 = m.n44 ;
	}

	/**
	 * Multiplies this matrix by a passed in as if they were 3x3 matrices.
	 *
	 * @param m2 	The matrix to multiply with.
	 */
	public function multiply3x3( m2:Matrix4) : Void
	{
		var m111:Float = n11, m211:Float = m2.n11,
		m121:Float = n21, m221:Float = m2.n21,
		m131:Float = n31, m231:Float = m2.n31,
		m112:Float = n12, m212:Float = m2.n12,
		m122:Float = n22, m222:Float = m2.n22,
		m132:Float = n32, m232:Float = m2.n32,
		m113:Float = n13, m213:Float = m2.n13,
		m123:Float = n23, m223:Float = m2.n23,
		m133:Float = n33, m233:Float = m2.n33;

		n11 = m111 * m211 + m112 * m221 + m113 * m231;
		n12 = m111 * m212 + m112 * m222 + m113 * m232;
		n13 = m111 * m213 + m112 * m223 + m113 * m233;

		n21 = m121 * m211 + m122 * m221 + m123 * m231;
		n22 = m121 * m212 + m122 * m222 + m123 * m232;
		n23 = m121 * m213 + m122 * m223 + m123 * m233;

		n31 = m131 * m211 + m132 * m221 + m133 * m231;
		n32 = m131 * m212 + m132 * m222 + m133 * m232;
		n33 = m131 * m213 + m132 * m223 + m133 * m233;

		n14 = n24 = n34 = n41 = n42 = n43 = 0;
		n44 = 1;
	}


	/**
	 * Multiplies the upper left 3x3 sub matrix of this matrix by a passed in matrix.
	 *
	 * @param m2 	The matrix to multiply with.
	 */
	public function multiply4x3( m2:Matrix4 ):Void
	{
		var 	m111:Float = n11, 	m211:Float = m2.n11,
			m121:Float = n21, 	m221:Float = m2.n21,
			m131:Float = n31, 	m231:Float = m2.n31,
			m112:Float = n12, 	m212:Float = m2.n12,
			m122:Float = n22, 	m222:Float = m2.n22,
			m132:Float = n32, 	m232:Float = m2.n32,
			m113:Float = n13, 	m213:Float = m2.n13,
			m123:Float = n23, 	m223:Float = m2.n23,
			m133:Float = n33, 	m233:Float = m2.n33,
						m214:Float = m2.n14,
						m224:Float = m2.n24,
						m234:Float = m2.n34;

		n11 = m111 * m211 + m112 * m221 + m113 * m231;
		n12 = m111 * m212 + m112 * m222 + m113 * m232;
		n13 = m111 * m213 + m112 * m223 + m113 * m233;
		n14 = m214 * m111 + m224 * m112 + m234 * m113 + n14;

		n21 = m121 * m211 + m122 * m221 + m123 * m231;
		n22 = m121 * m212 + m122 * m222 + m123 * m232;
		n23 = m121 * m213 + m122 * m223 + m123 * m233;
		n24 = m214 * m121 + m224 * m122 + m234 * m123 + n24;

		n31 = m131 * m211 + m132 * m221 + m133 * m231;
		n32 = m131 * m212 + m132 * m222 + m133 * m232;
		n33 = m131 * m213 + m132 * m223 + m133 * m233;
		n34 = m214 * m131 + m224 * m132 + m234 * m133 + n34;

		n41 = n42 = n43 = 0;
		n44 = 1;
	}

	/**
	 * Multiplies this matrix by a passed in matrix.
	 *
	 * @param m2 	The matrix to multiply with.
	 */
	public function multiply( m2:Matrix4) : Void
	{
		var m111:Float = n11, m121:Float = n21, m131:Float = n31, m141:Float = n41,
			m112:Float = n12, m122:Float = n22, m132:Float = n32, m142:Float = n42,
			m113:Float = n13, m123:Float = n23, m133:Float = n33, m143:Float = n43,
			m114:Float = n14, m124:Float = n24, m134:Float = n34, m144:Float = n44,

			m211:Float = m2.n11, m221:Float = m2.n21, m231:Float = m2.n31, m241:Float = m2.n41,
			m212:Float = m2.n12, m222:Float = m2.n22, m232:Float = m2.n32, m242:Float = m2.n42,
			m213:Float = m2.n13, m223:Float = m2.n23, m233:Float = m2.n33, m243:Float = m2.n43,
			m214:Float = m2.n14, m224:Float = m2.n24, m234:Float = m2.n34, m244:Float = m2.n44;

		n11 = m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
		n12 = m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
		n13 = m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
		n14 = m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;

		n21 = m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
		n22 = m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
		n23 = m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
		n24 = m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;

		n31 = m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
		n32 = m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
		n33 = m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
		n34 = m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;

		n41 = m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
		n42 = m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
		n43 = m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
		n44 = m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;

	}

	/**
	 * Adds this matrix to a passed in matrix.
	 *
	 * <p>This matrix is added to the argument matrix, element by element:<br/>
	 * n11 = n11 + m2.n11, etc</p>
	 *
	 * @param m2 	Matrix to add to thei matrix.
	 */
	public function addMatrix( m2:Matrix4): Void
	{
		n11 += m2.n11;
		n12 += m2.n12;
		n13 += m2.n13;
		n14 += m2.n14;
		n21 += m2.n21;
		n22 += m2.n22;
		n23 += m2.n23;
		n24 += m2.n24;
		n31 += m2.n31;
		n32 += m2.n32;
		n33 += m2.n33;
		n34 += m2.n34;
		n41 += m2.n41;
		n42 += m2.n42;
		n43 += m2.n43;
		n44 += m2.n44;

	}

	/**
	 * Multiplies a Point3D with this matrix.
	 *
	 * @param pv	The Point3D to be mutliplied
	 */
	public function transform( pv:Point3D ):Void
	{
		var x:Float=pv.x, y:Float=pv.y, z:Float=pv.z;
		pv.x = (x * n11 + y * n12 + z * n13 + n14);
		pv.y = (x * n21 + y * n22 + z * n23 + n24);
		pv.z = (x * n31 + y * n32 + z * n33 + n34);
	}

	/**
	 * Creates transformation matrix from axis and translation Point3Ds.
	 *
	 * @param	px X axis Point3D.
	 * @param	py Y axis Point3D.
	 * @param	pz Z axis Point3D.
	 * @param	pt translation Point3D.
	 */
	public function fromPoint3Ds(px:Point3D, py:Point3D, pz:Point3D, pt:Point3D):Void
	{
		identity ();
		n11 = px.x; n21 = px.y; n31 = px.z;
		n12 = py.x; n22 = py.y; n32 = py.z;
		n13 = pz.x; n23 = pz.y; n33 = pz.z;
		n14 = pt.x; n24 = pt.y; n34 = pt.z;
	}

	/**
	 * Multiplies a 3D Point3D with this matrix.
	 *
	 * <p>The Point3D is multiplied with te upper left 3x3 sub matrix</p>
	 *
	 * @param pv	The Point3D to be mutliplied
	 */
	public function transform3x3( pv:Point3D ):Void
	{
		var x:Float=pv.x, y:Float=pv.y, z:Float=pv.z;
		pv.x = (x * n11 + y * n12 + z * n13);
		pv.y = (x * n21 + y * n22 + z * n23);
		pv.z = (x * n31 + y * n32 + z * n33);
	}


	/**
	 * Makes this matrix a rotation matrix for the given angle of rotation.
	 *
	 * @param angle Float angle of rotation in degrees
	 * @return the computed matrix
	 */
	public function rotationX ( angle:Float ):Void
	{
		identity();
		//
		angle = NumberUtil.toRadian(angle);
		var c:Float = TRIG.cos( angle );
		var s:Float = TRIG.sin( angle );
		//
		n22 =  c;
		n23 =  -s;
		n32 = s;
		n33 =  c;
	}

	/**
	 * Makes this matrix a rotation matrix for the given angle of rotation.
	 *
	 * <p>The matrix is computed from the angle of rotation around the y axes.</p>
	 *
	 * @param angle 	Angle of rotation around y axis in degrees.
	 */
	public function rotationY ( angle:Float ):Void
	{
		identity();
		//
		angle = NumberUtil.toRadian(angle);
		var c:Float = TRIG.cos( angle );
		var s:Float = TRIG.sin( angle );
		// --
		n11 =  c;
		n13 = -s;
		n31 =  s;
		n33 =  c;
	}

	/**
	 * Makes this matrix a rotation matrix for the given angle of rotation.
	 *
	 * <p>The matrix is computed from the angle of rotation around the z axes.</p>
	 *
	 * @param angle 	Angle of rotation around z axis in degrees.
	 */
	public function rotationZ ( angle:Float ):Void
	{
		identity();
		//
		angle = NumberUtil.toRadian(angle);
		var c:Float = TRIG.cos( angle );
		var s:Float = TRIG.sin( angle );
		// --
		n11 =  c;
		n12 =  -s;
		n21 = s;
		n22 =  c;
	}

	/**
	 * Makes this matrix a rotation matrix for a rotation around a given axis.
	 *
	 * <p>The matrix is computed from the angle of rotation around the given axes of rotation.<br />
	 * The axis is given as a 3D Point3D.</p>
	 *
	 * @param v 	The axis of rotation
	 * @param angle	The angle of rotation in degrees
	 */
	public function axisRotationPoint3D ( v:Point3D, angle:Float ) : Void
	{
		axisRotation( v.x, v.y, v.z, angle );
	}


	/**
	 * Makes this matrix a translation matrix from translation components.
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
	 */
	public function translation(nTx:Float, nTy:Float, nTz:Float) : Void
	{
		identity();
		//
		n14 = nTx;
		n24 = nTy;
		n34 = nTz;
	}

	/**
	 * Makes this matrix a translation matrix from a translation Point3D.
	 *
	 * <pre>
	 * |1  0  0  0|
	 * |0  1  0  0|
	 * |0  0  1  0|
	 * |v.x v.y v.z 1|
	 * </pre>
	 *
	 * @param v 	The translation Point3D.
	 */
	public function translationPoint3D( v:Point3D ) : Void
	{
		identity();
		//
		n14 = v.x;
		n24 = v.y;
		n34 = v.z;
	}

	/**
	 * Makes this matrix a scale matrix from scale components.
	 *
	 * <pre>
	 * |Sx 0  0  0|
	 * |0  Sy 0  0|
	 * |0  0  Sz 0|
	 * |0  0  0  1|
	 * </pre>
	 *
	 * @param nXScale 	x-scale.
	 * @param nYScale 	y-scale.
	 * @param nZScale	z-scale.
	 */
	public function scale(nXScale:Float, nYScale:Float, nZScale:Float) : Void
	{
		identity();
		//
		n11 = nXScale;
		n22 = nYScale;
		n33 = nZScale;
	}

	/**
	 * Makes this matrix a scale matrix from a scale Point3D.
	 *
	 * <pre>
	 * |Sx 0  0  0|
	 * |0  Sy 0  0|
	 * |0  0  Sz 0|
	 * |0  0  0  1|
	 * </pre>
	 *
	 * @param v	The scale Point3D.
	 */
	public function scalePoint3D( v:Point3D) : Void
	{
		identity();
		//
		n11 = v.x;
		n22 = v.y;
		n33 = v.z;
	}

	/**
	* Returns the determinant of this 4x4 matrix.
	*
	* @return 	The determinant
	*/
	public function det():Float
	{
		return		(n11 * n22 - n21 * n12) * (n33 * n44 - n43 * n34)- (n11 * n32 - n31 * n12) * (n23 * n44 - n43 * n24)
				 + 	(n11 * n42 - n41 * n12) * (n23 * n34 - n33 * n24)+ (n21 * n32 - n31 * n22) * (n13 * n44 - n43 * n14)
				 - 	(n21 * n42 - n41 * n22) * (n13 * n34 - n33 * n14)+ (n31 * n42 - n41 * n32) * (n13 * n24 - n23 * n14);

	}

	/**
	* Returns the determinant of the upper left 3x3 sub matrix of this matrix.
	*
	* @return 	The determinant
	*/
	public function det3x3():Float
	{
		return n11 * ( n22 * n33 - n23 * n32 ) + n21 * ( n32 * n13 - n12 * n33 ) + n31 * ( n12 * n23 - n22 * n13 );
	}

	/**
	 * Returns the trace of the matrix.
	 *
	 * <p>The trace value is the sum of the element on the diagonal of the matrix</p>
	 *
	 * @return 	The trace value
	 */
	public function getTrace():Float
	{
		return n11 + n22 + n33 + n44;
	}

	/**
	* Return the inverse of the matrix passed in parameter.
	* @param m The matrix4 to inverse
	* @return Matrix4 The inverse Matrix4
	*/
	public function inverse():Void
	{
		//take the determinant
		var d:Float = det();
		if( Math.abs(d) < 0.001 )
		{
			throw "cannot invert a matrix with a null determinant";
			return;
		}
		 //We use Cramer formula, so we need to devide by the determinant. We prefer multiply by the inverse
		 d = 1/d;
		 var 	m11:Float = n11, m21:Float = n21, m31:Float = n31, m41:Float = n41,
		 		m12:Float = n12, m22:Float = n22, m32:Float = n32, m42:Float = n42,
		 		m13:Float = n13, m23:Float = n23, m33:Float = n33, m43:Float = n43,
		 		m14:Float = n14, m24:Float = n24, m34:Float = n34, m44:Float = n44;

		 n11 = d * ( m22*(m33*m44 - m43*m34) - m32*(m23*m44 - m43*m24) + m42*(m23*m34 - m33*m24) );
		 n12 = -d* ( m12*(m33*m44 - m43*m34) - m32*(m13*m44 - m43*m14) + m42*(m13*m34 - m33*m14) );
		 n13 = d * ( m12*(m23*m44 - m43*m24) - m22*(m13*m44 - m43*m14) + m42*(m13*m24 - m23*m14) );
		 n14 = -d* ( m12*(m23*m34 - m33*m24) - m22*(m13*m34 - m33*m14) + m32*(m13*m24 - m23*m14) );
		 n21 = -d* ( m21*(m33*m44 - m43*m34) - m31*(m23*m44 - m43*m24) + m41*(m23*m34 - m33*m24) );
		 n22 = d * ( m11*(m33*m44 - m43*m34) - m31*(m13*m44 - m43*m14) + m41*(m13*m34 - m33*m14) );
		 n23 = -d* ( m11*(m23*m44 - m43*m24) - m21*(m13*m44 - m43*m14) + m41*(m13*m24 - m23*m14) );
		 n24 = d * ( m11*(m23*m34 - m33*m24) - m21*(m13*m34 - m33*m14) + m31*(m13*m24 - m23*m14) );
		 n31 = d * ( m21*(m32*m44 - m42*m34) - m31*(m22*m44 - m42*m24) + m41*(m22*m34 - m32*m24) );
		 n32 = -d* ( m11*(m32*m44 - m42*m34) - m31*(m12*m44 - m42*m14) + m41*(m12*m34 - m32*m14) );
		 n33 = d * ( m11*(m22*m44 - m42*m24) - m21*(m12*m44 - m42*m14) + m41*(m12*m24 - m22*m14) );
		 n34 = -d* ( m11*(m22*m34 - m32*m24) - m21*(m12*m34 - m32*m14) + m31*(m12*m24 - m22*m14) );
		 n41 = -d* ( m21*(m32*m43 - m42*m33) - m31*(m22*m43 - m42*m23) + m41*(m22*m33 - m32*m23) );
		 n42 = d * ( m11*(m32*m43 - m42*m33) - m31*(m12*m43 - m42*m13) + m41*(m12*m33 - m32*m13) );
		 n43 = -d* ( m11*(m22*m43 - m42*m23) - m21*(m12*m43 - m42*m13) + m41*(m12*m23 - m22*m13) );
		 n44 = d * ( m11*(m22*m33 - m32*m23) - m21*(m12*m33 - m32*m13) + m31*(m12*m23 - m22*m13) );
	}

	/**
	 * Realize a rotation around a specific axis through a specified point.
	 *
	 * <p>a rotation by a specified angle around a specified axis through a specific position, the reference point,
	 * is applied to this matrix.</p>
	 *
	 * @param pAxis 	A 3D Point3D representing the axis of rtation. Must be normalized!
	 * @param ref 		The reference point.
	 * @param pAngle	The angle of rotation in degrees.
	 */
	public function axisRotationWithReference( axis:Point3D, ref:Point3D, pAngle:Float ):Void
	{
		var tmp:Matrix4 = new Matrix4();
		var angle:Float = ( pAngle + 360 ) % 360;
		translation ( ref.x, ref.y, ref.z );
		tmp.axisRotation( axis.x, axis.y, axis.z, angle );
		multiply ( tmp );
		tmp.translation ( -ref.x, -ref.y, -ref.z );
		multiply ( tmp );
		tmp = null;
	}

	/**
	 * Returns a string representation of this matrix.
	 *
	 * @return	The string representing this matrix
	 */
	public function toString(): String
	{
		var round = NumberUtil.roundTo;
		var s:String =  "sandy.core.data.Matrix4" + "(\n";
		s += round(n11, .0001)+"\t "+round(n12, .0001)+"\t "+round(n13, .0001)+"\t "+round(n14, .0001)+"\n";
		s += round(n21, .0001)+"\t "+round(n22, .0001)+"\t "+round(n23, .0001)+"\t "+round(n24, .0001)+"\n";
		s += round(n31, .0001)+"\t "+round(n32, .0001)+"\t "+round(n33, .0001)+"\t "+round(n34, .0001)+"\n";
		s += round(n41, .0001)+"\t "+round(n42, .0001)+"\t "+round(n43, .0001)+"\t "+round(n44, .0001)+"\n)";
		return s;
	}

	/**
	 * Returns a Point3D that containes the 3D position information.
	 *
	 * @return A Point3D
	 */
	public function getTranslation():Point3D
	{
		return new Point3D( n14, n24, n34 );
	}

	/**
	 * Compute a Rotation around an axis{@code Matrix4}.
	 *
	 * @param {@code nRotX} rotation X.
	 * @param {@code nRotY} rotation Y.
	 * @param {@code nRotZ} rotation Z.
	 * @param The angle of rotation in degree
	 * @return The result of computation : a {@code Matrix4}.
	 */
	public function axisRotation ( u:Float, v:Float, w:Float, angle:Float ) : Void
	{
		identity();
		//
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

		n11  =   c + u * u * scos	;
		n12  = - sw 	+ suv 			;
		n13  =   sv 	+ suw			;

		n21  =   sw 	+ suv 			;
		n22  =   c + v * v * scos 	;
		n23  = - su 	+ svw			;

		n31  = - sv	+ suw 			;
		n32  =   su	+ svw 			;
		n33  =   c	+ w * w * scos	;
	}



	/**
	 * Compute a Rotation {@code Matrix4} from the Euler angle in degrees unit.
	 *
	 * @param {@code ax} angle of rotation around X axis in degree.
	 * @param {@code ay} angle of rotation around Y axis in degree.
	 * @param {@code az} angle of rotation around Z axis in degree.
	 * @return The result of computation : a {@code Matrix4}.
	 */
	public function eulerRotation ( ax:Float, ay:Float, az:Float ) : Void
	{
		identity();
		//
		ax = NumberUtil.toRadian(ax);
		ay = NumberUtil.toRadian(ay);
		az = NumberUtil.toRadian(az);
		// --
		var a:Float = TRIG.cos(ax);
		var b:Float = TRIG.sin(ax);
		var c:Float = TRIG.cos(ay);
		var d:Float = TRIG.sin(ay);
		var e:Float = TRIG.cos(az);
		var f:Float = TRIG.sin(az);
		var ad:Float = a * d	;
		var bd:Float = b * d	;
		//
		n11 =   c  * e         ;
		n12 = - c  * f         ;
		n13 = - d              ;
		n21 = - bd * e + a * f ;
		n22 = - bd * f + a * e ;
		n23 = - b  * c 	 ;
		n31 =   ad * e + b * f ;
		n32 = - ad * f + b * e ;
		n33 =   a  * c         ;
	}

	/**
	 * Get the eulers angles from the rotation matrix
	 * @param t The Matrix4 instance from which t extract these angles
	 *
	 * @return A Point3D that represent the Euler angles in the 3D space (X, Y and Z)
	 */
	public static function getEulerAngles( t:Matrix4 ):Point3D
	{
		var lAngleY:Float = Math.asin( t.n13 );
		var lCos:Float = Math.cos( lAngleY );

		//lAngleY *= NumberUtil.TO_DEGREE;
		var lTrx:Float, lTry:Float, lAngleX:Float, lAngleZ:Float;

		if( Math.abs( lCos ) > 0.005 )
		{
			lTrx = t.n33 / lCos;
			lTry = -t.n22 / lCos;
			lAngleX = Math.atan2( lTry, lTrx );
			// --
			lTrx = t.n11 / lCos;
			lTry = -t.n12 / lCos;
			lAngleZ = Math.atan2( lTry, lTrx );
		}
		else
		{
			lAngleX = 0;
			lTrx = t.n22;
			lTry = t.n21;
			lAngleZ = Math.atan2( lTry, lTrx );
		}

		//lAngleX *= NumberUtil.TO_DEGREE;
		//lAngleZ *= NumberUtil.TO_DEGREE;

		if( lAngleX < 0 ) lAngleX += 360;
		if( lAngleY < 0 ) lAngleY += 360;
		if( lAngleZ < 0 ) lAngleZ += 360;

		return new Point3D( lAngleX, lAngleY, lAngleZ );
	}

	/**
	* Get a string representation of the {@code Matrix4} in a format useful for XML output
	*
	* @return	A serialized String representing the {@code Matrix4}.
	*/
	public function serialize(d:Float = .000001):String
	{
		var round = NumberUtil.roundTo;
		var s:String =  new String("");
		s += round(n11, d) + "," + round(n12, d) + "," + round(n13, d) + "," + round(n14, d) + ",";
		s += round(n21, d) + "," + round(n22, d) + "," + round(n23, d) + "," + round(n24, d) + ",";
		s += round(n31, d) + "," + round(n32, d) + "," + round(n33, d) + "," + round(n34, d) + ",";
		s += round(n41, d) + "," + round(n42, d) + "," + round(n43, d) + "," + round(n44, d);
		return s;
	}

	/**
	* Convert a string representation in a {@code Matrix4}; useful for XML input
	*
	* @return	A {@code Matrix4} equivalent to the input string
	*/
	public static function deserialize(convertFrom:String):Matrix4
	{
		//trace ("Matrix4.Deserialize convertFrom " + convertFrom);

		var ta = convertFrom.split(",");
		if (ta.length != 16) {
			trace ("Unexpected length of string to deserialize into a matrix4 " + convertFrom);
		}
		var tmp = new Array();
		for(i in 0...ta.length) {
			tmp[i] = Std.parseFloat(ta[i]);
		}
		var temp2:Matrix4 = new Matrix4 (tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], tmp[5], tmp[6], tmp[7],
										tmp[8], tmp[9], tmp[10], tmp[11], tmp[12], tmp[13], tmp[14], tmp[15]);
		//trace ("temp2 in Matrix4.deserialize is " + temp2);
		return temp2;
	}
}

