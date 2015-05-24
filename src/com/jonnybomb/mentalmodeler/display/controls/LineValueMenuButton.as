package com.jonnybomb.mentalmodeler.display.controls
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class LineValueMenuButton extends Sprite
	{
		private var _title:TextField;
		private var _isOver:Boolean = false;
		private var _isDown:Boolean = false;
		private var _isSelected:Boolean = false;
		private var _isRemove:Boolean = false;
		private var _idx:int;
		private var _total:int;
		private var _value:LineValueData;
		
		private var _uiButton:UIButton;
		
		public function get idx():int{ return _idx; }
		public function get value():LineValueData { return _value; }
		
		public function LineValueMenuButton(lvd:LineValueData/*value:String*/, idx:int, total:int)
		{
			mouseEnabled = true;
			buttonMode = false;
			
			_value = lvd;
			_idx = idx;
			_total = total - 1;
			
			init();
		}
		
		public function finalize():void
		{
			DisplayObjectUtil.remove(_title);
			DisplayObjectUtil.finalizeAndRemove(_uiButton);
			
			_title = null;
			_uiButton = null;
		}
		
		public function setAsSelected(value:Boolean):void
		{
			_isSelected = true;
			//draw();
		}
		
		private function init():void
		{
			_isRemove = value.label == CMapConstants.LINE_VALUE_REMOVE_LABEL;
			
			draw();
			
			// add label
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "VerdanaEmbedded";
			textFormat.size = _isRemove ? 10 : 16;
			textFormat.letterSpacing = 0;
			textFormat.color = _isRemove ? CMapConstants.LINE_VALUE_FILL : CMapConstants.LINE_VALUE_TEXT;
			
			_title = addChild(new TextField()) as TextField;
			_title.defaultTextFormat = textFormat;
			_title.antiAliasType = AntiAliasType.ADVANCED;
			_title.embedFonts = true;
			_title.wordWrap = false;
			_title.multiline = false;
			_title.selectable = false;
			_title.mouseEnabled = false;
			_title.mouseWheelEnabled = false;
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.text = _value.label;
			_title.x = -_title.width / 2 + (_isRemove ? -1 : 0);
			_title.y = - _title.height / 2;
			_title.filters = [CMapConstants.INSET_BEVEL];
		}
		
		private function draw():void
		{
			var props:Object = {};
			props[UIButton.WIDTH] = CMapConstants.LINE_VALUE_WIDTH;
			props[UIButton.HEIGHT] = CMapConstants.LINE_VALUE_HEIGHT;
			var bEllispe:int = CMapConstants.BUTTON_ELLIPSE;
			if (idx == 0)
				props[UIButton.ELLIPSE] = {tr:bEllispe, tl:bEllispe, br:0, bl:0};
			else if (idx == _total)
				props[UIButton.ELLIPSE] = {tr:0, tl:0, br:bEllispe, bl:bEllispe};
			else
				props[UIButton.ELLIPSE] = 0;
			props[UIButton.BEVEL_FILTER] = null;
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			_uiButton = addChild(new UIButton(props)) as UIButton;
			_uiButton.x = -props[UIButton.WIDTH]/2;
			_uiButton.y = -props[UIButton.HEIGHT]/2;
			_uiButton.bevel.scrollRect = new Rectangle(0, 0, _uiButton.bevel.width, _uiButton.height/2);
			_uiButton.enabled = true;
		}
	}
}