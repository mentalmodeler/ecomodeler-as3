package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.display.controls.TextScrollPanel;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	public class NotesPanel extends AbstractPanel
	{
		private var _textScrollPanel:TextScrollPanel;
		private var _curNotable:INotable;
		
		public function NotesPanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
			_minHeight = 50;
		}
		
		override public function setSize(w:Number, h:Number):void
		{
			super.setSize(w, h);
			if (_sizeChanged)
			{
				_tf.width = _width - MinCompsScrollBarConstants.SIZE - TextScrollPanel.TF_PADDING;
				_textScrollPanel.setSize(_width - TextScrollPanel.TF_PADDING, _height - HEADER_HEIGHT);
			}
			
			/*
			if (w != _width || h != _height)
			{
				_width = w;
				_height = h;
				_tf.width = _width - MinCompsScrollBarConstants.SIZE - TextScrollPanel.TF_PADDING;
				_textScrollPanel.setSize(_width - TextScrollPanel.TF_PADDING, _height - HEADER_HEIGHT);
			}
			*/
		}
		
		override public function get height():Number { return _height; }
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			
			_textScrollPanel.tf.tabEnabled = value;
			_textScrollPanel.visible = value;
		}
		
		override public function init():void
		{
			super.init();
			
			// create tf for text scroll panel
			var props:Object = {color: 0x000000,
								size: 13,
								align: TextFormatAlign.LEFT,
								letterSpacing: 0,
								autoSize: TextFieldAutoSize.LEFT,
								multiline: true,
								mouseEnabled: true,
								wordWrap: true,
								type: TextFieldType.INPUT,
								width: _width - MinCompsScrollBarConstants.SIZE - TextScrollPanel.TF_PADDING,
								selectable: true
								};
			var tf:TextField = CMapUtils.createTextField("", props);
			// create text scroll panel
			_textScrollPanel = addChild(new TextScrollPanel(tf, _width - TextScrollPanel.TF_PADDING, _height - HEADER_HEIGHT, CMapConstants.NOTES_PREFILL_TEXT)) as TextScrollPanel;
			_textScrollPanel.x = TextScrollPanel.TF_PADDING
			_textScrollPanel.y = _header.height;
			_textScrollPanel.addEventListener(Event.CHANGE, handleTextScrollPanelChange, false, 0, true);
			enabled = false;
			
			//_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedCDChange, false, 0, true);
			//_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedLineChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
		}
		
		private function handleTextScrollPanelChange(e:Event):void
		{
			if (_curNotable)
				_curNotable.notes = _textScrollPanel.tf.text
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			var cd:ConceptDisplay = getCurCd();
			var selected:INotable = getCurSelected();
			
			//trace("NotesPanel >> handleSelectedChange, line:"+line+", cd:"+cd+", selected:"+selected);
			_curNotable = selected;
			if (_curNotable)
			{
				enabled = true
				if (_curNotable == line)
					_textScrollPanel.tf.text = line.notes == "" && CMapConstants.NOTES_PREFILL_TEXT != "" ? CMapConstants.NOTES_PREFILL_TEXT : line.notes;
				else if (_curNotable == cd)
					_textScrollPanel.tf.text = cd.notes == "" && CMapConstants.NOTES_PREFILL_TEXT != "" ? CMapConstants.NOTES_PREFILL_TEXT : cd.notes;
				else
					enabled = false;
			}
			else
				enabled = false;
		}
		
		/*
		private function handleSelectedLineChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			if (line)
			{
				enabled = true;
				_curNotable = line;
				_textScrollPanel.tf.text = line.notes == "" && CMapConstants.NOTES_PREFILL_TEXT != "" ? CMapConstants.NOTES_PREFILL_TEXT : line.notes;
			}
			else if (!getCurCd())
				enabled = false;
		}
		
		private function handleSelectedCDChange(e:ModelEvent):void
		{
			var cd:ConceptDisplay = getCurCd();
			if (cd)
			{
				enabled = true;
				_curNotable = cd;
				_textScrollPanel.tf.text = cd.notes == "" && CMapConstants.NOTES_PREFILL_TEXT != "" ? CMapConstants.NOTES_PREFILL_TEXT : cd.notes;
			}
			else if (!getCurLine())
			{
				_curNotable = null;
				enabled = false;
				//trace("\tenabled = false");
			}
			//trace("Notes > handleSelectedCDChange, enabled:"+enabled)
		}
		*/
	}
}