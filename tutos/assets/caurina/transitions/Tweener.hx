package caurina.transitions;

extern class Tweener {
	static function addCaller(?Object : Dynamic, ?Object : Dynamic) : Bool;
	static function addTween(?Object : Dynamic, ?Object : Dynamic) : Bool;
	static function debug_getList() : String;
	static function getTweenCount(count : Dynamic) : Float;
	static function getTweens(_timeScale : Dynamic) : Array<Dynamic>;
	static function getVersion() : String;
	static function init(?p_tween : Dynamic) : Void;
	static function isTweening(Object : Dynamic) : Bool;
	static function onEnterFrame(p_tween : flash.events.Event) : Void;
	static function pauseAllTweens() : Bool;
	static function pauseTweenByIndex(Object : Float) : Bool;
	static function pauseTweens(Object : Dynamic, ?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Bool;
	static function registerSpecialProperty(p_tween : String, p_tween : Dynamic, p_tween : Dynamic, ?p_tween : Array<Dynamic>) : Void;
	static function registerSpecialPropertyModifier(p_tween : String, p_tween : Dynamic, p_tween : Dynamic) : Void;
	static function registerSpecialPropertySplitter(p_tween : String, p_tween : Dynamic, ?p_tween : Array<Dynamic>) : Void;
	static function registerTransition(p_tween : String, p_tween : Dynamic) : Void;
	static function removeAllTweens() : Bool;
	static function removeTweenByIndex(Object : Float, ?Object : Bool) : Bool;
	static function removeTweens(Object : Dynamic, ?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Bool;
	static function removeTweensByTime(Object : Dynamic, Object : Dynamic, Object : Float, Object : Float) : Bool;
	static function resumeAllTweens() : Bool;
	static function resumeTweenByIndex(Object : Float) : Bool;
	static function resumeTweens(Object : Dynamic, ?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic ) : Bool;
	static function setTimeScale(p_tween : Float) : Void;
	static function splitTweens(p_tween : Float, p_properties : Array<Dynamic>) : UInt;
	static function updateTime() : Void;
}
