package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class ViewPanel extends AbstractPanel
	{
		public static const VIEW_LINES_NONE:int = 0;
		public static const VIEW_LINES_FROM:int = 1;
		public static const VIEW_LINES_TO:int = 2;
		
		private static var colors:Object = { up: ColorData.getColor(ColorData.CHECKBOX_UP),
											 over: ColorData.getColor(ColorData.CHECKBOX_OVER)
										   };
		
		private static const BG_COLOR:uint = 0x727272;
		
		private var bodyY:Number;
		private var _viewLinesTo:UIButton;
		private var _viewLinesFrom:UIButton;
		private var _resetView:UIButton;
		private var _cdViewMode:MovieClip;
		private var _linesViewMode:MovieClip;
		
		public function ViewPanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
		}
		
		override public function get height():Number { return _cover.height; }
		
		override public function init():void
		{
			super.init();
			removeChild(_body);
			
			_cdViewMode = addChild(new MovieClip()) as MovieClip;
			_cdViewMode.y = HEADER_HEIGHT;
			_cdViewMode.bg = _cdViewMode.addChild(createBg(new Rectangle(0, 0, _width, HEADER_HEIGHT), BG_COLOR)) as Sprite;
			_viewLinesFrom = _cdViewMode. addChild(createButton("View Only Lines From")) as UIButton;
			_viewLinesTo = _cdViewMode. addChild(createButton("View Only Lines To")) as UIButton;
			_viewLinesFrom.x = (_width - _viewLinesFrom.width) / 2;
			bodyY = _viewLinesFrom.x + 2;
			_viewLinesFrom.y = bodyY;
			_viewLinesTo.x = (_width - _viewLinesTo.width) / 2;
			_viewLinesTo.y = _viewLinesFrom.height + bodyY + 6;
			_cdViewMode.bg.height = _viewLinesTo.y + _viewLinesTo.height + bodyY;
			
			_linesViewMode = addChild(new MovieClip()) as MovieClip;
			_linesViewMode.y = HEADER_HEIGHT;
			_linesViewMode.bg = _linesViewMode.addChild(createBg(new Rectangle(0, 0, _width, HEADER_HEIGHT), BG_COLOR)) as Sprite;
			_resetView = _linesViewMode.addChild(createButton("Reset View Filter", false)) as UIButton;
			_resetView.x = (_width - _resetView.width) / 2;
			_resetView.y = bodyY;
			_resetView.addEventListener(MouseEvent.MOUSE_DOWN, handleResetDown, false, 0 ,true);
			_linesViewMode.bg.height = _resetView.y + _resetView.height + bodyY;
			
			update(false);
			enabled = false;
			
			_viewLinesFrom.addEventListener(UIButton.SELECTED_CHANGE, handleLinesFromSelectedChange, false, 0, true);
			_viewLinesTo.addEventListener(UIButton.SELECTED_CHANGE, handleLinesToSelectedChange, false, 0, true);
			//_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedCDChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
		}
		
		private function update(updatePanels:Boolean = true):void
		{
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			
			enabled = false;
			return;
			
			if (curSelected is ConceptDisplay)
			{
				_cdViewMode.visible = true;
				_linesViewMode.visible = false;
				_cover.height = _cdViewMode.y + _cdViewMode.height;
			}
			else if (_viewLinesTo.selected || _viewLinesFrom.selected/*curSelected is InfluenceLineDisplay*/)
			{
				_cdViewMode.visible = false;
				_linesViewMode.visible = true;
				_cover.height = _linesViewMode.y + _linesViewMode.height
			}
			else
			{
				_cdViewMode.visible = false; 
				_linesViewMode.visible = false;
				_cover.height = HEADER_HEIGHT;
			}
			
			if (updatePanels)
				_controlPanel.updateLayout();
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			//trace("handleSelectedChange, curCd:"+curCd+", curLine:"+curLine+", curSelected:"+curSelected);
			
			if (curSelected is ConceptDisplay)
			{
				enabled = true;
				if (_viewLinesFrom.selected)
					_controlPanel.controller.setComponentSoloView(VIEW_LINES_FROM, true);
				else if (_viewLinesTo.selected)
					_controlPanel.controller.setComponentSoloView(VIEW_LINES_TO, true);
			}
			else if (_viewLinesTo.selected || _viewLinesFrom.selected)
			{
				enabled = true;
			}
			/*else if (curSelected is InfluenceLineDisplay && curCd)
			{
				if ( (_viewLinesTo.selected && curLine.influencee == curCd) || (_viewLinesFrom.selected && curLine.influencer == curCd) )
					enabled = true;
				else
					enabled = false;
			}*/
			else
				enabled = false;
			
			update();
		}
		
		private function handleResetDown(e:MouseEvent):void
		{
			if (_viewLinesFrom.selected)
			{
				_controlPanel.controller.setComponentSoloView(VIEW_LINES_FROM, false);
				_viewLinesFrom.selected = false;
				enabled = false;
			}
			else if (_viewLinesTo.selected)
			{
				_controlPanel.controller.setComponentSoloView(VIEW_LINES_TO, true);
				_viewLinesTo.selected = false;
				enabled = false;
			}
			
			update();
		}
		
		private function handleLinesFromSelectedChange(e:Event):void
		{
			//trace("handleLinesFromMouseUp, _viewLinesFrom.selected:"+_viewLinesFrom.selected+", _viewLinesTo.selected:"+_viewLinesTo.selected);
			if (_viewLinesFrom.selected)
			{
				if (_viewLinesTo.selected)
					_viewLinesTo.selected = false;
				
				_controlPanel.controller.setComponentSoloView(VIEW_LINES_FROM, true);
			}
			else if (!_viewLinesTo.selected)
				_controlPanel.controller.setComponentSoloView(VIEW_LINES_NONE, true);
		}
		
		private function handleLinesToSelectedChange(e:Event):void
		{
			//trace("handleLinesToMouseUp, _viewLinesTo.selected:"+_viewLinesTo.selected+", _viewLinesFrom.selected:"+_viewLinesFrom.selected);
			if (_viewLinesTo.selected)
			{
				if (_viewLinesFrom.selected)
					_viewLinesFrom.selected = false;
				
				_controlPanel.controller.setComponentSoloView(VIEW_LINES_TO, true);
			}
			else if (!_viewLinesFrom.selected)
				_controlPanel.controller.setComponentSoloView(VIEW_LINES_NONE, true);
		}
		
		private function createButton(s:String, toggleButton:Boolean = true):UIButton
		{
			props = {color: 0xFFFFFF,
				size: 13,
				bold:true,
				align: TextFormatAlign.CENTER,
				letterSpacing: -1,
				multiline:true,
				wordWrap:true,
				autoSize:TextFieldAutoSize.CENTER,
				width:166
			};
			var tf:TextField = CMapUtils.createTextField(s, props);
			var hPadding:int = 7;
			var vPadding:int = 3;
			var props:Object = {};
			props[UIButton.STATE_COLORS] = colors;
			props[UIButton.WIDTH] = 166; //tf.width + hPadding*2;
			props[UIButton.DISABLED_ALPHA] = 1;
			props[UIButton.HEIGHT] = tf.height + vPadding*2;
			props[UIButton.ELLIPSE] = 6;
			
			props[UIButton.MOUSE_DOWN_DISTANCE] = 4;
			
			// toggle button configs
			props[UIButton.HAS_TOGGLE_GRAPHIC] = toggleButton;
			props[UIButton.HAS_SELECTED_STATE] = toggleButton;
			props[UIButton.USE_DROP_SHADOW] = !toggleButton;
			
			
			var b:UIButton = new UIButton(props);
			tf.x = (b.width - tf.width) / 2;
			tf.y = (b.height - tf.height) / 2 - props[UIButton.MOUSE_DOWN_DISTANCE];
			b.addLabel(tf);
			
			return b;
		}
	}
}

/*
_header = addChild(new Sprite()) as Sprite;
DrawingUtil.drawRect(_header, _width, 60, HEADER_CD);

// create tf for text scroll panel
var props:Object = {color: 0xFFFFFF,
size: 14,
align: TextFormatAlign.LEFT,
letterSpacing: 0,
autoSize: TextFieldAutoSize.LEFT,
multiline: true,
wordWrap: true,
width: _width - _tfPadding*2,
html:true
};

_tf = addChild(CMapUtils.createTextField("", props)) as TextField;
_tf.x = _tf.y = _tfPadding;
_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedCDChange, false, 0, true);
_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedLineChange, false, 0, true);
_controlPanel.controller.model.addEventListener(ModelEvent.ELEMENT_TITLE_CHANGE, handleElementTitleChange, false, 0, true);
_controlPanel.controller.model.addEventListener(ModelEvent.LINE_VALUE_CHANGE, handleLineValueChange, false, 0, true);
update(TYPE_NULL);
*/