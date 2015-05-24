package com.jonnybomb.mentalmodeler.display.controls
{
	import com.mincomps.components.ScrollPanel;
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	public class TextScrollPanel extends Sprite
	{
		public static const TF_PADDING:int = 5;
		private static const NULL_LINE_HEIGHT:Number = -1;
		
		private var _scrollPanel:ScrollPanel;
		private var _prevTFHeight:Number;
		private var _tf:TextField;
		private var _width:int;
		private var _height:int;
		private var _prefillText:String;
		private var _prevTFHeightBiggerThanPanel:Boolean = false;
		
		public function get tf():TextField { return _tf; }
		
		public function TextScrollPanel(tf:TextField, width:int, height:int, prefillText:String = "")
		{
			_tf = tf;
			_width = width;
			_height = height;
			_prefillText = prefillText;
			
			init();
		}
		
		public function setSize(w:Number, h:Number):void
		{
			//trace("TextScrollPanel, setSize, w:"+w+", h:"+h+", _width:"+_width+", _height:"+_height);
			if (w != _width || h != _height)
			{
				var vScroll:Number = _scrollPanel.vScroll;
				var scrollMax:Number = Math.ceil(_tf.height - _height);
				var scrollPct:Number = vScroll / scrollMax;
				//trace("\tBEFORE vScroll:"+vScroll+", scrollMax:"+scrollMax+", scrollPct:"+scrollPct);
				_width = w;
				_height = h;
				_scrollPanel.setSize(w, h);
				scrollMax = Math.ceil(_tf.height - _height);
				_scrollPanel.vScroll = scrollPct * scrollMax;
				//trace("\tAFTER vScroll:"+_scrollPanel.vScroll+", scrollMax:"+scrollMax+", scrollPct:"+scrollPct);
				
			}
		}
		
		private function init():void
		{
			mouseEnabled = false;
			
			_tf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
			_tf.addEventListener(KeyboardEvent.KEY_DOWN, handleKey, false, 0, true);
			_tf.addEventListener(KeyboardEvent.KEY_UP, handleKey, false, 0, true);
			
			if (_prefillText != "")
			{
				_tf.addEventListener(FocusEvent.FOCUS_IN, handleFocus, false, 0, true);
				_tf.addEventListener(FocusEvent.FOCUS_OUT, handleFocus, false, 0, true);
			}
			
			_scrollPanel = addChild(createScrollPanel(0, 0, _width, _height)) as ScrollPanel;
			_scrollPanel.content.addChild(_tf);
			_scrollPanel.addEventListener(ScrollPanel.BG_MOUSE_DOWN, handleScrollPanelBgMouseDown, false, 0, true);
		}
		
		private function createScrollPanel(x:int, y:int, w:int, h:int):ScrollPanel
		{
			var s:ScrollPanel = new ScrollPanel();
			s.x = x;
			s.y = y;
			s.hideHScrollbar = true;
			s.autoHideVScrollbar = true;
			s.externalDropShadow = false;
			s.borderThickness = 0;
			s.setSize(w, h);
			//s.color = 0xe6e6e6;
			//s.autoVScroll = true;
			//s.draw();
			//s.addEventListener(Event.CHANGE, handleScrollChange, false, 0, true);
			return s;
		}
		
		private function getLineIndexFromCaretPosition(tf:TextField):int
		{
			var caretIdx:int = tf.caretIndex;
			var lineIdx:int = tf.getLineIndexOfChar(caretIdx);
			return lineIdx;
		}
		
		private function getTextFieldLineHeight(tf:TextField):Number
		{
			var caretIdx:int = tf.caretIndex;
			var lineIdx:int = tf.getLineIndexOfChar(caretIdx);
			var textLineMetrics:TextLineMetrics = getLineMetrics(lineIdx, tf);
			if (textLineMetrics)
				return textLineMetrics.height;
			else
				return NULL_LINE_HEIGHT;
		}
		
		private function handleScrollPanelBgMouseDown(e:Event):void
		{
			stage.focus = _tf;
		}
		
		private function handleFocus(e:FocusEvent):void
		{ 
			var focusIn:Boolean = e.type == FocusEvent.FOCUS_IN;
			if (focusIn && _tf.text == _prefillText)
				_tf.text = "";
			else if (!focusIn && _tf.text == "")
				_tf.text = _prefillText;
		}
		
		private function handleKey(e:KeyboardEvent):void { onTextChange(); }
		private function handleTextChange(e:Event):void
		{
			e.preventDefault();
			e.stopImmediatePropagation();
			
			onTextChange();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onTextChange():void
		{
			//trace("_tf.height"+_tf.height+" _height:"+_height+", _prevTFHeight:"+_prevTFHeight+", _scrollPanel.content.height:"+_scrollPanel.content.height);
			if (_tf.height > _height || _prevTFHeight > _height)
			{	
				_scrollPanel.draw();
				var lineIdx:int = getLineIndexFromCaretPosition(_tf);
				var lineHeight:Number = getTextFieldLineHeight(_tf);
				//trace("\tlineIdx"+lineIdx+" lineHeight:"+lineHeight+", _scrollPanel.vScroll:"+_scrollPanel.vScroll+", _tf.numLines:"+_tf.numLines);
				var pxScroll:Number = _tf.height - _height;
				var scrollPct:Number = lineIdx < 0 ? 1 : lineIdx/(_tf.numLines - 1);
				var scrollDelta:Number = Math.round(pxScroll * scrollPct);
				_scrollPanel.vScroll = scrollDelta;
				//trace("\t\tpxScroll:"+pxScroll+", scrollPct:"+scrollPct+", scrollDelta:"+scrollDelta+", _tf.numLines:"+_tf.numLines);
			}
			
			_prevTFHeight = height;
		}
		
		private function getLineMetrics(lineIdx:int, tf:TextField):TextLineMetrics
		{	
			//trace("getLineMetrics, lineIdx:"+lineIdx+", tf:"+tf);
			if (lineIdx > -1)
			{
				var tlm:TextLineMetrics;
				try
				{
					tlm = tf.getLineMetrics(lineIdx);
					return tlm;
				}
				catch(e:Error)
				{
					//trace("catch, e:"+e);
					return null;
				}
			}
			return null;
		}	
	}
}