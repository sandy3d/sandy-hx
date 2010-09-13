package sandy.core.scenegraph;

import sandy.animation.IKeyFramed;
import sandy.core.data.Point3D;
import sandy.core.data.Matrix4;
import sandy.core.scenegraph.AnimatedShape3D;
// import sandy.core.scenegraph.Node;
// import sandy.core.scenegraph.TagCollection;
// import sandy.core.scenegraph.TransformGroup;
import sandy.primitive.KeyFramedShape3D;


import sandy.HaxeTypes;

/**
 * Contains groups of IKeyFramed primitives as a single rotation group. Formats
 * like MD3 can contain multiple meshes per file, which are loaded into
 * a KeyFramedTransformGroup.
 *
 * @author		Russell Weir (madrok)
 * @date		03.21.2009
 * @version		3.2
 */
class KeyFramedTransformGroup extends TransformGroup, implements IKeyFramed {

	/** Tag name where this group is attached to, if any **/
	public var attachedAt : String;
	/** Matrices for each tag for the current frame **/
	public var currentFrameMatrices(__getCurrentFrameMatrices,null) : TypedArray<Hash<Matrix4>>;
	//////////////////////// IKeyFramed ///////////////////
	public var frame (__getFrame,__setFrame):Float;
	public var frameCount(__getFrameCount,null):Int;
	public var frameUpdateBounds(__getFrameUpdateBounds,__setFrameUpdateBounds) : Bool;
	public var interpolateBounds(__getInterpolateBounds,__setInterpolateBounds) : Bool;

	/**
	* Creates a key framed transform group.
	*
	* @param  p_sName	A string identifier for this object
	*/
	public function new( ?p_sName:String = "")
	{
		super( p_sName );
		this.trackBounds = true;
		m_nCurFrame = 0;
		m_nFrames = 0;
		m_aCurrentTags = new TypedArray();
		m_bEditable = true;
		m_bFrameUpdateBounds = false;
		m_bInterpolateBounds = false;
	}

	public override function addChild( p_oChild:Node ):Void
	{
		if(!Std.is(p_oChild, IKeyFramed) || p_oChild == null)
			throw "Invalid child type";

		var kf = cast(p_oChild, IKeyFramed);
		// if first child, reset
		if(children.length == 0) {
			m_nFrames = kf.frameCount;
		}

		// Seems that tag-only files can have different frame counts
		if(kf.frameCount != m_nFrames) {
			trace("IKeyFramed " + p_oChild.name + " frame count " + kf.frameCount + " incorrect. Expected " + m_nFrames + ". Disabling edits.");
			m_bEditable = false;
// 				continue;
		}
		if(Std.is(p_oChild, TagCollection)) {
			super.addChild( p_oChild );
		}
		else if(Std.is(p_oChild, KeyFramedShape3D)) {
			super.addChild( p_oChild );
		}
		else if(Std.is(p_oChild, KeyFramedTransformGroup)) {
			for(c in p_oChild.children)
				super.addChild( c );
		}
		else {
			throw "Invalid/unhandled child type";
		}

		// update to current transform group frame
		kf.frame = m_nCurFrame;
	}

	public override function clone( p_sName:String ):TransformGroup
	{
		var l_oGroup = new KeyFramedTransformGroup( p_sName );

		for ( l_oNode in children )
		{
			if( Reflect.hasField(l_oNode, "clone") )
			{
				l_oGroup.addChild( untyped l_oNode.clone( p_sName+"_"+l_oNode.name ) );
			}
		}
		l_oGroup.m_nCurFrame = m_nCurFrame;
		l_oGroup.m_nFrames = m_nFrames;
		l_oGroup.m_bFrameUpdateBounds = m_bFrameUpdateBounds;
		l_oGroup.m_bInterpolateBounds = m_bInterpolateBounds;
		// --
		var a = new TypedArray<Hash<Matrix4>>();
		for(i in 0...m_aCurrentTags.length) {
			var h = new Hash<Matrix4>();
			for(key in m_aCurrentTags[i].keys()) {
				h.set(key, m_aCurrentTags[i].get(key).clone());
			}
			a.push(h);
		}
		l_oGroup.m_aCurrentTags = a;
		// --
		l_oGroup.m_bEditable = m_bEditable;
		// finally, just call the setter to update anything that
		// may have been missed.
		l_oGroup.frame = this.frame;
		return l_oGroup;
	}

	private function __getCurrentFrameMatrices() : TypedArray<Hash<Matrix4>> {
		return m_aCurrentTags;
	}

	/**
	* Returns a string representation of the TransformGroup.
	*
	* @return	The fully qualified name.
	*/
	public override function toString():String
	{
		return "sandy.core.scenegraph.KeyFramedTransformGroup :["+name+"]";
	}

	public function setSkin(data:Hash<Dynamic>) {
		for(c in children)
			trace(c.name);
	}

	//////////////////////// IKeyFramed ///////////////////
	public function appendFrameCopy (frameNumber:Int):Int {
		if(!m_bEditable)
			throw "Mismatched frame counts do not allow for edits";
		var rv : Int = -1;
		for ( l_oNode in children ) {
			if( Std.is(l_oNode, IKeyFramed) ) {
				var kf : IKeyFramed = cast(l_oNode, IKeyFramed);
				rv = kf.appendFrameCopy(frameNumber);
			}
		}
		return rv;
	}

	public function replaceFrame (destFrame:Int, sourceFrame:Float):Void {
		if(!m_bEditable)
			throw "Mismatched frame counts do not allow for edits";
		for ( l_oNode in children ) {
			if( Std.is(l_oNode, IKeyFramed) ) {
				var kf : IKeyFramed = cast(l_oNode, IKeyFramed);
				kf.replaceFrame(destFrame, sourceFrame);
			}
		}
	}

	private function __getFrame ():Float {
		return m_nCurFrame;
	}

	private function __getFrameCount():Int {
		return m_nFrames;
	}

	private function __setFrame (value:Float):Float {
		m_nCurFrame = value;
		var fInt = Std.int(m_nCurFrame);
		var c1:Float = m_nCurFrame - fInt;
		var c2:Float = 1 - c1;

		// clear current tags
		m_aCurrentTags.splice(0,m_aCurrentTags.length);
		// Updates all the vertex and position info in children
		for ( l_oNode in children ) {
			if(Std.is(l_oNode, TagCollection)) {
				var kf : TagCollection = cast(l_oNode, TagCollection);
				kf.frame = m_nCurFrame;
				var tagMatrices = kf.getCurrentFrameTags();
				m_aCurrentTags.push(tagMatrices);
// 				if(attachedAt != null && tagMatrices.exists(attachedAt)) {
// 					this.resetCoords();
// 					this.matrix = tagMatrices.get(attachedAt);
// 				}
			}
			else if( Std.is(l_oNode, IKeyFramed) ) {
				var kf : IKeyFramed = cast(l_oNode, IKeyFramed);
				kf.frame = m_nCurFrame;
			}
		}

		// Notify parent AnimatedShape3D of tag changes
		if(m_aCurrentTags.length > 0)
		{
			if(hasParent() && Std.is(parent, AnimatedShape3D))
			{
				cast(parent, AnimatedShape3D).onFrameChanged(this,m_aCurrentTags);
			}
		}
		// --
		changed = true;
		return value;
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


	private var m_nCurFrame : Float;
	private var m_nFrames : Int;
	// maps of tag -> Matrix4
	private var m_aCurrentTags : TypedArray<Hash<Matrix4>>;
	// --
	private var m_bFrameUpdateBounds : Bool;
	private var m_bInterpolateBounds : Bool;
	// Ture if appendFrameCopy and replaceFrame can be used on this group
	private var m_bEditable : Bool;

}
