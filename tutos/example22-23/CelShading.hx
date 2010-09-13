import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.CelShadeAttributes;
import sandy.primitive.Sphere;
import flash.display.Sprite;
import flash.Lib;


class CelShading extends Sprite
{
	private var world:Scene3D;

	public function new ()
	{
	 world = new Scene3D ("scene", this, new Camera3D (200, 200), new Group ("root"));

		super();

		var a:CelShadeAttributes = new CelShadeAttributes ();

		var s:Sphere = new Sphere ("s", 100, 20, 20);
		var m:ColorMaterial = new ColorMaterial (0xFF, 1, new MaterialAttributes ([a]));
		m.lightingEnable = true; 
		s.appearance = new Appearance (m);
		var g:Group = new Group ("root"); 

		g.addChild (s); 
		g.addChild (world.camera);

		world.root = g; 
		world.light.setDirection (1, -1, 3); 
		world.render ();

		Lib.current.stage.addChild(this);
	}

		static function main() {
				new CelShading();
		}
}

