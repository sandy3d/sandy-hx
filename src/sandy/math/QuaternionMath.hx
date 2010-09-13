
package sandy.math;

import sandy.core.data.Matrix4;
import sandy.core.data.Quaternion;
import sandy.core.data.Point3D;
import sandy.util.NumberUtil;

import sandy.HaxeTypes;

/**
* Math functions for manipulation of quaternion objects.
*
* <p>UNTESTED - DO NOT USE THIS CLASS UNLESS YOU KNOW EXACTLY WHAT YOU ARE DOING<br/>
* Do we ever ;-)[Petit comment]</p>
* <p>You can clearly see the reason this class is undocumented.</p>
*
* @author Thomas PFEIFFER - Kiroukou
* @author Russell Weir
* @version		3.1
*/
class QuaternionMath
{

	public static function getPoint3D( q:Quaternion):Point3D
	{
		return new Point3D( q.x,q.y,q.z );
	}

	public static function setPoint3D( q:Quaternion, v:Point3D ):Void
	{
		q.x = v.x;
		q.y = v.y;
		q.z = v.z;
	}

	public static function setScalar( q:Quaternion, n:Float ):Void
	{
		q.w = n;
	}

	public static function equal( q:Quaternion, q2:Quaternion ):Bool
	{
		return ( q.x == q2.x && q.y == q2.y && q.z == q2.z && q.w == q2.w );
	}


	public static function clone( q:Quaternion ):Quaternion
	{
		return new Quaternion( q.x, q.y, q.z, q.w );
	}

	public static function getConjugate( q:Quaternion ):Quaternion
	{
		return new Quaternion( -q.x, -q.y, -q.z, q.w );
	}

	public static function conjugate( q:Quaternion ):Void
	{
		q.x = -q.x;
		q.y = -q.y;
		q.z = -q.z;
	}

	public static function getMagnitude( q:Quaternion ):Float
	{
		//return Math.sqrt( this.multiply( this.getConjugate() ) );
		return Math.sqrt ( q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z );
	}

	public static function normalize( q:Quaternion ):Void
	{
		var m:Float = QuaternionMath.getMagnitude( q );
		q.x /= m;
		q.y /= m;
		q.z /= m;
		q.w /= m;
	}

	public static function multiply( q1:Quaternion, q2:Quaternion ):Quaternion
	{
		var x1:Float, x2:Float;
		var y1:Float, y2:Float;
		var z1:Float, z2:Float;
		var w1:Float, w2:Float;
		x1 = q1.x; y1 = q1.y; z1 = q1.z; w1 = q1.w;
		x2 = q2.x; y2 = q2.y; z2 = q2.z; w2 = q2.w;

		return new Quaternion(	w1*x2 + x1*w2 + y1*z2 - z1*y2,
								w1*y2 + y1*w2 + z1*x2 - x1*z2,
								w1*z2 + z1*w2 + x1*y2 - y1*x2,
								w1*w2 - x1*x2 - y1*y2 - z1*z2);

	}

	public static function multiplyPoint3D( q:Quaternion, v:Point3D ):Quaternion
	{
		var x1:Float, x2:Float;
		var y1:Float, y2:Float;
		var z1:Float, z2:Float;
		var w1:Float, w2:Float;
		x1 = q.x; y1 = q.y; z1 = q.z; w1 = q.w;
		x2 = v.x; y2 = v.y; z2 = v.z; w2 = 0;

		return new Quaternion( 	w1*x2 + y1*z2 - z1*y2,
								w1*y2 + z1*x2 - x1*z2,
								w1*z2 + x1*y2 - y1*x2,
								x1*x2 - y1*y2 - z1*z2);
	}


	public static function toEuler( q:Quaternion ):Point3D
	{
		var sqw:Float = q.w*q.w;
		var sqx:Float = q.x*q.x;
		var sqy:Float = q.y*q.y;
		var sqz:Float = q.z*q.z;
		var atan2 = Math.atan2;
		var rds:Float = 180/Math.PI;
		var euler:Point3D = new Point3D();
		// heading = rotaton about z-axis
		euler.z = atan2(2 * (q.x*q.y + q.z*q.w), (sqx - sqy - sqz + sqw) ) * rds ;
		// bank = rotation about x-axis
		euler.x = atan2(2 * (q.y*q.z + q.x*q.w),(-sqx - sqy + sqz + sqw) ) * rds ;
		// attitude = rotation about y-axis
		euler.y = Math.asin(-2 * (q.x*q.z - q.y*q.w)) * rds ;
		return euler ;
	}

	//Attention les angles doivent etre en degrés avec -180<x<180 , -90<y<90, -180<z<180 !!!
	public static function setEuler( x:Float, y:Float, z:Float ):Quaternion
	{
		var q:Quaternion = new Quaternion();
		var fsin = Math.sin;
		var fcos = Math.cos;
		//Conversion des angles en radians
		x = NumberUtil.toRadian( x );
		y = NumberUtil.toRadian( y );
		z = NumberUtil.toRadian( z );

		var angle:Float;
		angle = 0.5 * x ;
		var sx:Float = fsin(angle) ;
		var cx:Float = fcos(angle) ;
		angle = y * 0.5 ;
		var sy:Float = fsin(angle) ;
		var cy:Float = fcos(angle) ;
		angle = z * 0.5 ;
		var sz:Float = fsin(angle) ;
		var cz:Float = fcos(angle) ;

		var cycz:Float = cy * cz ;
		var sycz:Float = sy * cz ;
		var cysz:Float = cy * sz ;
		var sysz:Float = sy * sz ;

		q.x = sx * cycz - cx * sysz ;
		q.y = cx * sycz + sx * cysz ;
		q.z = cx * cysz - sx * sycz ;
		q.w = cx * cycz + sx * sysz ;
		QuaternionMath.normalize( q );
		return q;
	}

	public static function getRotationMatrix( q:Quaternion ):Matrix4
	{
		var xx:Float, yy:Float, zz:Float, xy:Float, xz:Float;
		var xw:Float, yz:Float, yw:Float, zw:Float;

		xx = q.x*q.x;
		xy = q.x*q.y;
		xz = q.x*q.z;
		xw = q.x*q.w;
		yy = q.y*q.y;
		yz = q.y*q.z;
		yw = q.y*q.w;
		zz = q.z*q.z;
		zw = q.z*q.w;

		var m:Matrix4 = new Matrix4();

		m.n11  = 1 - 2 * ( yy + zz )	 	;
		m.n12  = 	2 * ( xy + zw ) 		;
		m.n13  = 	2 * ( xz - yw ) 		;

		m.n21  = 	2 * ( xy - zw ) 		;
		m.n22  = 1 - 2 * ( xx + zz ) 		;
		m.n23  =   	2 * ( yz + xw ) 		;

		m.n31  = 	2 * ( xz + yw ) 		;
		m.n32  =   	2 * ( yz - xw ) 		;
		m.n33 = 1 - 2 * ( xx + yy )			;

		return m;
	}


	public static function setByMatrix( m:Matrix4 ):Quaternion
	{
		var q:Quaternion = new Quaternion();
		var t:Float = m.getTrace();
		var m0:Float = m.n11; var m5:Float = m.n22; var m10:Float = m.n33;
		var s:Float;
		if( t > 0.0000001 )
		{
			s = Math.sqrt( t ) * 2 ;
			q.x = ( m.n23 - m.n32 ) / s ;
			q.y = ( m.n31 - m.n13 ) / s ;
			q.z = ( m.n12 - m.n21 ) / s ;
			q.w = 0.25 * s ;
		}
		else if( m0 > m5 && m0 > m10 )
		{
			s = Math.sqrt( 1 + m0 - m5 - m10 ) * 2 ;
			q.x = 0.25 * s ;
			q.y = ( m.n12 + m.n21 ) / s ;
			q.z = ( m.n31 + m.n13 ) / s ;
			q.w = ( m.n23 - m.n32 ) / s ;
		}
		else if( m5 > m10 )
		{
			s = Math.sqrt( 1 + m5 - m0 - m10 ) * 2 ;
			q.y = 0.25 * s ;
			q.x = ( m.n12 + m.n21 ) / s ;
			q.w = ( m.n31 - m.n13 ) / s ;
			q.z = ( m.n23 + m.n32 ) / s ;
		}
		else
		{
			s = Math.sqrt( 1 + m10 - m5 - m0 ) * 2 ;
			q.z = 0.25 * s ;
			q.w = ( m.n12 - m.n21 ) / s ;
			q.x = ( m.n31 + m.n13 ) / s ;
			q.y = ( m.n23 + m.n32 ) / s ;
		}
		QuaternionMath.normalize( q );
		return q;
	}


	public static function setAxisAngle( axe:Point3D, angle:Float):Quaternion
	{
		axe.normalize();
		var a2:Float = angle * 0.5;
		var sa:Float = Math.sin( a2 ) ;
		var q:Quaternion = new Quaternion();
		q.w = Math.cos( a2 ) ;
		q.x = axe.x * sa ;
		q.y = axe.y * sa ;
		q.z = axe.z * sa ;
		QuaternionMath.normalize( q );
		return q;
	}


	public static function getAxisAngle( q:Quaternion ):Quaternion
	{
		QuaternionMath.normalize( q );
		var ca:Float = q.w;
		var a:Float = Math.acos( ca ) * 2 ;
		var sa:Float = Math.sqrt( 1 - ca * ca ) ;
		if( Math.abs( sa ) < 0.00005 ) sa = 1;
		var axis:Point3D = new Point3D(q.x/sa, q.y/sa, q.z/sa);

		var rq:Quaternion = new Quaternion();
		QuaternionMath.setPoint3D( rq, axis );
		QuaternionMath.setScalar( rq, NumberUtil.toDegree( a ) );
		return rq;
	}

	public static function getDotProduct( q:Quaternion, q2:Quaternion):Float
	{
		return ( q.x * q2.x) + (q.y * q2.y) + (q.z * q2.z) + (q.w * q2.w);
	}


	public static function multiplyByPoint3D( q:Quaternion, v:Point3D ):Point3D
	{
		return new Point3D( q.x * v.x * -q.x, q.y * v.y * -q.y, q.z * v.z * -q.z );
		/*
		var q:Quaternion = this.clone();
		var qc:Quaternion;
		qc = q.getConjugate();
		q.multiplyPoint3D(v);
		q.multiply(qc);
		return new Point3D4(q.getX(), q.getY(), q.getZ(), 0);
		*/
		/*
		// nVidia SDK implementation adapted by kiroukou
		var uv, uuv, qvec, v1, v2:Point3D4;
		qvec 	=  new Point3D4(q.x, q.y, q.z, 0);

		uv   	= qvec.crossV(v);

		uuv 	= qvec.crossV(uv);

		uv.scale(2 * q.w);
		uuv.scale(2);
		v1 = uv.getAddV(uuv);

		v2 = v.getAddV(v1);

		return (v2);
		*/
	}


}