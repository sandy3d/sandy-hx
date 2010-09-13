import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.data.UVCoord;
import sandy.core.data.Point3D;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.TransformGroup;
import sandy.events.Shape3DEvent;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.BitmapMaterial;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Line3D;
import sandy.primitive.Box;
import sandy.primitive.Sphere;
import sandy.primitive.Torus;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.ui.Keyboard;
import flash.Lib;

class HedgehogShapes extends Sprite {
		private var myBox:Box;
		private var mySphere:Sphere;
		private var myTorus:Torus;
		private var scene:Scene3D;
		private var lCamera:Camera3D;

		private var textureTwo:BitmapData;
		private var textureThree:BitmapData;

		private var lTg:TransformGroup;
		private var l_oPoly:Polygon;

		public function new () { 
				textureTwo = new BitmapData( 200, 200, false, 0x0000FF );
				textureThree = new BitmapData( 200, 200, false, 0x00CC33 );

				lTg = new TransformGroup("rotation");

				super(); 

				lCamera = new Camera3D( 650, 500 );
				lCamera.z = -900;
				lCamera.y = 70;
				lCamera.lookAt( 160, -40, 0 );

				var root:Group = createScene3D();
				scene = new Scene3D( "scene", this, lCamera, root );

				Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyPressed );
				addEventListener( Event.ENTER_FRAME, enterFrameHandler );

				Lib.current.stage.addChild(this);
		}

		function createScene3D():Group {
				var lG:Group = new Group();

				myBox = new Box( "theBox", 100, 100, 100 ); 
				myBox.x = -170;
				myBox.y = 70;

				myBox.useSingleContainer = false;
				myBox.enableBackFaceCulling = true;
				myBox.enableNearClipping = true;

				var materialAttr:MaterialAttributes = new MaterialAttributes([new LightAttributes( true, 0.1) ]);
				var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
				material.lightingEnable = true;
				myBox.appearance = new Appearance( material );

				myBox.enableEvents = true;
				myBox.addEventListener( MouseEvent.CLICK, onClickOne );

				mySphere = new Sphere( "theSphere", 60, 10, 10 );
				mySphere.x = 170;
				mySphere.y = -70;

				mySphere.useSingleContainer = false;
				mySphere.enableBackFaceCulling = true;
				mySphere.enableNearClipping = true;

				var l_oAttr:MaterialAttributes = new MaterialAttributes( [new LineAttributes()] );
				mySphere.appearance = new Appearance( new BitmapMaterial( textureTwo, l_oAttr ) );

				mySphere.enableEvents = true;
				mySphere.addEventListener( MouseEvent.CLICK, onClickTwo );

				myTorus = new Torus( "theTorus", 70, 20 );

				myTorus.useSingleContainer = false;
				myTorus.enableBackFaceCulling = true;
				myTorus.enableNearClipping = true;

				myTorus.appearance = new Appearance( new BitmapMaterial( textureThree, l_oAttr ) );

				myTorus.enableEvents = true;
				myTorus.addEventListener( MouseEvent.CLICK, onClickThree );

				lTg.addChild( mySphere );
				lTg.addChild( myBox );
				lTg.addChild( myTorus );
				lG.addChild( lTg );

				return lG; 
		}

		function enterFrameHandler( event:Event ):Void {
				scene.render();
		}

		private function onClickOne( p_eEvent:Shape3DEvent ):Void
		{
				var v:Point3D = p_eEvent.point;
				var top:Point3D = p_eEvent.polygon.normal.getPoint3D().clone();
				top.scale( 20 );
				top.add( v );
				var m_oLine3D = new Line3D("normal", [v, top] );
				lTg.addChild( m_oLine3D );
		}

		private function onClickTwo( p_eEvent:Shape3DEvent ):Void
		{
				l_oPoly = p_eEvent.polygon;
				var l_oPoint:Point = new Point( scene.container.mouseX, scene.container.mouseY );

				var l_oIntersectionUV:UVCoord = p_eEvent.uv;
				var l_oMaterial:BitmapMaterial = (l_oPoly.visible ? cast( l_oPoly.appearance.frontMaterial, BitmapMaterial ) : cast( l_oPoly.appearance.backMaterial, BitmapMaterial ) );
				if( l_oMaterial == null )
				{
						trace("ce material doit etre un moviematerial");
				}
				else
				{
						var l_oRealTexturePosition:UVCoord = new UVCoord( l_oIntersectionUV.u * l_oMaterial.texture.width, 
										l_oIntersectionUV.v * l_oMaterial.texture.height );
						var l_oTexture:BitmapData = l_oMaterial.texture;
						l_oTexture.fillRect( new Rectangle( l_oRealTexturePosition.u-2, l_oRealTexturePosition.v-2, 4, 4 ), Std.int(0xAA999FF9) );
						l_oMaterial.texture = l_oTexture;
				}

		}

		private function onClickThree( p_eEvent:Shape3DEvent ):Void
		{
				l_oPoly = p_eEvent.polygon;
				var l_oPoint:Point = new Point( scene.container.mouseX, scene.container.mouseY );

				var v:Point3D = p_eEvent.point;
				var top:Point3D = l_oPoly.normal.getPoint3D().clone();

				top.scale( 20 );
				top.add( v );
				var m_oLine3D = new Line3D("normal", [v, top] );
				lTg.addChild( m_oLine3D );
				var l_oIntersectionUV:UVCoord = p_eEvent.uv;
				var l_oMaterial:BitmapMaterial = (l_oPoly.visible ? cast(l_oPoly.appearance.frontMaterial, BitmapMaterial) : cast(l_oPoly.appearance.backMaterial, BitmapMaterial));
				if( l_oMaterial == null )
				{
						trace("ce material doit etre un moviematerial");
				}
				else
				{
						var l_oRealTexturePosition:UVCoord = new UVCoord( l_oIntersectionUV.u * l_oMaterial.texture.width, 
										l_oIntersectionUV.v * l_oMaterial.texture.height );
						var l_oTexture:BitmapData = l_oMaterial.texture;
						l_oTexture.fillRect( new Rectangle( l_oRealTexturePosition.u-2, l_oRealTexturePosition.v-2, 4, 4 ), 0x990000);
						l_oMaterial.texture = l_oTexture;
				}
		}

		function keyPressed( event:KeyboardEvent ):Void {
				switch( event.keyCode ) {
						case 38: // KEY_UP
								lTg.tilt +=3;
						case 40: // KEY_DOWN
								lTg.tilt -=3;
						case 39: // KEY_RIGHT
								lTg.rotateY +=3;
						case 37: // KEY_LEFT
								lTg.rotateY -=3;
						case 34: // PAGE_DOWN
								lCamera.z -= 5;
						case 33: // PAGE_UP
								lCamera.z += 5;
				}
		}

		static function main() {
				new HedgehogShapes();
		}
}

