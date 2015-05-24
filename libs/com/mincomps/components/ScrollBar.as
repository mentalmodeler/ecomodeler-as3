/**
 * ScrollBar.as
 * Keith Peters
 * version 0.9.5
 * 
 * Base class for HScrollBar and VScrollBar
 * 
 * Copyright (c) 2010 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.mincomps.components
{
	import com.jonnybomb.mentalmodeler.utils.visual.TintUtil;
	import com.mincomps.data.MinCompsColorData;
	import com.mincomps.data.MinCompsColorExtended;
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.utils.Timer;

	public class ScrollBar extends Component
	{
		protected const DELAY_TIME:int = 500;
		protected const REPEAT_TIME:int = 100; 
		protected const UP:String = "up";
		protected const DOWN:String = "down";

        protected var _autoHide:Boolean = false;
		protected var _autoDisable:Boolean = false;
		protected var _upButton:PushButton;
		protected var _downButton:PushButton;
		protected var _scrollSlider:ScrollSlider;
		protected var _orientation:String;
		protected var _lineSize:int = 1;
		protected var _delayTimer:Timer;
		protected var _repeatTimer:Timer;
		protected var _direction:String;
		protected var _shouldRepeat:Boolean = false;
		
		protected var _hide:Boolean = false;
		public function set hide(value:Boolean):void { _hide = value; }
		public function get hide():Boolean { return _hide; }
		
		/**
		 * Constructor
		 * @param orientation Whether this is a vertical or horizontal slider.
		 * @param parent The parent DisplayObjectContainer on which to add this Slider.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function ScrollBar(orientation:String, parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function = null)
		{
			_orientation = orientation;
			super(parent, xpos, ypos);
			if(defaultHandler != null)
			{
				addEventListener(Event.CHANGE, defaultHandler);
			}
			this.visible = false;
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void
		{
			var size:int = MinCompsScrollBarConstants.SIZE;
			var pos:Number = size * 0.5;
			pos = (pos % 1) ? int(pos + 0.5) : pos;
			
			_scrollSlider = new ScrollSlider(_orientation, this, 0, 10, onChange);
			_upButton = new PushButton(this, 0, 0, "", null, _orientation);
			_upButton.hasDropShadow = false;
			_upButton.addEventListener(MouseEvent.MOUSE_DOWN, onUpClick);
			_upButton.setSize(size, size);
			var upArrow:Shape = drawArrow(new Shape());
			upArrow.x = upArrow.y = pos;
			_upButton.addChild(upArrow);
			
			_downButton = new PushButton(this, 0, 0, "", null,  _orientation);
			_downButton.hasDropShadow = false;
			_downButton.addEventListener(MouseEvent.MOUSE_DOWN, onDownClick);
			_downButton.setSize(size, size);
			var downArrow:Shape = drawArrow(new Shape());
			downArrow.x = downArrow.y = pos;
			_downButton.addChild(downArrow);
			
			if(_orientation == Slider.VERTICAL)
			{
				upArrow.rotation = 0;
				downArrow.rotation = 180;
			}
			else
			{
				upArrow.rotation = 270;
				downArrow.rotation = 90;
			}
		}
		
		private function drawArrow(arrow:Shape):Shape
		{
			var side:int = int(MinCompsScrollBarConstants.SIZE * 0.22 + 0.5);
			var color:uint = (MinCompsColorData.getColor(MinCompsColorData.TN_75_SCROLLBAR_ARROW).fill as MinCompsColorExtended).color;
			arrow.graphics.beginFill(color);
			arrow.graphics.moveTo(0, -side);
			arrow.graphics.lineTo(-side, side);
			arrow.graphics.lineTo(side, side);
			arrow.graphics.lineTo(0, -side);
			arrow.graphics.endFill();
			arrow.filters = [MinCompsScrollBarConstants.INSET_BEVEL];
			return arrow;
		}
		
		/**
		 * Initializes the component.
		 */
		protected override function init():void
		{
			super.init();
			
			if(_orientation == Slider.HORIZONTAL)
				setSize(100, MinCompsScrollBarConstants.SIZE);
			else
				setSize(MinCompsScrollBarConstants.SIZE, 100);
		
			_delayTimer = new Timer(DELAY_TIME, 1);
			_delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayComplete);
			_repeatTimer = new Timer(REPEAT_TIME);
			_repeatTimer.addEventListener(TimerEvent.TIMER, onRepeat);
		}
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Convenience method to set the three main parameters in one shot.
		 * @param min The minimum value of the slider.
		 * @param max The maximum value of the slider.
		 * @param value The value of the slider.
		 */
		public function setSliderParams(min:Number, max:Number, value:Number):void
		{
			_scrollSlider.setSliderParams(min, max, value);
		}
		
		/**
		 * Sets the percentage of the size of the thumb button.
		 */
		public function setThumbPercent(value:Number):void
		{
			_scrollSlider.setThumbPercent(value);
		}
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();
			var size:int = MinCompsScrollBarConstants.SIZE;
			if(_orientation == Slider.VERTICAL)
			{
				_scrollSlider.x = 0;
				_scrollSlider.y = size;
				_scrollSlider.width = size;
				_scrollSlider.height = _height - size * 2;
				_downButton.x = 0;
				_downButton.y = _height - size;
			}
			else
			{
				_scrollSlider.x = size;
				_scrollSlider.y = 0;
				_scrollSlider.width = _width - size * 2;
				_scrollSlider.height = _height;
				_downButton.x = _width - size;
				_downButton.y = 0;
			}
			
			_scrollSlider.draw();
			
			//if (_orientation == Slider.VERTICAL) trace("Vertical  ScrollBar >> draw\n\t_scrollSlider.thumbPercent:"+_scrollSlider.thumbPercent)
			
			if (_hide)
				visible = false;
			else if (_autoHide)
				visible = _scrollSlider.thumbPercent < 1.0;
			else if (_autoDisable)
			{
				visible = true;
				if (_scrollSlider.thumbPercent < 1.0) // show the scrollbars
					TintUtil.removeTint(this);
				else // tint them to hide them
					TintUtil.tint(this, 0xe6e6e6);
			}
			else
				visible = true;
			
		}
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////

        /**
         * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
         */
        public function set autoHide(value:Boolean):void
        {
            _autoHide = value;
            invalidate();
        }
        public function get autoHide():Boolean
        {
            return _autoHide;
        }

		/**
		 * Sets / gets whether the scrollbar will auto disable when there is nothing to scroll.
		 */
		public function set autoDisable(value:Boolean):void
		{
			_autoDisable = value;
			invalidate();
		}
		public function get autoDisable():Boolean
		{
			return _autoDisable;
		}
		
		/**
		 * Sets / gets the current value of this scroll bar.
		 */
		public function set value(v:Number):void
		{
			_scrollSlider.value = v;
		}
		public function get value():Number
		{
			return _scrollSlider.value;
		}
		
		/**
		 * Sets / gets the minimum value of this scroll bar.
		 */
		public function set minimum(v:Number):void
		{
			_scrollSlider.minimum = v;
		}
		public function get minimum():Number
		{
			return _scrollSlider.minimum;
		}
		
		/**
		 * Sets / gets the maximum value of this scroll bar.
		 */
		public function set maximum(v:Number):void
		{
			_scrollSlider.maximum = v;
		}
		public function get maximum():Number
		{
			return _scrollSlider.maximum;
		}
		
		/**
		 * Sets / gets the amount the value will change when up or down buttons are pressed.
		 */
		public function set lineSize(value:int):void
		{
			_lineSize = value;
		}
		public function get lineSize():int
		{
			return _lineSize;
		}
		
		/**
		 * Sets / gets the amount the value will change when the back is clicked.
		 */
		public function set pageSize(value:int):void
		{
			_scrollSlider.pageSize = value;
			invalidate();
		}
		public function get pageSize():int
		{
			return _scrollSlider.pageSize;
		}
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		protected function onUpClick(event:MouseEvent):void
		{
			goUp();
			_shouldRepeat = true;
			_direction = UP;
			_delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
				
		protected function goUp():void
		{
			_scrollSlider.value -= _lineSize;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onDownClick(event:MouseEvent):void
		{
			goDown();
			_shouldRepeat = true;
			_direction = DOWN;
			_delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
		
		protected function goDown():void
		{
			_scrollSlider.value += _lineSize;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onMouseGoUp(event:MouseEvent):void
		{
			_delayTimer.stop();
			_repeatTimer.stop();
			_shouldRepeat = false;
		}
		
		protected function onChange(event:Event):void
		{
			dispatchEvent(event);
		}
		
		protected function onDelayComplete(event:TimerEvent):void
		{
			if(_shouldRepeat)
			{
				_repeatTimer.start();
			}
		}
		
		protected function onRepeat(event:TimerEvent):void
		{
			if(_direction == UP)
			{
				goUp();
			}
			else
			{
				goDown();
			}
		}
	}
}

import com.mincomps.components.Component;
import com.mincomps.components.Slider;
import com.mincomps.components.Style;
import com.mincomps.data.MinCompsColorData;
import com.mincomps.data.MinCompsColorExtended;
import com.mincomps.data.MinCompsGradientColorData;
import com.mincomps.data.MinCompsScrollBarConstants;
import com.mincomps.utils.MinCompsDrawingUtil;

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;

/**
 * Helper class for the slider portion of the scroll bar.
 */
class ScrollSlider extends Slider
{
	protected var _thumbPercent:Number = 1.0;
	protected var _pageSize:int = 1;
	
	protected var _handleFace:Sprite;
	protected var _handleColorData:MinCompsColorData;
	protected var _handleDrawn:Boolean = false;
	protected var _backFill:Shape;
	protected var _backFace:Shape;
	protected var _backColorData:MinCompsColorData;
	protected var _backDrawn:Boolean = false;
	
	/**
	 * Constructor
	 * @param orientation Whether this is a vertical or horizontal slider.
	 * @param parent The parent DisplayObjectContainer on which to add this Slider.
	 * @param xpos The x position to place this component.
	 * @param ypos The y position to place this component.
	 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
	 */
	public function ScrollSlider(orientation:String, parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function = null)
	{
		_backColorData = MinCompsColorData.getColor(MinCompsColorData.TN_75_SCROLLBAR_TRACK);
		_handleColorData = MinCompsColorData.getColor(MinCompsColorData.TN_75_SCROLLBAR_THUMB);
		
		super(orientation, parent, xpos, ypos);
		if(defaultHandler != null)
		{
			addEventListener(Event.CHANGE, defaultHandler);
		}
	}
	
	/**
	 * Initializes the component.
	 */
	protected override function init():void
	{
		super.init();
		setSliderParams(1, 1, 0);
		backClick = true;
	}
	
	/**
	 * Draws the handle of the slider.
	 */
	override protected function drawHandle() : void
	{
		var size:Number;
		if(_orientation == HORIZONTAL)
		{
			size = Math.round(_width * _thumbPercent);
			size = Math.max(_height, size);
		}
		else
		{
			size = Math.round(_height * _thumbPercent);
			size = Math.max(_width, size);
		}
		
		if (!_handleDrawn)
		{
			_handleDrawn = true;
			
			if (_handleFill == null)
				_handleFill = _handle.addChild(new Sprite()) as Sprite;
			
			if (_handleFace == null)
				_handleFace = _handle.addChild(new Sprite()) as Sprite;
			
			var cd:MinCompsColorData = _handleColorData;
			if(_orientation == HORIZONTAL)
			{
				MinCompsGradientColorData(cd.fill).rotation = 90;
				MinCompsDrawingUtil.drawRect(_handleFill, size, _height, cd, 1);
				MinCompsDrawingUtil.drawRect(_handleFace, size - 2, _height - 2, cd, 0);
			}
			else
			{
				MinCompsDrawingUtil.drawRect(_handleFill, _width, size, cd, 1);
				MinCompsDrawingUtil.drawRect(_handleFace, _width - 2, size - 2, cd, 0);
			}
			
			_handleFace.x = 1;
			_handleFace.y = 1;
			_handleFace.filters = [MinCompsScrollBarConstants.INNER_GLOW];
			_handle.filters = [];
		}
		else
		{
			if(_orientation == HORIZONTAL)
			{
				_handleFill.width = size;
				_handleFill.height = _height
				_handleFace.width = size - 2;
				_handleFace.height = _height - 2;
			}
			else
			{
				_handleFill.width = _width;
				_handleFill.height = size
				_handleFace.width = _width - 2;
				_handleFace.height = size - 2;
			}
		}
		
		positionHandle();
	}
	
	/**
	 * Draws the back of the slider.
	 */
	override protected function drawBack():void
	{
		var stroke:int = 1;
		if (!_backDrawn)
		{
			_backDrawn = true;
			
			var cd:MinCompsColorData = _backColorData;
			var g:Graphics;
			
			if (_backFill == null)
				_backFill = _back.addChild(new Shape()) as Shape;
			
			g = _backFill.graphics;
			g.beginFill(MinCompsColorExtended(cd.stroke).color, 1);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			
			if (_backFace == null)
				_backFace = _back.addChild(new Shape()) as Shape;
			
			g = _backFace.graphics;
			g.beginFill(MinCompsColorExtended(cd.fill).color, 1);
			g.drawRect(0, 0, _width - stroke * 2, _height);
			g.endFill();
			_backFace.x = 1;
			_backFace.filters = [MinCompsScrollBarConstants.TRACK_DROP_SHADOW];
			_back.filters = [];
		}
		else
		{
			_backFill.width = _width;
			_backFill.height = _height;
			_backFace.width = _width - stroke * 2;
			_backFace.height = _height;
		}
		
		if(_backClick)
			_back.addEventListener(MouseEvent.MOUSE_DOWN, onBackClick);
		else
			_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBackClick);
	}

	/**
	 * Adjusts position of handle when value, maximum or minimum have changed.
	 * TODO: Should also be called when slider is resized.
	 */
	protected override function positionHandle():void
	{
		var range:Number;
		if(_orientation == HORIZONTAL)
		{
			range = width - _handle.width;
			_handle.x = (_value - _min) / (_max - _min) * range;
		}
		else
		{
			range = height - _handle.height;
			_handle.y = (_value - _min) / (_max - _min) * range;
		}
	}
	
	///////////////////////////////////
	// public methods
	///////////////////////////////////
	
	/**
	 * Sets the percentage of the size of the thumb button.
	 */
	public function setThumbPercent(value:Number):void
	{
		_thumbPercent = Math.min(value, 1.0);
		invalidate();
	}
	
	///////////////////////////////////
	// event handlers
	///////////////////////////////////
	
	/**
	 * Handler called when user clicks the background of the slider, causing the handle to move to that point. Only active if backClick is true.
	 * @param event The MouseEvent passed by the system.
	 */
	protected override function onBackClick(event:MouseEvent):void
	{
		if(_orientation == HORIZONTAL)
		{
			if(mouseX < _handle.x)
			{
				if(_max > _min)
					_value -= _pageSize;
				else
					_value += _pageSize;
				
				correctValue();
			}
			else
			{
				if(_max > _min)
					_value += _pageSize;
				else
					_value -= _pageSize;
				
				correctValue();
			}
			positionHandle();
		}
		else
		{
			if(mouseY < _handle.y)
			{
				if(_max > _min)
					_value -= _pageSize;
				else
					_value += _pageSize;
			
				correctValue();
			}
			else
			{
				if(_max > _min)
					_value += _pageSize;
				else
					_value -= _pageSize;
				
				correctValue();
			}
			positionHandle();
		}
		dispatchEvent(new Event(Event.CHANGE));
		
	}
	
	/**
	 * Internal mouseDown handler. Starts dragging the handle.
	 * @param event The MouseEvent passed by the system.
	 */
	protected override function onDrag(event:MouseEvent):void
	{
		stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onSlide);
		if(_orientation == HORIZONTAL)
			_handle.startDrag(false, new Rectangle(0, 0, _width - _handle.width, 0));
		else
			_handle.startDrag(false, new Rectangle(0, 0, 0, _height - _handle.height));
	}
	
	/**
	 * Internal mouseMove handler for when the handle is being moved.
	 * @param event The MouseEvent passed by the system.
	 */
	protected override function onSlide(event:MouseEvent):void
	{
		var oldValue:Number = _value;
		if(_orientation == HORIZONTAL)
		{
			if(_width == _handle.width)
				_value = _min;
			else
				_value = _handle.x / (_width - _handle.width) * (_max - _min) + _min;
		}
		else
		{
			if(_height == _handle.height)
				_value = _min;
			else
				_value = _handle.y / (_height - _handle.height) * (_max - _min) + _min;
		}
		
		if(_value != oldValue)
			dispatchEvent(new Event(Event.CHANGE));
	}
	
	///////////////////////////////////
	// getter/setters
	///////////////////////////////////
		
	/**
	 * Sets / gets the amount the value will change when the back is clicked.
	 */
	public function set pageSize(value:int):void
	{
		_pageSize = value;
		invalidate();
	}
	public function get pageSize():int { return _pageSize; }
    public function get thumbPercent():Number { return _thumbPercent; }
}
