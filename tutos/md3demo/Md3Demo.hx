
import sandy.animation.Animation;
import sandy.animation.MD3AnimationCfg;
import sandy.core.Scene3D;
import sandy.core.scenegraph.AnimatedShape3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.core.scenegraph.KeyFramedTransformGroup;
import sandy.events.QueueEvent;
import sandy.parser.MD3Parser;
import sandy.parser.ParserEvent;
import sandy.primitive.MD3;
import sandy.util.LoaderQueue;
import sandy.view.BasicView;
import sandy.HaxeTypes;

import flash.net.URLRequest;

import feffects.Tween;

import utils.ObjectTransformer;
import utils.Origin;


class Md3Demo extends BasicView {
	var player : Player;
	var shotgun : Shotgun;
	var origin : Origin;
	var transformer : ObjectTransformer;

	public static function main() {
		if(haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		var d = new Md3Demo();
	}

	public function new() : Void {
		super();
		init();
		flash.Lib.current.addChild(this);

		camera.z = -175;
		origin = new Origin(rootNode);
		origin.visible = true;

		player = new Player("player");
		player.onLoaded = onPlayerLoaded;
		player.load();

	}


	function onPlayerLoaded() {
		trace(here.methodName);
// 		var b = addBox();
// 		b.appearance = makeColorAppearance(0xFFAA44);
		rootNode.addChild(player);

		player.playAnimation("Stand");
		player.queueAnimation("Stand Idle");
		render();

		transformer = new ObjectTransformer(player, camera);
		transformer.enable();
		var me = this;
		transformer.onControlObjectChage = function(v) { me.shotgun.shotgun.frame = v; };

		shotgun = new Shotgun("shotgun");
		shotgun.onLoaded = onShotgunLoaded;
		shotgun.load();
	}

	function onShotgunLoaded() {
		if(!player.attach(shotgun, "shotgun", "torso")) {
			trace("Unable to give player a shotgun");
			var m = "Tags on shotgun :";
			for(t in shotgun.tagNames)
				m += " " + t;
			trace(m);

			var m = "Tags on torso :";
			for(t in player.getPart("torso").tagNames)
				m += " " + t;
			trace(m);

			trace(Type.getClassName(Type.getClass(shotgun.children[0].children[0])));
		}
		else {
			player.queueAnimation("Stand With Weapon");
			player.queueAnimation("Stand Idle");
		}
	}
}

class Shotgun extends AnimatedShape3D {
	static var WMODELS: String = "../assets/tremulous/models/weapons";

	private var queue : LoaderQueue;
	private var parser : MD3Parser;
	private var parserTags: MD3Parser;
	public var shotgun : KeyFramedTransformGroup;

	public function new(p_sName:String) {
		super(p_sName);
	}

	public function load() {
		queue = new LoaderQueue();
		// loads the textures that make up the model
		queue.add("shotgun", new URLRequest(WMODELS + "/shotgun/shotgun.jpg") );
		queue.addEventListener( QueueEvent.QUEUE_COMPLETE, onAssetsLoaded );
		queue.addEventListener( QueueEvent.QUEUE_LOADER_ERROR,  onAssetsError );
		queue.start();
	}

	function removeQueueEvents() {
		queue.removeEventListener( QueueEvent.QUEUE_COMPLETE, onAssetsLoaded );
		queue.removeEventListener( QueueEvent.QUEUE_LOADER_ERROR,  onAssetsError );
	}

	function onAssetsError( e ) {
		removeQueueEvents();
		trace("Unable to load shotgun texture file");
	}

	function onAssetsLoaded( e ) {
		removeQueueEvents();

		// load the shotgun parts
		parser = new MD3Parser( WMODELS + "/shotgun/shotgun.md3", "shotgun", queue );
		parserTags = new MD3Parser( WMODELS + "/shotgun/shotgun_hand.md3", "shotgunTags", queue );

		parser.addEventListener( ParserEvent.FAIL, onMd3Fail);
		parser.addEventListener( ParserEvent.INIT, onMd3Loaded);
		parserTags.addEventListener( ParserEvent.FAIL, onMd3Fail);
		parserTags.addEventListener( ParserEvent.INIT, onMd3Loaded);
		parser.parse();
	}

	function onMd3Fail( e ) {
		trace("MD3 load error");
	}

	function onMd3Loaded( e : ParserEvent) {
		var complete = false;
		var n = e.group.children[0];
// 		trace(n.name);
		var kftg = cast(n, KeyFramedTransformGroup);
		switch(kftg.name) {
		case "shotgun":
			shotgun = kftg;
			parserTags.parse();
			parser.removeEventListener( ParserEvent.FAIL, onMd3Fail);
			parser.removeEventListener( ParserEvent.INIT, onMd3Loaded);
		case "shotgunTags":
			complete = true;
			shotgun.addChild(kftg);
			parserTags.removeEventListener( ParserEvent.FAIL, onMd3Fail);
			parserTags.removeEventListener( ParserEvent.INIT, onMd3Loaded);
		}

		if(complete && shotgun != null) {
			if(!attach(shotgun, this.name))
				trace("Unable to add group to shape");
			shotgun.frame = 0;
			onLoaded();
		}
	}

	public dynamic function onLoaded() : Void {}

}

class Player extends AnimatedShape3D {
	static var PMODELS: String = "../assets/tremulous/models/players";

	public var lower : KeyFramedTransformGroup;
	public var upper : KeyFramedTransformGroup;
	public var head : KeyFramedTransformGroup;

	private var queue : LoaderQueue;
	private var parserLp: MD3Parser;
	private var parserUp: MD3Parser;
	private var parserHp: MD3Parser;

	private var m_qAnimations : Array<{name:String, cb:Void->Void}>;

	public function new(p_sName:String) {
		super(p_sName);
		m_qAnimations = new Array();
	}

	public function load() {
		queue = new LoaderQueue();
		// loads the animation.cfg file, as well as all the textures that make
		// up the model
		queue.add("human_base_cfg", new URLRequest(PMODELS + "/human_base/animation.cfg"), BIN);
		queue.add("l_legs", new URLRequest(PMODELS + "/human_base/light.png") );
		queue.add("l_kneepads", new URLRequest(PMODELS + "/human_base/armour.png") );
		queue.add("u_torso", new URLRequest(PMODELS + "/human_base/base.png") );
		queue.add("u_armour_light", new URLRequest(PMODELS + "/human_base/armour.png") );
		queue.add("u_shoulderpads_light", new URLRequest(PMODELS + "/human_base/shoulderpads.png") );
		queue.add("h_head_helmet", new URLRequest(PMODELS + "/human_base/h_helmet.png") );

		queue.addEventListener( QueueEvent.QUEUE_COMPLETE, onAssetsLoaded );
		queue.addEventListener( QueueEvent.QUEUE_LOADER_ERROR,  onAssetsError );
		queue.start();
	}

	function removeQueueEvents() {
		queue.removeEventListener( QueueEvent.QUEUE_COMPLETE, onAssetsLoaded );
		queue.removeEventListener( QueueEvent.QUEUE_LOADER_ERROR,  onAssetsError );
	}

	function onAssetsError( e ) {
		removeQueueEvents();
		trace("Unable to load animation.cfg file");
	}

	function onAssetsLoaded( e ) {
		removeQueueEvents();
		// read in all the animation data
		var bytes : Bytes = cast queue.data.get("human_base_cfg");
		animations = MD3AnimationCfg.read(bytes, MD3.ANIMATIONS_PLAYER, MD3.ANIMATIONS_PLAYER_TYPES);
		loadModels();
	}

	function loadModels() {
		// load all the body parts
		parserLp = new MD3Parser( PMODELS + "/human_base/lower.md3", "lower", queue );
		parserUp = new MD3Parser( PMODELS + "/human_base/upper.md3", "upper", queue );
		parserHp = new MD3Parser( PMODELS + "/human_base/head.md3", "head", queue );

		parserLp.addEventListener( ParserEvent.FAIL, onMd3Fail);
		parserLp.addEventListener( ParserEvent.INIT, onMd3Loaded);
		parserLp.parse();
		parserUp.addEventListener( ParserEvent.FAIL, onMd3Fail);
		parserUp.addEventListener( ParserEvent.INIT, onMd3Loaded);
		parserUp.parse();
		parserHp.addEventListener( ParserEvent.FAIL, onMd3Fail);
		parserHp.addEventListener( ParserEvent.INIT, onMd3Loaded);
		parserHp.parse();
	}

	function onMd3Fail( e ) {
		trace("MD3 load error");
	}

	function onMd3Loaded( e : ParserEvent) {
		var n = e.group.children[0];
		trace(n.name);
		var kftg = cast(n, KeyFramedTransformGroup);
		switch(kftg.name) {
		case "lower": lower = kftg;
		case "upper": upper = kftg;
		case "head": head = kftg;
		}

		if(lower != null && upper != null && head != null) {
			parserLp.removeEventListener( ParserEvent.FAIL, onMd3Fail);
			parserLp.removeEventListener( ParserEvent.INIT, onMd3Loaded);
			parserUp.removeEventListener( ParserEvent.FAIL, onMd3Fail);
			parserUp.removeEventListener( ParserEvent.INIT, onMd3Loaded);
			parserHp.removeEventListener( ParserEvent.FAIL, onMd3Fail);
			parserHp.removeEventListener( ParserEvent.INIT, onMd3Loaded);

			attach(lower, this.name);
			attach(upper, "torso", this.name);
			attach(head, "head", "torso");
			lower.frame = 0;
			upper.frame = 0;
			onLoaded();
		}
	}

	public function playAnimation(name : String, ?cb:Void->Void) {
		if(!animations.exists(name)) {
			trace("Animation named " + name + " does not exist");
			return;
		}

		// stop current animation
		if(currentAnimation != null) {
			try {
				var t = cast(currentAnimation, Tween);
				if(t != null)
					t.stop();
			} catch(e:Dynamic) {}
			currentAnimation = null;
		}

		var me = this;
		var a = animations.get(name);
		trace("Playing animation " + Std.string(a));

		var tween = new Tween(a.firstFrame, a.lastFrame, a.duration, feffects.easing.Linear.easeNone);

		var onTweenComplete = (a.loopingFrames > 0) ?
			function(_) {
				if(me.m_qAnimations.length == 0) {
					tween.reverse();
					tween.start();
				} else {
					if(cb != null)
						cb();
					var o = me.m_qAnimations.shift();
					if(o != null)
						me.playAnimation(o.name, o.cb);
				}
			}
			:
			function(_) {
				if(cb != null) cb();
				me.currentAnimation = null;
				var o = me.m_qAnimations.shift();
				if(o != null)
					me.playAnimation(o.name, o.cb);
			};

		switch(a.type) {
		case "both":
			tween.setTweenHandlers(function(v) { me.lower.frame = me.upper.frame = v;}, onTweenComplete);
		case "legs":
			tween.setTweenHandlers(
					function(v) { me.lower.frame = v;}, onTweenComplete);
		case "torso":
			tween.setTweenHandlers(function(v) { me.upper.frame = v;}, onTweenComplete);
		}
		currentAnimation = a;
		tween.start();
	}

	public function queueAnimation(name : String, ?cb:Void->Void) {

		if(!animations.exists(name)) {
			trace("Animation named " + name + " does not exist");
			return;
		}
		m_qAnimations.push({name:name, cb:cb});
		if(currentAnimation == null) {
			var o = m_qAnimations.shift();
			playAnimation(o.name, o.cb);
		}
	}

	public dynamic function onLoaded() : Void {}
}
