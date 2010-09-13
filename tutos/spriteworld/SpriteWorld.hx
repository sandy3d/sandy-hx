
import caurina.transitions.Tweener;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.ui.Keyboard;
import flash.Lib;

import sandy.bounds.BSphere;
import sandy.core.Scene3D;
import sandy.core.data.Point3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Sprite2D;
import sandy.core.scenegraph.Sprite3D;
import sandy.core.scenegraph.ATransformable;
import sandy.materials.Appearance;
import sandy.materials.BitmapMaterial;
import sandy.math.IntersectionMath;
import sandy.primitive.SkyBox;

import sandy.HaxeTypes;
import haxe.FastList;

class SpriteWorld extends Sprite
{
	private var m_oProxyPlaneList:Hash<ProxyTween>;
	private var m_oProxyMissileList:Hash<ProxyTween>;

	public function new()
	{
			keyPressed = new Array();
			planeList = new Hash();
			missileList = new Hash();

			m_oProxyPlaneList = new Hash<ProxyTween>();
			m_oProxyMissileList = new Hash<ProxyTween>();

			super();

			init();
			Lib.current.stage.addChild(this);
	}
	private var keyPressed:Array<Bool>;
	private var planeList:Hash<Sprite3D>;
	private var missileList:Hash<Sprite2D>;
	private var MissileClass:Class<BitmapData>;
	private var AvionClass:Class<MovieClip>;
	private var loader:Loader;
	private var scene:Scene3D;

	public function init():Void
	{
			var l_oURL:URLRequest = new URLRequest();
			l_oURL.url = "../assets/kamikaze_optim.swf";
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
			loader.load( l_oURL );
	}

	private function completeHandler( e:Event ):Void 
	{
			var domain:ApplicationDomain = loader.contentLoaderInfo.applicationDomain;

			AvionClass = domain.getDefinition("Avion");
			MissileClass = domain.getDefinition("Missile");

			_createScene();
	}

	public function __onKeyDown(e:KeyboardEvent):Void
	{
			if( e.keyCode != Keyboard.SPACE )
			{
					keyPressed[e.keyCode]=true;
			}
			else
			{
					var l_oMissileData:BitmapData = Type.createInstance( MissileClass, [20, 20] );
					var l_oMissile:Bitmap = new Bitmap(l_oMissileData);
					// --
					var n:String = "missile_"+Lib.getTimer();
					var l_oSprite:Sprite2D = new Sprite2D(n, l_oMissile, 0.4 );
					l_oSprite.setBoundingSphereRadius( 10 );
					scene.root.addChild( l_oSprite );

					var pt:ProxyTween = {x:l_oSprite.x,z:l_oSprite.z,tgt:n}; 
					m_oProxyMissileList.set( n, pt );
					missileList.set( l_oSprite.name, l_oSprite );
					_moveMissile( pt );
					// --
			}
	}

	public function __onKeyUp(e:KeyboardEvent):Void
	{
			keyPressed[e.keyCode]=false;
	}

	private function _moveSprite( p_oProxy:ProxyTween ):Void {

			// fix: if a missile collides with a plane, then due to the tween closure
			// this function continues being called with a proxy targeting a missing plane.

			if ( !planeList.exists( p_oProxy.tgt ) ) {
					p_oProxy = null;
					return;
			}

			var lDestX:Float = Math.random()*3000-1500;
			var lDestZ:Float = Math.random()*3000-1500;
			// --
			planeList.get( p_oProxy.tgt ).lookAt( lDestX, 0, lDestZ );
			planeList.get( p_oProxy.tgt ).offset = 180; // TODO find why this is needed
			// --

                        var self = this;
			Tweener.addTween( p_oProxy, {x : lDestX, z : lDestZ, time : 5+Math.random()*5, transition : "linear", onComplete : callback( _moveSprite, p_oProxy ) });

	}

	private function _removeMissile( p_oSprite:Sprite2D ):Void
	{
			Tweener.removeTweens( p_oSprite );
			missileList.remove( p_oSprite.name );
			m_oProxyMissileList.remove( p_oSprite.name );
			p_oSprite.remove();
	}

	private function _removePlane( p_oSprite:Sprite3D ):Void
	{
			Tweener.removeTweens( p_oSprite );
			planeList.remove( p_oSprite.name );
			m_oProxyPlaneList.remove( p_oSprite.name );
			p_oSprite.remove();
	}

	private function _moveMissile( p_oProxy:ProxyTween ):Void
	{
			var l_oDir:Point3D = scene.camera.out.clone();
			var l_nDepart:Int = 40;
			var l_nDist:Int = 1000;
			var l_oPos:Point3D = scene.camera.getPosition(ABSOLUTE);
			// --
			missileList.get( p_oProxy.tgt ).x = l_oPos.x + l_oDir.x * l_nDepart;
			missileList.get( p_oProxy.tgt ).z = l_oPos.z + l_oDir.z * l_nDepart;
			// --
			l_oDir.scale(l_nDist );
			l_oPos.add( l_oDir );
			// --
                        var self = this;
			Tweener.addTween( p_oProxy, { x : l_oPos.x, z : l_oPos.z, time : 5, transition : "linear", onComplete : callback( _removeMissile, missileList.get( p_oProxy.tgt ) ) });
	}

	private function _createScene():Void
	{
			var l_oGroup:Group = new Group("root");

			for( id in 0...100 )
			{
					var l_oAvion:MovieClip = Type.createInstance( AvionClass, [] );
							var n:String = "avion_"+id;
					var l_oSprite3D:Sprite3D = new Sprite3D(n, l_oAvion, 1+Math.random()*2 );
					l_oSprite3D.z = Math.random()*2000-1000;
					l_oSprite3D.x = Math.random()*2000-1000;
					// --
					l_oGroup.addChild( l_oSprite3D );
							var pt:ProxyTween = {x:0.0,z:0.0,tgt:n}; 
							m_oProxyPlaneList.set( n, pt );
					planeList.set( l_oSprite3D.name, l_oSprite3D );
					_moveSprite( pt );
					// --
			}

			// -- creation de la skybox
			var l_oSkyBox:SkyBox = new SkyBox( "game_sky", 15000, 6, 6 );
			var lPic:Bitmap;

			lPic = new Bitmap( new SkyBox_FRONT() );
			l_oSkyBox.front.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );

			lPic = new Bitmap( new SkyBox_BACK() );
			l_oSkyBox.back.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );

			lPic = new Bitmap( new SkyBox_LEFT() );
			l_oSkyBox.left.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );

			lPic = new Bitmap( new SkyBox_RIGHT() );
			l_oSkyBox.right.appearance = new Appearance( new BitmapMaterial( lPic.bitmapData ) );

			l_oSkyBox.top.remove();
			l_oSkyBox.bottom.remove();

			//l_oGroup.addChild( l_oSkyBox );

			var camera = new Camera3D( 800, 600 );
			scene = new Scene3D( "scene", this, camera, l_oGroup );

			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			addEventListener(Event.ENTER_FRAME, _onEnterFrame );

	}

	private function processIntersectionTest():Void
	{
			var l_bIsIntersection:Bool = false;
			// --
			for( l_oJd in missileList )
			{
					var l_oMissile:Sprite2D = l_oJd;
					l_bIsIntersection = false;
					// --
					var l_oBS:BSphere = l_oMissile.boundingSphere;
					// --
					for(  l_oPlane in planeList ) 
					{
							// --
							if( IntersectionMath.intersectionBSphere( l_oPlane.boundingSphere, l_oBS ) )
							{
									_removePlane( l_oPlane );
									_removeMissile( l_oMissile );
									// --
									l_bIsIntersection = true;
									// --
									break;
							}
					}
			}

	}

	private function _onEnterFrame( e:Event  ):Void
	{
			var cam:Camera3D = scene.camera;

			for ( l_oProxy in m_oProxyPlaneList ) {
					if ( planeList.exists( l_oProxy.tgt ) ) {
							planeList.get( l_oProxy.tgt ).x = l_oProxy.x;
							planeList.get( l_oProxy.tgt ).z = l_oProxy.z;
					} else {
							m_oProxyPlaneList.remove( l_oProxy.tgt );
					}
			}
			for ( l_oProxy in m_oProxyMissileList ) {
					if ( missileList.exists( l_oProxy.tgt ) ) {
							missileList.get( l_oProxy.tgt ).x = l_oProxy.x;
							missileList.get( l_oProxy.tgt ).z = l_oProxy.z;
					} else {
							m_oProxyMissileList.remove( l_oProxy.tgt );
					}
			}


			if( keyPressed[Keyboard.RIGHT] )
			{
					cam.rotateY -= 2;
			}
			if( keyPressed[Keyboard.LEFT] )
			{
					cam.rotateY += 2;
			}
			processIntersectionTest();

			scene.render();
	}

	static function main () {
			new SpriteWorld();
	}

}

class SkyBox_LEFT extends BitmapData {
		public function new () {
				super(0,0);
		}
}

	class SkyBox_RIGHT extends BitmapData {
		public function new () {
				super(0,0);
		}
}

class SkyBox_BACK extends BitmapData {
		public function new () {
				super(0,0);
		}
}

class SkyBox_FRONT extends BitmapData {
		public function new () {
				super(0,0);
		}
}

typedef ProxyTween = {
		var x : Float;
		var z : Float;
		var tgt : String;
}
