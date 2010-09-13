
package sandy.core.scenegraph;

import flash.events.Event;
import sandy.bounds.BBox;
import sandy.bounds.BSphere;
import sandy.core.Scene3D;
import sandy.core.data.Matrix4;
import sandy.events.BubbleEventBroadcaster;
import sandy.events.SandyEvent;
import sandy.materials.Appearance;
import sandy.view.CullingState;
import sandy.view.Frustum;

import sandy.HaxeTypes;

/**
* ABSTRACT CLASS - Base class for all nodes in the object tree.
*
* <p>The base class for all Group and object nodes,
* that handles all basic operations on a tree node.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		16.03.2007
*
**/
class Node
{
	/**
	* Set that appearance to all the children of that node
	*/
	public var appearance( __getAppearance, __setAppearance ):Appearance;
	/**
	* This property set the cache status of the current node.
	* IMPORTANT Currently this property IS IN USE FOR CACHE SYSTEM
	*/
	public var changed(__getChanged,__setChanged):Bool;
	/**
	* This property represent the culling state of the current node.
	* This state is defined during the culling phasis as it refers to the position of the object against the viewing frustum.
	*/
	public var culled:Int; //CullingState;

	/**
	* Name of this node.
	* Of no name is specified, the unique ID of the node will be used
	*/
	public var name:String;
	/**
	* The broadcaster
	*
	* <p>The broadcaster is used to send events to listeners.<br />
	* This property is a BubbleEventBroadcaster.</p>
	*
	* @return The instance of the current node broadcaster.
	*/
	public var broadcaster(__getBroadcaster,__setBroadcaster):BubbleEventBroadcaster;
	/**
	* The children of this node are stored inside this array.
	* IMPORTANT: Use this property mainly as READ ONLY. To add, delete or search a specific child, you can use the specific method to do that
	*/
	public var children:Array<Node>;
	/**
	* Specifies whether back face culling be enabled for this object.
	*
	* If set to false all faces of this object are drawn.
	* A true value enables the back face culling algorithm - Default true
	*/
	public var enableBackFaceCulling(__getEnableBackFaceCulling,__setEnableBackFaceCulling):Bool;
	/**
	* Enables the event system for mouse events.
	*
	* <p>When set to true, the onPress, onRollOver and onRollOut events are broadcast.<br/>
	* The event system is enabled or disabled for all faces of this object.<br/>
	* As an alternative, you have the possibility to enable events only for specific faces.</p>
	*
	* <p>Once this feature is enabled, the animation is more CPU intensive.</p>
	*
	* <p>Example
	* <code>
	* 	var l_oShape:Shape3D = new Sphere("sphere");
	* 	l_oShape.enableEvents = true;
	* 	l_oShape.addEventListener( MouseEvent.CLICK, onClick );
	*
	* 	function onClick( p_eEvent:Shape3DEvent ):void
	* 	{
	*   	var l_oPoly:Polygon = ( p_eEvent.polygon );
	*   	var l_oPointAtClick:Point3D =  p_eEvent.point;
	*   	// -- get the normalized uv of the point under mouse position
	*  	var l_oIntersectionUV:UVCoord = p_eEvent.uv;
	*   	// -- get the correct material
	*   	var l_oMaterial:BitmapMaterial = (l_oPoly.visible ? l_oPoly.appearance.frontMaterial : l_oPoly.appearance.backMaterial) as BitmapMaterial;
	* 	}
	* </code>
	*/
	public var enableEvents( __getEnableEvents, __setEnableEvents ):Bool;
	/**
	* Enable the interactivity on this shape and its polygon.
	* Be careful, this mode have some requirements :
	*   - to have useSingleContainer set to false. It is done automatically if enabled
	*
	* The original settings are back to their  original state when the mode is disabled
	*/
	public var enableInteractivity(__getEnableInteractivity,__setEnableInteractivity):Bool;
	/**
	*  Cached matrix corresponding to the transformation to the 0,0,0 frame system
	*/
	public var modelMatrix:Matrix4;
	/**
	* The parent node of this node.
	*
	* <p>The reference is null if this node has no parent (for exemple for a root node).</p>
	*/
	public var parent( __getParent, __setParent ):Node;
	/**
	* Cached matrix corresponding to the transformation to the camera frame system
	*/
	public var viewMatrix:Matrix4;

	/**
	* The bounding box of this node
	* IMPORTANT: Do not modify it unless you perfectly know what you are doing
	*/
	public var boundingBox:BBox;

	/**
	* The bounding sphere of this node
	* IMPORTANT: Do not modify it unless you perfectly know what you are doing
	*/
	public var boundingSphere:BSphere;

	/**
	* The unique id of this node in the node graph.
	* <p>This value is very useful to retrieve a specific node.</p>
	*/
	public var id:Int;
	/**
	* Property that changes the way to render this object,
	* Set to true, the shape will be rendered into a single Sprite object,
	* which is accessible through the container property.
	* Set to false, the container property does not target anything, but all the
	* polygons will be rendered into their own dedicated container.
	*
	* <p>If true, this object renders itself on a single container ( Sprite ),<br/>
	* if false, each polygon is rendered on its own container.</p>
	*/
	public var useSingleContainer( __getUseSingleContainer,__setUseSingleContainer ):Bool;
	/**
	* Specify the visibility of this node.
	* If true, the node is visible, if fase, it will not be displayed.
	*/
	public var visible(__getVisible,__setVisible) : Bool;

	/**
	* Reference to the scene is it linked to.
	* Initially null.
	*/
	public var scene(__getScene,__setScene):Scene3D;

	/**
	* Creates a node in the object tree of the world.
	*
	* <p>This constructor should normally not be called directly, only from a sub class.</p>
	*
	* @param p_sName	A string identifier for this object.
	*/
	public function new( ?p_sName:String)
	{
		// instance initializers
		culled = CullingState.OUTSIDE;
		children = new Array();
		modelMatrix = new Matrix4();
		viewMatrix = new Matrix4();
		boundingBox = new BBox();
		boundingSphere = new BSphere();
		id = _ID_++;
		//private initializers
		m_bVisible = true;

		parent = null;
		name = (p_sName != null) ? p_sName : Std.string(id);
		// --
		changed = true;
		m_oEB = new BubbleEventBroadcaster( this );
		// --
		culled = CullingState.INSIDE;
		scene = null;
		boundingBox.reset();
		boundingSphere.reset();
	}

	private var m_bVisible : Bool;
	private function __getVisible() : Bool
	{
		return m_bVisible;
	}
	private function __setVisible(p_bVisibility:Bool) : Bool
	{
		if(m_bVisible == p_bVisibility) return p_bVisibility;
		m_bVisible = p_bVisibility;
		changed = true;
		// do this to specify renderer that objects has been removed from displayList
		// we do not set this in changed setter because we need to force children changed property only in that case!
		for (  node in children )
		 	node.changed = true;
		return p_bVisibility;
	}

	private function __getBroadcaster():BubbleEventBroadcaster
	{
		return m_oEB;
	}
	private function __setBroadcaster(v):BubbleEventBroadcaster
	{
		return m_oEB = v;
	}

	/**
	* Adds a listener for the specified event.
	*
	* @param p_sEvt Name of the Event.
	* @param p_oL Listener object.
	*/
	public function addEventListener<T>(p_sEvt:String, p_oL:T->Void ) : Void
	{
		m_oEB.addEventListener(p_sEvt, p_oL);
	}

	/**
	* Removes a listener for the specified event.
	*
	* @param p_sEvt Name of the Event.
	* @param oL Listener object.
	*/
	public function removeEventListener<T>(p_sEvt:String, p_oL:T->Void) : Void
	{
		m_oEB.removeEventListener(p_sEvt, p_oL);
	}

	/**
	* Tests if the node passed in the argument is parent of this node.
	*
	* @param p_oNode 	The node you are testing
	* @return		true if the node in the argument is the parent of this node, false otherwise.
	*/
	public function isParent( p_oNode:Node ):Bool
	{
		return (_parent == p_oNode && p_oNode != null);
	}

	private function __getUseSingleContainer ():Bool
	{return false;}

	private function __setUseSingleContainer( p_bUseSingleContainer:Bool ):Bool
	{
		for ( l_oNode in children )
		{
			l_oNode.useSingleContainer = p_bUseSingleContainer;
		}
		changed = true;
		return p_bUseSingleContainer;
	}

	/**
	 * Apply clipping to all the children of that node
	 * @param p_bUseClipping if true, the clipping will be used on that object and all its children if any
	 */
	private function __setEnableClipping( p_bUseClipping:Bool ):Bool
	{
		for ( l_oNode in children )
		{
			cast( l_oNode, Shape3D ).enableClipping = p_bUseClipping;
		}
		changed = true;
		return p_bUseClipping;
	}

	private function __getEnableBackFaceCulling( ):Bool
	{
		return false;
	}

	private function __setEnableBackFaceCulling( b:Bool ):Bool
	{
		for ( l_onode in children )
		{
			l_onode.enableBackFaceCulling = b;
		}
		changed = true;
		return b;
	}

	private function __getEnableInteractivity():Bool
	{ return false; }

	private function __setEnableInteractivity( p_bState:Bool ):Bool
	{
		for ( l_oNode in children )
		{
			l_oNode.enableInteractivity = p_bState;
		}
		return p_bState;
	}

	private function __getEnableEvents():Bool
	{
		return false;
	}

	private function __setEnableEvents( b:Bool ):Bool
	{
		for ( l_oNode in children )
		{
			l_oNode.enableEvents = b;
		}
		return b;
	}

	private function __getAppearance():Appearance
	{
		return null;
	}

	private function __setAppearance( p_oApp:Appearance ):Appearance
	{
		for ( l_oNode in children )
		{
			l_oNode.appearance = p_oApp;
		}
		changed = true;
		return p_oApp;
	}

	/**
	* @private
	*/
	private function __setParent( p_oNode:Node ):Node
	{
		if( p_oNode != null )
		{
			_parent = p_oNode;
			changed = true;
		}
		return p_oNode;
	}

	private function __getParent():Node
	{
		return _parent;
	}

	/**
	* Tests if this node has a parent.
	*
	* @return 	true if this node has a parent, false otherwise.
	*/
	public function hasParent():Bool
	{
		return ( _parent != null );
	}

	/**
	* Adds a new child to this node.
	*
	* <p>A node can have several children, and when you add a child to a node,
	* it is automatically connected to the parent node through its parent property.</p>
	*
	* @param p_oChild	The child node to add
	*/
	public function addChild( p_oChild:Node ):Void
	{
		if( p_oChild.parent != null )
		{
			p_oChild.parent.removeChild( p_oChild );
		}
		// --
		p_oChild.parent = this;
		changed =  true ;
		children.push( p_oChild );
		if( p_oChild.broadcaster != null ) m_oEB.addChild( p_oChild.broadcaster );
		if( scene != null ) p_oChild.scene = scene;
	}

	/**
	* Returns the child node with the specified name.
	*
	* @param p_sName	The name of the child you want to retrieve
	* @param p_bRecurs 	Set to true if you want to search the the children for the requested node
	*
	* @return		The requested node or null if no child with this name was found
	*/
	public function getChildByName( p_sName:String, ?p_bRecurs:Bool=false ):Node
	{
		for ( l_oNode in children )
		{
			if( l_oNode.name == p_sName )
			{
				return l_oNode;
			}
		}
		if( p_bRecurs )
		{
			var node:Node = null;
			for ( l_oNode in children )
			{
				node = l_oNode.getChildByName( p_sName, p_bRecurs );
				if( node != null )
				{
					return node;
				}
			}
		}
		return null;
	}


	/**
	* Moves this node to another parent node.
	*
	* <p>This node is removed from its current parent node, and added as a child of the specified node</p>
	*
	* @param p_oNewParent	The node to become parent of this node
	* @deprecated Use addChild on p_oNewParent
	*/
	public function swapParent( p_oNewParent:Node ):Void
	{
		if( parent.removeChild( this ) != null ) {
			p_oNewParent.addChild( this );
			changed = true;
		}
	}

	/**
	* Removes the specified child.
	*
	* All children of the node you want to remove are lost.
	* The link between them and the rest of the tree is broken, so
	* they will not be rendered anymore.
	*
	* The object itself and its children are still in memory, if
	* you want to free them completely, call child.destroy()
	*
	* @param p_oNode The child to remove.
	* @return child instance if the node was removed from node tree, null otherwise.
	*/
	public function removeChild( p_oNode : Node ) : Node {
		var found:Node = null;
		for(i in 0...children.length)
		{
			if( children[i] == p_oNode  )
			{
				found = children[i];
				broadcaster.removeChild( children[i].broadcaster );
				children.splice( i, 1 );
				changed = true;
				break;
			}
		}
		return found;
	}

	/**
	* Removes the child node with the specified name.
	*
	* All children of the node you want to remove are lost.
	* The link between them and the rest of the tree is broken, so
	* they will not be rendered anymore.
	*
	* The object itself and its children are still in memory, if
	* you want to free them completely, call child.destroy()
	*
	* @param p_sName	The name of the node you want to remove.
	* @return child instance if the node was removed from node tree, null otherwise.
	*/
	public function removeChildByName( p_sName:String ) : Node
	{
		var found:Node = null;
		for(i in 0...children.length)
		{
			if( children[i].name == p_sName  )
			{
				found = children[i];
				broadcaster.removeChild( children[i].broadcaster );
				children.splice( i, 1 );
				changed = true;
				break;
			}
		}

		return found;
	}

	/**
	* Delete this node and all its child nodes.
	*
	* <p>This node nad all its child nodes are deleted, including all data they are storing.<br/>
	* The method makes recursive calls to the destroy method of the child nodes.
	*/
	public function destroy():Void
	{
		// the unlink this node to his parent
		if( hasParent() == true ) parent.removeChild( this );

		if(children != null) {
			var l_aTmp = children.copy();
			for ( lNode in l_aTmp )
			{
				lNode.destroy();
			}
			children.splice(0,children.length);
			children = null;
			l_aTmp = null;
		}
		m_oEB = null;
		scene = null;
		parent = null;
	}

	/**
	* Removes this node from the node tree, saving its child nodes.
	*
	* <p>NOTE that remove method only remove the current node and NOT its children!<br />
	* To remove the current node and all its children please refer to the destroy method.</p>
	* <p>The child nodes of this node becomes child nodes of this node's parent.</p>
	*/
	public function remove() :Void
	{
		// first we remove this node as a child of its parent
		// we do not update rigth now, but a little bit later ;)
		if(hasParent())
			parent.removeChild( this );

		// now we make current node children the current parent's node children
		//var l_aTmp:Array = children.concat();
		var l_aTmp:Array<Node> = children;
		for ( lNode in l_aTmp )
		{
			parent.addChild( lNode );
		}
		children.splice(0,children.length);
		m_oEB = null;
		changed = true;
	}

	/**
	* Updates this node.
	*
	* <p>For a node with transformation, this method update the transformation taking into account the matrix cache system.</p>
	*
	* @param p_oScene The current scene
	* @param p_oModelMatrix
	* @param p_bChanged
	*/
	public function update( p_oModelMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		culled = CullingState.INSIDE;
		// --
		if( boundingBox != null )
			boundingBox.uptodate = false;
		if( boundingSphere != null )
			boundingSphere.uptodate = false;

		/* Shall be overriden */
		changed = changed || p_bChanged;

		for ( l_oNode in children )
		{
			l_oNode.update( p_oModelMatrix, changed );
		}

	}


	/**
	* Tests this node against the frustum volume to get its visibility.
	*
	* <p>If the node and its children aren't in the frustum, the node is set to cull
	* and will not be displayed.<br/>
	* <p>The method also updates the bounding volumes, to make a more accurate culling system possible.<br/>
	* First the bounding sphere is updated, and if intersecting, the bounding box is updated to perform a more
	* precise culling.</p>
	* <p><b>[MANDATORY] The update method must be called first!</b></p>
	*
	* @param p_oScene	The current scene
	* @param p_oFrustum	The frustum of the current camera
	* @param p_oViewMatrix	<b>[ToDo: explain]</b>
	* @param p_bChanged	<b>[ToDo: explain]</b>
	*
	*/
	public function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		if( visible == false )
		{
			culled = CullingState.OUTSIDE;
		}
		else
		{
			if( p_bChanged || changed )
			{
				viewMatrix.copy( p_oViewMatrix );
				viewMatrix.multiply4x3( modelMatrix );
			}
		}
	}

	public function __getChanged():Bool
	{
		return m_bChanged;
	}

	public function __setChanged(pVal:Bool):Bool
	{
		m_bChanged = pVal;
		return pVal;
	}

	private var m_bChanged:Bool;

	/**
	* Updates the bounding volumes of this object.
	* NO IMPLEMENTATION RIGHT NOW.
	* MIGHT BE USED IN THE FUTURE
	*/
	public function updateBoundingVolumes():Void
	{
	}

	/**
	* Notification from child that it's bounding volumes have
	* changed.
	**/
	private function onChildBoundsChanged(p_oNode:Node):Void
	{
	}

	private var m_oScene:Scene3D;
	public function __getScene():Scene3D
	{
		return m_oScene;
	}
	/**
		* Reference to the scene is it linked to.
		* Initialized at null.
		*/
	private function __setScene( p_oScene:Scene3D ) : Scene3D
	{
		if( p_oScene == null ) return null;
		if( m_oScene != null)
			m_oScene.removeEventListener(SandyEvent.SCENE_RENDER_FINISH, _updateFlags );
		// --
		m_oScene = p_oScene;
		m_oScene.addEventListener(SandyEvent.SCENE_RENDER_FINISH, _updateFlags );
		// --
		for( node in children )
			node.scene = m_oScene;
		return p_oScene;
	}

	private function _updateFlags( _ ):Void
	{
		changed = false;
	}

	/**
	* Performs an operation on this node and all of its children.
	*
	* <p>Traverses the subtree made up of this node and all of its children.
	* While traversing the subtree, individual operations are performed
	* on entry and exit of each node of the subtree.</p>
	* <p>Implements the visitor design pattern:
	* Using the visitor design pattern, you can define a new operation on Node
	* and its subclasses without having to change the classes and without having
	* to take care of traversing the node tree.</p>
	*
	* @example
	* <listing version="3.1">
	*     var mySpecialOperation:SpecialOperation = new SpecialOperation;
	*
	*     mySpecialOperation.someParameter = 0.8;
	*     someTreeNode.perform(mySpecialOperation);
	*     trace(mySpecialOperation.someResult);
	*
	*     mySpecialOperation.someParameter = 0.2;
	*     someOtherTreeNode.perform(mySpecialOperation);
	*     trace(mySpecialOperation.someResult);
	* </listing>
	*
	* @param  p_iOperation   The operation to be performed on the node subtree
	*/
	public function perform( p_iOperation:INodeOperation ):Void
	{
		p_iOperation.performOnEntry( this );

		// perform operation on all child nodes
		for ( l_oChild in children )
		{
			l_oChild.perform( p_iOperation );
		}

		p_iOperation.performOnExit( this );
	}


	/**
	* Returns a string representation of this object
	*
	* @return	The fully qualified name of this class
	*/
	public function toString():String
	{
		return "sandy.core.scenegraph.Node";
	}

	/**
	* Makes this node a copy of the src node. Many things are not copied,
	* like the parent or children of the object, events, visibility etc.
	*
	* Used internally for clone(), which is a better method to use if
	* you require a new object.
	**/
	private function copy( src:Node, includeTransforms:Bool=false, includeGeometry:Bool=true ) : Void
	{
		changed = true;
		//appearance = src.appearance();
		if(includeGeometry) {
			boundingBox = src.boundingBox.clone();
			boundingSphere = src.boundingSphere.clone();
		}
		// must come first
		useSingleContainer = src.useSingleContainer;

		enableBackFaceCulling = src.enableBackFaceCulling;
		enableEvents = src.enableEvents;
		enableInteractivity = src.enableInteractivity;
	}

	////////////////////
	//// PRIVATE PART
	////////////////////
	private static var _ID_:Int = 0;
	private var _parent:Node;
	private var m_oEB:BubbleEventBroadcaster;

}

