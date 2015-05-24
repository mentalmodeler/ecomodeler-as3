package com.jonnybomb.mentalmodeler.display.controls
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.string.StringUtil;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	public class LineLabel extends Sprite
	{
		private var _text:String;
		private var _hasFocus:Boolean = false;
		private var _textProps:Object;
		private var _tf:TextField;
		private var _preFillText:String;
		private var _minTextWidth:int = 20;
		
		public function get preFillText():String { return _preFillText; }
		public function get tf():TextField{ return _tf; }
		public function get text():String { return _text; }
		public function set text(s:String):void
		{ 
			_text = s;
			updateDisplayText( getSourceTextForDisplay() );
		}
		
		private function getSourceTextForDisplay():String
		{
			return _text == "" ? _preFillText : _text;	
		}
		
		private function updateDisplayText(s:String):void
		{
			_tf.text = s == "" ? _preFillText : s;
			updateTextField();
		}
		
		public function LineLabel(startLabelText:String = "")
		{
			_text = startLabelText;
			_preFillText = CMapConstants.LINE_PREFILL_TEXT;
			_textProps = { user:0x000000,
							prefill:0x999999
			};
			init();
		}
		
		public function updateWidth(w:int):void
		{
			_tf.width = w > _minTextWidth ? w : _minTextWidth;
			updatePosition();
			updateTextField();
		}
		
		private function updatePosition():void
		{
			var lineMetrics:TextLineMetrics = _tf.getLineMetrics(0);
			var gutter:int = 2;
			_tf.y =  - (lineMetrics.height + gutter - lineMetrics.leading * 0.4 );	
		}
		
		public function updateTF(stageX:Number, stageY:Number):void
		{
			stage.focus = _tf;
			var localPoint:Point = _tf.globalToLocal(new Point(stageX, stageY))
			var charIdx:int = _tf.getCharIndexAtPoint(localPoint.x, localPoint.y);
			if (charIdx != -1)
				_tf.setSelection(charIdx, charIdx);
		}
		
		private function handleFocus(e:FocusEvent):void
		{
			_hasFocus = e.type == FocusEvent.FOCUS_IN;
			//_tf.background = _hasFocus;
			if (e.type == FocusEvent.FOCUS_IN && _tf.text == _preFillText)
			{	
				_tf.text = "";
				colorTF(_tf, _textProps.user);
			}
			else if (e.type == FocusEvent.FOCUS_OUT && _tf.text == "")
			{
				_tf.text = _preFillText;
				colorTF(_tf, _textProps.prefill);
			}
			
			//handleTextChange(null);
			
			//position();
			
			if (_hasFocus)
				addEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false, 0, true);
			else
				removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false);
			
		}
		
		private function handleKeyUp(e:KeyboardEvent):void { handleTextChange(null); }
		private function handleTextChange(e:Event):void
		{
			updateTextField();
			//position();
		}
		
		private function updateTextField():void
		{
			_tf.text = removeTrailingDoubleSpace( getSourceTextForDisplay() );
			var maxLines:int = 2;
			var needsEllipsis:Boolean = _tf.numLines > maxLines;
			if (needsEllipsis)
			{
				_tf.appendText("...");
				while(_tf.numLines > maxLines || _tf.height > 45)
					_tf.text = removeChar(_tf.text, _tf.text.length - 4);
				
				// got to call it twice to make sure updates have registered
				while(_tf.numLines > maxLines || _tf.height > 45)
					_tf.text = removeChar(_tf.text, _tf.text.length - 4);
			}
			// to let model know label is changing
			//dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		
		private function removeChar(s:String, idx:int):String
		{
			return s.substring(0, idx).concat(s.substring(idx + 1));
		}
		
		private function removeNewLines(s:String):String
		{
			s = StringUtil.remove(s, "\r");
			s = StringUtil.remove(s, "\n");
			return s;
		}
		
		private function removeTrailingDoubleSpace(s:String):String
		{
			// var maxWidth:int = CMapConstants.CD_WIDTH - CMapConstants.CD_TEXT_PADDING * 2;
			// var lastLineTextWidth:Number = tf.getLineMetrics(tf.numLines - 1).width;
			
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
		
		private function init():void
		{
			_tf = addChild( createTF(_text) ) as TextField;
			/*
			_tf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
			addEventListener(FocusEvent.FOCUS_IN, handleFocus, false, 0 , true);
			addEventListener(FocusEvent.FOCUS_OUT, handleFocus, false, 0 , true);
			*/
		}
		
		private function colorTF(tf:TextField, color:uint):void
		{
			var format:TextFormat = tf.getTextFormat();
			format.color = color;
			tf.defaultTextFormat = format;
			tf.setTextFormat(format);
		}
		
		private function createTF(label:String):TextField
		{
			var props:Object = {size:14,
								autoSize:TextFieldAutoSize.LEFT,
								multiLine: true,
								wordWrap: true,
								mouseEnabled: false,
								antiAliasType: AntiAliasType.ADVANCED,
								type: TextFieldType.INPUT,
								leading: 4,
								selectable: false,
								background: false,
								backgroundColor: 0xE6E6E6
			};
			
			if (label == "")
				label = _preFillText;
			
			return CMapUtils.createTextField(label, props);
		}
	}
}