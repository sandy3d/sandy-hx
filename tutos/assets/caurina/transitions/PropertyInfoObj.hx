package caurina.transitions;

extern class PropertyInfoObj {
	var hasModifier : Bool;
	var modifierFunction : Dynamic;
	var modifierParameters : Array<Dynamic>;
	var valueComplete : Float;
	var valueStart : Float;
	function new(p0 : Float, p1 : Float, p2 : Dynamic, p3 : Array<Dynamic>) : Void;
	function clone() : PropertyInfoObj;
	function toString() : String;
}
