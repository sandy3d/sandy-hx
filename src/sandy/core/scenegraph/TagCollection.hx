
package sandy.core.scenegraph;

import sandy.animation.IKeyFramed;
import sandy.animation.Tag;
import sandy.core.data.Point3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Quaternion;
import sandy.HaxeTypes;

/**
 * Contains a hash of Tag elements
 *
 * @author		Russell Weir (madrok)
 * @date		03.21.2009
 * @version		3.2
 */
class TagCollection extends Node, implements IKeyFramed {

	public var frame (__getFrame,__setFrame)	: Float;
	public var frameCount(__getFrameCount,null)	: Int;
	public var tags(__getTags,__setTags)		: Hash<TypedArray<Tag>>;
	/**
	* No effect in TagCollection.
	**/
	public var frameUpdateBounds(__getFrameUpdateBounds,__setFrameUpdateBounds) : Bool;
	public var interpolateBounds(__getInterpolateBounds,__setInterpolateBounds) : Bool;


	/**
	* Creates a key framed transform group.
	*
	* @param  p_sName	A string identifier for this object
	*/
	public function new( ?p_sName:String = "", ?p_hTags:Hash<TypedArray<Tag>>)
	{
		super( p_sName );
		m_nCurFrame = 0;
		m_nFrames = 0;
		m_hTags = new Hash();
		m_hMatricesCurFrame = new Hash();
		m_hMatricesTmp = new Hash();
		tags = p_hTags;
	}

	/**
	* Creates a new TagCollection with cloned Tags
	*
	* @param p_sName Name for new TagCollection
	**/
	public function clone( p_sName:String ):TagCollection
	{
		var rv = new TagCollection( p_sName );
		var nh = new Hash<TypedArray<Tag>>();

		for(key in m_hTags.keys()) {
			var ar = m_hTags.get(key);
			var na = new TypedArray<Tag>();
			for(i in 0...ar.length)
				na[i] = ar[i].clone();
			nh.set(key, na);
		}
		//--
		rv.tags = nh;
		rv.frame = this.frame;
		return rv;
	}

	public function getCurrentFrameTags() : Hash<Matrix4> {
		return m_hMatricesCurFrame;
	}

	private function interpolateForFrame( value : Float ) : Void {
		var fInt = Std.int(value);
		var c1:Float = value - fInt;
		var c2:Float = 1 - c1;
		for( key in m_hTags.keys() ) {
			var ta = m_hTags.get(key);
			var l = ta.length;
			var ft1:Tag = ta[fInt % l];
			var ft2:Tag = ta[(fInt + 1) % l];

			// set current tag origins
			var origin1 = ft1.origin;
			var origin2 = ft2.origin;
			var interPos : Point3D = new Point3D();
			var interMatrix : Matrix4 = null;

			if(c1 == 0.) { // no need to interpolate
				interPos = origin1.clone();
				interMatrix = ft1.matrix.clone();
			}
			else {
				// interpolate position
				interPos.x = c2 * origin1.x + c1 * origin2.x;
				interPos.y = c2 * origin1.y + c1 * origin2.y;
				interPos.z = c2 * origin1.z + c1 * origin2.z;

				// interpolate rotations
				var currRot: Quaternion = ft1.quaternion;
				var nextRot: Quaternion = ft2.quaternion;
				var interRot : Quaternion = Quaternion.slerp(currRot, nextRot, c1);
				interMatrix = interRot.getRotationMatrix();
			}
			interMatrix.n14 = interPos.x;
			interMatrix.n24 = interPos.y;
			interMatrix.n34 = interPos.z;
			m_hMatricesTmp.set(key, interMatrix);
		}
	}

	//////////////////////// IKeyFramed ///////////////////

	public function appendFrameCopy (frameNumber:Int):Int {
		if(frameNumber < 0 || frameNumber >= m_nFrames)
			return -1;
		m_nFrames++;
		for(ar in m_hTags) {
			ar.push(ar.slice(frameNumber)[0]);
		}
		return m_nFrames - 1;
	}

	public function replaceFrame (destFrame:Int, sourceFrame:Float):Void {
		interpolateForFrame(sourceFrame);
		for(key in m_hMatricesTmp.keys()) {
			var m = m_hMatricesTmp.get(key);
			var o = new Point3D(m.n14, m.n24, m.n34);
			m.n14 = 0.;
			m.n24 = 0.;
			m.n34 = 0.;
			var newTag = new Tag("", o, m);
			var ta = m_hTags.get(key);
			if(ta != null) {
				ta[destFrame] = newTag;
			}
		}
	}

	private function __getFrame ():Float {
		return m_nCurFrame;
	}

	private function __setFrame (value:Float):Float {
		m_nCurFrame = value;
		interpolateForFrame(value);
		var t = m_hMatricesTmp;
		m_hMatricesTmp = m_hMatricesCurFrame;
		m_hMatricesCurFrame = t;
		return value;
	}

	private function __getFrameCount():Int {
		return m_nFrames;
	}

	private function __getTags() : Hash<TypedArray<Tag>> {
		return m_hTags;
	}

	private function __setTags(v: Hash<TypedArray<Tag>>) : Hash<TypedArray<Tag>> {
		if(v == null) {
			m_nFrames = 0;
			return null;
		}
		m_nFrames = -1;
		for(a in v) {
			if(m_nFrames == -1)
				m_nFrames = a.length;
			else if(m_nFrames != a.length)
				throw "Tags must all have the same number of frames";
		}
		if(m_nFrames == -1) m_nFrames = 0;
		return m_hTags = v;
	}

	private function __getFrameUpdateBounds() : Bool {
		return m_bFrameUpdateBounds;
	}

	private function __setFrameUpdateBounds(v:Bool) : Bool {
		for(c in children) {
			if(Std.is(c, IKeyFramed)) {
				cast(c, IKeyFramed).frameUpdateBounds = v;
			}
		}
		return m_bFrameUpdateBounds = v;
	}

	private function __getInterpolateBounds() : Bool {
		return m_bInterpolateBounds;
	}

	private function __setInterpolateBounds(v:Bool) : Bool {
		for(c in children) {
			if(Std.is(c, IKeyFramed)) {
				cast(c, IKeyFramed).interpolateBounds = v;
			}
		}
		return m_bInterpolateBounds = v;
	}

	private var m_hTags:Hash<TypedArray<Tag>>; // tag elements
	// maps tag -> Matrix4
	private var m_hMatricesCurFrame : Hash<Matrix4>;
	// where interpolateForFrame generates to
	private var m_hMatricesTmp : Hash<Matrix4>;
	private var m_nCurFrame : Float;
	private var m_nFrames : Int;
	//--
	private var m_bFrameUpdateBounds : Bool;
	private var m_bInterpolateBounds : Bool;
}
