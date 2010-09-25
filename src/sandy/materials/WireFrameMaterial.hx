
package sandy.materials;

import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.BitmapData;
import flash.geom.Matrix;

#if js
import Html5Dom;
#end

import sandy.core.Scene3D;
import sandy.core.data.Polygon;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.attributes.MaterialAttributes;

import sandy.HaxeTypes;

/**
* Displays the faces of a 3D shape as a wire frame.
*
* <p>This material is used to represent a kind a naked view of a Shape3D. It shows all the edges
* with a certain thickness, color and alpha that you can specify inside the constructor</p>
*
* @author		Thomas PFEIFFER - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.06.2007
*/
class WireFrameMaterial extends Material
{
	#if js
	static inline var WIREFRAME_FRAGMENT_SHADER:String = '
#ifdef GL_ES
		precision highp float;
#endif

		varying vec2 vTexCoord;

		uniform sampler2D uSurface;

		void main(void) {
			gl_FragColor = texture2D(uSurface, vec2(vTexCoord.s, vTexCoord.t));
		}
	';

	static inline var WIREFRAME_VERTEX_SHADER:String = '
		attribute vec3 aVertPos;
		attribute vec2 aTexCoord;

		uniform mat4 uViewMatrix;
		uniform mat4 uProjMatrix;

		varying vec2 vTexCoord;

		void main(void) {
			gl_Position = uProjMatrix * uViewMatrix  * vec4(aVertPos, 1.0);
			vTexCoord = aTexCoord;
		}
	';
	static inline var WIREFRAME_GL_TEXTURE_SIZE = 128;
	static inline var WIREFRAME_GL_LINE_WIDTH_FACTOR = 4;
	#end
	/**
	 * Creates a new WireFrameMaterial.
	 *
	 * @param p_nThickness	The thickness of the lines.
	 * @param p_nColor		The color of the lines.
	 * @param p_nAlpha		The alpha transparency value of the material.
	 * @param p_oAttr		The attributes for this material.
	 *
	 * @see sandy.materials.attributes.MaterialAttributes
	 */
	public function new( p_nThickness:Int = 1, p_nColor:Int = 0, p_nAlpha: Float = 1.0, p_oAttr:MaterialAttributes=null )
	{
		#if (js && SANDY_WEBGL)
		if ( jeash.Lib.mOpenGL )
		{
			if (m_sFragmentShader == null )
				m_sFragmentShader = WIREFRAME_FRAGMENT_SHADER;
			if (m_sVertexShader == null )
				m_sVertexShader = WIREFRAME_VERTEX_SHADER;
			m_oShaderGL = flash.display.Graphics.CreateShaderGL( m_sFragmentShader, m_sVertexShader, ["aVertPos", "aTexCoord"] );
		}
		#end

		super( p_oAttr );
		// --
		m_oType = MaterialType.WIREFRAME;
		// --
		attributes.attributes.push( new LineAttributes( p_nThickness, p_nColor,p_nAlpha ) ) ;

	}

	#if js
	/**
	* @param p_oGraphics	The graphics object that will draw this material
	*/
	public override function initGL( p_oGraphics:Graphics ):Void
	{
		super.initGL( p_oGraphics );
		try
		{
			var l_oLineAttribute : LineAttributes = cast Lambda.filter( attributes.attributes, function (_) { return Std.is(_, LineAttributes); } ).pop();

			var l_oCanvas : HTMLCanvasElement = cast js.Lib.document.createElement("canvas");
			l_oCanvas.width = WIREFRAME_GL_TEXTURE_SIZE;
			l_oCanvas.height = WIREFRAME_GL_TEXTURE_SIZE;
			var l_oCtx : CanvasRenderingContext2D = l_oCanvas.getContext("2d");
			l_oCtx.fillStyle = "rgba(255,255,255," + l_oLineAttribute.alpha + ")";
			l_oCtx.fillRect(0,0,WIREFRAME_GL_TEXTURE_SIZE,WIREFRAME_GL_TEXTURE_SIZE);
			l_oCtx.strokeStyle = "#" + StringTools.hex(l_oLineAttribute.color);
			l_oCtx.lineWidth = WIREFRAME_GL_LINE_WIDTH_FACTOR * l_oLineAttribute.thickness;
			l_oCtx.strokeRect(0,0,WIREFRAME_GL_TEXTURE_SIZE,WIREFRAME_GL_TEXTURE_SIZE);

			l_oCtx.beginPath();
			l_oCtx.moveTo(0,WIREFRAME_GL_TEXTURE_SIZE);
			l_oCtx.lineTo(WIREFRAME_GL_TEXTURE_SIZE,0);
			l_oCtx.closePath();
			l_oCtx.stroke();
			
			var l_oBitmapData = BitmapData.CreateFromHandle(l_oCanvas);
			p_oGraphics.beginBitmapFill(l_oBitmapData);
		} catch (e:Dynamic) {
			trace(e);
		}
	}
	#end

	/**
	* @private
	*/
	public override function renderPolygon( p_oScene:Scene3D, p_oPolygon:Polygon, p_mcContainer:Sprite ):Void
	{
		if( attributes != null )
			attributes.draw( p_mcContainer.graphics, p_oPolygon, this, p_oScene );
	}

}

