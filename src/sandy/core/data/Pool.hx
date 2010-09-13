package sandy.core.data;

import sandy.HaxeTypes;

/**
* @author thomas
* @author Russell Weir - haXe port
*/
class Pool
{
	public var nextVertex(__getNextVertex,null) : Vertex;
	public var nextUV(__getNextUV,null) : UVCoord;
	public var nextPoint3D(__getNextPoint3D,null) : Point3D;

	private var m_nSize:Int;
	private var m_aVertices:Array<Vertex>;
	private var m_nIdVertice:Int;

	private var m_aUV:Array<UVCoord>;
	private var m_nIdUV:Int;

	private var m_aPoint3Ds:Array<Point3D>;
	private var m_nIdPoint3D:Int;

	private static var INSTANCE:Pool;

	public static function getInstance():Pool
	{
		if( INSTANCE == null ) INSTANCE = new Pool();
		return INSTANCE;
	}

	public function new()
	{
		if (INSTANCE != null)
		{
			throw "There *MUST* be single Pool instance.";
		}

		// initializers
		m_nSize = 300;
		m_aVertices = new Array();
		m_nIdVertice = 0;
		m_aUV = new Array();
		m_nIdUV = 0;
		m_aPoint3Ds = new Array();
		m_nIdPoint3D = 0;

		for( i in 0...m_nSize )
		{
			m_aVertices[i] = new Vertex();
			m_aUV[i] = new UVCoord();
			m_aPoint3Ds[i] = new Point3D();
		}
	}

	public function init():Void
	{
		m_nIdVertice = m_nIdUV = m_nIdPoint3D = 0;
	}

	private function __getNextVertex():Vertex
	{
		if( m_nIdVertice >= m_aVertices.length )
			m_aVertices[m_aVertices.length] = new Vertex();
		// --
		var l_oV:Vertex = m_aVertices[m_nIdVertice++];
		l_oV.projected = false;
		l_oV.transformed = false;
		return l_oV;
	}

	private function __getNextUV():UVCoord
	{
		if( m_nIdUV >= m_aUV.length )
			m_aUV[m_aUV.length] = new UVCoord();
		// --
		return m_aUV[m_nIdUV++];
	}

	private function __getNextPoint3D():Point3D
	{
		if( m_nIdPoint3D >= m_aPoint3Ds.length )
			m_aPoint3Ds[m_aPoint3Ds.length] = new Point3D();
		// --
		return m_aPoint3Ds[m_nIdPoint3D++];
	}

}
