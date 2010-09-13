package sandy.util;

import sandy.core.scenegraph.Geometry3D;
import sandy.core.data.Vertex;
import sandy.core.data.UVCoord;

/**
 * The VertexWelder class is a static class that is able to weld duplicate
 * vertices in a geometry.
 *
 * <p>It can faithfully transfer all UV data in a non-destructive manner,
 * and automatically smooth all vertex normal data by averaging
 * all the normals of duplicate vertices in the geometry.</p>
 * 
 * @see sandy.core.scenegraph.Geometry3D
 * @see sandy.core.data.UVCoord
 * @see sandy.core.data.Vertex
 * 
 * @author	Gregorius Soedharmo
 * @version	3.1.1
 * @date	11.15.2009
 */
 
class VertexWelder {
	/**
	*
	* Cached result of the previous call to <code>weld</code>.
	*
	* @default null
	*
	*/
	public static var geometry : Geometry3D;
	
	/**
	 *
	 * Throw an error if the user tried to instantiate the class.
	 *
	 * @private 
	 *
	 */
	public function VertexWelder():Void
	{
		throw "VertexWelder is a static only class and can not be instantiated.";
	}
	
	/**
	 * Create a clone of a geometry, deletes all redundant data, and welds
	 * all duplicate vertex found in the former geometry.
	 * 
	 * @param p_oGeom The geometry input to be processed
	 * @param p_iPrecision The precision threshold of vertex welding.
	 * @return The welded geometry clone of <code>p_oGeom</code>
	 *
	 * @example <listing version="3.0">
	 * VertexWelder( myShape3D.geometry, 4); // This will weld myShape3D geometry with 0.0001 welding threshold.
	 * </listing>
	 */
	public static function weld(p_oGeom:Geometry3D, p_iPrecision:Int = 2):Geometry3D {
		var precision:Float = Math.pow(10, p_iPrecision);
		var _geometry:Geometry3D = new Geometry3D();
		
		var refGeom:Geometry3D =p_oGeom;
		var aVertex:Array<Vertex> = refGeom.aVertex;
		var aUVCoords:Array<UVCoord> = refGeom.aUVCoords;
		var aFacesNormals:Array<Vertex> = refGeom.aFacesNormals;
		var aVertexNormals:Array<Vertex> =refGeom.aVertexNormals;

		var vertexCache:Hash<Int> = new Hash();
		var vertexMap:Array<Int> = new Array();
		var uvCache:Hash<Int> = new Hash();
		var uvMap:Array<Int> = new Array();
		
		/**
		 *
		 * Copy over all the UV coordinate datas, deleting duplicates
		 * with duplicates defined as the same ID obtained when 
		 * the string Us + "_" + Vs equals each other where
		 * Us and Vs defines as the floor of U and V values
		 * after being multiplied by a million.
		 *
		 * Rationale: 1/1000000 is a good enough precision considering that
		 * Flash player can only handle a maximum bitmap size of 4096 x 4096.
		 *
		 * Create a many to one mapping array so we can move the old data
		 * to the newly optimized UV list data when we rebuild the geometry.
		 *
		 */
		var len:Int=aUVCoords.length;
		var mapID:Int;
		for (i in 0...len) {
			var uv:UVCoord=aUVCoords[i];
			if( null == uv ) continue;	// aUVCoords array can be sparse
			var uvID:String=Std.string(Std.int(uv.u*1000000))+"_"+Std.string(Std.int(uv.v*1000000));
			if (!uvCache.exists(uvID)) {
				mapID=_geometry.setUVCoords(_geometry.getNextUVCoordID(),uv.u,uv.v);
				uvCache.set(uvID,mapID);
			} else {
				mapID=uvCache.get(uvID);
			}
			uvMap[i]=mapID;
		}
		
		/**
		 *
		 * Now we do the same with the vertices, except that this time,
		 * the precision is left to the user to decide, and the ID is set
		 * to Xs + "_" + Ys + "_" + Zs.
		 *
		 * If multiple vertices were found, get their normals and average them.
		 * We will temporarily use the Vertex.flag of the normal to store 
		 * the duplicate count of vertices found.
		 *
		 */
		len=aVertex.length;
		var nRef:Vertex, nNew:Vertex;
		for (i in 0...len) {
			var v:Vertex=aVertex[i];
			if( null == v ) continue;	// aVertex array can be sparse
			var vID:String=Std.string(Std.int(v.x*precision))+"_"+Std.string(Std.int(v.y*precision))+"_"+Std.string(Std.int(v.z*precision));
			if (!vertexCache.exists(vID)) {
				mapID=_geometry.setVertex(_geometry.getNextVertexID(),v.x,v.y,v.z);
				vertexCache.set(vID,mapID);

				nRef=aVertexNormals[i];
				if( null != nRef ){		// Vertex normal might not exist for "virgin" geometries from parsers.
					_geometry.setVertexNormal(mapID, nRef.x, nRef.y, nRef.z);
					nNew=_geometry.aVertexNormals[mapID];
					nNew.flags=1;
				}
			} else {
				mapID=vertexCache.get(vID);

				nRef=aVertexNormals[i];
				if( null != nRef ){		// Vertex normal might not exist for "virgin" geometries from parsers.
					nNew=_geometry.aVertexNormals[mapID];
					nNew.add(nRef);
					nNew.flags++;
				}
			}
			vertexMap[i]=mapID;
		}
		
		/**
		 *
		 * Average the normals, normalize, and reset the flag to 0.
		 *
		 */
		len=_geometry.aVertexNormals.length;
		for (i in 0...len) {
			nNew=_geometry.aVertexNormals[i];
			if( null != nNew){		// Vertex normal might not exist for "virgin" geometries from parsers.
				nNew.scale(1/nNew.flags);
				nNew.normalize();
				nNew.flags=0;
			}
		}
		
		/**
		 *
		 * Rebuild the geometry faces and copy the face normal data
		 * and the UV data.
		 *
		 * Make sure the data exists before we try to rebuild it.
		 *
		 */
		var facesVtx:Array<Array<Int>>=refGeom.aFacesVertexID;
		var facesUV:Array<Array<Int>>=refGeom.aFacesUVCoordsID;
		var facesNorm:Array<Vertex>=refGeom.aFacesNormals;
		len=facesVtx.length;
		for (i in 0...len) {
			var faceVtx:Array<Int>=facesVtx[i].slice(0);
			var faceUV:Array<Int>=facesUV[i].slice(0);
			for (j in 0...faceVtx.length) {
				if(faceVtx != null) faceVtx[j]=vertexMap[faceVtx[j]];
				if(faceUV != null) faceUV[j]=uvMap[faceUV[j]];
			}
			if(faceVtx != null) _geometry.setFaceVertexIds(i, faceVtx);
			if(faceUV != null) _geometry.setFaceUVCoordsIds(i, faceUV);

			nRef=facesNorm[i];
			if(nRef != null) _geometry.setFaceNormal(i, nRef.x, nRef.y, nRef.z);
		}

		/* stack variables will be GC-ed
		aVertex=null;
		aUVCoords=null;
		aFacesNormals=null;
		aVertexNormals=null;
		vertexMap=null;
		uvMap=null;
		refGeom=null;
		*/

		for (prop in vertexCache.keys()) {
			vertexCache.remove(prop);
		}

		for (prop in uvCache.keys()) {
			uvCache.remove(prop);
		}
		
		geometry = _geometry;
		return _geometry;
	}
}
