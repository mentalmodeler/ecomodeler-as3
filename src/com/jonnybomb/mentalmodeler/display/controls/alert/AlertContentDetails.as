package com.jonnybomb.mentalmodeler.display.controls.alert
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.model.CMapModel;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.TextFieldAsset;
	
	public class AlertContentDetails extends Sprite implements IAlertContent
	{
		private var _tf:TextField;
		private var _button:UIButton;
		private var _cancel:UIButton;
		private var _buttonsHolder:Sprite;
		private var _author:Sprite;
		private var _authorInput:TextField;
		private var _description:Sprite;
		private var _descriptionInput:TextField;
		
		public function get cancelButton():UIButton { return _cancel; }
		public function get actionButton():UIButton { return _button; }
		
		public function AlertContentDetails(w:int = 400)
		{
			var descr:String = "Please enter an author and description for this file. *This is optional"
			var  buttonLabel:String = "CONTINUE";
			var addCancel:Boolean = true;
			
			mouseEnabled = false;
			_buttonsHolder = addChild(new Sprite()) as Sprite;
			_tf = addChild(createTF(descr, w, 14, 0xFFFFFF)) as TextField;
			
			if (buttonLabel != "")
			{
				var buttonPadding:int = 7;
				var label:TextField = createTF(buttonLabel, w - buttonPadding*2, 14, 0x555555/*0xFFFFFF*/, true, false)
				var props:Object = {};
				props[UIButton.HEIGHT] = CMapConstants.MENU_HEIGHT;
				props[UIButton.WIDTH] = label.width  +buttonPadding*2;
				props[UIButton.ELLIPSE] = 4;
				props[UIButton.STROKE] = 1;
				props[UIButton.STATE_COLORS] =  { up: ColorData.getColor(ColorData.ALERT_BUTTON_UP), over: ColorData.getColor(ColorData.ALERT_BUTTON_OVER) };
				//props[UIButton.BEVEL_FILTER] = null;
				props[UIButton.USE_DROP_SHADOW] = false;
				_button = _buttonsHolder.addChild(new UIButton(props)) as UIButton;
				_button.bevel.scrollRect = new Rectangle(0, 0, _button.bevel.width, _button.height/2);
				label.x = (_button.width - label.width)/2; 
				label.y = (_button.height - label.height)/2 - 1;
				_button.addLabel(label);
				
				if (addCancel)
				{
					label = createTF("CANCEL", w - buttonPadding*2, 14, 0x555555/*0xFFFFFF*/, true, false)
					_cancel = _buttonsHolder.addChild(new UIButton(props)) as UIButton;
					_cancel.bevel.scrollRect = new Rectangle(0, 0, _cancel.bevel.width, _cancel.height/2);
					label.x = (_cancel.width - label.width)/2; 
					label.y = (_cancel.height - label.height)/2 - 1;
					_cancel.addLabel(label);
					_cancel.x = _button.width + 50;
				}
				
				var nY:int = _tf.y + _tf.height + CMapConstants.ALERT_SPACING * 0.5;
				
				var o:Object = createInput("Author", w, 39);
				_author = addChild(o.s) as Sprite;
				_authorInput = o.tf as TextField;
				_authorInput.addEventListener(Event.CHANGE, handleAuthorChange, false, 0, true);
				_authorInput.text = CMapModel.author;
				_author.y = nY;
				nY += _author.height + CMapConstants.ALERT_SPACING * 0.5;
				
				o = createInput("Description", w,  117);
				_description = addChild(o.s) as Sprite;
				_descriptionInput = o.tf as TextField;
				_descriptionInput.addEventListener(Event.CHANGE, handleDescriptionChange, false, 0, true);
				_descriptionInput.text = CMapModel.description;
				_description.y = nY;
				nY += _description.height + CMapConstants.ALERT_SPACING;
				
				_buttonsHolder.x = (w - _buttonsHolder.width)/2;
				_buttonsHolder.y = nY;
			}
		}
		
		public function destroy():void
		{
			if (_authorInput)
				_authorInput.removeEventListener(Event.CHANGE, handleAuthorChange);
			
			if (_descriptionInput)
				_descriptionInput.removeEventListener(Event.CHANGE, handleDescriptionChange);
			
			DisplayObjectUtil.removeChildrenAndDestroy(this);
			_buttonsHolder = null;
			_button = null
			_tf = null;
			_author = null;
			_authorInput = null;
			_description = null;
			_descriptionInput = null;
		}
		
		private function handleAuthorChange(e:Event):void
		{
			CMapModel.author = _authorInput.text;
		}
		
		private function handleDescriptionChange(e:Event):void
		{
			CMapModel.description = _descriptionInput.text;
		}
		
		private function createInput(title:String, w:int, maxChars:int):Object
		{
			var s:Sprite = new Sprite();
			s.mouseEnabled = false;
			var tf:TextField = s.addChild(createTF(title, w, 14, 0xFFFFFF/*0x333333*/, true)) as TextField;
			tf.filters = [CMapConstants.INSET_BEVEL];
			var inputTf:TextField = s.addChild(createTF(createMaxCharsString(maxChars), w)) as TextField;
			inputTf.type = TextFieldType.INPUT;
			inputTf.selectable = true;
			inputTf.background = true;
			inputTf.backgroundColor = 0xFFFFFF;
			inputTf.border = true;
			inputTf.borderColor = 0x333333;
			var h:Number = inputTf.height;
			inputTf.text = "";
			inputTf.multiline = false;
			inputTf.maxChars = int(maxChars * 1.5);
			inputTf.autoSize = TextFieldAutoSize.NONE;
			inputTf.width = w;
			inputTf.height = h;
			
			inputTf.y = tf.y + tf.height;
			inputTf.mouseEnabled = true;
			return  {s:s, tf:inputTf};
		}
		
		private function createMaxCharsString(maxChars:int):String
		{
			var letter:String = "N";
			var s:String = "";
			var i:int;
			
			for (i=0; i<maxChars; i++)
				s += letter;
			
			return s;
		}
		
		private function createTF(s:String, w:int = 0, size:int = 14, color:uint = 0x333333/*0x000000*/, bold:Boolean = false, useInsetBevel:Boolean = false):TextField
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