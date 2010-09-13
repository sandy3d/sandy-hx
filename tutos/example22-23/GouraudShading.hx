import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.ColorMaterial;
import sandy.materials.attributes.GouraudAttributes;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.PhongAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.primitive.Sphere;
import flash.display.Sprite;
import flash.Lib;


class GouraudShading extends Sprite
{
	private var world:Scene3D;

	public function new ()
	{
	 world = new Scene3D ("scene", this, new Camera3D (200, 200), new Group ("root"));

		super();

		var a1:GouraudAttributes = new GouraudAttributes (true, 0.3);
		a1.diffuse = 0.5;
		var a2:PhongAttributes = new PhongAttributes (true, 0, 15);
		a2.diffuse = 0.5;
		a2.specular = 1;
		a2.gloss = 5;
		a2.onlySpecular = true;

		var a:LightAttributes = new LightAttributes (true, 0.2);

		var s:Sphere = new Sphere ("s", 100, 4, 3);
		var m:ColorMaterial = new ColorMaterial (0xFF, 1, new MaterialAttributes ([a1,a2]));
		m.lightingEnable = true; 
		s.appearance = new Appearance (m);
		var g:Group = new Group ("root"); 

		g.addChild (s); 
		g.addChild (world.camera);

		world.root = g; 
		world.light.setDirection (1, -1, 0); 
		world.render ();

		Lib.current.stage.addChild(this);
	}

		static function main() {
				new GouraudShading();
		}
}

