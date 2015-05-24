package com.jonnybomb.mentalmodeler.display
{
	
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controls.LineValueMenuButton;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class LineValueMenuDisplay extends Sprite
	{
		private var _buttons:Vector.<LineValueMenuButton> = new Vector.<LineValueMenuButton>();
		private var _controller:CMapController;
		
		private var _height:Number;
		override public function get height():Number { return _height; }
		
		public function LineValueMenuDisplay(controller:CMapController)
		{
			visible = false;
			_controller = controller;
			init();
		}
		
		public function show(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
			visible = true;
			
			if (stage)
				stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
		}
		
		public function hide():void
		{
			visible = false;
			
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		private function init():void
		{
			build();
			layout();
		}
		
		private function handleMouseDown(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			e.preventDefault();
			
			if (e.target is UIButton && (e.target as DisplayObject).parent is LineValueMenuButton)
			{
				var lvmb:LineValueMenuButton = LineValueMenuButton((e.target as DisplayObject).parent)
				_controller.lineValue = lvmb.value;
			}
			
			hide();
		}
		
		private function build():void
		{
			var lvd:LineValueData;
			var options:Vector.<LineValueData> = CMapConstants.LINE_VALUES;
			var button:LineValueMenuButton;
			var len:int = options.length;
			for each (lvd in options)
			{
				button = addChild(new LineValueMenuButton(lvd, options.indexOf(lvd), len + 1)) as LineValueMenuButton;
				_buttons.push(button);
			}
			
			button = addChild(new LineValueMenuButton(new LineValueData(CMapConstants.INFLUENCE_STRING_VALUE_NULL, LineValueData.REMOVE_VALUE, CMapConstants.LINE_VALUE_REMOVE_LABEL), len, len + 1)) as LineValueMenuButton;
			_buttons.push(button);
		}
		
		private function layout():void
		{
			var h:int = CMapConstants.LINE_VALUE_HEIGHT;
			var nY:int = h/2;
			var border:int = CMapConstants.LINE_VALUE_BORDER;
			var button:LineValueMenuButton
			for each (button in _buttons)
			{
				button.y = nY;
				nY += h - border;
			}
			
			_height = nY + h/2
		}
		
		public function finalize():void
		{
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			for each (var button:LineValueMenuButton in _buttons)
			DisplayObjectUtil.finalizeAndRemove(button);
			
			_buttons = null
			_controller = null;
		}
	}
}