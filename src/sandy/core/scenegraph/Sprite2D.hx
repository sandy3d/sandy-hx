
package sandy.core.scenegraph;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import sandy.core.Scene3D;
import sandy.core.data.Matrix4;
import sandy.core.data.Vertex;
import sandy.events.BubbleEvent;
import sandy.events.SandyEvent;
import sandy.materials.Material;
import sandy.view.CullingState;
import sandy.view.Frustum;

import sandy.HaxeTypes;

/**
* The Sprite2D class is used to create a 2D sprite.
*
* <p>A Sprite2D object is used to display a static or dynamic texture in the Sandy world.<br/>
* The sprite always shows the same side to the camera. This is useful when you want to show more
* or less complex images, without heavy calculations of perspective distortion.</p>
* <p>The Sprite2D has a fixed bounding sphere radius, set by default to 30.<br />
* In case your sprite is bigger, you can adjust it to aVoid any frustum culling issue</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @author		Russell Weir - haXe port
* @version		3.1
* @date 		26.07.2007
*/
class Sprite2D extends ATransformable, implements IDisplayable
{
	// FIXME Create a Sprite as the spriteD container,
	//and offer a method to attach a visual content as a child of the sprite

	/**
	* Set this to true if you want this sprite to rotate with camera.
	*/
	public var fixedAngle:Bool;

	/**
	* When enabled, the sprite will be displayed at its graphical center.
	* Otherwise its top left corner will be set at the computed screen position
	*/
	public var autoCenter:Bool;

	/**
	* When enabled, the sprite will be displayed at its bottom line.
	* Otherwise it is positioned at its registration point (usually top left corner).
	* This property has no effect when autoCenter is enabled.
	*/
	public var floorCenter:Bool;

	/**
	 * @private
	 */
	public var v:Vertex;
	/**
	 * @private
	 */
	public var vx:Vertex;
	/**
	 * @private
	 */
	public var vy:Vertex;

	/**
	* Creates a Sprite2D.
	*
	* @param p_sName	A string identifier for this object
	* @param p_oContent	The container containing all the pre-rendered picture
	* @param p_nScale 	A number used to change the scale of the displayed object.
	* 			In case that the object projected dimension
	*			isn't adapted to your needs.
	*			Default value is 1.0 which means unchanged.
	* 			A value of 2.0 will make the object will double the size
	*/
	public function new( ?p_sName:String="", ?p_oContent:DisplayObject=null, ?p_nScale:Float=1.0)
	{
		//public initializers
		fixedAngle = false;
		autoCenter = true;
		floorCenter = false;
		enableForcedDepth = false;
		forcedDepth = 0;
		//private initializers
		m_bEv = false;
		m_nW2=0;
		m_nH2=0;
		m_nPerspScaleX=0;
		m_nPerspScaleY=0;
		m_nRotation=0;

		super(p_sName);
		m_oContainer = new Sprite();
		// --
		v = new Vertex(); vx = new Vertex(); vy = new Vertex();
		// --
		_nScale = p_nScale;
		// --
		if( p_oContent != null ) 
		{
			this.__setContent( p_oContent );
			setBoundingSphereRadius( Math.max (30, Math.abs (_nScale) * Math.max (content.width, content.height)) );
		}
	}

	/**
	* The DisplayObject that will used as content of this Sprite2D.
	* If this DisplayObject has already a screen position, it will be reseted to 0,0.
	* If the DisplayObject has allready a parent, it will be unrelated from it automatically. (its transform matrix property is resetted to identity too).
	* @param p_content The DisplayObject to attach to the Sprite2D#container.
	*
	* Gives access to your content reference.
	* The content is the exact visual object you passed to the constructor.
	* In comparison with the container which is the container of the content (in Sandy's architecture, the container must be a Sprite),
	* but the content can be any kind of visual object AS3 offers (MovieClip, Bitmap, Sprite etc.)
	* WARNNIG: Be careful when manipulating the content object to not break any link with the sandy container (content.parent).
	*/
	public var content(__getContent,__setContent):DisplayObject;
	private function __getContent() : DisplayObject { return m_oContent; }
	private function __setContent( p_content:DisplayObject ):DisplayObject
	{
		p_content.transform.matrix.identity();
		if( m_oContent != null ) m_oContainer.removeChild( m_oContent );
		m_oContent = p_content;
		m_oContainer.addChildAt( m_oContent, 0 );
		m_oContent.x = 0;
		m_oContent.y = 0;
		m_nW2 = m_oContainer.width / 2;
		m_nH2 = m_oContainer.height / 2;
		return p_content;
	}

	override private function __setScene(p_oScene:Scene3D):Scene3D
	{
		if( p_oScene == null ) return null;
		if( scene != null )
		{
			scene.removeEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
			scene.removeEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
		}
		super.__setScene( p_oScene );
		// --
		scene.addEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
		scene.addEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
		return p_oScene;
	}

	private function _finishMaterial( pEvt:SandyEvent ):Void
	{
		if( m_oMaterial == null ) return;
		if( !visible ) return;
		// --
		m_oMaterial.finish( scene );
	}

	private function _beginMaterial( pEvt:SandyEvent ):Void
	{
		if( m_oMaterial == null ) return;
		if( !visible ) return;
		// --
		m_oMaterial.begin( scene );
	}

	/**
	* The container of this sprite ( canvas )
	*/
	public var container(__getContainer,null):Sprite;
	private function __getContainer():Sprite
	{
		return m_oContainer;
	}

	/**
	* Sets the radius of bounding sphere for this sprite.
	*
	* @param p_nRadius	The radius
	*/
	public function setBoundingSphereRadius( p_nRadius:Float ):Void
	{
		boundingSphere.radius = p_nRadius;
	}

	/**
	* The scale of this sprite.
	*
	* <p>Using scale, you can change the dimension of the sprite rapidly.</p>
	*/
	public var scale(__getScale,__setScale):Float;
	private function __getScale():Float
	{
		return _nScale;
	}

	/**
	* @private
	*/
	private function __setScale( n:Float ):Float
	{
		if(!Math.isNaN(n)) _nScale = n;
		changed = true;
		return n;
	}

	/**
	* The depth to draw this sprite at.
	* <p>[<b>ToDo</b>: Explain ]</p>
	*/
	public var depth(__getDepth,__setDepth):Float;
	private function __getDepth():Float
	{
		return m_nDepth;
	}

	private function __setDepth( p_nDepth:Float ):Float
	{
		m_nDepth = p_nDepth; changed = true;
		return p_nDepth;
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
	* @param p_oFrustum	The frustum of the current camera
	* @param p_oViewMatrix	The view martix of the curren camera
	* @param p_bChanged
	*/
	public override function cull( p_oFrustum:Frustum, p_oViewMatrix:Matrix4, p_bChanged:Bool ):Void
	{
		super.cull( p_oFrustum, p_oViewMatrix, p_bChanged );
		if( visible == false )
		{
			container.visible = visible;
			return;
		}
		// --
		if( viewMatrix != null )
		{
			/////////////////////////
			//// BOUNDING SPHERE ////
			/////////////////////////
			boundingSphere.transform( viewMatrix );
			culled = p_oFrustum.sphereInFrustum( boundingSphere );
		}
		// --
		if( culled == CullingState.OUTSIDE )
		{
			container.visible = false;
		}
		else {
			if( culled == CullingState.INTERSECT )
			{
				if( boundingSphere.position.z <= scene.camera.near )
					container.visible = false;
				else {
					container.visible = true;
					// --
					scene.renderer.addToDisplayList( this );
				}
			}
			else {
				container.visible = true;
				// --
				scene.renderer.addToDisplayList( this );
			}
		}
	}

	/**
	* Clears the graphics object of this object's container.
	*
	* <p>The the graphics that were drawn on the Graphics object is erased,
	* and the fill and line style settings are reset.</p>
	*/
	public function clear():Void
	{
		//m_oContainer.visible = false;
	}

	/**
	* Provide the classical remove behaviour, plus remove the container to the display list.
	*/
	public override function remove():Void
	{
		if( m_oContainer.parent != null ) m_oContainer.parent.removeChild( m_oContainer );
		m_oContainer.graphics.clear();
		enableEvents = false;

		if( scene != null )
		{
			scene.removeEventListener(SandyEvent.SCENE_RENDER_FINISH, _finishMaterial );
			scene.removeEventListener(SandyEvent.SCENE_RENDER_DISPLAYLIST, _beginMaterial );
		}

		super.remove();
	}

	/**
	* @inheritDoc
	*/
	public override function destroy():Void
	{
		remove ();
		super.destroy ();
	}

	/**
	* Displays this sprite.
	*
	* <p>display the object onto the scene.
	* If the object has autocenter enabled, sprite center is set at screen position.
	* Otherwise the sprite top left corner will be at that position.</p>
	*
	* @param p_oContainer	The container to draw on
	*/
	public function display( ?p_oContainer:Sprite  ):Void
	{
		m_nPerspScaleX = (_nScale == 0) ? 1 : _nScale * (vx.sx - v.sx);
		m_nPerspScaleY = (_nScale == 0) ? 1 : _nScale * (v.sy - vy.sy);
		m_nRotation = Math.atan2( viewMatrix.n12, viewMatrix.n22 );

		m_oContainer.scaleX = m_nPerspScaleX;
		m_oContainer.scaleY = m_nPerspScaleY;
		m_oContainer.x = v.sx - (autoCenter ? m_oContainer.width/2 : 0);
		m_oContainer.y = v.sy - (autoCenter ? m_oContainer.height/2 : (floorCenter ? m_oContainer.height : 0) );

		// --
		if (fixedAngle) m_oContainer.rotation = m_nRotation * 180 / Math.PI;
		// --
		if (m_oMaterial != null) m_oMaterial.renderSprite( this, m_oMaterial, scene );
	}

	/**
	* Material that the sprite will be dressed in. Use it to apply some attributes
	* to sprite, such as light attributes.
	*/
	public var material(__getMaterial,__setMaterial):Material;
	private function __getMaterial():Null<Material>
	{
		return m_oMaterial;
	}
	/**
	* @private
	*/
	private function __setMaterial( p_oMaterial:Null<Material> ):Null<Material>
	{
		m_oMaterial = p_oMaterial;
		changed = true;
		return p_oMaterial;
	}

	/**
	* Should forced depth be enable for this object?.
	*
	* <p>If true it is possible to force this object to be drawn at a specific depth,<br/>
	* if false the normal Z-sorting algorithm is applied.</p>
	* <p>When correctly used, this feature allows you to aVoid some Z-sorting problems.</p>
	*/
	public var enableForcedDepth:Bool;

	/**
	* The forced depth for this object.
	*
	* <p>To make this feature work, you must enable the ForcedDepth system too.<br/>
	* The higher the depth is, the sooner the more far the object will be represented.</p>
	*/
	public var forcedDepth:Float;

	override public var enableEvents(__getEnableEvents,__setEnableEvents):Bool;
	override private function __getEnableEvents():Bool
	{
		return m_bEv;
	}

	override private function __setEnableEvents( b:Bool ):Bool
	{
		if( b &&!m_bEv )
		{
			m_oContainer.addEventListener(MouseEvent.CLICK, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.MOUSE_UP, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.ROLL_OVER, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.ROLL_OUT, _onInteraction);

			m_oContainer.addEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
			m_oContainer.addEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
		}
		else if( !b && m_bEv )
		{
			m_oContainer.removeEventListener(MouseEvent.CLICK, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.MOUSE_UP, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.MOUSE_DOWN, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.ROLL_OVER, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.ROLL_OUT, _onInteraction);

			m_oContainer.removeEventListener(MouseEvent.DOUBLE_CLICK, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.MOUSE_MOVE, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.MOUSE_OVER, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.MOUSE_OUT, _onInteraction);
			m_oContainer.removeEventListener(MouseEvent.MOUSE_WHEEL, _onInteraction);
		}
		return b;
	}

	private function _onInteraction( p_oEvt:Event ):Void
	{
		m_oEB.dispatchEvent( new BubbleEvent( p_oEvt.type, this ) );
	}

	override public function toString():String
	{
		return "sandy.core.scenegraph.Sprite2D, container:"+m_oContainer;
	}

	private var m_bEv:Bool; // The event system state (enable or not)

	private var m_nW2:Float;
	private var m_nH2:Float;
	private var m_oContainer:Sprite;
	private var m_nPerspScaleX:Float;
	private var m_nPerspScaleY:Float;
	private var m_nRotation:Float;
	public var m_nDepth:Float;
	private var _nScale:Float;
	private var m_oContent:DisplayObject;
	private var m_oMaterial:Null<Material>;
}

