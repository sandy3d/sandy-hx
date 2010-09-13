package sandy;

#if flash10
typedef TypedArray<T> = flash.Vector<T>;
#else
typedef TypedArray<T> = Array<T>;
#end

typedef Bytes = flash.utils.ByteArray;

#if !flash
typedef UInt = Int;
#end

#if SANDY_USE_FAST_MATH
typedef TRIG = sandy.math.FastMath;
#else
typedef TRIG = Math;
#end

#if neko
typedef Int32 = I32;
#else
typedef Int32 = Int;
#end

#if (flash9 || flash10)
typedef Xml = sandy.util.FlashXml__;
typedef FastXml = sandy.util.FastXml__;
#else
typedef FastXml = haxe.xml.Fast;
#end

class Haxe {
	#if flash10
	private static inline var MEM_POOL_LENGTH : Int = 10240;
	private static var MEM_POOL:flash.utils.ByteArray;
	#end

	/**
	* Converts a TypedArray to a normal array
	*/
	public static function toArray<T>(v : TypedArray<T>) : Array<T> {
		var a = new Array<T>();
		for(i in 0...v.length)
			a[i] = v[i];
		return a;
	}

	/**
	* Converts a normal Array to a TypedArray
	*/
	public static inline function toTypedArray<T>(v : Array<T>) : TypedArray<T> {
		#if flash10
			return untyped __vector__(v);
		#else
			return v;
		#end
	}

	static function __init__() {
		#if flash10
			MEM_POOL = new flash.utils.ByteArray();
			MEM_POOL.length = MEM_POOL_LENGTH;
			flash.Memory.select(MEM_POOL);
		#end
	}
}

#if flash
typedef ObjectMap<K,V> = flash.utils.TypedDictionary<K,V>;
#else
/**
* Maps objects to values, using an internal tag to
* track what objects have what value. Similar to
* a flash TypedDictionary, but without weak references
*/
class ObjectMap<K,V>  {
	static inline var TAG : String = "__{ObjectMapTag}";

	var m_keys : Array<K>;
	var m_values : Array<V>;

	public function new(useWeak:Bool=false) {
		m_values = new Array();
	}

	public inline function get(key:K) : Null<V> {
		var idx = getTagIndex(key);
		return (idx < 0) ? null : m_values[idx];
	}

	public inline function set(key:K, value:V) : Void {
		var idx = getTagIndex(key);
		if(idx < 0) {
			m_values[idx] = value;
		}
		else { // new one
			m_keys.push(key);
			Reflect.setField(key, TAG, m_values.push(value) - 1);
		}
	}

	public inline function exists(key:K) : Bool {
		return getTagIndex(key) >= 0;
	}

	public inline function delete( key:K ) : Void {
		var idx = getTagIndex(key);
		if(idx >= 0) {
			#if debug
				if(m_keys[idx] != key)
					throw "Internal error.";
			#end
			m_keys[idx] = null;
			m_values[idx] = null;
		}
		Reflect.deleteField(key, TAG);
	}

	public inline function keys() : Array<K> {
		return m_keys;
	}

	public inline function iterator() : Iterator<K> {
		return m_keys.iterator();
	}

	/**
	* Returns index, or -1 if doesn't exist
	**/
	private function getTagIndex(key:K) : Int {
		var idyn : Dynamic = Reflect.field(key, TAG);
		if(idyn == null)
			return -1;
		switch(Type.typeof(idyn)) {
		case TInt:
			return idyn;
		default:
			return -1;
		}
	}
}
#end

enum Alignment {
	XY;
	YZ;
	ZX;
}

enum ColorChannel {
	RED;
	GREEN;
	BLUE;
	ALPHA;
	AV;
}

enum CoordinateSystem {
	LOCAL;
	CAMERA;
	ABSOLUTE;
}
