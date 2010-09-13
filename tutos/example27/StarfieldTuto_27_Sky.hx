import sandy.core.scenegraph.StarField;
import sandy.core.Scene3D;
import sandy.core.data.Vertex;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import flash.filters.GlowFilter;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;

class StarfieldTuto_27_Sky extends Sprite {
	static var w : Int = 400;
	static var h : Int = 300;
	var scene:Scene3D;
	var sky:StarField;

				private var frame:Int;
				private var t:Float;
				private var myTextField:TextField;

	public static function main() : Void
	{
		flash.Lib.current.stage.addChild( new StarfieldTuto_27_Sky() );
	}

	public function new () : Void {
		super();
		// set up scene
		scene = new Scene3D ("", this, new Camera3D (w, h), new Group (""));
		// set up sky
		sky = new StarField ();
		// make stars
		var N:Int = 10000, radius:Float = 500;
		for ( i in 0 ... N ) {
			var phi:Float = Math.acos (-1 + (2*i -1) / N);
			var theta:Float = Math.sqrt (N * Math.PI) * phi;
			phi   += 0.1 * (Math.random () - 0.5);
			theta += 0.1 * (Math.random () - 0.5);
			sky.stars [i] = new Vertex (
				/* x */ radius * Math.cos(theta) * Math.sin(phi),
				/* y */ radius * Math.sin(theta) * Math.sin(phi),
				/* z */ radius * Math.cos(phi)
			);
		}
		sky.container.filters = [ new GlowFilter (0x7FFF, 1, 6, 6, 10) ];
		scene.root.addChild (sky);
		// subscribe to Event.ENTER_FRAME
		addEventListener (Event.ENTER_FRAME, enterFrameHandler);

		frame = 0;
						t = flash.Lib.getTimer();
				myTextField = new TextField();
						flash.Lib.current.stage.addChild(myTextField);
						myTextField.width = 600;
	}


	private function enterFrameHandler (event:Event):Void {
						frame++;
		// render the scene
		sky.rotateY += 0.1;
		scene.render ();
						if( frame == 1000 )
						{
								var elapsed:Float = (flash.Lib.getTimer() - t);
								flash.Lib.trace( "Rendering time for 1000 frames = "+(elapsed)+" ms" );
								myTextField.text = "Rendering time for 1000 frames = "+(elapsed)+" ms";
								removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
								stage.removeChild( this );
						}
	}
}
