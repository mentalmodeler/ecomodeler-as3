package com.jonnybomb.mentalmodeler.display.controls
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.string.StringUtil;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	import flash.utils.Timer;

	public class ConceptDisplayLabel extends InteractiveElement
	{
		private var _idx:int;
		private var _tf:TextField;
		private var _preFillText:String;
		private var _maxWidth:int = CMapConstants.CD_WIDTH_MAX - CMapConstants.CD_TEXT_PADDING*2;
		private var _maxHeight:int = 500;
		private var _width:int;
		private var _height:int;
		private var _hasFocus:Boolean = false;
		private var _textProps:Object;
		
		public function get tf():TextField { return _tf; }
		public function get concept():ConceptDisplay { return parent && parent is ConceptDisplay ? parent as ConceptDisplay : null; }
		public function get minWidth():Number { return _maxWidth }; //return _tf.width + CMapConstants.CD_TEXT_PADDING * 2; }
		public function get minHeight():Number { return _tf.height + CMapConstants.CD_TEXT_PADDING * 1.4; }
		
		public function ConceptDisplayLabel(idx:int, w:int = -1, h:int = -1, title:String = "", preFillText:String = "", textProps:Object = null)
		{
			_idx = idx;
			if (textProps != null)
				_textProps = textProps;
			_preFillText = preFillText;
			updateMaxSize(w, h);
			init(title);
			enabled = true;
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			buttonMode = false;
		}
		
		override public function finalize():void
		{
			removeEventListener(FocusEvent.FOCUS_IN, handleFocus, false);
			removeEventListener(FocusEvent.FOCUS_OUT, handleFocus, false);
			
			DisplayObjectUtil.remove(_tf);
			_tf = null;
			super.finalize();
		}
		
		public function updateMaxSize(w:int, h:int):void
		{
			_width = w;
			_height = h;
			/*
			_maxWidth = w - CMapConstants.CD_TEXT_PADDING * 2;
			_maxHeight = h - CMapConstants.CD_TEXT_PADDING * 1.4;
			*/
			
			position();
		}
		
		public function get text():String
		{
			var text:String = _tf ? _tf.text : "";
			return text;
		}
		
		public function updateTF(stageX:Number, stageY:Number):void
		{
			stage.focus = _tf;
			var localPoint:Point = _tf.globalToLocal(new Point(stageX, stageY))
			var charIdx:int = _tf.getCharIndexAtPoint(localPoint.x, localPoint.y);
			if (charIdx != -1)
				_tf.setSelection(charIdx, charIdx);
		}
		
		private function init(title:String):void
		{
			addEventListener(FocusEvent.FOCUS_IN, handleFocus, false, 0 , true);
			addEventListener(FocusEvent.FOCUS_OUT, handleFocus, false, 0 , true);
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = CMapConstants.FONT_FAMILY;
			textFormat.size = 12;
			textFormat.bold = _textProps.bold;
			textFormat.letterSpacing = _textProps.letterSpacing;
			textFormat.color = _textProps.user;//0x000000;
			textFormat.align = TextFormatAlign.CENTER;
			
			_tf = addChild(new TextField()) as TextField;
			_tf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
			_tf.type = TextFieldType.INPUT;
			_tf.defaultTextFormat = textFormat
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.embedFonts = true;
			_tf.wordWrap = false; //true;
			_tf.multiline = false;//true;
			_tf.width = 1; //30;
			_tf.height = 1; //30;
			_tf.background = false;
			_tf.backgroundColor = 0xFFFFFF;
			_tf.selectable = true;
			_tf.mouseEnabled = false;
			_tf.mouseWheelEnabled = false;
			_tf.autoSize = TextFieldAutoSize.LEFT
			_tf.text = title; // != "" ? title : _idx + ". Enter text here";
			
			if (_textProps && _textProps.insetBevel)
			{
				var bevel:BevelFilter = CMapConstants.INSET_BEVEL.clone() as BevelFilter;
				bevel.highlightAlpha = 0.5;
				bevel.shadowAlpha = 0;
				_tf.filters = [bevel];
			}
			if (_tf.text == _preFillText)
				colorTF(_tf, _textProps.prefill);
			
			handleTextChange(null);
		}
		
		private function position():void
		{
			if (_tf)
			{
				_tf.x = (_width -_tf.width)/2;
				_tf.y = (_height - _tf.height)/2;
			}
		}
		
		private function colorTF(tf:TextField, color:uint):void
		{
			tf.alpha = (color == _textProps.prefill) ? 0.5 : 1;
			
			/*
			var format:TextFormat = tf.getTextFormat();
			format.color = color;
			tf.defaultTextFormat = format;
			tf.setTextFormat(format);
			*/
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
			position();
			
			if (_hasFocus)
				addEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false, 0, true);
			else
				removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false);
				
		}
		
		private function handleKeyUp(e:KeyboardEvent):void { handleTextChange(null); }
		private function handleTextChange(e:Event):void
		{
			updateTextField();
			/*
			if (concept)	
				concept.updateSize(minWidth, minHeight);
			*/
			position();
		}
		
		private function updateTextField():void
		{
			//updateTFWidth(_tf, _maxWidth, true);
			
			_tf.text = removeTrailingDoubleSpace(_tf);
			
			var count:int = 0;
			/*
			while(_tf.height > _maxHeight && count++ < 10000)
			*/
			while(_tf.width > _maxWidth && count++ < 10000)
			{
				var idx:int = _tf.caretIndex - 1;
				_tf.text = removeChar(_tf.text, idx);
				_tf.setSelection(idx, idx);
			}
			
			// to let model know label is changing
			dispatchEvent(new Event(Event.CHANGE, true, true));
		}
		
		private function updateTFWidth(tf:TextField, maxWidth:int, runAgain:Boolean = false):void
		{
			var diff:Number = 7.6;
			if (tf.textWidth <= maxWidth - diff)
			{
				tf.width = 1;
				tf.wordWrap = false;
				if (runAgain)
					updateTFWidth(tf, maxWidth);
			}
			else if (tf.width > maxWidth - diff)
			{
				tf.width = maxWidth; 
				tf.wordWrap = true;
			}
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
	}
}