package utils;

import sandy.core.data.Point3D;
import sandy.core.scenegraph.Node;
import sandy.primitive.Line3D;
import sandy.materials.Appearance;
import sandy.materials.WireFrameMaterial;


class Origin {

	var xLine : Line3D;
	var yLine : Line3D;
	var zLine : Line3D;
	public var visible(default, setVisible) : Bool;

	public function new(root:Node) {
		xLine = new Line3D( "x-coord", [new Point3D(-50, 0, 0), new Point3D( 50, 0, 0 )]);
		yLine = new Line3D( "y-coord", [new Point3D(0, -50, 0), new Point3D( 0, 50, 0 )]);
		zLine = new Line3D( "z-coord", [new Point3D(0, 0, -50), new Point3D( 0, 0, 50 )]);

		xLine.appearance = new Appearance( new WireFrameMaterial(1, 0xFF0000, 1.0) );
		yLine.appearance = new Appearance( new WireFrameMaterial(1, 0x00FF00, 1.0) );
		zLine.appearance = new Appearance( new WireFrameMaterial(1, 0x0000FF, 1.0) );

		root.addChild(xLine);
		root.addChild(yLine);
		root.addChild(zLine);

	}

	public function getPosition( ?p_eMode ):Point3D
	{
		return xLine.getPosition( p_eMode );
	}

	function setVisible(v : Bool) : Bool {
		xLine.visible = v;
		yLine.visible = v;
		zLine.visible = v;
		return this.visible = v;
	}
}