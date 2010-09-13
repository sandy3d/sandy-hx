package sandy.util;

import sandy.HaxeTypes;

/**
* Static methods for cross platform use of Array's and TypedArray's. [array]
* parameters are Dynamic, so use with caution.
*
* @author		Russell Weir
* @version		3.2
**/
class ArrayUtil {
	public static inline function indexOf(array:Dynamic, searchElement:Dynamic, fromIndex:Int=0) : Int
	{
		#if (flash || js)
			return untyped array.indexOf(searchElement, fromIndex);
		#else
			var idx = -1;
			for(i in fromIndex...untyped array.length) {
				if(untyped array[i] == searchElement) {
					idx = i;
					break;
				}
			}
			return idx;
		#end
	}

	public static inline function lastIndexOf(array:Dynamic, searchElement:Dynamic, ?fromIndex:Int=0x7FFFFFFF) : Int
	{
		#if (flash || js)
			return untyped array.lastIndexOf(searchElement, fromIndex);
		#else
		if(fromIndex > untyped array.length)
			fromIndex = untyped array.length;
		var idx : Int = -1;
		while(--fromIndex > -1) {
			if(untyped array[fromIndex] == searchElement) {
				idx = fromIndex;
				break;
			}
		}
		return idx;
		#end
	}

	/**
	* Makes an array 0 length, in the faster way possible per platform
	*/
	public static inline function truncate(array:Dynamic) : Void {
		#if (flash || js)
		untyped array.length = 0;
		#else
		untyped array.splice(0, untyped array.length);
		#end
	}

	#if js
	static function jsSort<T>( a:T, b:T )
	{
		untyped
		{
			return (a['m_nDepth'] < b['m_nDepth']) ? 1 : -1;
		}
	}

	#end
	
	inline public static function sortOnLite<T>(inArray:Array<T>, fieldNames:Array<String>, ?options:Int = 0):Array<T> {
			#if flash
			

			var result:Dynamic = untyped inArray.sortOn(fieldNames, options & 23);
			return Std.is(result,Array) ? result : [];
			

			#elseif (js && SANDY_JS_DIRTY_SORT)
				inArray.sort( jsSort );
				return inArray;

			#else
			
			var result:Array<T> = [];
			if (inArray.length != 0) {
				var oNumeric = options >> 4 & 1 == 1;
				var oUniquesort = options >> 2 & 1 == 1;
				var oDescending = options >> 1 & 1 == 1;
				var oCaseinsensitive = options & 1 == 1;
				
				var hasDup = false;
				if (oUniquesort) {
					var testCase = new Array<Array<Dynamic>>();
					for (i in 0...inArray.length) {
						testCase[i] = new Array<Dynamic>();
						for (f in fieldNames) {
							var fi = Reflect.field(inArray[i],f);
							var isString = !(Std.is(fi,Float) || Std.is(fi,Int));
							var ele:Dynamic;
							if (oCaseinsensitive && isString) {
								ele = Std.string(fi).toLowerCase();
							} else {
								ele = inArray[i];
							}
							testCase[i].push(ele);
						}
					}
					var removedDup = ArrayUtil.removeDuplicates2(testCase);
					if (removedDup.length != testCase.length) hasDup = true;
				}
				if (!hasDup){
					inArray.sort(getSortingFunction(oNumeric, false, oUniquesort, oDescending, oCaseinsensitive,fieldNames));
			
					result = inArray;
				}
			}
			return result;
			#end
		}
		
		/**
			Basically same as sortOn, but ArrayUtil.SORT_RETURNINDEXEDARRAY is fixed whatever you supplied as options.
			The return is typed as Array<Int>.
		*/
		#if cpp
		inline
		#end public static function indicesOfSorted(inArray:Array<Dynamic>, fieldNames:Array<String>, ?options:Int = 0):Array<Int> {
			#if flash
			

			var result:Dynamic = untyped inArray.sortOn(fieldNames, options | 8);
			return Std.is(result,Array) ? result : [];
			

			#else
			
			var result:Array<Int> = [];
			var sortArray = ArrayUtil.sortOnLite(inArray.copy(), fieldNames, options);
					
			if (sortArray.length != 0) {
				var usedArray = new Array<Bool>();
				for (e in inArray){
					usedArray.push(false);
				}
				for (e in inArray){
					var index = 0;
					do {
						index = ArrayUtil.indexOf(sortArray,e,index);
					} while ((index < usedArray.length) && (usedArray[index] == true));
					usedArray[index] = true;
	
					result.push(index);
				}
			}
			return result;
			#end
		}
		
		private static function getSortingFunction(oNumeric:Bool, oReturnindexedarray:Bool, oUniquesort:Bool, oDescending:Bool, oCaseinsensitive:Bool, fieldNames:Array<String>):Dynamic {
			return function (a,b):Int {
						var r = 0;
						for (f in fieldNames){
							var af:Dynamic = Reflect.field(a,f);
							var bf:Dynamic = Reflect.field(b,f);
						
							if (!oNumeric){
								if (Std.is(af,Float) || Std.is(af,Int)) {
									af = Std.string(af);
								}
								if (Std.is(bf,Float) || Std.is(bf,Int)) {
									bf = Std.string(bf);
								}
							}
						
							if (oCaseinsensitive) {
								if (Std.is(af,String)) {
									af = af.toLowerCase();
								}
								if (Std.is(bf,String)) {
									bf = bf.toLowerCase();
								}
							}
							
							if (af != bf){
								if (!oDescending) {
									if (!oNumeric){
										r = strcmp(af,bf) > 0 ? 1 : -1;
									} else {
										r = af>bf ? 1 : -1;
									}
								} else {
									if (!oNumeric){
										r = strcmp(af,bf) < 0 ? 1 : -1;
									} else {
										r = af<bf ? 1 : -1;
									}
								}
							}
						}
						return r;
					}
		}
		
		inline public static var SORT_CASEINSENSITIVE(_CASEINSENSITIVE,null):Int;
		inline public static var SORT_DESCENDING(_DESCENDING,null):Int;
		inline public static var SORT_UNIQUESORT(_UNIQUESORT,null):Int;
		inline public static var SORT_RETURNINDEXEDARRAY(_RETURNINDEXEDARRAY,null):Int;
		inline public static var SORT_NUMERIC(_NUMERIC,null):Int;
		
		inline private static function _CASEINSENSITIVE():Int {
			return 1;
		}
		
		inline private static function _DESCENDING():Int {
			return 2;
		}
		
		inline private static function _UNIQUESORT():Int {
			return 4;
		}
		
		inline private static function _RETURNINDEXEDARRAY():Int {
			return 8;
		}
		
		inline private static function _NUMERIC():Int {
			return 16;
		}
		
		private static function strcmp(s0:String,s1:String):Float {
			var r:Float = s0.length-s1.length;
			for (i in 0...Math.floor(Math.min(s0.length,s1.length))){
				if (s0.charAt(i) != s1.charAt(i)) {
					#if!php
					r = s0.charCodeAt(i) - s1.charCodeAt(i);
					#else
					var c0 = s0.charAt(i);
					var c1 = s1.charAt(i);
					r = untyped __php__("ord($c0)-ord($c1)");
					#end
					break;
				}
			}
			return r;
		}
		
		inline private static function removeDuplicates2<T>(inArray:Array<Array<T>>):Array<Array<T>> {
			var i = 0;
			var cp = inArray.copy();
			var outArray:Array<Array<T>> = inArray.copy();
			for (i in cp){
				for (j in 1...ArrayUtil.contains2(outArray,i)){
					outArray.remove(i);
				}
			}
			return outArray;
		}
		
		private static function contains2<T>(inArray:Array<Array<T>>, item:Array<T>):UInt {
			var i:Int  = indexOf(inArray, item, 0);
			var t:UInt = 0;
			
			while (i != -1) {
				i = indexOf2(inArray, item, i + 1);
				t++;
			}
			
			return t;
		}
		
		private static function indexOf2<T>(inArray:Array<Array<T>>, match:Array<T>, ?fromIndex:Int = 0):Int {
			var i = fromIndex-1;
			while (++i < inArray.length) {
				if (ArrayUtil.equals(inArray[i],match)) return i;
			}
			return -1;
		}
		
		inline public static function equals(first:Array<Dynamic>, second:Array<Dynamic>):Bool {
			var i:UInt = first.length;
			var result:Bool = true;
			
			if (i != second.length) {
				result = false;
			} else {
				while (i-- > 0) {
					if (first[i] != second[i]) {
						result = false;
						break;
					}
				}
			}
			
			return result;
		}
}
