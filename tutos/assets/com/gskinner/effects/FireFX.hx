/**
* FireFX by Grant Skinner. May 30, 2007
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
* You may distribute and modify this class freely, provided that you leave this header intact,
* and add appropriate headers to indicate your changes. Credit is appreciated in applications
* that use this code, but is not required.
*
* Please contact info@gskinner.com for more information.
* 
* haXe port : Niel Drummond
*/

package com.gskinner.effects;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.ColorTransform;
import flash.filters.ColorMatrixFilter;
import flash.filters.BlurFilter;
import flash.filters.DisplacementMapFilter;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.events.Event;
import flash.display.Bitmap;
import flash.display.DisplayObject;

class FireFX extends Sprite {
	private var _fadeRate:Float;
	private var _distortionScale:Float;
	private var _distortion:Float;
	private var _flameHeight:Float;
	private var _flameSpread:Float;
	private var _blueFlame:Bool;
	private var _smoke:Float;
	
// private properties:
	// display elements:
	private var displayBmp:BitmapData;
	private var scratchBmp:BitmapData;
	private var perlinBmp:BitmapData;
	
	// geom:
	private var mtx:Matrix;
	private var pnt:Point;
	private var drawColorTransform:ColorTransform;
	
	// filters:
	private var fireCMF:ColorMatrixFilter;
	private var dispMapF:DisplacementMapFilter;
	private var blurF:BlurFilter;
	
	// other:
	private var endCount:Int;
	private var bmpsValid:Bool;
	private var perlinValid:Bool;
	private var filtersValid:Bool;
	private var _target:DisplayObject;
	
	public function new() {
	 _fadeRate=0.4;
	 _distortionScale=0.4;
	 _distortion=0.5;
	 _flameHeight=0.3;
	 _flameSpread=0.3;
	 _blueFlame = false;
	 _smoke = 0;

	 bmpsValid=false;
	 perlinValid=false;
	 filtersValid=false;

	super ();
	
		var frame:DisplayObject = getChildAt(0);
		frame.visible = false;
		frame.height = height;
		frame.width = width;
		scaleX = scaleY = 1;
		
		mtx = new Matrix();
		pnt = new Point();
		
		startFire();
	}
	
	/* 
	[Inspectable(defaultValue=0.4,name='fadeRate (0-1)')]
	*/
	/**
        * Sets the rate that flames fade as they move up. 0 is slowest, 1 is fastest.
        *
        * @default 0.4
	 */
	private function __setFadeRate(value:Float):Float {
		filtersValid = filtersValid && (value == _fadeRate);
		_fadeRate = value;
		return value;
	}
	public var fadeRate(__getFadeRate,__setFadeRate):Float;
	private function __getFadeRate():Float {
		return _fadeRate;
	}
	
	/*
	[Inspectable(defaultValue=0.4,name='distortionScale (0-1)')]
	*/
	/**
        * Sets the scale of flame distortion. 0.1 is tiny and chaotic, 1 is large and smooth.
        *
        * @default 0.4
	 */
	private function __setDistortionScale(value:Float):Float {
		perlinValid = perlinValid && (value == _distortionScale);
		_distortionScale = value;
		return value;
	}
	public var distortionScale(__getDistortionScale,__setDistortionScale):Float;
	private function __getDistortionScale():Float {
		return _distortionScale;
	}
	
	/*
	[Inspectable(defaultValue=0.4,name='distortion (0-1)')]
	*/
	/**
        * Sets the amount of distortion. 0.1 is little, 1 is chaotic.
        *
        * @default 0.4
	 */
	private function __setDistortion(value:Float):Float {
		filtersValid = filtersValid && (value == _fadeRate);
		_distortion = value;
		return value;
	}
	public var distortion(__getDistortion,__setDistortion):Float;
	private function __getDistortion():Float {
		return _distortion;
	}
	
	/*
	[Inspectable(defaultValue=0.3,name='flameHeight (0-1)')]
	*/
	/**
        * Sets the how high the flame will burn. 0 is zero gravity, 1 is a bonfire.
        *
        * @default 0.3
	 */
	private function __setFlameHeight(value:Float):Float {
		perlinValid = perlinValid && (value == _flameHeight);
		_flameHeight = value;
		return value;
	}
	public var flameHeight(__getFlameHeight,__setFlameHeight):Float;
	private function __getFlameHeight():Float {
		return _flameHeight;
	}
	
	/*
	[Inspectable(defaultValue=0.3,name='flameSpread (0-1)')]
	*/
	/**
        * Sets the how much the fire will spread out around the target. 0 is no spread, 1 is a lot.
        *
        * @default 0.3
	 */
	private function __setFlameSpread(value:Float):Float {
		filtersValid = filtersValid && (value == _flameSpread);
		_flameSpread = value;
		return value;
	}
	public var flameSpread(__getFlameSpread,__setFlameSpread):Float;
	private function __getFlameSpread():Float {
		return _flameSpread;
	}
	
	/*
	[Inspectable(defaultValue=false,name='blueFlame')]
	*/
	/**
        * Indicates whether it should use a blue or red flame.
        *
        * @default false
	 */
	private function __setBlueFlame(value:Bool):Bool {
		filtersValid = filtersValid && (value == _blueFlame);
		_blueFlame = value;
		return value;
	}
	public var blueFlame(__getBlueFlame,__setBlueFlame):Bool;
	private function __getBlueFlame():Bool {
		return _blueFlame;
	}
	
	/*
	[Inspectable(defaultValue=0,name='smoke (0-1)')]
	*/
	/**
        * Sets the amount of smoke. 0 little, 1 lots.
        *
        * @default 0
	 */
	private function __setSmoke(value:Float):Float {
		filtersValid = filtersValid && (value == _smoke);
		_smoke = value;
		return value;
	}
	public var smoke(__getSmoke,__setSmoke):Float;
	private function __getSmoke():Float {
		return _smoke;
	}
	
	
	/*
	[Inspectable(defaultValue='',name='target')]
	*/
	/**
        * Sets the amount of smoke. 0 little, 1 lots.
        *
        * @default 
	 */
	public var targetName(null,__setTargetName):String;
	private function __setTargetName(value:String):String {
		var targ:DisplayObject = parent.getChildByName(value);
		if (targ == null) {
			//try { targ = parent[value] as DisplayObject; }
			try { targ = Reflect.field( parent, value ); }
			catch (e:Dynamic) {}
		}
		target = targ;
		return value;
	}
	
	/**
        * Defines the shape of the fire. The fire will burn upwards, so it should be near the bottom, and centered in the FireFX component.
        *
        * @default 
	 */
	private function __setTarget(value:DisplayObject):DisplayObject {
		_target = value;
		clear();
		return value;
	}
	public var target(__getTarget,__setTarget):DisplayObject;
	private function __getTarget():DisplayObject {
		return _target;
	}
	
	/**
        * Clears the fire.
	 */
	public function clear():Void {
		if (displayBmp != null) {
			displayBmp.fillRect(displayBmp.rect,0);
		}
	}
	
	/**
        * Stops the fire effect after letting it burn down over 20 frames.
	 */
	public function stopFire():Void {
		// let the fire burn down for 20 frames:
		if (endCount == 0) { endCount = 20; }
	}
	
	
	private function updateBitmaps():Void {
		if (displayBmp != null) {
			displayBmp.dispose();
			displayBmp = null;
			scratchBmp.dispose();
			scratchBmp = null;
			perlinBmp.dispose();
			perlinBmp = null;
		}
		
		displayBmp = new BitmapData(Std.int(width), Std.int(height), true, 0);
		scratchBmp = displayBmp.clone();
		perlinBmp = new BitmapData(Std.int(width*3), Std.int(height*3), false, 0);
		
		while (numChildren > 0) { removeChildAt(0); }
		addChild(new Bitmap(displayBmp));
		
		updatePerlin();
		updateFilters();
		bmpsValid = true;
	}
	
	private function updatePerlin():Void {
		perlinBmp.perlinNoise(30*_distortionScale,20*_distortionScale,1,-Std.int(Math.random()*1000)|0,false,true,1|2,false);
		perlinBmp.colorTransform(perlinBmp.rect,new ColorTransform(1,  1-_flameHeight*0.5  ,1,1,0,0,0,0));
		perlinValid = true;
	}
	
	function updateFilters():Void {
		if (_blueFlame) {
			fireCMF = new ColorMatrixFilter([0.8-0.55*_fadeRate,0,0,0,0,
											 0,0.93-0.48*_fadeRate,0,0,0,
											 0,0.1,0.96-0.35*_fadeRate,0,0,
											 0,0.1,0,1,-25+_smoke*24]);
			drawColorTransform = new ColorTransform(0,0,0,1,210,240,255,0);
		} else {
			fireCMF = new ColorMatrixFilter([0.96-0.35*_fadeRate,0.1,0,0,-1,
											 0,0.9-0.45*_fadeRate,0,0,0,
											 0,0,0.8-0.55*_fadeRate,0,0,
											 0,0.1,0,1,-25+_smoke*24]);
			drawColorTransform = new ColorTransform(0,0,0,1,255,255,210,0);
		}
		dispMapF = new DisplacementMapFilter(perlinBmp,pnt,1,2,14*_distortion,-30,flash.filters.DisplacementMapFilterMode.CLAMP);
		blurF = new BlurFilter(32*_flameSpread,32*_flameSpread,1);
		
		filtersValid = true;
	}
	
	
	
	private function startFire():Void {
		endCount = 0;
		addEventListener(Event.ENTER_FRAME,doFire);
	}
	
	private function doFire(evt:Event):Void {
		if (_target == null) { return; }
		if (!bmpsValid) { updateBitmaps(); }
		if (!perlinValid) { updatePerlin(); }
		if (!filtersValid) { updateFilters(); }
		if (endCount == 0) {
			var drawMtx:Matrix = _target.transform.matrix;
			drawMtx.tx = _target.x-x;
			drawMtx.ty = _target.y-y;
			scratchBmp.fillRect(scratchBmp.rect,0);
			drawColorTransform.alphaOffset = Std.int(-Math.random()*200)|0;
			scratchBmp.draw(_target,drawMtx,drawColorTransform,flash.display.BlendMode.ADD);
			scratchBmp.applyFilter(scratchBmp,scratchBmp.rect,pnt,blurF);
			displayBmp.draw(scratchBmp,mtx,null,flash.display.BlendMode.ADD);
		}
		dispMapF.mapPoint = new Point( Std.int(-Math.random()*(perlinBmp.width-displayBmp.width))|0, Std.int(-Math.random()*(perlinBmp.height-displayBmp.height))|0 );
		displayBmp.applyFilter(displayBmp,displayBmp.rect,pnt,dispMapF);
		displayBmp.applyFilter(displayBmp,displayBmp.rect,pnt,fireCMF);
		
		if (endCount != 0 && --endCount == 0) {
			removeEventListener(Event.ENTER_FRAME,doFire);
		}
	}
	
}

