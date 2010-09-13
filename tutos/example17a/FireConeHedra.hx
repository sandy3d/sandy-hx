import com.gskinner.effects.FireFX;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.Lib;
import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.Shape3D;
import sandy.materials.Appearance;
import sandy.materials.Material;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Hedra;
import sandy.primitive.Cone;
import org.aswing.JPanel;
import org.aswing.JSlider;
import org.aswing.JLabel;
import org.aswing.JCheckBox;
import org.aswing.geom.IntDimension;
import org.aswing.geom.IntPoint;

enum FireParams {
		DISTORTION;
		DISTORTIONSCALE;
		FADERATE;
		FLAMEHEIGHT;
		FLAMESPREAD;
		SMOKE;
}

class FireConeHedra extends Sprite {

		private var scene:Scene3D;
		private var camera:Camera3D;
		private var myCone:Cone;
		private var myHedra:Hedra;
		private var myText:TextField;
		private var needRemove:Bool;

		private var myPanel:JPanel;
		private var fireFX:FireFX;

		private var blueFlameCheckBox:JCheckBox;
		private var hide3DCheckBox:JCheckBox;
		private var distortionSlider:JSlider;
		private var distortionScaleSlider:JSlider;

		private var params:Array<FireParams>;

		public function new () { 

				myText = new TextField();
				needRemove = false;

				params = [DISTORTION, DISTORTIONSCALE,
											FADERATE, FLAMEHEIGHT, FLAMESPREAD, SMOKE];

				super(); 
				fireFX = new FX();

				myPanel = new JPanel();
				myPanel.setSize(new IntDimension(300, 600));
				myPanel.setLocation(new IntPoint(350, 0));

				// Blue flame
				var blueFlame:JCheckBox = new JCheckBox();
				blueFlame.setLocation(new IntPoint(0, 0));
				blueFlame.setSize(new IntDimension(100, 20));
				blueFlame.setHorizontalAlignment( 2 );
				blueFlame.setText("Blue flame");

				// Hide 3D
				var hideText:JCheckBox = new JCheckBox();
				hideText.setLocation(new IntPoint(100, 0));
				hideText.setSize(new IntDimension(100, 20));
				hideText.setHorizontalAlignment( 2 );
				hideText.setText("Hide 3D");

				// top-level sprite contains the hedra and cone
				var obj:Sprite = new Sprite();

				// set clickhandlers on checkboxes
				var fx:FireFX = fireFX;
				var handleCheckBox = function () {
						fx.blueFlame = blueFlame.isSelected();
						obj.visible = !hideText.isSelected();
				}
				hideText.addStateListener(handleCheckBox);
				blueFlame.addStateListener(handleCheckBox);

				myPanel.append(blueFlame);
				myPanel.append(hideText);
		
				// generate labels and sliders
				var i:Int, l:UInt = params.length;
				for (i in 0...l) {

						var name:String = switch ( params[i] ) {
								case DISTORTION: "distortion";
								case DISTORTIONSCALE: "distortionScale";
								case FADERATE: "fadeRate";
								case FLAMEHEIGHT: "flameHeight";
								case FLAMESPREAD: "flameSpread";
								case SMOKE: "smoke";
						}

						var label:JLabel = new JLabel();
						label.setLocation(new IntPoint(0, 25+50*i));
						label.setSize(new IntDimension(140, 20));
						label.setHorizontalAlignment( 2 );
						label.setText(name);

						myPanel.append( label );

						label = new JLabel();
						var label:JLabel = new JLabel();
						label.setLocation(new IntPoint(110, 25+50*i));
						label.setSize(new IntDimension(50, 20));
						label.setHorizontalAlignment( 4 );
						label.setText("0.35");

						myPanel.append( label );

						var slider:JSlider = new JSlider();
						slider.setLocation(new IntPoint(0, 55+50*i));
						slider.setSize(new IntDimension(150, 20));
						slider.setValue(35);
						slider.setExtent(400);
						slider.setMinimum(-200);
						slider.setMaximum(200);

						var param:FireParams = params[i];
						slider.addStateListener(function () {
										var value:Float = slider.getValue() / 100.0;
										switch ( param ) {
										case DISTORTION: fx.distortion = value;
										case DISTORTIONSCALE: fx.distortionScale = value;
										case FADERATE: fx.fadeRate = value;
										case FLAMEHEIGHT: fx.flameHeight = value;
										case FLAMESPREAD: fx.flameSpread = value;
										case SMOKE: fx.smoke = value;
										}
										label.setText(Std.string(	value ));
										});

						myPanel.append( slider );

				}
				addChild( myPanel );

			var root:Group = createScene();
		 
			camera = new Camera3D( Std.int( fireFX.width ), Std.int( fireFX.height ) );

			camera.x = 100;
			camera.y = 100;
			camera.z = -300;
			camera.lookAt(0,0,0);
		 
			scene = new Scene3D( "scene", obj, camera, root );

			obj.blendMode = flash.display.BlendMode.MULTIPLY;

			addEventListener( Event.ENTER_FRAME, enterFrameHandler );

			// preserve ordering of layers.
			Lib.current.stage.addChild(fireFX);
			Lib.current.stage.addChild(obj);
			Lib.current.stage.addChild(this);
		}

		function createScene():Group {
			var g:Group = new Group();

			myCone = new Cone("Cone",50, 100);
			myHedra = new Hedra( "Hedra", 80, 60, 60 );
		 
			myCone.x = -160;
			myCone.z = 150;
			myCone.y -= 50;
			myHedra.x = 50;
			myHedra.y -= 50;

			myCone.container.buttonMode = true;
			myHedra.container.buttonMode = true;
		 
			var materialAttr:MaterialAttributes = new MaterialAttributes( 
				[new LineAttributes( 0.5, 0x2111BB, 0.4 ),
				new LightAttributes( true, 0.1)]
				);

			var material:Material = new ColorMaterial( 0xFFCC33, 1, materialAttr );
			material.lightingEnable = true;
			var app:Appearance = new Appearance( material );
			myCone.appearance = app;
			myHedra.appearance = app;
		 
			myCone.enableEvents = true;
			myCone.addEventListener(MouseEvent.CLICK, clickHandler);
			myHedra.enableEvents = true;
			myHedra.addEventListener(MouseEvent.CLICK, clickHandler);

			myCone.container.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			myHedra.container.addEventListener(MouseEvent.MOUSE_OUT, outHandler);

			g.addChild(myCone);
			g.addChild(myHedra);

			return g;
		}

		function enterFrameHandler( event:Event ):Void {
			myHedra.pan +=4;
			myCone.pan +=4;
			scene.render();
		}

		private function clickHandler(event:sandy.events.BubbleEvent):Void {
			var shape:Shape3D = event.object;

			trace( "You have hit the " + shape.name );
			needRemove = true;

			fireFX.target = shape.container;
		}

		private function outHandler(event:MouseEvent):Void {
			if(needRemove)
			{
				//this.removeChild(myText);
				needRemove = false;
			}
		}

		static function main() {
				new FireConeHedra();
		}
}

class FX extends FireFX {
		public function new () {

				// sets bounds on the fire 
				var circle1:Sprite = new Sprite();
				circle1.graphics.drawCircle(200, 200, 200);
				this.addChild( circle1 );
				super();
		}
}
