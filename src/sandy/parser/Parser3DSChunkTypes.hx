
package sandy.parser;

import sandy.HaxeTypes;

/**
* Static class that defines the chunks offsets of 3DS file.
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @since		1.0
* @version		3.1
* @date 		04.03.2009
*
*/
class Parser3DSChunkTypes
{
	//>------ primary chunk

	public static inline var MAIN3DS       :Int = 0x4D4D;

	public static inline var EDIT3DS       :Int = 0x3D3D;  // this is the start of the editor config
	public static inline var KEYF3DS       :Int = 0xB000;  // this is the start of the keyframer config

	//>------ sub defines of EDIT3DS

	public static inline var EDIT_MATERIAL :Int = 0xAFFF;
	public static inline var EDIT_CONFIG1  :Int = 0x0100;
	public static inline var EDIT_CONFIG2  :Int = 0x3E3D;
	public static inline var EDIT_VIEW_P1  :Int = 0x7012;
	public static inline var EDIT_VIEW_P2  :Int = 0x7011;
	public static inline var EDIT_VIEW_P3  :Int = 0x7020;
	public static inline var EDIT_VIEW1    :Int = 0x7001;
	public static inline var EDIT_BACKGR   :Int = 0x1200;
	public static inline var EDIT_AMBIENT  :Int = 0x2100;
	public static inline var EDIT_OBJECT   :Int = 0x4000;

	public static inline var EDIT_UNKNW01  :Int = 0x1100;
	public static inline var EDIT_UNKNW02  :Int = 0x1201;
	public static inline var EDIT_UNKNW03  :Int = 0x1300;
	public static inline var EDIT_UNKNW04  :Int = 0x1400;
	public static inline var EDIT_UNKNW05  :Int = 0x1420;
	public static inline var EDIT_UNKNW06  :Int = 0x1450;
	public static inline var EDIT_UNKNW07  :Int = 0x1500;
	public static inline var EDIT_UNKNW08  :Int = 0x2200;
	public static inline var EDIT_UNKNW09  :Int = 0x2201;
	public static inline var EDIT_UNKNW10  :Int = 0x2210;
	public static inline var EDIT_UNKNW11  :Int = 0x2300;
	public static inline var EDIT_UNKNW12  :Int = 0x2302;
	public static inline var EDIT_UNKNW13  :Int = 0x3000;
	public static inline var EDIT_UNKNW14  :Int = 0xAFFF;

	//>------ sub defines of EDIT_OBJECT
	public static inline var OBJ_TRIMESH   :Int = 0x4100;
	public static inline var OBJ_LIGHT     :Int = 0x4600;
	public static inline var OBJ_CAMERA    :Int = 0x4700;

	public static inline var OBJ_UNKNWN01  :Int = 0x4010;
	public static inline var OBJ_UNKNWN02  :Int = 0x4012; //>>---- Could be shadow

	// MAP_TEXFLNM is part of MAT_TEXMAP, MAT_TEXMAP is part of EDIT_MATERIAL
	public static inline var MAT_NAME		:Int = 0xA000;
	public static inline var MAT_TEXMAP	:Int = 0xA200;
	public static inline var MAT_TEXFLNM	:Int = 0xA300;

	//>------ sub defines of OBJ_CAMERA
	public static inline var CAM_UNKNWN01  :Int = 0x4710;
	public static inline var CAM_UNKNWN02  :Int = 0x4720;

	//>------ sub defines of OBJ_LIGHT
	public static inline var LIT_OFF       :Int = 0x4620;
	public static inline var LIT_SPOT      :Int = 0x4610;
	public static inline var LIT_UNKNWN01  :Int = 0x465A;

	//>------ sub defines of OBJ_TRIMESH
	public static inline var TRI_VERTEXL   :Int = 0x4110;
	public static inline var TRI_FACEL2    :Int = 0x4111;
	public static inline var TRI_FACEL1    :Int = 0x4120;
	public static inline var TRI_MATERIAL:Int = 0x4130;
	public static inline var TRI_TEXCOORD  :Int = 0x4140;	// DAS 11-26-04
	public static inline var TRI_SMOOTH    :Int = 0x4150;
	public static inline var TRI_LOCAL     :Int = 0x4160;
	public static inline var TRI_VISIBLE   :Int = 0x4165;


	//>>------ sub defs of KEYF3DS

	public static inline var KEYF_UNKNWN01 :Int = 0xB009;
	public static inline var KEYF_UNKNWN02 :Int = 0xB00A;
	public static inline var KEYF_FRAMES   :Int = 0xB008;
	public static inline var KEYF_OBJDES   :Int = 0xB002;

	//>>------ FRAMES INFO
	public static inline var NODE_ID   	:Int = 0xB030;
	public static inline var NODE_HDR   	:Int = 0xB010;
	public static inline var PIVOT   		:Int = 0xB013;
	public static inline var POS_TRACK_TAG	:Int = 0xB020;
	public static inline var ROT_TRACK_TAG	:Int = 0xB021;
	public static inline var SCL_TRACK_TAG	:Int = 0xB022;

	//>>------  these define the different color chunk types
	public static inline var COL_RGB  :Int = 0x0010;
	public static inline var COL_TRU  :Int = 0x0011;
	public static inline var COL_UNK  :Int = 0x0013;

	//>>------ defines for viewport chunks

	public static inline var TOP           :Int = 0x0001;
	public static inline var BOTTOM        :Int = 0x0002;
	public static inline var LEFT          :Int = 0x0003;
	public static inline var RIGHT         :Int = 0x0004;
	public static inline var FRONT         :Int = 0x0005;
	public static inline var BACK          :Int = 0x0006;
	public static inline var USER          :Int = 0x0007;
	public static inline var CAMERA        :Int = 0x0008; // :Int = 0xFFFF is the actual code read from file
	public static inline var LIGHT         :Int = 0x0009;
	public static inline var DISABLED      :Int = 0x0010;
	public static inline var BOGUS         :Int = 0x0011;
}

