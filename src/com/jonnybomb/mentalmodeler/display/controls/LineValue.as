package com.jonnybomb.mentalmodeler.display.controls
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class LineValue extends Sprite
	{
		private static const PADDING_HORZ:int = 2;
		private static const PADDING_VERT:int = -2;
		private var _title:TextField;
		private var _button:UIButton;
		private var _value:LineValueData;
		
		public function LineValue(startValue:LineValueData)
		{
			_value = startValue;
			init();
		}
		
		public function finalize():void
		{
			DisplayObjectUtil.finalizeAndRemove(_button);
			DisplayObjectUtil.remove(_title);
			
			_title = null;
			_button = null;
		}
		
		public function get value():LineValueData { return _value; }
		public function set value(lvd:LineValueData):void 
		{ 
			_value = lvd;
			updateButton();
		}
		
		private function adjustTitle(s:String):String
		{
			if (s.indexOf("+") != -1)
				return "+";
			else if (s.indexOf("-") != -1)
				return "-";
			return s;
		}
		
		private function updateButton(lvd:LineValueData = null):void
		{
			var value:LineValueData = lvd ? lvd : _value;
			_title.text = adjustTitle(value.label);
			var format:TextFormat = _title.getTextFormat();
			format.size = value.size;
			format.letterSpacing = value.letterSpacing;
			_title.setTextFormat(format);
			_title.x = - _title.width / 2 + value.x; 
			_title.y = - _title.height / 2 + value.y;
			var w:int = _title.width + PADDING_HORZ*2;
			var h:int = _title.height + PADDING_VERT*2;
			var cd:ColorData = new ColorData();
			cd.stroke = new ColorExtended(value.color);
			cd.fill = new ColorExtended(value.color);
			
			_button.setSize(w, h);
			_button.x = -w/2;
			_button.y = -h/2;
		}
		
		private function init():void
		{
			var props:Object = {};
			props[UIButton.DISABLED_ALPHA] = 1;
			props[UIButton.WIDTH] = CMapConstants.LINE_CLOSE_SIDE; //CMapConstants.LINE_VALUE_INDICATOR_WIDTH; //CMapConstants.LINE_VALUE_WIDTH  * 0.75;
			props[UIButton.HEIGHT] = CMapConstants.LINE_CLOSE_SIDE; //CMapConstants.LINE_VALUE_HEIGHT;
			props[UIButton.ELLIPSE] = CMapConstants.LINE_CLOSE_ELLIPSE; //CMapConstants.BUTTON_ELLIPSE;
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			props[UIButton.STATE_COLORS] = {up:ColorData.getColor(ColorData.BUTTON_UP), over:ColorData.getColor(ColorData.BUTTON_OVER), bevel:ColorData.getColor(ColorData.BUTTON_BEVEL)};
			_button = addChild(new UIButton(props)) as UIButton;
			_button.enabled = true;
			_button.x = -props[UIButton.WIDTH]/2;
			_button.y = -props[UIButton.HEIGHT]/2;
			var lineValueData:LineValueData = _value != null ? _value : CMapConstants.LINE_VALUE_DEFAULT;
			createCloseLabel(lineValueData);
			updateButton(lineValueData);
			
			/*
			var s:Sprite = addChild(new Sprite()) as Sprite;
			var g:Graphics = s.graphics;
			g.beginFill(0x00FF00);
			g.drawCircle(0, 0, 2);
			g.endFill();
			*/
		}
		
		private function createCloseLabel(lvd:LineValueData):void
		{
			var defaultLineValueData:LineValueData = CMapConstants.LINE_VALUE_DEFAULT;
			
			// add label
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "VerdanaEmbedded";
			textFormat.size = lvd.size; //15;//_isRemove ? 10 : 16;
			textFormat.letterSpacing = lvd.letterSpacing;
			textFormat.bold = true;
			textFormat.color = CMapConstants.LINE_VALUE_TEXT;
			
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
			_title.text = defaultLineValueData.label;
			_title.filters = [CMapConstants.INSET_BEVEL];
		}
	}
}