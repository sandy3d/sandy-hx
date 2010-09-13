﻿/**
* FireFX by Grant Skinner. May 30, 2007
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
* You may distribute and modify this class freely, provided that you leave this header intact,
* and add appropriate headers to indicate your changes. Credit is appreciated in applications
* that use this code, but is not required.
*
* Please contact info@gskinner.com for more information.
*/

package com.gskinner.effects {
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
	
	public class FireFX extends Sprite {
		private var _fadeRate:Number=0.4;
		private var _distortionScale:Number=0.4;
		private var _distortion:Number=0.5;
		private var _flameHeight:Number=0.3;
		private var _flameSpread:Number=0.3;
		private var _blueFlame:Boolean = false;
		private var _smoke:Number = 0;
		
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
		private var endCount:Number;
		private var bmpsValid:Boolean=false;
		private var perlinValid:Boolean=false;
		private var filtersValid:Boolean=false;
		private var _target:DisplayObject;
		
		public function FireFX() {
			var frame:DisplayObject = getChildAt(0);
			frame.visible = false;
			frame.height = height;
			frame.width = width;
			scaleX = scaleY = 1;
			
			mtx = new Matrix();
			pnt = new Point();
			
			startFire();
		}
		
		// getter/setters:
		override public function set width(value:Number):void {
			bmpsValid &&= (value == width);
			super.width = value|0;
		}
		override public function get width():Number {
			return super.width;
		}
		
		override public function set height(value:Number):void {
			bmpsValid &&= (value == height);
			super.height = value|0;
		}
		override public function get height():Number {
			return super.height;
		}
		
		[Inspectable(defaultValue=0.4,name='fadeRate (0-1)')]
		/**
         * Sets the rate that flames fade as they move up. 0 is slowest, 1 is fastest.
         *
         * @default 0.4
		 */
		public function set fadeRate(value:Number):void {
			filtersValid &&= (value == _fadeRate);
			_fadeRate = value;
		}
		public function get fadeRate():Number {
			return _fadeRate;
		}
		
		[Inspectable(defaultValue=0.4,name='distortionScale (0-1)')]
		/**
         * Sets the scale of flame distortion. 0.1 is tiny and chaotic, 1 is large and smooth.
         *
         * @default 0.4
		 */
		public function set distortionScale(value:Number):void {
			perlinValid &&= (value == _distortionScale);
			_distortionScale = value;
		}
		public function get distortionScale():Number {
			return _distortionScale;
		}
		
		[Inspectable(defaultValue=0.4,name='distortion (0-1)')]
		/**
         * Sets the amount of distortion. 0.1 is little, 1 is chaotic.
         *
         * @default 0.4
		 */
		public function set distortion(value:Number):void {
			filtersValid &&= (value == _fadeRate);
			_distortion = value;
		}
		public function get distortion():Number {
			return _distortion;
		}
		
		[Inspectable(defaultValue=0.3,name='flameHeight (0-1)')]
		/**
         * Sets the how high the flame will burn. 0 is zero gravity, 1 is a bonfire.
         *
         * @default 0.3
		 */
		public function set flameHeight(value:Number):void {
			perlinValid &&= (value == _flameHeight);
			_flameHeight = value;
		}
		public function get flameHeight():Number {
			return _flameHeight;
		}
		
		[Inspectable(defaultValue=0.3,name='flameSpread (0-1)')]
		/**
         * Sets the how much the fire will spread out around the target. 0 is no spread, 1 is a lot.
         *
         * @default 0.3
		 */
		public function set flameSpread(value:Number):void {
			filtersValid &&= (value == _flameSpread);
			_flameSpread = value;
		}
		public function get flameSpread():Number {
			return _flameSpread;
		}
		
		[Inspectable(defaultValue=false,name='blueFlame')]
		/**
         * Indicates whether it should use a blue or red flame.
         *
         * @default false
		 */
		public function set blueFlame(value:Boolean):void {
			filtersValid &&= (value == _blueFlame);
			_blueFlame = value;
		}
		public function get blueFlame():Boolean {
			return _blueFlame;
		}
		
		[Inspectable(defaultValue=0,name='smoke (0-1)')]
		/**
         * Sets the amount of smoke. 0 little, 1 lots.
         *
         * @default 0
		 */
		public function set smoke(value:Number):void {
			filtersValid &&= (value == _smoke);
			_smoke = value;
		}
		public function get smoke():Number {
			return _smoke;
		}
		
		
		[Inspectable(defaultValue='',name='target')]
		/**
         * Sets the amount of smoke. 0 little, 1 lots.
         *
         * @default 
		 */
		public function set targetName(value:String):void {
			var targ:DisplayObject = parent.getChildByName(value);
			if (targ == null) {
				try { targ = parent[value] as DisplayObject; }
				catch (e:*) {}
			}
			target = targ;
		}
		
		/**
         * Defines the shape of the fire. The fire will burn upwards, so it should be near the bottom, and centered in the FireFX component.
         *
         * @default 
		 */
		public function set target(value:DisplayObject):void {
			_target = value;
			clear();
		}
		public function get target():DisplayObject {
			return _target;
		}
		
		/**
         * Clears the fire.
		 */
		public function clear():void {
			if (displayBmp) {
				displayBmp.fillRect(displayBmp.rect,0);
			}
		}
		
		/**
         * Stops the fire effect after letting it burn down over 20 frames.
		 */
		public function stopFire():void {
			// let the fire burn down for 20 frames:
			if (endCount == 0) { endCount = 20; }
		}
		
		
		private function updateBitmaps():void {
			if (displayBmp) {
				displayBmp.dispose();
				displayBmp = null;
				scratchBmp.dispose();
				scratchBmp = null;
				perlinBmp.dispose();
				perlinBmp = null;
			}
			
			displayBmp = new BitmapData(width, height, true, 0);
			scratchBmp = displayBmp.clone();
			perlinBmp = new BitmapData(width*3, height*3, false, 0);
			
			while (numChildren) { removeChildAt(0); }
			addChild(new Bitmap(displayBmp));
			
			updatePerlin();
			updateFilters();
			bmpsValid = true;
		}
		
		private function updatePerlin():void {
			perlinBmp.perlinNoise(30*_distortionScale,20*_distortionScale,1,-Math.random()*1000|0,false,true,1|2,false);
			perlinBmp.colorTransform(perlinBmp.rect,new ColorTransform(1,  1-_flameHeight*0.5  ,1,1,0,0,0,0));
			perlinValid = true;
		}
		
		function updateFilters():void {
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
			dispMapF = new DisplacementMapFilter(perlinBmp,pnt,1,2,14*_distortion,-30,"clamp");
			blurF = new BlurFilter(32*_flameSpread,32*_flameSpread,1);
			
			filtersValid = true;
		}
		
		
		
		private function startFire():void {
			endCount = 0;
			addEventListener(Event.ENTER_FRAME,doFire);
		}
		
		private function doFire(evt:Event):void {
			if (_target == null) { return; }
			if (!bmpsValid) { updateBitmaps(); }
			if (!perlinValid) { updatePerlin(); }
			if (!filtersValid) { updateFilters(); }
			if (endCount == 0) {
				var drawMtx:Matrix = _target.transform.matrix;
				drawMtx.tx = _target.x-x;
				drawMtx.ty = _target.y-y;
				scratchBmp.fillRect(scratchBmp.rect,0);
				drawColorTransform.alphaOffset = -Math.random()*200|0;
				scratchBmp.draw(_target,drawMtx,drawColorTransform,"add");
				scratchBmp.applyFilter(scratchBmp,scratchBmp.rect,pnt,blurF);
				displayBmp.draw(scratchBmp,mtx,null,"add");
			}
			dispMapF.mapPoint = new Point( -Math.random()*(perlinBmp.width-displayBmp.width)|0, -Math.random()*(perlinBmp.height-displayBmp.height)|0 );
			displayBmp.applyFilter(displayBmp,displayBmp.rect,pnt,dispMapF);
			displayBmp.applyFilter(displayBmp,displayBmp.rect,pnt,fireCMF);
			
			if (endCount != 0 && --endCount == 0) {
				removeEventListener(Event.ENTER_FRAME,doFire);
			}
		}
		
	}
}
