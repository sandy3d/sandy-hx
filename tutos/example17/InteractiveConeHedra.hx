import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Hedra;
import sandy.primitive.Cone;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.Lib;

class InteractiveConeHedra extends Sprite {

		private var scene:Scene3D;
		private var camera:Camera3D;
		private var myCone:Cone;
		private var myHedra:Hedra;
		private var myText:TextField;
		private var needRemove:Bool;

		public function new () { 
			myText = new TextField();
			needRemove = false;

			super(); 

			camera = new Camera3D( 300, 300 );
			camera.x = 100;
			camera.y = 100;
			camera.z = -300;
			camera.lookAt(0,0,0);

			// text position
			myText.width = 200;
			myText.x = 20;
			myText.y = 20;

			var root:Group = createScene();

			scene = new Scene3D( "scene", this, camera, root );

			addEventListener( Event.ENTER_FRAME, enterFrameHandler );

			Lib.current.stage.addChild(this);
		}

		function createScene():Group {
			var g:Group = new Group();

			myCone = new Cone("theObj1",50, 100);
			myHedra = new Hedra( "theObj2", 80, 60, 60 );

			myCone.x = -160;
			myCone.z = 150;
			myCone.y -= 50;
			myHedra.x = 50;
			myHedra.y -= 50;

			#if !cpp
			myCone.container.buttonMode = true;
			myHedra.container.buttonMode = true;
			#end

			var materialAttr:MaterialAttributes = new MaterialAttributes( 
							[new LineAttributes( 0.5, 0x2111BB, 0.4 ),
							new LightAttributes( true, 0.1)]
							);

			var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
			material.lightingEnable = true;
			var app:Appearance = new Appearance( material );
			myCone.appearance = app;
			myHedra.appearance = app;

			// adding interactivity...
			myCone.container.addEventListener(MouseEvent.CLICK, clickHandler);
			myCone.container.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			myHedra.container.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			myHedra.container.addEventListener(MouseEvent.MOUSE_OUT, outHandler);


			// we now add all the object to the root group:
			g.addChild(myCone);
			g.addChild(myHedra);

			return g;
		}

		function enterFrameHandler( event:Event ):Void {
			myHedra.pan +=4;
			myCone.pan +=4;
			scene.render();
		}

		private function clickHandler(event:MouseEvent):Void {
			myText.text = "You have hit the Cone";
			this.addChild(myText);
			needRemove = true;
		}

		private function overHandler(event:MouseEvent):Void {
			myText.text = "Your mouse is over the Hedra";
			myText.x = 20;
			myText.y = 20;
			this.addChild(myText);
			needRemove = true;
		}

		private function outHandler(event:MouseEvent):Void {
			if(needRemove)
			{
					this.removeChild(myText);
					needRemove = false;
			}
		}

		static function main() {
			#if cpp
				nme.Lib.create(function(){
					new InteractiveConeHedra();
				}, 400, 300, 24, 0xFFFFFF, nme.Lib.RESIZABLE);
			#else
				new InteractiveConeHedra();
			#end
		}
}

