package com.jonnybomb.ui.components.radiobutton
{
	import com.jonnybomb.ui.UI;
	import com.jonnybomb.ui.utils.DisplayObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;

	/**
	 * @author DCD - Jonathan Elbom
	 */
	
	public class RadioButton extends Sprite
	{
		private static const GLOSS:BevelFilter = new BevelFilter(5, 90, 0xFFFFFF, 1, 0xFFFFFF, 1, 10, 10, 1.75, BitmapFilterQuality.MEDIUM, BitmapFilterType.INNER, true);
		private static const DS:DropShadowFilter = new DropShadowFilter(1, 90, 0x000000, 1, 3, 3, 0.59, BitmapFilterQuality.LOW);
		
		private var _radius:int = 7;
		private var _outlineColor:uint = 0x000000;
		private var _upColor:uint = 0xCCCCCC; //0xC1C1C1;
		private var _overColor:uint = 0xE53E29; //0x83A603; //0xE17138;
		private var _dotSpacingHorz:int = 5;
		
		private var _holder:Sprite;
		private var _overFill:Shape;
		private var _selectedIcon:Shape;
		private var _hitHelper:Shape;
		
		private var _data:RadioButtonData;
		private var _group:RadioButtonGroup;
		private var _selected:Boolean;
		private var _contentRenderer:IRadioButtonContentRenderer;
		
		public function RadioButton(data:RadioButtonData, ContentRenderer:Class, group:RadioButtonGroup, dotSpacingHorz:int = -9999)
		{
			_data = data;
			_group = group;
			
			_contentRenderer = new ContentRenderer() as IRadioButtonContentRenderer;
			if (_contentRenderer == null)
				_contentRenderer = new DefaultRadioButtonContentRenderer() as IRadioButtonContentRenderer;
			
			if (dotSpacingHorz != -9999)
				_dotSpacingHorz = dotSpacingHorz;
				
			//mouseChildren = false;
			init();	
		}
		
		public function update(data:Object):void { _contentRenderer.update(data); }
		
		public function get value():Object { return _data.value; }
		
		public function finalize():void
		{
			enabled = false;
			_data.finalize();
			
			while (_holder.numChildren > 0)
				DisplayObjectUtil.remove(_holder.getChildAt(0));
			DisplayObjectUtil.remove(_holder);
			DisplayObjectUtil.finalizeAndRemove(_contentRenderer as DisplayObject);
			while (numChildren > 0)
				DisplayObjectUtil.remove(getChildAt(0));
			
			_contentRenderer = null;
			_holder = null;
			_overFill = null;
			_selectedIcon = null;
			_data = null;
			_group = null;
		}
		
		private function init():void
		{
			_selected = _data.selected;
			
			drawButton();
			
			renderContent();
			positionContent();
			
			_hitHelper = addChildAt(new Shape(), 0) as Shape;
			setHitHelperWidth();
			
			if (_selected)
				_group.selectItem(this);
			else
				enabled = true;
		}
		
		public function set selected(value:Boolean):void
		{
			enabled = !value;
			_selectedIcon.visible = value;
			
			if (value)
				updateDisplay(false);
		}
		
		public function set enabled(value:Boolean):void
		{
			buttonMode = value;
			mouseEnabled = value;
			
			if (value)
			{
				addEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false, 0, true);
				addEventListener(MouseEvent.CLICK, handleMouseClick, false, 0, true);
			}
			else
			{
				removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false);
				removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false);
				removeEventListener(MouseEvent.CLICK, handleMouseClick, false);
			}
		}
		
		public function setHitHelperWidth(value:Number = -1):void
		{
			value = Math.round(value);
			var cr:DisplayObject = DisplayObject(_contentRenderer);
			var tallest:DisplayObject = (_holder.height > cr.height) ? _holder : cr;
			var h:int = tallest.height;
			var w:int = cr.x + cr.width;
			var g:Graphics = _hitHelper.graphics;
			g.clear();
			g.beginFill(0x00ff00, 0);
			if (value > -1) 
				g.drawRect(0, 0, value, h);
			else	
				g.drawRect(0, 0, w, h);
			g.endFill();
		}
		
		private function renderContent():void
		{
			var w:int  = _data.totalWidth - (_holder.width + _dotSpacingHorz);
			_contentRenderer.build(_data.contentRendererData, w);
			addChild(_contentRenderer as DisplayObject);
		}
		
		private function positionContent():void
		{
			DisplayObject(_contentRenderer).x = Math.round(_radius * 2 + _dotSpacingHorz);
			DisplayObject(_contentRenderer).y = Math.round( (_holder.height - DisplayObject(_contentRenderer).height) / 2 );
		}
		
		private function drawButton():void
		{
			_holder = addChild(new Sprite()) as Sprite;
			
			var x:Number = _radius;
			var y:Number = _radius;
			
			var s:Shape = _holder.addChild(new Shape()) as Shape;
			var g:Graphics = s.graphics;
			g.beginFill(_outlineColor, 1);
			g.drawCircle(x, y, _radius);
			g.endFill();
			s.filters = [DS];
			
			s = _holder.addChild(new Shape()) as Shape;
			g = s.graphics;
			g.beginFill(_upColor, 1);
			g.drawCircle(x, y, _radius - 1);
			g.endFill();
			
			_overFill = _holder.addChild(new Shape()) as Shape;
			_overFill.visible = false;
			g = _overFill.graphics;
			g.beginFill(_overColor, 1);
			g.drawCircle(x, y, _radius - 1);
			g.endFill();
			
			s = _holder.addChild(new Shape()) as Shape;
			g = s.graphics;
			g.beginFill(0x000000, 1);
			g.drawCircle(x, y, _radius - 1);
			g.endFill();
			s.filters = [GLOSS];
			
			_selectedIcon = _holder.addChild(new Shape()) as Shape;
			_selectedIcon.visible = false;
			g = _selectedIcon.graphics;
			g.beginFill(_outlineColor, 1);
			g.drawCircle(x, y, int(_radius/2));
			g.endFill();
		}
		
		private function handleMouseClick(event:MouseEvent):void
		{
			_group.selectItem(this);
		}
		
		private function handleMouseOverOut(event:MouseEvent):void
		{
			updateDisplay(event.type == MouseEvent.MOUSE_OVER);
		}
		
		private function updateDisplay(over:Boolean):void
		{
			_overFill.visible = over;
		}
	}
}