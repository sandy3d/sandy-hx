package sandy.core.scenegraph;
/**
* Interface which specifies the element can be rendererd by a Sandy3D Camera3D object.
* @author thomas
*/
interface Renderable
{
	function render( p_oCamera:Camera3D ):Void;

}
