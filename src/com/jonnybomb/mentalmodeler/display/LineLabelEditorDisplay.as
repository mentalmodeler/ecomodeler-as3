package com.jonnybomb.mentalmodeler.display
{
	import com.gskinner.motion.plugins.CurrentFramePlugin;
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.string.StringUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	public class LineLabelEditorDisplay extends Sprite
	{
		private var _controller:CMapController;
		private var _outline:Sprite;
		private var _bg:Sprite;
		private var _tf:TextField;
		private var _curLine:InfluenceLineDisplay;
		private var _hasFocus:Boolean;
		private var _preFillText:String;
		
		public function LineLabelEditorDisplay(controller:CMapController)
		{
			visible = false;
			_controller = controller;
			_preFillText = CMapConstants.LINE_PREFILL_TEXT;;
			init();
		}
		
		public function show(point:Point, line:InfluenceLineDisplay):void
		{
			_curLine = line;
			//trace("show, _curLine:"+_curLine);
			x = Math.round(point.x - width/2);
			y = Math.round(point.y - height/2);
			visible = true;
			
			var s:String = line.getLineLabelText(true);
			if (s == _preFillText)
				s = "";
			_tf.text = s;
			
			stage.focus = _tf;
			toggleFocusHandler(true);
			
			//if (stage)
				//stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
		}
		
		public function hide():void
		{
			//trace("hide, _curLine:"+_curLine);
			removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false);
			visible = false;
			toggleFocusHandler(false);
			if (_curLine)
			{
				_curLine.toggleLineLabelShown(true);
				_curLine = null;
			}
			
			//if (stage)
				//stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}

		private function init():void
		{
			var outlineStroke:int = 1;
			var padding:int = CMapConstants.LINE_LABEL_EDITOR_PADDING;
			var w:int = CMapConstants.LINE_LABEL_EDITOR_MAX_TEXT_WIDTH + padding * 2;
			var h:int = CMapConstants.LINE_LABEL_EDITOR_MAX_TEXT_HEIGHT + padding * 2;
			_outline = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_outline, w, h, ColorData.getColor(ColorData.LINE_LABEL_EDITOR_OUTLINE),  0, CMapConstants.LINE_LABEL_EDITOR_ELLIPSE);
			_bg = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_bg, w - outlineStroke*2, h - outlineStroke*2, ColorData.getColor(ColorData.LINE_LABEL_EDITOR_FILL),  /*CMapConstants.LINE_LABEL_EDITOR_STROKE*/0, CMapConstants.LINE_LABEL_EDITOR_ELLIPSE - outlineStroke);
			_bg.x = _bg.y = outlineStroke
			var ds:DropShadowFilter = CMapConstants.CD_DROP_SHADOW.clone() as DropShadowFilter 
			ds.knockout = false;
			_outline.filters = [ds];
			
			_tf = addChild( createTF("") ) as TextField;
			_tf.x = _tf.y = padding;
		}
		
		private function toggleFocusHandler(value:Boolean):void
		{
			if (value)
			{
				_tf.addEventListener(FocusEvent.FOCUS_IN, handleFocus, false, 0 , true);
				_tf.addEventListener(FocusEvent.FOCUS_OUT, handleFocus, false, 0 , true);
				_tf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
				_tf.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false, 0, true);
			}
			else
			{
				_tf.removeEventListener(FocusEvent.FOCUS_IN, handleFocus, false);
				_tf.removeEventListener(FocusEvent.FOCUS_OUT, handleFocus, false);
				_tf.removeEventListener(Event.CHANGE, handleTextChange, false);
				_tf.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false);
			}
		}
		
		private function handleFocus(e:FocusEvent):void
		{
			//trace("stage.focus:"+stage.focus);
			_hasFocus = e.type == FocusEvent.FOCUS_IN;
			
			//handleTextChange(null);
			//position();
			
			if (_hasFocus)
				addEventListener(KeyboardEvent.KEY_DOWN, handleKeyUp, false, 0, true);
			else
				hide();
			
			/*
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
			*/
		}
		
		private function handleKeyUp(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
				hide();
			//handleTextChange(null);
		}
		
		private function handleTextChange(e:Event):void
		{   
			if (e && _curLine)
				_curLine.setLineLabelText(_tf.text);
			updateTextField(); 
			//position();
		}
		    
		private function updateTextField():void
		{
			_tf.text = removeTrailingDoubleSpace(_tf);
			
			var maxLines:int = 2;
			while(_tf.numLines > maxLines)
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
		
		private function createTF(label:String):TextField
		{
			var props:Object = {size:14,
					autoSize:TextFieldAutoSize.NONE,
					multiLine: true,
					wordWrap: true,
					mouseEnabled: true,
					antiAliasType: AntiAliasType.ADVANCED,
					type: TextFieldType.INPUT,
					leading: 0,
					selectable: true,
					width:CMapConstants.LINE_LABEL_EDITOR_MAX_TEXT_WIDTH,
					height:CMapConstants.LINE_LABEL_EDITOR_MAX_TEXT_HEIGHT,
					background: false,
					backgroundColor: 0xE6E6E6
			};
			
			return CMapUtils.createTextField(label, props);
		}
		
		public function finalize():void
		{
			//if (stage)
				//stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
	}
}