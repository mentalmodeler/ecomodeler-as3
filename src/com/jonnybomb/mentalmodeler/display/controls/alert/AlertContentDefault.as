package com.jonnybomb.mentalmodeler.display.controls.alert
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class AlertContentDefault extends Sprite implements IAlertContent
	{
		private var _tf:TextField;
		private var _button:UIButton;
		private var _cancel:UIButton;
		private var _buttonsHolder:Sprite;
		public function get cancelButton():UIButton { return _cancel; }
		public function get actionButton():UIButton { return _button; }
		
		public function AlertContentDefault(descr:String, buttonLabel:String="", addCancel:Boolean = false, w:int = 400)
		{
			mouseEnabled = false;
			_buttonsHolder = addChild(new Sprite()) as Sprite;
			_tf = addChild(createTF(descr, w, 14)) as TextField;
			
			if (buttonLabel != "")
			{
				var buttonPadding:int = 7;
				var label:TextField = createTF(buttonLabel, w - buttonPadding*2, 14, 0xFFFFFF, true, true)
				var props:Object = {};
				props[UIButton.HEIGHT] = CMapConstants.MENU_HEIGHT;
				props[UIButton.WIDTH] = label.width  +buttonPadding*2;
				props[UIButton.ELLIPSE] = 0;
				props[UIButton.STROKE] = 0;
				props[UIButton.STATE_COLORS] =  {
													up: ColorData.getColor(ColorData.ALERT_BUTTON_UP),
													over: ColorData.getColor(ColorData.ALERT_BUTTON_OVER)
												};
				props[UIButton.USE_DROP_SHADOW] = false;
				//props[UIButton.BEVEL_FILTER] = null;
				_button = _buttonsHolder.addChild(new UIButton(props)) as UIButton;
				_button.bevel.scrollRect = new Rectangle(0, 0, _button.bevel.width, _button.height/2);
				label.x = (_button.width - label.width)/2; 
				label.y = (_button.height - label.height)/2 - 1;
				_button.addLabel(label);
				
				if (addCancel)
				{
					label = createTF("CANCEL", w - buttonPadding*2, 14, 0xFFFFFF, true, true)
					_cancel = _buttonsHolder.addChild(new UIButton(props)) as UIButton;
					_cancel.bevel.scrollRect = new Rectangle(0, 0, _cancel.bevel.width, _cancel.height/2);
					label.x = (_cancel.width - label.width)/2; 
					label.y = (_cancel.height - label.height)/2 - 1;
					_cancel.addLabel(label);
					_cancel.x = _button.width + 50;
				}
				
				if (_tf.width > _buttonsHolder.width)
					_buttonsHolder.x = (_tf.width - _buttonsHolder.width)/2;
				else
					_tf.x = (_buttonsHolder.width - _tf.width)/2;
			
				_buttonsHolder.y = _tf.y + _tf.height + CMapConstants.ALERT_SPACING;
			}
		}
		
		public function destroy():void
		{
			DisplayObjectUtil.removeChildrenAndDestroy(this);
			_buttonsHolder = null;
			_button = null
			_tf = null;
		}
		
		private function createTF(s:String, w:int = 0, size:int = 14, color:uint = 0xFFFFFF/*0x000000*/, bold:Boolean = true, useInsetBevel:Boolean = false):TextField
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "VerdanaEmbedded";
			textFormat.size = size;
			textFormat.letterSpacing = 0;
			textFormat.color = color;
			textFormat.bold = bold;
			textFormat.align = TextFormatAlign.LEFT;
			
			var tf:TextField = new TextField();
			tf.type = TextFieldType.DYNAMIC;
			tf.defaultTextFormat = textFormat
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.embedFonts = true;
			tf.wordWrap = false;
			tf.multiline = false;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			tf.autoSize = TextFieldAutoSize.LEFT
			
			tf.htmlText = s;
			
			if (w > 0 && tf.width > w)
			{
				tf.text = "";
				tf.width = w;
				tf.wordWrap = true;
				tf.multiline = true;
				tf.htmlText = s;
			}
			
			if (useInsetBevel)
				tf.filters = [CMapConstants.INSET_BEVEL];
			return tf; 
		}
	}
}