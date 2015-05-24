package com.mincomps.components
{
	import com.mincomps.components.Component;
	import com.mincomps.components.HScrollBar;
	import com.mincomps.components.ScrollBar;
	import com.mincomps.components.ScrollPane;
	import com.mincomps.components.Slider;
	import com.mincomps.components.Style;
	import com.mincomps.components.VScrollBar;
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	
	public class ScrollPanel extends ScrollPane
	{
		public static const BG_MOUSE_DOWN:String = "bgMouseDown"
		private static const SCROLL_DELTA:int = 20;
		
		private var _origWidth:Number;
		private var _origHeight:Number;
		private var _disableScrollbars:Boolean = false;
		private var _exShadow:Boolean = true;
		private var _dropShadow:DropShadowFilter = null;
		private var _borderThickness:Number = 2;
		private var _applyDropShadow:Boolean = false;
		private var _normalShadow:DropShadowFilter = null;
		
		private var _autoVScroll:Boolean = false;
		
		public function ScrollPanel(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			/*_shadow = false;*/
			_normalShadow = getShadow(2, true);
			_dropShadow = new DropShadowFilter();
			super(parent, xpos, ypos);		
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel );
			
			mouseEnabled = false;
			_background.mouseEnabled = false;
			//content.mouseEnabled = false;
		}

		public function get vScrollBarWidth():Number { return _vScrollbar.width; }
		public function get hScrollBarHeight():Number { return _hScrollbar.height; }
		public function get vScrollBar():VScrollBar { return _vScrollbar; }
		public function get hScrollBar():HScrollBar { return _hScrollbar; }
		
		public function set hideHScrollbar(value:Boolean):void { _hScrollbar.hide = value; update();}
		public function set hideVScrollbar(value:Boolean):void { _vScrollbar.hide = value; update();}
		public function set autoHideHScrollbar(value:Boolean):void { _hScrollbar.autoHide = value; update();}
		public function set autoHideVScrollbar(value:Boolean):void { _vScrollbar.autoHide = value; update();}
		public function set autoVScroll(value:Boolean):void { _autoVScroll = value;}
		
		public function set vScroll(value:Number):void { _vScrollbar.value = value; }
		public function get vScroll():Number { return _vScrollbar.value }
		public function set hScroll(value:Number):void { _hScrollbar.value = value; }
		public function get hScroll():Number { return _hScrollbar.value }
		
		public function set autoDisable(value:Boolean):void
		{ 
			_hScrollbar.autoDisable = value;
			_vScrollbar.autoDisable = value;
			update();
		}
		
		public function getScrollMinMax(type:String):Object
		{
			return (type == Slider.VERTICAL) ? {min:_vScrollbar.minimum, max:_vScrollbar.maximum} : {min:_hScrollbar.minimum, max:_hScrollbar.maximum}; 
		}
		
		public function disableScrollBars():void
		{
			this.removeChild(_hScrollbar);
			this.removeChild(_vScrollbar);
			this.removeChild(_corner);

			_hScrollbar.visible = false;
			_vScrollbar.visible = false;
			_corner.visible = false;
			_disableScrollbars = true;
		}
		
		/*
		public function scrollTo(value:Number):void
		{
			_vScrollbar.value = value;
		}

		public function scrollPosition():Number
		{
			return _vScrollbar.value;
		}
		*/
		protected function onMouseWheel(event:MouseEvent):void
		{
			_vScrollbar.value -= event.delta * 3;
			onScroll(null);
		}
		
		override protected function onScroll(event:Event):void
		{
			super.onScroll(event);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		override protected function addChildren():void
		{
			super.addChildren();
			filters = [/*_normalShadow,*/_dropShadow];
			// increasing the line size of the vertical scroll bar to make it scroll faster.
			_vScrollbar.lineSize = SCROLL_DELTA;
			_hScrollbar.lineSize = SCROLL_DELTA;
			// filters = [];
		}

		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();
			_background.graphics.clear();
			
			/*
			if(isNaN(_borderThickness))
				_borderThickness = 2;
			_background.graphics.lineStyle(_borderThickness, 0, 0);
			*/
			
			if (_color == -1)
				_color = Style.PANEL;
			
			_background.graphics.beginFill(0xff0000, 0);//_color, 0);
			_background.graphics.drawRect(0, 0, _width, _height);
			_background.graphics.endFill();
			
			//_background.mouseEnabled = true;
			_background.buttonMode = false;
			_background.removeEventListener(MouseEvent.MOUSE_DOWN, handleBgMouseDown, false);
			//_background.addEventListener(MouseEvent.MOUSE_DOWN, handleBgMouseDown, false, 0, true);
			
			// drawGrid();
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000);
			_mask.graphics.drawRect(0, 0, _width, _height);
			_mask.graphics.endFill();
			_mask.mouseEnabled = false;
			
			if (_applyDropShadow)
			{
				var arr:Array = new Array();
				//arr.push(_normalShadow);
				if (_exShadow)
					arr.push(_dropShadow);  
				filters = arr;
				_applyDropShadow = false;
			}
			
			if ( _disableScrollbars )
			{
				//content.y -= 2.5;
			}
			
			if (_autoVScroll && vScroll < content.height - _height)
				vScroll = content.height - _height
		}
		
		private function handleBgMouseDown(e:MouseEvent):void
		{
			e.preventDefault();
			e.stopImmediatePropagation();
			dispatchEvent(new Event(BG_MOUSE_DOWN));
		}
		
		public function set borderThickness(value:Number):void
		{
			_borderThickness = value;
			invalidate();
		}

		public function set externalDropShadow(value:Boolean):void
		{
			_exShadow = value;
			_applyDropShadow = true;
			invalidate();
		}

		/**
		 * Sets the size of the scroll panel. If you are going to disable the scroll bars, make
		 * sure you call this after you disable them.
		 * 
		 * @param	w
		 * @param	h
		 */
		/*
		override public function setSize(w:Number, h:Number):void
		{
			_origWidth = w;
			_origHeight = h;
			if (!isNaN(h) && !isNaN(w))
			{
				// This is to deal with DE33865. When we changed the sizes of the scroll bars 
				// we changed the sizes of all the fill in and grid in items since these sizes
				// are partially based on that size (old size was 10, new size=15)
				
				if ( _disableScrollbars )
					super.setSize(w + 10, h + 10 );
				else
					super.setSize(w + _vScrollbar.width, h + _hScrollbar.height);
			}
		}
		*/
	}

}