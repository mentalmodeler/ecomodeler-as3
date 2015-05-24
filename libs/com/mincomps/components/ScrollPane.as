/**
 * ScrollPane.as
 * Keith Peters
 * version 0.9.5
 * 
 * A panel with scroll bars for scrolling content that is larger.
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
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ScrollPane extends Panel
	{
		protected var _vScrollbar:VScrollBar;
		protected var _hScrollbar:HScrollBar;
		protected var _corner:Sprite; //Shape;
		protected var _dragContent:Boolean = true;
		protected var _scrollbarSize:int = MinCompsScrollBarConstants.SIZE;
		
		public function get vScrollMaximum():Number { return _vScrollbar.maximum; }
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this ScrollPane.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 */
		public function ScrollPane(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		/**
		 * Initializes this component.
		 */
		override protected function init():void
		{
			super.init();
			addEventListener(Event.RESIZE, onResize);
			// Disabling drag functionality on the scroll pane container itself.
			//_background.addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
			_background.useHandCursor = true;
			_background.buttonMode = true;
			setSize(100, 100);
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void
		{
			super.addChildren();
			_vScrollbar = new VScrollBar(this, width - _scrollbarSize, 0, onScroll);
			_hScrollbar = new HScrollBar(this, 0, height - _scrollbarSize, onScroll);
			_corner = new Sprite(); //Shape();
			_corner.graphics.beginFill(0xCCCCCC/*0x4C4C4CStyle.BUTTON_FACE*/);
			_corner.graphics.drawRect(0, 0, _scrollbarSize, _scrollbarSize);
			_corner.graphics.endFill();
			addChild(_corner);
			
			content.mouseEnabled = false;
			//_background.mouseEnabled = false;
		}
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();
			_vScrollbar.x = width - _scrollbarSize;
			_hScrollbar.y = height - _scrollbarSize;
			_hScrollbar.width = width - _scrollbarSize;
			
			// Auto turn on and off the corner graphic and reset the size of the scrollbars - JMV (10/05/2010)
			if (_hScrollbar.visible) {
				if (_vScrollbar.visible) {
					_corner.visible = true;
					_vScrollbar.height = height - _scrollbarSize;
					_hScrollbar.width = width - _scrollbarSize;
				} else { 
					_corner.visible = false;
					_hScrollbar.width = width;
				}
			} else {
				_corner.visible = false;
				_vScrollbar.height = height;
			}
			
			//trace("ScrollPane >> draw\n\t_height:"+_height+", getScrollbarSize():"+getScrollbarSize()+", content.height:"+content.height+", content.width:"+content.width);
			_vScrollbar.setThumbPercent((_height - getScrollbarSize()) / content.height);
			_vScrollbar.maximum = Math.max(0, content.height - _height + getScrollbarSize());
			_vScrollbar.pageSize = _height - getScrollbarSize();
			
			_hScrollbar.setThumbPercent((_width - getScrollbarSize(Slider.HORIZONTAL)) / content.width);
			_hScrollbar.maximum = Math.max(0, content.width - _width + getScrollbarSize(Slider.HORIZONTAL));
			_hScrollbar.pageSize = _width - getScrollbarSize(Slider.HORIZONTAL);
			
			_corner.x = width - _scrollbarSize;
			_corner.y = height - _scrollbarSize;
			content.x = -_hScrollbar.value;
			content.y = -_vScrollbar.value;
		}
		
		private function getScrollbarSize(type:String = Slider.VERTICAL):Number
		{
			var size:Number = 0;
			if (type == Slider.HORIZONTAL)
			{
				if (!_vScrollbar.hide && _vScrollbar.visible)
					size = _scrollbarSize;	
			}
			else
			{
				if (!_hScrollbar.hide && _hScrollbar.visible)
					size = _scrollbarSize;
			}
			return size;
		}
		
		/**
		 * Updates the scrollbars when content is changed. Needs to be done manually.
		 */
		public function update():void
		{
			invalidate();
		}
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Called when either scroll bar is scrolled.
		 */
		protected function onScroll(event:Event):void
		{
			content.x = -_hScrollbar.value;
			content.y = -_vScrollbar.value;
		}
		
		protected function onResize(event:Event):void
		{
			invalidate();
		}
		
		protected function onMouseGoDown(event:MouseEvent):void
		{
			content.startDrag(false, new Rectangle(0, 0, Math.min(0, _width - content.width - _scrollbarSize), Math.min(0, _height - content.height - _scrollbarSize)));
			var container:Sprite = this;
			if (this.parent)
				container = Sprite(content.parent);
				
			// Disabling drag functionality on the scroll pane container itself.
			//container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			//container.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			_hScrollbar.value = -content.x;
			_vScrollbar.value = -content.y;
		}
		
		protected function onMouseGoUp(event:MouseEvent):void
		{
			content.stopDrag();
			var container:Sprite = this;
			if (this.parent)
				container = Sprite(content.parent);
				
			// Disabling drag functionality on the scroll pane container itself.
			//container.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			//container.removeEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}

		public function set dragContent(value:Boolean):void
		{
			_dragContent = value;
			if(_dragContent)
			{
				// Disabling drag functionality on the scroll pane container itself.
				//_background.addEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
				_background.useHandCursor = true;
				_background.buttonMode = true;
			}
			else
			{
				// Disabling drag functionality on the scroll pane container itself.
				//_background.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseGoDown);
				_background.useHandCursor = false;
				_background.buttonMode = false;
			}
		}
		public function get dragContent():Boolean
		{
			return _dragContent;
		}

        /**
         * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
         */
        public function set autoHideScrollBar(value:Boolean):void
        {
            _vScrollbar.autoHide = value;
            _hScrollbar.autoHide = value;
        }
        public function get autoHideScrollBar():Boolean
        {
            return _vScrollbar.autoHide;
        }
	}
}