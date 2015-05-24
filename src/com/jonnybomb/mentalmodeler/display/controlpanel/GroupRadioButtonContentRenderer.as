package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.ui.components.radiobutton.IRadioButtonContentRenderer;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class GroupRadioButtonContentRenderer extends Sprite implements IRadioButtonContentRenderer
	{
		public static const GROUP_NAME_CHANGE:String = "groupNameChange"
		
		public function get text():String { return _tf.text == _preFillText ? "" : _tf.text; }	
			
		private var _tf:TextField;
		private var _maxWidth:Number;
		private var _hasFocus:Boolean = false;
		private var _preFillText:String = "Enter -group name.";
		private var _bg:Shape;
		
		public function GroupRadioButtonContentRenderer()
		{
			super();
		}
		
		public function update(data:Object):void
		{
			_tf.text = data.label != "" ? data.label : _preFillText;
			updateTextField();
			updateTextAlpha();
		}
		
		public function build(data:Object, w:int=-1, h:int=-1):void
		{
			_maxWidth = w;
			
			_bg = addChild(new Shape()) as Shape;
			
			if (data.preFillText)
				_preFillText = data.preFillText;
			
			var format:TextFormat = new TextFormat();
			format.color = 0x000000;
			format.size = 13;
			format.font = "VerdanaEmbedded"; //"FontEmbedded";
			format.bold = false;
			format.italic = false;
			format.kerning = 0;
			format.letterSpacing = -0.5;
			
			var tf:TextField = addChild(new TextField()) as TextField;
			tf.embedFonts = true;
			tf.defaultTextFormat = format;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.type = TextFieldType.INPUT;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.wordWrap = false;
			tf.multiline = false;
			tf.selectable = true;
			tf.mouseEnabled = true;
			tf.mouseWheelEnabled = false;
			tf.text = data.label != "" ? data.label : _preFillText;
			//tf.background = true;
			//tf.backgroundColor = data.color;
			
			tf.width = w;
			tf.autoSize = TextFieldAutoSize.NONE;
			//filters = [new DropShadowFilter(1, 90, 0x000000, 1, 4, 4, 0.35, BitmapFilterQuality.MEDIUM)];
			
			_tf = tf;
			
			var g:Graphics = _bg.graphics;
			g.lineStyle(1, 0x000000, 0.25);
			g.beginFill(data.color);
			g.drawRoundRect(0, 1, _tf.width, _tf.height, 4);
			g.endFill();
			
			updateTextAlpha();
			
			tf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
			
			addEventListener(FocusEvent.FOCUS_IN, handleFocus, false, 0 , true);
			addEventListener(FocusEvent.FOCUS_OUT, handleFocus, false, 0 , true);
		}
		
		private function updateTextAlpha():void
		{
			_tf.alpha = (_tf.text == _preFillText) ? 0.35 : 1;	
		}
		
		private function handleKeyUp(e:KeyboardEvent):void { handleTextChange(null); }
		private function handleTextChange(e:Event):void
		{
			updateTextField();
			dispatchEvent(new Event(GROUP_NAME_CHANGE, true));
		}
		
		private function handleFocus(e:FocusEvent):void
		{
			_hasFocus = e.type == FocusEvent.FOCUS_IN;
			if (e.type == FocusEvent.FOCUS_IN && _tf.text == _preFillText)
				_tf.text = "";
			else if (e.type == FocusEvent.FOCUS_OUT && _tf.text == "")
				_tf.text = _preFillText;
			
			updateTextAlpha();
			
			if (_hasFocus)
				addEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false, 0, true);
			else
				removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false);
			
		}
		
		private function updateTextField():void
		{
			_tf.text = removeTrailingDoubleSpace(_tf);
			
			var count:int = 0;
			while(_tf.textWidth > _maxWidth - 5 && count++ < 10000)
			{
				var idx:int = _tf.caretIndex - 1;
				_tf.text = removeChar(_tf.text, idx);
				_tf.setSelection(idx, idx);
			}
			
			// to let model know label is changing
			//dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		
		private function removeChar(s:String, idx:int):String
		{
			return s.substring(0, idx).concat(s.substring(idx + 1));
		}
		
		private function removeTrailingDoubleSpace(tf:TextField):String
		{
			// var maxWidth:int = CMapConstants.CD_WIDTH - CMapConstants.CD_TEXT_PADDING * 2;
			// var lastLineTextWidth:Number = tf.getLineMetrics(tf.numLines - 1).width;
			
			var s:String = _tf.text;
			var lastChar:String = s.charAt(s.length - 1);
			var secondLastChar:String = s.charAt(s.length - 2);
			while(lastChar == " " && secondLastChar == " ")
			{
				s = s.substr(0, s.length - 1);
				lastChar = s.charAt(s.length - 1);
				secondLastChar = s.charAt(s.length - 2);
			}
			return s;
		}
		
		public function finalize():void
		{
		}
	}
}