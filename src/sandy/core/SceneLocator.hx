
package sandy.core;

import sandy.HaxeTypes;

/**
* The SceneLocator serves as a registry of all scenes in the application.
*
* <p>An application can only have one SceneLocator. Using the SceneLocator, scenes can be located, registered, and unregistered.</p>
* <p>When scenes are created in an application, they automatically
* register with the SceneLocator registry.</p>
*
* @author		Thomas Pfeiffer - kiroukou
* @author		Niel Drummond - haXe port
* @version		3.1
* @date 		26.07.2007
*
* @see Scene3D
*/
class SceneLocator
{

	private static var _oI	: SceneLocator;
	private var _m		: Hash<Scene3D>;

	/**
	 * Creates the SceneLocator registry
	 *
	 * <p>This constructor is never called directly.<br />
	 * Instead you get the registry instance by calling SceneLocator.getInstance().</p>
	 *
	 * @param access	A singleton access flag object
	 */
	public function new( access : PrivateConstructorAccess )
	{
		_m = new Hash();
	}

	/**
	 * Returns a SceneLocator.
	 *
	 * @return 	The single locator
	 */
	public static function getInstance() : SceneLocator
	{
		if ( _oI == null ) _oI = new SceneLocator( new PrivateConstructorAccess() );
		return _oI;
	}


	/**
	 * Returns the Scene3D object with the specified name.
	 *
	 * @param	key 	The name of the scene
	 * @return	The requested scene
	 */
	public function getScene( key : String ) : Scene3D
	{
		if ( !(isRegistered( key )) ) trace( "Can't locate scene instance with '" + key + "' name in " + this );
		return _m.get( key );
	}

	/**
	 * Check if a scene with the specified name is registered.
	 *
	 * @param 	key The Name of the scene to check
	 * @return	true if a scene with that name is registered, false otherwise
	 */
	public function isRegistered( key : String ) : Bool
	{
		return _m.get( key ) != null;
	}

	/**
	 * Registers a scene with this SceneLocator
	 *
	 * @param	key : String, name of the scene to register
	 * @param	o	: Scene3D, object to register
	 * @return	true if the registration was successful, false otherwise
	 */
	public function registerScene( key : String, o : Scene3D ) : Bool
	{
		if ( isRegistered( key ) )
		{
			trace( "scene instance is already registered with '" + key + "' name in " + this );
			return false;

		}
		else
		{
			_m.set( key, o );
			return true;
		}
	}

	/**
	 * Unregisters a scene with the specified name
	 *
	 * @param	key Th name of the scene to unregister
	 */
	public function unregisterScene( key : String ) : Void
	{
		_m.remove( key );
	}

}


class PrivateConstructorAccess {
	public function new () {}
}
