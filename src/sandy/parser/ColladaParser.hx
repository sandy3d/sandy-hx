
package sandy.parser;

import sandy.core.data.Matrix4;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.ATransformable;
import sandy.core.scenegraph.Geometry3D;
import sandy.core.scenegraph.Node;
import sandy.core.scenegraph.Shape3D;
import sandy.core.scenegraph.TransformGroup;
import sandy.events.QueueEvent;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.util.LoaderQueue;
import sandy.util.NumberUtil;

import flash.events.Event;
import flash.net.URLRequest;

import sandy.HaxeTypes;

/**
* Transforms a COLLADA XML document into Sandy geometries.
* <p>Creates a Group as rootnode which appends all geometries it finds.
* Recommended settings for the COLLADA exporter:</p>
* <ul>
* <li>Relative paths</li>
* <li>Triangulate</li>
* <li>Normals</li>
* </ul>
*
* @author		Dennis Ippel - ippeldv
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @since		1.0
* @version		3.1
* @date 		26.07.2007
*
* @example To parse a COLLADA object at runtime:
*
* <listing version="3.1">
*     var parser:IParser = Parser.create( "/path/to/my/colladafile.dae", Parser.COLLADA );
* </listing>
*
* @example To parse an embedded COLLADA object:
*
* <listing version="3.1">
*     [Embed( source="/path/to/my/colladafile.dae", mimeType="application/octet-stream" )]
*     private var MyCollada:Class;
*
*     ...
*
*     var parser:IParser = Parser.create( new MyCollada(), Parser.COLLADA );
* </listing>
*/
typedef ColladaImage = {
	bitmapData: flash.display.BitmapData,
	id : String,
	fileName : String
}

class ColladaParser extends AParser, implements IParser
{
	private var m_oCollada : FastXml;
	private var m_oUp:UpAxis;

	private var m_oMaterials : Hash<ColladaImage>;

	/**
	 * Creates a new COLLADA parser instance.
	 *
	 * @param p_sUrl		Can be either a string pointing to the location of the
	 * 						COLLADA file or an instance of an embedded COLLADA file.
	 * @param p_nScale		The scale factor.
	 * @param p_sTextureExtension	Overrides texture extension. You might want to use it for models that
	 * specify BMP or PCX textures.
	 */
	public function new<URL>( p_sUrl:URL, ?p_nScale:Float=1.0, ?p_sTextureExtension:String )
	{
		super( p_sUrl, p_nScale, p_sTextureExtension );
	}

	/**
	 * @private
	 * Starts the parsing process
	 *
	 * @param e				The Event object
	 */
	private override function parseData( ?e:Event ) : Void
	{
		super.parseData( e );

		// -- read the XML
		m_oCollada = new FastXml( Xml.parse( m_oFile ).firstElement() );

		var l_sAxis = m_oCollada.node.asset.node.up_axis.innerData;
		switch ( l_sAxis ) {
				case "Y_UP":	m_oUp = Y_UP;
				case "Z_UP":	m_oUp = Z_UP;
				case "X_UP":	m_oUp = X_UP;
				default:	m_oUp = NONE;
		}

		if( m_oCollada.hasNode.library_images )
			loadImages( m_oCollada.node.library_images.nodes.image );
		else
			parseScene( m_oCollada.node.library_visual_scenes.node.visual_scene );
	}

	private function parseScene( p_oScene : FastXml ) : Void
	{
		// -- local variables
		var l_oNodes : List<FastXml> = p_oScene.nodes.node;

		for( l_oN in l_oNodes )
		{
			var l_oNode : Node = parseNode( l_oN );
			// -- add the shape to the group node
			if( l_oNode != null )
				m_oGroup.addChild( l_oNode );
		}

		// -- Parsing is finished
		dispatchInitEvent();
	}

	private function parseNode( p_oNode : FastXml ) : Node
	{
		// -- local variables
		var l_oNode:ATransformable = null;
		//var l_oMatrix : Matrix4 = new Matrix4();
		var l_sGeometryID : String;
		var l_oNodes : List<FastXml>;
		var l_nNodeLen : Int;
		var l_oPoint3D : Point3D;
		//var l_oPivot:Point3D = new Point3D();
		var l_oGeometry : Geometry3D = null;
		//var l_oScale : Transform3D;
		var i:Int;

		if( p_oNode.hasNode.instance_geometry )
		{
			var l_aGeomArray:Array<String>;
			var l_oAppearance : Appearance = m_oStandardAppearance;
			l_oGeometry = new Geometry3D();
			l_oAppearance = getAppearance( p_oNode );

			l_aGeomArray = p_oNode.node.instance_geometry.att.url.split( "#" );
			l_sGeometryID = l_aGeomArray[ 1 ];
			// -- get the vertices
			l_oGeometry = getGeometry( l_sGeometryID, m_oMaterials );

			if( l_oGeometry == null ) return null;
			// -- create the new shape
			l_oNode = new Shape3D( p_oNode.att.name, l_oGeometry, l_oAppearance );
		}
		else
		{
			l_oNode = new TransformGroup( p_oNode.att.name );
		}

		// -- scale
		if( p_oNode.hasNode.scale )
		{
			l_oPoint3D = stringToPoint3D( p_oNode.node.scale.innerData );
			// --
			formatPoint3D( l_oPoint3D );
			// --
			l_oNode.scaleX = l_oPoint3D.x;
			l_oNode.scaleY = l_oPoint3D.y;
			l_oNode.scaleZ = l_oPoint3D.z;

		}
		// -- translation
		if( p_oNode.hasNode.translate )
		{
			var l_aTransAtt:List<FastXml> = p_oNode.nodes.translate;
			for( l_oT in l_aTransAtt )
			{
				var l_sTranslationValue:String = "";
				// --
				var l_oAttTranslateNode:String = null;
				var l_sAttTranslateValue:String = "";
				if( l_oT.has.sid ) {
					l_oAttTranslateNode = l_oT.att.sid;
					l_sAttTranslateValue = l_oAttTranslateNode.toLowerCase();
				}

				if( l_sAttTranslateValue == "translation" || l_sAttTranslateValue ==  "translate" )
						l_sTranslationValue = l_oT.innerData;
				else if( l_sAttTranslateValue.length == 0 )
						l_sTranslationValue = l_oT.innerData;

				if( l_sTranslationValue.length > 0 )
				{
					// --
					l_oPoint3D = stringToPoint3D( l_sTranslationValue );
					l_oPoint3D.scale(m_nScale);
					// --
					formatPoint3D( l_oPoint3D );
					// --
					l_oNode.x = l_oPoint3D.x;
					l_oNode.y = l_oPoint3D.y;
					l_oNode.z = l_oPoint3D.z;
				}
			}
		}
		// -- rotate
		if( Lambda.count( p_oNode.nodes.rotate ) == 1 )
		{
			var l_oRotations : Array<Int> = stringToArray( p_oNode.node.rotate.innerData );

			switch (m_oUp)
			{
				case X_UP:
				// not implemented
				case Y_UP:
				l_oNode.rotateAxis(	l_oRotations[ 0 ], l_oRotations[ 1 ], l_oRotations[ 2 ], l_oRotations[ 3 ] );
				case Z_UP:
				// not implemented
				case NONE:
				l_oNode.rotateAxis(	l_oRotations[ 0 ], l_oRotations[ 2 ], l_oRotations[ 1 ], l_oRotations[ 3 ] );
			}

		}
		else if( Lambda.count( p_oNode.nodes.rotate ) == 3 )
		{
			var l_oRotateNodes : List<FastXml> = p_oNode.nodes.rotate;
			for( l_oN in l_oRotateNodes )
			{
				var l_oRot : Array<Int> = stringToArray( l_oN.innerData );

				switch( l_oN.att.sid.toLowerCase() )
				{
					case "rotatex":
					{
						if( l_oRot[ 3 ] != 0 )
						{
							switch (m_oUp) {
							case X_UP: // not implemented
							case Y_UP: l_oNode.rotateX = l_oRot[ 3 ];
							case Z_UP: // not implemented
							case NONE: l_oNode.rotateX = l_oRot[ 3 ];
							}
						}
						break;
					}
					case "rotatey":
					{
						if( l_oRot[ 3 ] != 0 )
						{
							switch (m_oUp) {
							case X_UP: // not implemented
							case Y_UP: l_oNode.rotateY = l_oRot[ 3 ];
							case Z_UP: // not implemented
							case NONE: l_oNode.rotateZ = l_oRot[ 3 ];
							}
						}
						break;
					}
					case "rotatez":
					{
						if( l_oRot[ 3 ] != 0 )
						{
							switch (m_oUp) {
							case X_UP: // not implemented
							case Y_UP: l_oNode.rotateZ = l_oRot[ 3 ];
							case Z_UP: // not implemented
							case NONE: l_oNode.rotateY = l_oRot[ 3 ];
							}
						}
						break;
					}
				}
			}
		}

		// -- baked matrix
		if( p_oNode.hasNode.matrix )
		{
			stringToMatrix( p_oNode.node.matrix.innerData );
		}

		// -- loop through subnodes
		l_oNodes = p_oNode.nodes.node;

		for( l_oN in l_oNodes )
		{
			var l_oChildNode : Node = parseNode( l_oN );
			// -- add the shape to the group node
			if( l_oChildNode != null )
				l_oNode.addChild( l_oChildNode );
		}

		// quick hack to get url-ed nodes parsed
		if( p_oNode.hasNode.instance_node )
		{
			var l_sNodeId:String = p_oNode.node.instance_node.att.url;
			if ((l_sNodeId != "") && (l_sNodeId.charAt(0) == "#"))
			{
				l_sNodeId = l_sNodeId.substr(1);
				var l_oMatchingNodes:List<FastXml> = m_oCollada.node.library_nodes.nodes.node;
				for ( l_oMatchingNode in l_oMatchingNodes ) {
					if ( l_oMatchingNode.att.id == l_sNodeId ) {
						var l_oNode3D:Node = parseNode( l_oMatchingNode );
						// -- add the shape to the group node
						if( l_oNode3D != null )
							l_oNode.addChild( l_oNode3D );
					}
				}
			}
		}

		//l_oShape.matrix = l_oMatrix;
		return l_oNode;
	}

	private function getGeometry( p_sGeometryID : String, p_oMaterials : Hash<ColladaImage> ) :  Geometry3D
	{
		var i : Int;
		var l_oOutpGeom : Geometry3D = new Geometry3D();
		var l_oGeometries : List<FastXml> = m_oCollada.node.library_geometries.nodes.geometry;
		var l_oGeometry : FastXml = null;

		// -- parse geometry node
		for ( l_oNode in l_oGeometries ) {
			if ( l_oNode.att.id == p_sGeometryID ) {
					if ( l_oGeometry == null )
							l_oGeometry = l_oNode;
			}
		}
		if ( l_oGeometry == null ) return null;

		// -- triangles
		var l_oTriangles : FastXml = l_oGeometry.node.mesh.node.triangles;
		if( l_oTriangles == null ) return null;
		var l_aTriangles : Array<Int> = stringToArray( l_oTriangles.node.p.innerData );
		var l_sMaterial : String = l_oTriangles.att.material;
		var l_nCount : Int = Std.parseInt( l_oTriangles.att.count );
		var l_nStep : Int = Lambda.count( l_oTriangles.nodes.input );

		// -- parse xml semantics
		var l_sVerticesID : String = null;
		var l_oTexCoord : FastXml = null;
		var l_oNormal : FastXml = null;
		var l_aInput = l_oTriangles.nodes.input;
		for ( l_oInput in l_aInput ) {
			switch (l_oInput.att.semantic) {
			case "VERTEX":
					if ( l_sVerticesID == null )
							l_sVerticesID = l_oInput.att.source.split("#")[1];
			case "TEXCOORD":
					if ( l_oTexCoord == null )
							l_oTexCoord = l_oInput;
			case "NORMAL":
					if ( l_oNormal == null )
							l_oNormal = l_oInput;
			default:
			// log warning ?
			}
		}

		// -- get vertices float array
		var l_sPosSourceID : String = null;
		var l_aVertices = l_oGeometry.node.mesh.nodes.vertices;

		// -- check that the VerticesID was parsed correctly
		if ( l_aVertices.length > 0 && l_sVerticesID == null ) return null;

		for ( l_oNode in l_aVertices ) {
				if ( l_oNode.att.id == l_sVerticesID ) {
						var l_aInput = l_oNode.nodes.input;
						for ( l_oInput in l_aInput ) {
								if ( l_oInput.att.semantic == "POSITION" ) {
										if ( l_sPosSourceID == null )
												l_sPosSourceID = l_oInput.att.source.split("#")[1];
								}
						}
				}
		}

		var l_aVertexFloats : Array<Point3D> = getFloatArray( l_sPosSourceID, l_oGeometry );
		var l_nVertexFloat : Int = l_aVertexFloats.length;
		// -- set vertices
		for( i in 0...l_nVertexFloat )
		{
			var l_oVertex:Point3D = l_aVertexFloats[ i ];
			l_oVertex.scale( m_nScale );
			// --
			formatPoint3D( l_oVertex );
			// --
			l_oOutpGeom.setVertex(	i,
									l_oVertex.x,
									l_oVertex.y,
									l_oVertex.z );
		}

		if( l_oTexCoord != null )
		{
			// -- get uvcoords float array
			var l_sUVCoordsID : String = l_oTexCoord.att.source.split("#")[1];
			var l_aUVCoordsFloats : Array<Point3D> = getFloatArray( l_sUVCoordsID, l_oGeometry );
			var l_nUVCoordsFloats : Int = l_aUVCoordsFloats.length;

			// -- set uvcoords
			for( i in 0...l_nUVCoordsFloats )
			{
				var l_oUVCoord:Point3D = l_aUVCoordsFloats[ i ];

				l_oOutpGeom.setUVCoords( i,l_oUVCoord.x, 1 - l_oUVCoord.y );
			}
		}

		// -- get normals float array
		// THOMAS TODO: Why using VertexNormal?  It is face normal !
		if( l_oNormal != null )
		{
			var l_sNormalsID : String = l_oNormal.att.source.split("#")[1];
			var l_aNormalFloats : Array<Point3D> = getFloatArray( l_sNormalsID, l_oGeometry );
			var l_nNormalFloats : Int = l_aNormalFloats.length;

			// -- set normals
			for( i in 0...l_nNormalFloats )
			{
				var l_oNormal:Point3D = l_aNormalFloats[ i ];
				// STRANGE, AREN'T NORMAL VECTORS NORMALIZED?
				l_oNormal.normalize();
				// --
				formatPoint3D(l_oNormal);
				// --
			}
		}


		var l_aTrianglez:Array<Hash<Array<Int>>> = convertTriangleArray( l_oTriangles.nodes.input, l_aTriangles, l_nCount );
		var l_nTriangeLength : Int = l_aTrianglez.length;

		for( i in 0...l_nTriangeLength )
		{
			var l_aVertex : Array<Int> = l_aTrianglez[ i ].get( 'VERTEX' );
			var l_aNormals : Array<Int> = l_aTrianglez[ i ].get( 'NORMAL' );
			var l_aUVs : Array<Int> = l_aTrianglez[ i ].get( 'TEXCOORD' );

				l_oOutpGeom.setFaceVertexIds( i, [l_aVertex[ 0 ], l_aVertex[ 1 ], l_aVertex[ 2 ]] );
				if( l_aUVs != null ) l_oOutpGeom.setFaceUVCoordsIds( i, [l_aUVs[ 0 ], l_aUVs[ 1 ], l_aUVs[ 2 ]] );
		}

		return l_oOutpGeom;
	}

	private function getFloatArray( p_sSourceID : String, p_oGeometry : FastXml ) : Array<Point3D>
	{
		var l_aSources : List<FastXml> = p_oGeometry.node.mesh.nodes.source;
		var l_oSource : FastXml = null;
		for ( l_oNode in l_aSources )
		{
			if ( l_oNode.att.id == p_sSourceID ) {
				l_oSource = l_oNode;
				break;
			}
		}
		if ( l_oSource == null ) return null;

		var l_aFloatArray : Array<String> = l_oSource.node.float_array.innerData.split(" ");
		var l_nCount:Int = Std.parseInt( l_oSource.node.technique_common.node.accessor.att.count );
		var l_nOffset:Int = Std.parseInt( l_oSource.node.technique_common.node.accessor.att.stride );

		var l_nFloatArray : Int = l_aFloatArray.length;
		var l_aOutput : Array<Point3D> = new Array();

		var i:Int = 0;
		while(  i < l_nFloatArray )
		{
			var l_oCoords : Point3D = null;
			// FIX FROM THOMAS to solve the case there's only UV coords exported instead of UVW. To clean
			if( l_nOffset == 3 )
			{
				l_oCoords = new Point3D( Std.parseFloat( l_aFloatArray[ i ] ),
										Std.parseFloat( l_aFloatArray[ i + 1 ] ),
										Std.parseFloat( l_aFloatArray[ i + 2 ] ) );
			}
			else if( l_nOffset == 2 )
			{
				l_oCoords =	new Point3D( Std.parseFloat( l_aFloatArray[ i ] ),
										Std.parseFloat( l_aFloatArray[ i + 1 ]) , 0 );
			}
			l_aOutput.push( l_oCoords );
			i += l_nOffset;
		}

		return l_aOutput;
	}

	private function convertTriangleArray( p_oInput : List<FastXml>, p_aTriangles : Array<Int>, p_nTriangleCount : Int ) : Array<Hash<Array<Int>>>
	{
		var l_nTriangles : Int = p_aTriangles.length;
		var l_aOutput : Array<Hash<Array<Int>>> = new Array();
		var l_nValuesPerTriangle : Int = Std.int( l_nTriangles / p_nTriangleCount );
		var l_nMaxOffset : Int = 0;

		var l_aInputA:Array<FastXml> = Lambda.array(p_oInput);
		var l_aInputB:Array<FastXml> = l_aInputA.copy();
		for( l_oI in l_aInputA )
		{
			l_nMaxOffset = Std.int( Math.max( l_nMaxOffset, Std.parseFloat( l_oI.att.offset ) ) );
		}
		l_nMaxOffset += 1;
		// -- iterate through all triangles
		for( i in 0...p_nTriangleCount )
		{
			var semantic : Hash<Array<Int>> = new Hash();

			for( j in 0...l_nValuesPerTriangle )
			{
				for( l_oI in l_aInputB )
				{
					var l_oSemantic:String = l_oI.att.semantic;
					var l_oOffset:String = l_oI.att.offset;
					if( Std.parseInt( l_oOffset ) == j % l_nMaxOffset )
					{
						if( semantic.get( l_oSemantic ) == null )
							semantic.set( l_oSemantic, new Array() );

						var index:Int = ( i * l_nValuesPerTriangle ) + j;
						semantic.get( l_oSemantic ).push( p_aTriangles[ index ] );
					}
				}
			}

			l_aOutput.push( semantic );
		}

		return l_aOutput;
	}

	/**
	* Converts a space separated string to an array
	*
	* @param p_sValues		A string containing space separated values
	* @return 				The resulting array
	*/
	private function stringToArray( p_sValues : String ) : Array<Int>
	{
		//var l_aValues : Array = p_sValues.split(/\s+/);
		var l_aValues : Array<String> = p_sValues.split(" ");
		var l_nValues : Array<Int> = new Array();

		for( l_oV in l_aValues )
		{
			l_nValues.push( Std.parseInt( l_oV ) );
		}

		return l_nValues;
	}

	/**
	* Converts a string to a Point3D
	*
	* @param p_sValues		A string containing space separated values
	* @return 				The resulting Point3D
	*/
	private function stringToPoint3D( p_sValues : String ) : Point3D
	{
		//var l_aValues : Array = p_sValues.split(/\s+/);
		var l_aValues : Array<String> = p_sValues.split(" ");
		var l_nValues : Int = l_aValues.length;
		// --
		if( l_nValues != 3 )
			throw "ColladaParser.stringToPoint3D(): A Point3D must have 3 values";
		// --
		return new Point3D( Std.parseFloat( l_aValues[ 0 ] ), Std.parseFloat( l_aValues[ 1 ] ), Std.parseFloat( l_aValues[ 2 ] ) );
	}

	private function stringToMatrix( p_sValues : String ) : Matrix4
	{
		//var l_aValues : Array = p_sValues.split(/\s+/);
		var l_aValues : Array<String> = p_sValues.split(" ");
		var l_nValues : Int = l_aValues.length;

		if( l_nValues != 16 )
			throw "ColladaParser.stringToMatrix(): A Point3D must have 16 values";

		var l_oMatrix4 : Matrix4 = new Matrix4(
			Std.parseFloat( l_aValues[ 0 ] ), Std.parseFloat( l_aValues[ 1 ] ), Std.parseFloat( l_aValues[ 2 ] ), Std.parseFloat( l_aValues[ 3 ] ),
			Std.parseFloat( l_aValues[ 4 ] ), Std.parseFloat( l_aValues[ 5 ] ), Std.parseFloat( l_aValues[ 6 ] ), Std.parseFloat( l_aValues[ 7 ] ),
			Std.parseFloat( l_aValues[ 8 ] ), Std.parseFloat( l_aValues[ 9 ] ), Std.parseFloat( l_aValues[ 10 ] ), Std.parseFloat( l_aValues[ 11 ] ),
			Std.parseFloat( l_aValues[ 12 ] ), Std.parseFloat( l_aValues[ 13 ] ), Std.parseFloat( l_aValues[ 14 ] ), Std.parseFloat( l_aValues[ 15 ] )
		);

		return l_oMatrix4;
	}


	private function formatPoint3D( p_oVect:Point3D ):Void
	{
		var tmp:Float;
		switch (m_oUp) {
				case X_UP:
						// not implemented
				case Y_UP:
						p_oVect.x = -p_oVect.x;
				case Z_UP:
						var t = p_oVect.z;
						p_oVect.z = p_oVect.y;
						p_oVect.y = t;
				case NONE:
		}
	}

	private function getAppearance( p_oNode : FastXml ) : Appearance
	{
		// -- local variables
		var l_oAppearance : Appearance = null;

		// -- Get this node's instance materials
		var l_aInstance : List<FastXml> = p_oNode.nodes.instance_geometry;
		var l_aBind : List<FastXml> = null;
		var l_aTechnique : List<FastXml> = null;
		var l_oMaterials : Array<FastXml> = [];
		for ( l_oInstance in l_aInstance ) {
				l_aBind = l_oInstance.nodes.bind_material;
				for ( l_oBind in l_aBind ) {
						l_aTechnique = l_oBind.nodes.technique_common;
						for ( l_oTechnique in l_aTechnique ) {
								var l_aMaterials = l_oTechnique.nodes.instance_material;
								for ( l_oMaterial in l_aMaterials )
										l_oMaterials.push( l_oMaterial );
						}
				}
		}
		for ( l_oInstMat in l_oMaterials )
		{
			// -- get the corresponding material from the library
			var l_sId :String = l_oInstMat.att.target.split( "#" )[ 1 ];
			var l_oMaterial : FastXml = null;
			var l_aMaterials : List<FastXml> = m_oCollada.node.library_materials.nodes.material;
			for ( l_oNode in l_aMaterials ) {
					if ( l_oNode.att.id == l_sId ) {
							l_oMaterial = l_oNode;
							break;
					}
			}
			if ( l_oMaterial == null ) return null;
			// -- get the corresponding effect
			var l_sEffectID : String = null;
			try {
					// am I mistaken, is there no way of knowing whether innerData is filled ?
					l_sEffectID = l_oMaterial.node.instance_effect.att.url.split( "#" )[ 1 ];
			} catch (e:Dynamic) {
					l_sEffectID = "";
			}

			var l_oEffect : FastXml = null;
			if ( l_sEffectID == "" )
			{
				l_oEffect = m_oCollada.node.library_effects.node.effect;
			} else {
					var l_aEffect : List<FastXml> = m_oCollada.node.library_effects.nodes.effect;
					for ( l_oNode in l_aEffect ) {
							if ( l_oNode.att.id == l_sEffectID ) {
									l_oEffect = l_oNode;
									break;
							}
					}
			}
			if ( l_oEffect == null ) return null;

			var l_oTechnique : FastXml;
			var l_aTexture : Array<FastXml> = [];
			var l_aPhong : Array<FastXml> = [];
			var l_aTechnique : Array<FastXml> = [];
			var l_oNode : FastXml = l_oEffect.node.profile_COMMON.node.technique;
			switch (true) {
					case l_oNode.hasNode.asset:
					if ( l_oNode.node.asset.hasNode.diffuse && l_oNode.node.asset.node.diffuse.hasNode.texture ) {
							l_aTexture.push( l_oNode.node.asset.node.diffuse.node.texture );
					} else if ( l_oNode.node.asset.hasNode.emission && l_oNode.node.asset.node.emission.hasNode.texture  ) {
							l_aTexture.push( l_oNode.node.asset.node.emission.node.texture );
					}
					case l_oNode.hasNode.annotate:
					if ( l_oNode.node.annotate.hasNode.diffuse && l_oNode.node.annotate.node.diffuse.hasNode.texture ) {
							l_aTexture.push( l_oNode.node.annotate.node.diffuse.node.texture );
					} else if ( l_oNode.node.annotate.hasNode.emission && l_oNode.node.annotate.node.emission.hasNode.texture  ) {
							l_aTexture.push( l_oNode.node.annotate.node.emission.node.texture );
					}
					case l_oNode.hasNode.blinn:
					if ( l_oNode.node.blinn.hasNode.diffuse && l_oNode.node.blinn.node.diffuse.hasNode.texture ) {
							l_aTexture.push( l_oNode.node.blinn.node.diffuse.node.texture );
					} else if ( l_oNode.node.blinn.hasNode.emission && l_oNode.node.blinn.node.emission.hasNode.texture  ) {
							l_aTexture.push( l_oNode.node.blinn.node.emission.node.texture );
					}
					case l_oNode.hasNode.constant:
					if ( l_oNode.node.constant.hasNode.diffuse && l_oNode.node.constant.node.diffuse.hasNode.texture ) {
							l_aTexture.push( l_oNode.node.constant.node.diffuse.node.texture );
					} else if ( l_oNode.node.constant.hasNode.emission && l_oNode.node.constant.node.emission.hasNode.texture  ) {
							l_aTexture.push( l_oNode.node.constant.node.emission.node.texture );
					}
					case l_oNode.hasNode.lambert:
					if ( l_oNode.node.lambert.hasNode.diffuse && l_oNode.node.lambert.node.diffuse.hasNode.texture ) {
							l_aTexture.push( l_oNode.node.lambert.node.diffuse.node.texture );
					} else if ( l_oNode.node.lambert.hasNode.emission && l_oNode.node.lambert.node.emission.hasNode.texture  ) {
							l_aTexture.push( l_oNode.node.lambert.node.emission.node.texture );
					}
					case l_oNode.hasNode.phong:
					if ( l_oNode.node.phong.hasNode.diffuse && l_oNode.node.phong.node.diffuse.hasNode.texture ) {
							l_aTexture.push( l_oNode.node.phong.node.diffuse.node.texture );
					} else if ( l_oNode.node.phong.hasNode.emission && l_oNode.node.phong.node.emission.hasNode.texture  ) {
							l_aTexture.push( l_oNode.node.phong.node.emission.node.texture );
					}
					case l_oNode.hasNode.extra:
					if ( l_oNode.node.extra.hasNode.diffuse && l_oNode.node.extra.node.diffuse.hasNode.texture ) {
							l_aTexture.push( l_oNode.node.extra.node.diffuse.node.texture );
					} else if ( l_oNode.node.extra.hasNode.emission && l_oNode.node.extra.node.emission.hasNode.texture  ) {
							l_aTexture.push( l_oNode.node.extra.node.emission.node.texture );
					}
			}

			var l_oNodes : List<FastXml> = l_oNode.nodes.phong;
			for ( l_oPhong in l_oNodes ) {
					l_aPhong.push( l_oPhong );
			}
			// -- no textures here or colors defined
			if( l_aTexture.length == 0 && l_aPhong.length == 0 ) return m_oStandardAppearance;

			if( l_aTexture.length > 0 )
			{
				// -- get the texture ID and use it to get the surface source
				var l_sTextureID : String = l_aTexture[0].att.texture;
				var l_aNewParam : List<FastXml> = l_oEffect.node.profile_COMMON.nodes.newparam;
				var l_oNewParam : FastXml = null;
				var l_sSurfaceID : String = null;
				var l_sImageID : String = null;
				for ( l_oNode in l_aNewParam ) {
						if ( l_oNode.att.sid == l_sTextureID ) {
										l_oNewParam = l_oNode;
										l_sSurfaceID = l_oNewParam.node.sampler2D.node.source.innerData;
						}
				}
				for ( l_oNode in l_aNewParam ) {
						if ( l_oNode.att.sid == l_sSurfaceID ) {
										l_oNewParam = l_oNode;
										l_sImageID = l_oNewParam.node.surface.node.init_from.innerData;
						}
				}
				if ( l_sImageID == null ) return null;

				// -- now get the image ID
				// -- get image's location on the hard drive

				if( m_oMaterials.get( l_sImageID ).bitmapData != null) l_oAppearance = new Appearance( new BitmapMaterial( m_oMaterials.get( l_sImageID ).bitmapData ) );
				if( l_oAppearance == null ) l_oAppearance = m_oStandardAppearance;
			}
			else if( l_aPhong.length > 0 )
			{
				// -- get the ambient color
				var l_aColors : Array<Int> = stringToArray( l_aPhong[0].node.ambient.node.color.innerData );
				var l_nColor : Int;

				var r : Int = Std.int( NumberUtil.constrain( l_aColors[0] * 255, 0, 255 ) );
				var g : Int = Std.int( NumberUtil.constrain( l_aColors[1] * 255, 0, 255 ) );
				var b : Int = Std.int( NumberUtil.constrain( l_aColors[2] * 255, 0, 255 ) );

				l_nColor =  r << 16 | g << 8 |  b;

				l_oAppearance = new Appearance( new ColorMaterial( l_nColor, l_aColors[ 3 ] * 100 ) );
			}
		}

		if( l_oAppearance == null ) return m_oStandardAppearance;
		else return l_oAppearance;
	}


	private function loadImages( p_oLibImages : List<FastXml> ) : Void
	{
		var l_oImages : Hash<ColladaImage> = new Hash();
		var l_oQueue : LoaderQueue = new LoaderQueue();

		for ( l_oImage in p_oLibImages )
		{
			var l_oInitFrom : String = l_oImage.node.init_from.innerData;
			var l_sId : String = l_oImage.att.id;
			l_oImages.set( l_sId, {
				bitmapData: null,
				id : l_sId,
				fileName : changeExt(l_oInitFrom.substr(l_oInitFrom.lastIndexOf("/") + 1, l_oInitFrom.length))
			});

			l_oQueue.add(
				l_sId,
				new URLRequest( RELATIVE_TEXTURE_PATH + "/" + l_oImages.get( l_sId ).fileName )
			);
		}

		m_oMaterials = l_oImages;
		l_oQueue.addEventListener( QueueEvent.QUEUE_COMPLETE, imageQueueCompleteHandler );
		l_oQueue.start();

	}

	private function imageQueueCompleteHandler( p_oEvent : QueueEvent ) : Void
	{
		var l_oLoaders : Hash<QueueElement> = p_oEvent.loaders;

		for ( l_oLoader in l_oLoaders )
		{
			if( l_oLoader.loader.content != null && Reflect.hasField( l_oLoader.loader.content, "bitmapData" ) )
				m_oMaterials.get( l_oLoader.name ).bitmapData = cast Reflect.field( l_oLoader.loader.content, "bitmapData" );
		}
		parseScene( m_oCollada.node.library_visual_scenes.node.visual_scene );
	}
}

enum UpAxis {
		Y_UP;
		X_UP;
		Z_UP;
		NONE;
}
