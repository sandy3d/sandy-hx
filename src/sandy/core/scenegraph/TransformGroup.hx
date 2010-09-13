
package sandy.core.scenegraph;

import sandy.core.data.Matrix4;
import sandy.bounds.BBox;
import sandy.bounds.BSphere;
import sandy.view.CullingState;
import sandy.view.Frustum;

import sandy.HaxeTypes;

/**
* The TransformGroup class is used to create transform group.
*
* <p>It represents a node in the object tree of the world.<br/>
* Transformations performed on this group are applied to all its children.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Russell Weir
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class TransformGroup extends ATransformable
{
	/**
	* Set to true if this group should keep a current BBox and BSphere
	**/
	public var trackBounds : Bool;

	// child bounds dictionary
	private var m_dChildBounds : ObjectMap<Node, BBox>;
	// this class is in the middle of a updateBoundingVolumes call
	// so onChildBoundsChanged events are ignored.
	private var m_bUpdatingBounds : Bool;

	/**
	 * Creates a transform group.
	 *
	 * @param  p_sName	A string identifier for this object
	 */
	public function new( ?p_sName:String = "")
	{
		super( p_sName );
		// Dictionary of child bounds
		m_dChildBounds = new ObjectMap();
	}

	public override function addChild( p_oChild:Node ):Void
	{
		super.addChild(p_oChild);
		updateChildBoundsCache( p_oChild );
	}

	/**
	* Tests this node against the camera frustum to get its visibility.
	*
	* <p>If this node and its children are not within the frustum,
	* the node is set to cull and it would not be displayed.<p/>
	* <p>The method also updates the bounding volumes to make the more accurate culling system possible.<br/>
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
	}

	public function clone( p_sName:String ):TransformGroup
	{
		var l_oGroup:TransformGroup = new TransformGroup( p_sName );

		for ( l_oNode in children )
		{
			if( Std.is(l_oNode,Shape3D) || Std.is(l_oNode,Group) || Std.is(l_oNode,TransformGroup) )
		    {
				l_oGroup.addChild( untyped l_oNode.clone( p_sName+"_"+l_oNode.name ) );
		    }
		}

		return l_oGroup;
	}

	public override function destroy() : Void
	{
		super.destroy();
		for(k in m_dChildBounds)
			m_dChildBounds.delete(k);
		m_dChildBounds = null;
	}

	private override function onChildBoundsChanged(child:Node):Void
	{
		// this class is the cause of the bounds update
		if(m_bUpdatingBounds)
			return;
		// on frame changes, bounds are reset in IKeyFramed children
		updateChildBoundsCache(child);

		// Reset current bounds, and rebuild from child boxes
		boundingBox.reset();
		for(key in m_dChildBounds)
			boundingBox.merge(m_dChildBounds.get(key));
		boundingSphere.resetFromBox(boundingBox);

		// Notify parent
		if(parent != null)
			parent.onChildBoundsChanged(this);
	}

	public override function removeChild( p_oNode : Node ) : Node {
		var rv = super.removeChild( p_oNode );
		m_dChildBounds.delete( p_oNode );
		return rv;
	}

	public override function removeChildByName( p_sName:String ):Node {
		var rv = super.removeChildByName( p_sName );
		if(rv != null)
			m_dChildBounds.delete( rv );
		return rv;
	}

	/**
	 * Returns a string representation of the TransformGroup.
	 *
	 * @return	The fully qualified name.
	 */
	public override function toString():String
	{
		return "sandy.core.scenegraph.TransformGroup :["+name+"]";
	}

	/**
	* Updates the bounding volumes of this object.
	*/
	public override function updateBoundingVolumes():Void
	{
		m_bUpdatingBounds = true;
		boundingBox.reset();
		for(child in children) {
			child.updateBoundingVolumes();
			boundingBox.merge(updateChildBoundsCache(child));
		}
		boundingSphere.resetFromBox(boundingBox);
		m_bUpdatingBounds = false;
	}


	/**
	* Updates the child bounding box entry for the specified child
	*
	* @param child Child node
	* @return local bounding box copy of child BBox
	*/
	private function updateChildBoundsCache(child:Node) : BBox {
		var box = m_dChildBounds.get(child);
		if(box == null) {
			box = new BBox();
			m_dChildBounds.set(child, box);
		}
		box.copy(child.boundingBox);
		return box;
	}
}

