
package sandy.materials.attributes;

import flash.display.Graphics;

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.core.data.Point3D;
import sandy.core.data.Vertex;
import sandy.materials.Material;

import sandy.HaxeTypes;

/**
* Display the vertex normals of a given object.
*
* <p>Developed originally for a debug purpose, this class allows you to create some
* special effects, displaying the normal of each vertex.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class VertexNormalAttributes extends LineAttributes
{
	private var m_nLength:Float;

	/**
	 * Creates a new VertexNormalAttributes object.
	 *
	 * @param p_nLength		The length of the segment.
	 * @param p_nThickness	The line thickness.
	 * @param p_nColor		The line color.
	 * @param p_nAlpha		The alpha transparency value of the material.
	 */
	public function new( ?p_nLength:Float = 10.0, ?p_nThickness:Int = 1, ?p_nColor:Int = 0, ?p_nAlpha:Float = 1.0)
	{
		m_nLength = p_nLength;
		// reuse LineAttributes setters
		thickness = p_nThickness;
		alpha = p_nAlpha;
		color = p_nColor;
		// --
		modified = true;
		super();
	}

	/**
	 * The line length.
	 */
	public var length(__getLength,__setLength):Float;
	private function __getLength():Float
	{
		return m_nLength;
	}

	/**
	 * The line length.
	 */
	private function __setLength( p_nValue:Float ):Float
	{
		m_nLength = p_nValue;
		modified = true;
		return p_nValue;
	}

	/**
	 * Draw the edges of the polygon into the graphics object.
	 *
	 * @param p_oGraphics the Graphics object to draw attributes into
	 * @param p_oPolygon the polygon which is going o be drawn
	 * @param p_oMaterial the refering material
	 * @param p_oScene the scene
	 */
	override public function draw( p_oGraphics:Graphics, p_oPolygon:Polygon, p_oMaterial:Material, p_oScene:Scene3D ):Void
	{
		var l_aPoints:Array<Vertex> = p_oPolygon.vertices;
		var l_oVertex:Vertex;
		// --
		p_oGraphics.lineStyle( thickness, color, alpha );
		p_oGraphics.beginFill(0);
		// --
		var lId:Int = l_aPoints.length;
		while( (l_oVertex = l_aPoints[ --lId ]) != null )
		{
			var l_oDiff:Point3D = p_oPolygon.vertexNormals[ lId ].getPoint3D().clone();
			p_oPolygon.shape.viewMatrix.transform3x3( l_oDiff );
			// --
			l_oDiff.scale( m_nLength );
			// --
			var l_oNormal:Vertex = Vertex.createFromPoint3D( l_oDiff );
			l_oNormal.add( l_oVertex );
			// --
			p_oScene.camera.projectVertex( l_oNormal );
			// --
			p_oGraphics.moveTo( l_oVertex.sx, l_oVertex.sy );
			p_oGraphics.lineTo( l_oNormal.sx, l_oNormal.sy );
			// --
			l_oNormal = null;
			l_oDiff = null;
		}
		// --
		p_oGraphics.endFill();
	}

	/**
	 * Method called before the display list rendering.
	 * This is the common place for this attribute to precompute things
	 */
	override public function begin( p_oScene:Scene3D ):Void
	{
		// TODO, do the normal projection here
	}
}

