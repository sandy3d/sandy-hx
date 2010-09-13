package caurina.transitions;

extern class TweenListObj {
	var auxProperties : Dynamic;
	var count : Float;
	var hasStarted : Bool;
	var isCaller : Bool;
	var isPaused : Bool;
	var onComplete : Dynamic;
	var onCompleteParams : Array<Dynamic>;
	var onError : Dynamic;
	var onOverwrite : Dynamic;
	var onOverwriteParams : Array<Dynamic>;
	var onStart : Dynamic;
	var onStartParams : Array<Dynamic>;
	var onUpdate : Dynamic;
	var onUpdateParams : Array<Dynamic>;
	var properties : Dynamic;
	var rounded : Bool;
	var scope : Dynamic;
	var skipUpdates : Float;
	var timeComplete : Float;
	var timePaused : Float;
	var timeStart : Float;
	var timesCalled : Float;
	var transition : Dynamic;
	var updatesSkipped : Float;
	var useFrames : Bool;
	var waitFrames : Bool;
	function new(p0 : Dynamic, p1 : Float, p2 : Float, p3 : Bool, p4 : Dynamic) : Void;
	function clone(p_transition : Bool) : TweenListObj;
	function toString() : String;
	static function makePropertiesChain(caurina.transitions:TweenListObj : Dynamic) : Dynamic;
}
