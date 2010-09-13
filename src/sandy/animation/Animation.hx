package sandy.animation;

/**
 * Holds information about a pre-calculated animation for key framed items.
 *
 * @author		Russell Weir (madrok)
 * @date		03.22.2009
 * @version		3.2
 **/
class Animation {

	public var name : String;

	/**
	* Total time for animation in milliseconds
	*/
	public var duration(__getDuration,null) : Int;

	/**
	* First keyframe of animation
	*/
	public var firstFrame : Float;

	/**
	* Last frame number of animation
	**/
	public var lastFrame(__getLastFrame, null) : Float;

	/**
	* Number of frames in animation sequence
	**/
	public var frames : Float;

	/**
	* Number of looping frames
	**/
	public var loopingFrames : Float;

	/**
	* Frames per second in sequence
	**/
	public var fps : Float;

	/**
	* Arbitrary animation type identifier
	**/
	public var type : String;

	/**
	* Footsteps sound associated with animation
	**/
	public var soundName : String;

	/**
	* Sound associated with animation
	**/
	public var sound : sandy.core.scenegraph.Sound3D;

	/**
	* Sex of model/animation. m, f or n
	**/
	public var sex : String;


	public function new(p_sName : String) {
		this.name = p_sName;
		this.fps = 0.0;
		this.sex = "n";
	}

	private function __getDuration() : Int {
		if(fps == 0.)
			return 0;
		return Std.int(frames/fps * 1000);
	}

	private function __getLastFrame() : Float {
		var v = firstFrame + frames - 1.;
		if(v < 0) return 0;
		return v;
	}

	public function toString() : String {
		return "sandy.animation.Animation " + name + " (" + type + ") start frame: " + firstFrame + " length: " + frames + " loop: " + loopingFrames + " fps: " + fps + " duration ms:" + duration + " sound: " + soundName;
	}
}
