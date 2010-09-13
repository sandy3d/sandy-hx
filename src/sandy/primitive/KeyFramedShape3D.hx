
package sandy.primitive;

import sandy.animation.IKeyFramed;
import sandy.animation.Tag;
import sandy.core.data.Point3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.core.data.UVCoord;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Shape3D;
import sandy.bounds.BBox;
import sandy.bounds.BSphere;
import sandy.materials.Appearance;
import sandy.primitive.Primitive3D;
import sandy.view.CullingState;
import sandy.view.Frustum;

import flash.utils.ByteArray;
import flash.utils.Endian;

import sandy.HaxeTypes;

/**
* Base class for shapes that are frame based animations.
* includes classes like MD2 and MD3
* @author Russell Weir (madrok)
* @author makc
* @todo Performance Issue: check boundingSphere interpolation for speed vs. resetFromBox
**/
class KeyFramedShape3D extends Shape3D,
	implements sandy.animation.IKeyFramed,
	implements Primitive3D
{
	/**
	* Frames map. This maps frame names to frame numbers. For many
	* model exported from 3d software, the frames may all be named
	* the same. Sandy does not rely on this hash, it may be used
	* to store arbitrary name->frame mapping.
	*/
	public var frames:Hash<Int>;
	public var frame (__getFrame,__setFrame):Float;
	public var frameCount(__getFrameCount,null):Int;
	public var vertexCount(__getVertexCount,null):Int;
	public var frameUpdateBounds(__getFrameUpdateBounds,__setFrameUpdateBounds) : Bool;
	public var interpolateBounds(__getInterpolateBounds,__setInterpolateBounds) : Bool;


	/**
	* Creates KeyFramedShape3D primitive.
	*
	* @param p_sName Shape instance name.
	* @param data MD2 binary data.
	* @param scale Adjusts model scale.
	*/
	public function new( p_sName:String="", data:Bytes=null, scale:Float=1.0, p_oAppearance:Appearance=null, p_bUseSingleContainer:Bool=true) {
		frames = new Hash();
		vertices = new TypedArray();
		m_oBBoxes = new TypedArray();
		m_oBSpheres = new TypedArray();
		m_bFrameUpdateBounds = false;
		m_bInterpolateBounds = false;
		scaling = scale;

		super(p_sName, null, p_oAppearance, p_bUseSingleContainer);

		if(data != null) {
			geometry = generate ([data]);
			resetFrameBounds();
			frame = 0;
		}
	}

	/**
	* Appends frame copy to animation.
	* You can use this to rearrange an animation at runtime, create transitions, etc.
	*
	* @return number of created frame.
	*/
	public function appendFrameCopy (frameNumber:Int):Int
	{
		var rv:Int = -1;
		if( frameNumber < vertices.length ) {
			var box : BBox = null;
			var sphere : BSphere = null;
			var f:TypedArray<Point3D> = vertices [frameNumber];

			if (f == null) {
				return -1;
			} else {
				num_frames++;
				if(frameNumber < m_oBBoxes.length)
					box = m_oBBoxes[frameNumber].clone();
				if(frameNumber < m_oBSpheres.length)
					sphere = m_oBSpheres[frameNumber].clone();
				rv = vertices.push ( f.slice(0) ) -1;

				if(box == null || sphere == null) {
					resetFrameBounds();
				}
				else {
					m_oBBoxes.push(box);
					m_oBSpheres.push(sphere);
				}

				return rv;
			}
		}
		return rv;
	}

	public override function clone( ?p_sName:String = "", ?p_bKeepTransform:Bool=false ):Shape3D
	{
		var l_oClone:KeyFramedShape3D = new KeyFramedShape3D( p_sName, null, scaling, appearance, m_bUseSingleContainer );
		// --
		l_oClone.geometry = geometry.clone();
		// --
		if( p_bKeepTransform == true ) l_oClone.matrix.copy( this.matrix );
		// --
		l_oClone.useSingleContainer = this.useSingleContainer;
		// --
		l_oClone.appearance = this.appearance;
		// Vertices
		var vc = new TypedArray<TypedArray<Point3D>>();
		for(i in 0...vertices.length) {
			var vr = new TypedArray<Point3D>();
			vc[i] = vr;
			for(j in 0...vertices[i].length)
				vr[j] = vertices[i][j].clone();
		}
		l_oClone.vertices = vc;
		// Bounds
		var boxes = new TypedArray<BBox>();
		var spheres = new TypedArray<BSphere>();
		for(i in 0...m_oBBoxes.length)
			boxes.push(m_oBBoxes[i].clone());
		for(i in 0...m_oBSpheres.length)
			spheres.push(m_oBSpheres[i].clone());
		l_oClone.m_oBBoxes = boxes;
		l_oClone.m_oBSpheres = spheres;
		// --
		l_oClone.num_frames = num_frames;
		l_oClone.num_vertices = num_vertices;
		l_oClone.m_nCurFrame = m_nCurFrame;
		l_oClone.scaling = scaling;
		l_oClone.m_bFrameUpdateBounds = m_bFrameUpdateBounds;
		l_oClone.m_bInterpolateBounds = m_bInterpolateBounds;

		return l_oClone;
	}

	private inline function interpolateFrameBounds(ratio:Float,frame1:Int,frame2:Int,toBox:BBox,toSphere:BSphere) : Void
	{
		var c2 = ratio;
		var c1 = 1 - c2;

		var l_nBoxesLen : Int = m_oBBoxes.length;
		if( l_nBoxesLen > frame1 && l_nBoxesLen > frame2) {
			var box1 = m_oBBoxes[frame1];
			var box2 = m_oBBoxes[frame2];

			if(c2 == 0.) {
				toBox.copy(box1);
			}
			else if(c2 == 1.) {
				toBox.copy(box2);
			}
			else {
				var min1 = box1.minEdge;
				var min2 = box2.minEdge;
				var max1 = box1.maxEdge;
				var max2 = box2.maxEdge;

				var edge = toBox.minEdge;
				edge.x = min1.x * c1 + min2.x * c2;
				edge.y = min1.y * c1 + min2.y * c2;
				edge.z = min1.z * c1 + min2.z * c2;

				edge = toBox.maxEdge;
				edge.x = max1.x * c1 + max2.x * c2;
				edge.y = max1.y * c1 + max2.y * c2;
				edge.z = max1.z * c1 + max2.z * c2;
			}
		}
		// probably faster here to interpolate sphere values than
		// to incur the sqrt in BSphere.resetFromBox
		var l_nSpheresLen : Int = m_oBSpheres.length;
		if( l_nSpheresLen > frame1 && l_nSpheresLen > frame2) {
			var s1 = m_oBSpheres[frame1];
			var s2 = m_oBSpheres[frame2];

			if(c2 == 0.) {
				toSphere.copy(s1);
			}
			else if(c2 == 1.) {
				toSphere.copy(s2);
			}
			else {
				toSphere.radius =  s1.radius * c1 + s2.radius * c2;
				toSphere.center.x = s1.center.x * c1 + s2.center.x * c2;
				toSphere.center.y = s1.center.y * c1 + s2.center.y * c2;
				toSphere.center.z = s1.center.z * c1 + s2.center.z * c2;
			}
		}
		else {
			toSphere.resetFromBox(toBox);
		}
		toBox.uptodate = false;
		toSphere.uptodate = false;
	}


	/**
	* Replaces specified frame with other key or interpolated frame.
	*/
	public function replaceFrame (destFrame:Int, sourceFrame:Float):Void
	{
		var sfi = Std.int(sourceFrame);
		var f0:TypedArray<Point3D> = new TypedArray();

		if(vertices.length > 0) {
			var frame1 : Int = sfi % num_frames;
			var frame2 : Int = (sfi + 1) % num_frames;
			// interpolation frames
			var f1:TypedArray<Point3D> = vertices [frame1];
			var f2:TypedArray<Point3D> = vertices [frame2];

			// interpolation coef-s
			var c2:Float = sourceFrame - sfi, c1:Float = 1. - c2;

			// loop through vertices
			for(i in 0...num_vertices)
			{
				var v0:Point3D = new Point3D();
				var v1:Point3D = f1 [i];
				var v2:Point3D = f2 [i];

				// interpolate
				v0.x = v1.x * c1 + v2.x * c2;
				v0.y = v1.y * c1 + v2.y * c2;
				v0.z = v1.z * c1 + v2.z * c2;

				// save
				f0 [i] = v0;
			}

			vertices [destFrame] = f0;
			num_frames = vertices.length;

			// interpolate bounds
			var box = new BBox();
			var sphere = new BSphere();
			interpolateFrameBounds(c2, frame1, frame2, box, sphere);
			m_oBBoxes[destFrame] = box;
			m_oBSpheres[destFrame] = sphere;
		}
	}


	/**
	* When the vertex list has been generated, this method should
	* be called to create all the bounds for each frame
	*/
	private function resetFrameBounds() : Void {
		m_oBBoxes = new TypedArray();
		m_oBSpheres = new TypedArray();

		for(frame in 0...num_frames) {
			var f0:TypedArray<Point3D> = vertices[frame];
			var va : Array<Vertex> = new Array();
			for (i in 0...num_vertices) {
				var v0:Vertex = m_oGeometry.aVertex [i];
				v0.x = f0[i].x; v0.wx = f0[i].x;
				v0.y = f0[i].y; v0.wy = f0[i].y;
				v0.z = f0[i].z; v0.wz = f0[i].z;
				va.push(v0);
			}

			var box = BBox.create(va);
			var sphere = new BSphere();
			sphere.resetFromBox(box);
			m_oBBoxes[frame] = box;
			m_oBSpheres[frame] = sphere;
		}
	}


	private function __getFrame ():Float { return m_nCurFrame; }

	/**
	* @private (setter)
	*/
	private function __setFrame (value:Float):Float
	{
		m_nCurFrame = value;
		changed = true;
		return value;
	}

	public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		super.cull (p_oFrustum, p_oViewMatrix, p_bChanged);

		if ((m_nCurFrame != m_nOldFrame) && (culled != CullingState.OUTSIDE) && (appearance != null)) {
			// it does make sense to do this only when we're on display list
			m_nOldFrame = m_nCurFrame;

			if(vertices.length == 0) return;

			var cfi : Int = Std.int(m_nCurFrame);
			var frame1 : Int = cfi % num_frames;
			var frame2 : Int = (cfi + 1) % num_frames;

			// interpolation frames
			var f1:TypedArray<Point3D> = vertices [frame1];
			var f2:TypedArray<Point3D> = vertices [frame2];

			// interpolation coef-s
			var c2:Float = m_nCurFrame - Std.int(m_nCurFrame), c1:Float = 1 - c2;

			// loop through vertices
			for (i in 0...num_vertices)
			{
				var v0:Vertex = m_oGeometry.aVertex [i];
				var v1:Point3D = f1 [i];
				var v2:Point3D = f2 [i];

				// interpolate
				v0.x = v1.x * c1 + v2.x * c2; v0.wx = v0.x;
				v0.y = v1.y * c1 + v2.y * c2; v0.wy = v0.y;
				v0.z = v1.z * c1 + v2.z * c2; v0.wz = v0.z;
			}

			// update face normals
			if (!animated) for (l_oPoly in aPolygons) l_oPoly.updateNormal ();

			if(m_bFrameUpdateBounds) {
				// Set current bounds, either based on interpolation
				// or on closest integral frame number
				if( m_bInterpolateBounds ) {
					interpolateFrameBounds(c2, frame1, frame2, boundingBox, boundingSphere);
				}
				else { // bounds set as closest frame
					var fno = (c2 < 0.5) ? frame1 : frame2;
					if(m_oBBoxes.length > fno)
						boundingBox = m_oBBoxes[fno];
					if(m_oBSpheres.length > fno)
						boundingSphere = m_oBSpheres[fno];
					else
						boundingSphere.resetFromBox(boundingBox);
					boundingBox.uptodate = false;
					boundingSphere.uptodate = false;
				}
				if(parent != null)
					parent.onChildBoundsChanged(this);
			}
		}

	}

	private function __getFrameCount():Int { return num_frames; }
	private function __getVertexCount():Int { return vertices.length; }

	/**
	* Generates the geometry.
	*
	* @return The geometry object.
	*/
	public function generate<T>(?arguments:Array<T>):Geometry3D
	{
		return new Geometry3D();
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

	/**
		Reads a C style null terminated string from an input buffer,
		consuming all of <code>count</code> bytes.
		@param data Input bytes
		@param count Bytes to consume
		@return String not including any bytes from a 0 on.
	**/
	public static function readCString(data:ByteArray, count:Int, ?breakOnNull:Bool) {
		var rv = "";
		var append = true;
		for (i in 0...count)
		{
			var c = data.readUnsignedByte ();
			if(c == 0) {
				append = false;
				if(breakOnNull)
					return rv;
				continue;
			}
			if(append)
				rv += String.fromCharCode(c);
		}
		return rv;
	}

	// total number of frames in animation
	private var num_frames:Int;
	private var num_vertices:Int;

	// animation "time" (frame number)
	private var m_nCurFrame:Float;
	private var m_nOldFrame:Float;
	private var scaling:Float;

	// vertices list for every frame
	private var vertices:TypedArray<TypedArray<Point3D>>;
	// boundingBoxes for every frame
	private var m_oBBoxes:TypedArray<BBox>;
	// bounding spheres for every frame
	private var m_oBSpheres:TypedArray<BSphere>;

	//--
	private var m_bFrameUpdateBounds : Bool;
	private var m_bInterpolateBounds : Bool;

}
