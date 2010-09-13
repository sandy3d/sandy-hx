package sandy.view;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;

import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.MovieMaterial;
import sandy.materials.attributes.AAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Box;
import sandy.primitive.Plane3D;
import sandy.primitive.Sphere;

/**
* Basic view to simplify Sandy scene setup.
* You just have to extends it, and call init method with your settings.
* Right after that you can use some utils methods to improve workflow.
*/
class BasicView extends Sprite
{
	public var useRenderingCache:Bool;
	public var camera:Camera3D;
	public var scene:Scene3D;
	public var rootNode:Group;

	public function new()
	{
		useRenderingCache = true;
		super();
	}

	public function init( p_nWidth:Int = 640, p_nHeight:Int = 480 ):Void
	{
		rootNode = new Group("root");
		camera = new Camera3D(p_nWidth, p_nHeight );
		scene = new Scene3D("mainScene", this, camera, rootNode);
	}

	public function render():Void
	{
		this.addEventListener(Event.ENTER_FRAME, simpleRender );
	}

	public function stop():Void
	{
		this.removeEventListener(Event.ENTER_FRAME, simpleRender );
	}

	public function simpleRender( pEvt:Event = null ):Void
	{
		scene.render( useRenderingCache );
	}

	public function makeMaterialAttributes( rest:Array<Dynamic> ):MaterialAttributes
	{
		var attr:MaterialAttributes = new MaterialAttributes();
		var l:Int = rest.length;
		while( --l > -1 )
		{
			if( Std.is(rest[l], AAttributes) )
				attr.attributes.unshift( rest[l] );
		}
		return attr;
	}
	public function makeBitmapAppearance( p_oTexture:BitmapData, p_oAttr:MaterialAttributes = null, p_nPrecision:Int = 0 ):Appearance
	{
		return new Appearance( new BitmapMaterial( p_oTexture, p_oAttr, p_nPrecision ) );
	}

	public function makeMovieAppearance( p_oTexture:Sprite, p_oAttr:MaterialAttributes = null, p_nPrecision:Int = 0 ):Appearance
	{
		return new Appearance( new MovieMaterial( p_oTexture, 30, p_oAttr, true ) );
	}

	public function makeColorAppearance( p_nColor:Int = 0xFF, p_nAlpha:Float = 1.0, p_oAttr:MaterialAttributes = null ):Appearance
	{
		return new Appearance( new ColorMaterial(p_nColor, p_nAlpha, p_oAttr ) );
	}

	public function addBox( p_nWidth:Int=100, p_nHeight:Int=100, p_nDepth:Int=100, p_nQuality:Int = 1, p_oPosition:Point3D = null, p_oRotation:Point3D = null ):Box
	{
		var l_oBox:Box = new Box( null, p_nWidth, p_nHeight, p_nDepth, "tri", p_nQuality );
		if( p_oPosition != null )
		{
			l_oBox.x = p_oPosition.x;
			l_oBox.y = p_oPosition.y;
			l_oBox.z = p_oPosition.z;
		}
		if( p_oRotation != null )
		{
			l_oBox.rotateX = p_oRotation.x;
			l_oBox.rotateY = p_oRotation.y;
			l_oBox.rotateZ = p_oRotation.z;
		}
		rootNode.addChild( l_oBox );
		return l_oBox;
	}

	public function addSphere( p_nRadius:Float=100.0, p_nQualityW:Int = 8, p_nQualityH:Int = 8, p_oPosition:Point3D = null, p_oRotation:Point3D = null ):Sphere
	{
		var l_oMesh:Sphere = new Sphere( null, p_nRadius, p_nQualityW, p_nQualityH );
		if( p_oPosition != null )
		{
			l_oMesh.x = p_oPosition.x;
			l_oMesh.y = p_oPosition.y;
			l_oMesh.z = p_oPosition.z;
		}
		if( p_oRotation != null )
		{
			l_oMesh.rotateX = p_oRotation.x;
			l_oMesh.rotateY = p_oRotation.y;
			l_oMesh.rotateZ = p_oRotation.z;
		}
		rootNode.addChild( l_oMesh );
		return l_oMesh;
	}

	public function addHorizontalPlane( p_nWidth:Float=100.0, p_nHeight:Float=100.0, p_nQuality:Int = 3, p_oPosition:Point3D = null, p_oRotation:Point3D = null ):Plane3D
	{
		var l_oMesh:Plane3D = new Plane3D( null, p_nHeight, p_nWidth, p_nQuality, p_nQuality, Plane3D.ZX_ALIGNED, "tri" );
		if( p_oPosition != null )
		{
			l_oMesh.x = p_oPosition.x;
			l_oMesh.y = p_oPosition.y;
			l_oMesh.z = p_oPosition.z;
		}
		if( p_oRotation != null )
		{
			l_oMesh.rotateX = p_oRotation.x;
			l_oMesh.rotateY = p_oRotation.y;
			l_oMesh.rotateZ = p_oRotation.z;
		}
		rootNode.addChild( l_oMesh );
		return l_oMesh;
	}

	public function addVerticalPlane( p_nWidth:Float=100.0, p_nHeight:Float=100.0, p_nQuality:Int = 3, p_oPosition:Point3D = null, p_oRotation:Point3D = null ):Plane3D
	{
		var l_oMesh:Plane3D = new Plane3D( null, p_nHeight, p_nWidth, p_nQuality, p_nQuality, Plane3D.XY_ALIGNED, "tri" );
		if( p_oPosition != null )
		{
			l_oMesh.x = p_oPosition.x;
			l_oMesh.y = p_oPosition.y;
			l_oMesh.z = p_oPosition.z;
		}
		if( p_oRotation != null )
		{
			l_oMesh.rotateX = p_oRotation.x;
			l_oMesh.rotateY = p_oRotation.y;
			l_oMesh.rotateZ = p_oRotation.z;
		}
		rootNode.addChild( l_oMesh );
		return l_oMesh;
	}

}