
package sandy.core.scenegraph;

import sandy.core.data.Matrix4;
import sandy.view.CullingState;
import sandy.view.Frustum;

import sandy.HaxeTypes;

/**
* The Group class is used for branch nodes in the Sandy object tree.
*
* <p>This class is fianl, and can not be sub classed</p>
* <p>This group binds together, but can not transform its children.<br/>
* To transform collections of objects, you should add them to a transform group.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		28.03.2006
*
* @see sandy.core.scenegraph.TransformGroup
*/
class Group extends Node
{
	/**
	 * Creates a branch group.
	 *
	 * @param p_sName	A string identifier for this object
	 */
	public function new( ?p_sName:String="" )
	{
		super( p_sName );
	}

	/**
	 * Tests this node against the camera frustum to get its visibility.
	 *
	 * <p>If this node and its children are not within the frustum,
	 * the node is culled and will not be displayed.<p/>
	 * <p>This method also updates the bounding volumes to make the more accurate culling system possible.<br/>
	 * First the bounding sphere is updated, and if intersecting,
	 * the bounding box is updated to perform the more precise culling.</p>
	 * <p><b>[MANDATORY] The update method must be called first!</b></p>
	 *
	 * @param p_oScene The current scene
	 * @param p_oFrustum	The frustum of the current camera
	 * @param p_oViewMatrix	The view martix of the curren camera
	 * @param p_bChanged
	 */
	public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		// TODO
		// Parse the children, take their bounding volume and merge it with the current node recurssively.
		// After that call the super cull method to get the correct cull value.
		if( visible == false )
		{
			culled = CullingState.OUTSIDE;
		}
		else
		{
		    var lChanged:Bool = p_bChanged || changed;
		    for ( l_oNode in children )
		        l_oNode.cull( p_oFrustum, p_oViewMatrix, lChanged );
		}
		// --
		//super.cull( p_oFrustum, p_oViewMatrix, p_bChanged );
	}

	public function clone( p_sName:String ):Group
	{
		var l_oGroup:Group = new Group( p_sName );

		for ( l_oNode in children )
		{
			if( Std.is(l_oNode,Shape3D) || Std.is(l_oNode,Group) || Std.is(l_oNode,TransformGroup) )
			{
				l_oGroup.addChild( untyped l_oNode.clone(  p_sName+"_"+l_oNode.name ) );
			}
		}

		return l_oGroup;
	}

	public override function toString():String
	{
		return "sandy.core.scenegraph.Group :["+name+"]";
	}
}

