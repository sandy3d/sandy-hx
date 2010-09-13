package sandy.animation;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.data.Quaternion;
import sandy.math.QuaternionMath;
import sandy.util.DataConverter;
import sandy.util.DataOrder;

import sandy.HaxeTypes;

/**
 * Representation of an MD3 style tag structure. The quaternion property is
 * updated when the matrix is updated, so it is available for quick interpolations.
 *
 * @author		Russell Weir
 * @date		03.21.2009
 * @version		3.2
 **/
class Tag {
	public var name : String;
	public var origin : Point3D;
	public var matrix(__getMatrix, __setMatrix) : Matrix4;
	/** The Quaternion of the rotation matrix **/
	public var quaternion(__getQuaternion,null):Quaternion;

	public function new( p_sName : String="", ?p_oOrigin : Point3D, ?p_oMatrix : Matrix4 ) {
		this.name = p_sName;
		origin = if(p_oOrigin == null) new Point3D() else p_oOrigin.clone();
		matrix = if(p_oMatrix == null) new Matrix4() else p_oMatrix.clone();
	}

	public function clone() : Tag {
		return new Tag( name, origin.clone(), matrix.clone());
	}

	private function __getMatrix() : Matrix4 { return m_oMatrix; }
	private function __setMatrix(v : Matrix4) : Matrix4 {
		m_oQuat = QuaternionMath.setByMatrix(v);
		return m_oMatrix = v;
	}

	private function __getQuaternion() : Quaternion { return m_oQuat; }


	public function toString() : String {
		return "sandy.primitive.Tag" + " [" +  name + "] origin: " + Std.string(origin) + " rotation: " + Std.string(matrix);
	}

	public static function read(data:Bytes, numFrames:Int, numTags:Int, dataOrder:DataOrder) : Hash<TypedArray<Tag>>
	{
		var tags:Hash<TypedArray<Tag>> = new Hash();
		for(f in 0...numFrames) {
			for(i in 0...numTags) {
				/*
				U8 * 64 	NAME 	Name of Tag object. ASCII character string, NUL-terminated (C-style).
				VEC3 	ORIGIN 	Coordinates of Tag object.
				VEC3 * 3 	AXIS 	3x3 rotation matrix associated with the Tag.
				*/
				var td = new Tag( sandy.primitive.KeyFramedShape3D.readCString(data, 64) );

				// quake MD3->Sandy == x->z y->x z->y
				var origin = new Point3D ();
				origin.x = data.readFloat();
				origin.y = data.readFloat();
				origin.z = data.readFloat();
				td.origin = DataConverter.point3DToSandy(origin, dataOrder);

				// --
				var matrix = new Matrix4();
				matrix.n11 = data.readFloat(); // a
				matrix.n12 = data.readFloat(); // b
				matrix.n13 = data.readFloat(); // c
				matrix.n21 = data.readFloat(); // d
				matrix.n22 = data.readFloat(); // e
				matrix.n23 = data.readFloat(); // f
				matrix.n31 = data.readFloat(); // g
				matrix.n32 = data.readFloat(); // h
				matrix.n33 = data.readFloat(); // i
				td.matrix = DataConverter.rotationMatrix3x3ToSandy(matrix, dataOrder);

				if(!tags.exists(td.name))
					tags.set(td.name, new TypedArray());
				tags.get(td.name).push(td);
			}
		}

		return tags;
	}

	private var m_oMatrix : Matrix4;
	private var m_oQuat : Quaternion;
}