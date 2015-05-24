package com.jonnybomb.ui.components
{
	import com.jonnybomb.ui.data.ColorData;
	import com.jonnybomb.ui.data.ColorExtended;
	import com.jonnybomb.ui.utils.DrawingUtil;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	
	public class Slider extends Sprite
	{
		public static const CONTINUOUS:int = 0;
		public static const NOTCHED:int = 1;
		public static const BG_BEVEL:BevelFilter = new BevelFilter(1, 270, 0xFFFFFF, 1, 0x000000, 1, 1, 1, 1, BitmapFilterQuality.LOW, BitmapFilterType.INNER, false);
		public static const BG_DS:DropShadowFilter = new DropShadowFilter(2, 90, 0x000000, 1, 5, 5, 0.5, BitmapFilterQuality.MEDIUM, true);
		
		private var _handle:SliderHandle;
		private var _bg:Sprite;
		private var _intervalLines:Sprite;
		private var _hit:Sprite;
		
		private var _isOver:Boolean = false;
		private var _isDown:Boolean = false;
		private var _isDragging:Boolean = false;
		private var _enabled:Boolean = false;
		
		private var _width:int;
		private var _height:int;
		private var _type:int;
		private var _values:Object;
		private var _styles:Object;
		private var _dragBounds:Rectangle;
		private var _bgHeightPct:Number = 0.25;
		
		private var _snapToData:Vector.<Object>;
		private var _snapToValue:Object;
		
		private var _pct:Number = 0;
		public function get pct():Number { return _pct; }
		
		private var _value:Number = 0;
		public function get value():Number { return _value; }
		
		public function Slider(width:int, height:int, type:int, values:Object, styles:Object)
		{
			_width = width;
			_height = height;
			_type = type;
			_values = values;
			_styles = styles;
			
			init();
		}
		
		public function init():void
		{
			//draw bg
			_bg = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_bg, _width, Math.round(_height * _bgHeightPct), _styles.bg, 0, 0); //_styles.ellipse);
			_bg.filters = [BG_DS];
			_bg.y = (_height - _bg.height) / 2;
			
			// draw handle
			_handle = addChild(new SliderHandle(10, _height, _styles)) as SliderHandle;
			_dragBounds = new Rectangle(0, 0, _width - _handle.width, 0);
			
			//draw hit
			_hit = addChild(new Sprite()) as Sprite;
			var g:Graphics = _hit.graphics;
			g.beginFill(0xFF0000, 0);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			
			if (_type == NOTCHED)
			{
				_intervalLines = addChildAt(new Sprite(), 0) as Sprite;
				_snapToData = new <Object>[];
				var intValue:Number = (_values.max - _values.min) / _values.numInt;
				var intPixel:Number = (_width - _handle.width) / _values.numInt ;
				for (var i:int=0; i<=_values.numInt; i++)
				{
					var value:Number = _values.min + intValue*i;
					var pixel:Number = Math.round(_handle.width/2 + intPixel*i);
					var pct:Number = i/_values.numInt;
					//trace(i+" >> value:"+value+", pixel:"+pixel+", pct:"+pct);
					_snapToData.push( {value:value, pixel:pixel, pct:pct} );
					drawIntervalLine(pixel);
				}
			}
			
			if (_values.init)
				setValue(_values.init);
			
			mouseChildren = false;
			buttonMode = true;
			enabled = true;
		}
		
		public function setValue(value:Number, dispatchChange:Boolean = true):void { updateProgressDisplay( (value - _values.min) / (_values.max - _values.min), dispatchChange ); }
		public function setPct(pct:Number, dispatchChange:Boolean = true):void { updateProgressDisplay(pct, dispatchChange); }
		
		public function set enabled(value:Boolean):void
		{
			if (value)
			{
				addEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			}
			else
			{
				if (stage)
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false);
				}
				
				removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false);
				removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false);
				removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
			}
		}
		
		private function drawIntervalLine(pixel:Number):void
		{
			var w:int = 2;
			var g:Graphics = _intervalLines.graphics;
			g.beginFill(_styles.bgColor);
			g.drawRect(Math.round(pixel-w/2), 0, w, _height);
			g.endFill();
		}
		
		private function placeHandle(pct:Number):void
		{
			var pixel:Number = _bg.x + (_bg.width - _handle.width) * pct;
			if (_type == NOTCHED && _snapToValue)
				pixel = _snapToValue.pixel - _handle.width/2;
			_handle.x = pixel;
		}
		
		private function update():void
		{
			_handle.update(_isOver || _isDown);
		}
		
		private function updateProgressDisplay(percent:Number = -1, dispatchChange:Boolean = true):void
		{
			if (percent == -1) // user is dragging the slider
				updateProgressPct();
			else 
				updateProgressPct(percent, dispatchChange); // slider value is set from elsewhere
			
			// update handle
			placeHandle(_pct);
			
			// set display value
			//calculateDisplayValue(value);
		}
		
		private function updateProgressPct(percent:Number = -1, dispatchChange:Boolean = true):void
		{
			if (percent != -1)
				_pct = percent;
			else
				_pct = (mouseX - _bg.x) / (_bg.width - _handle.width);
			
			_pct = (_pct < 0) ? 0 : (_pct > 1) ? 1 : _pct;
			_snapToValue = _snapToData[ getClosetIdx(_pct, _snapToData, "pct", _handle.width/2) ];
			
			calculateValue(_pct);
			
			if (!_isDragging && dispatchChange)
				dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function calculateValue(pct:Number):void
		{
			if (_type == NOTCHED && _snapToValue)
				_value = _snapToValue.value;
			else
				_value = _values.min + (_values.max - _values.min) * _pct; 
			/*
			if (customCalcValue != null)
				value = customCalcValue(pct);
			else
				value = Math.round(_min + pct * (_max - _min));
			*/
		}
		
		private function handleMouseUp(e:MouseEvent):void
		{
			if (_isDown)
			{
				_isDown = false;
				_isDragging = false;
				//_handle.stopDrag();
				if (stage)
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false);
				}
				updateProgressDisplay();
				update();
			}
		}
		
		private function handleMouseMove(e:MouseEvent):void
		{
			if (_isDown)
			{
				_isDragging = true;
				updateProgressDisplay();
			}
		}
		
		private function handleMouseDown(e:MouseEvent):void
		{
			if (!_isDown && stage)
			{
				_isDown = true;
				if (stage)
				{
					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
				}
				//_handle.x = Math.min(mouseX - _handle.width/2, _width - _handle.width);
				//_handle.startDrag(false, _dragBounds);
				updateProgressDisplay();
				update();
			}
		}
		
		private function handleMouseOverOut(e:MouseEvent):void
		{
			_isOver = e.type == MouseEvent.MOUSE_OVER;
			update();
		}
		
		private function getClosetIdx(value:Number, vector:Vector.<Object>, prop:String, buffer:Number = 0):int
		{
			var iMin:int = 0;
			var iMax:int = vector.length - 1;
			var idx:int;
			if ( value < vector[iMin][prop] || value > vector[iMax][prop] ) {
				idx = -1;
				if (value < vector[iMin][prop] && value >= vector[iMin][prop] - buffer)
					idx = iMin;
				else if (value > vector[iMax][prop] && value <= vector[iMax][prop] + buffer)
					idx = iMax;
				return idx;
			}
			
			while( iMax >= iMin ) {
				if (iMax == iMin + 1) {
					idx = this.isCloser(value, vector[iMin][prop], vector[iMax][prop]) ? iMin : iMax
					return idx;
				}
				else {
					var iMid:int = this.midpoint(iMin, iMax);
					if ( value < vector[iMid][prop] )
						iMax = iMid;
					else if ( value > vector[iMid][prop] )
						iMin = iMid;
					else
						return iMid;
				}
			}
			return -1;
		}
		
		private function midpoint(min:int, max:int):Number { return Math.round( min + (max - min) / 2 ); }
		private function isCloser(value:Number, first:Number, second:Number):Boolean { return (Math.abs(value - first) <= Math.abs(value - second)); }
	}
}
import com.jonnybomb.ui.utils.DrawingUtil;

import flash.display.Sprite;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;

/**
 * help class for slider handle
 */
class SliderHandle extends Sprite
{
	private static const DS:DropShadowFilter = new DropShadowFilter(2, 90, 0x000000, 1, 5, 5, 0.35, BitmapFilterQuality.MEDIUM);
	
	private var _up:Sprite;
	private var _over:Sprite;
	private var _bevel:Sprite;
	
	private var _width:int;
	private var _height:int;
	private var _styles:Object;
	
	public function SliderHandle(width:int, height:int, styles:Object)
	{
		_width = width;
		_height = height;
		_styles = styles;
		
		init();
	}
	
	public function init():void
	{
		var ellipse:int = _styles.ellipse;
		
		_up = addChild(new Sprite()) as Sprite;
		DrawingUtil.drawRect(_up, _width, _height, _styles.handle.up, 1, ellipse);
		
		_over = addChild(new Sprite()) as Sprite;
		DrawingUtil.drawRect(_over, _width, _height, _styles.handle.over, 1, ellipse);
		
		_bevel = addChild(new Sprite()) as Sprite;
		DrawingUtil.drawRect(_bevel, _width, _height, _styles.handle.bevel, 0, ellipse);
		_bevel.scrollRect = new Rectangle(0, 0, _width, _height/2);
		
		filters = [DS];
		update(false);
	}
	
	public function update(isOver:Boolean):void
	{
		_up.visible = !isOver;
		_over.visible = !_up.visible;
	}
}