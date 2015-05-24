package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptMainDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptPropertyDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	public class TitlePanel extends AbstractPanel
	{
		private static const TYPE_NULL:int = 0;
		private static const TYPE_CD:int = 1;
		private static const TYPE_LINE:int = 2;
		private static const MAX_HEIGHT:int = 80;
		
		private var _tfPadding:int = 8;
		private var _stripe:Shape;
		private var _curNotable:INotable;
		private var _lastColorType:int = 0;
		
		public function TitlePanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
			_maxHeight = 200;
			_minHeight = 10;
		}
		
		override public function get height():Number
		{
			if (!_tf.visible)
				return _header.height	
			return super.height;
		}
			
		override public function setSize(w:Number, h:Number):void
		{
			_sizeChanged = (w != _width && w != -1) || (h != _height && h != -1);
			
			if (w > -1)
				_width = w;
			if (h > -1)
				_height = normalizeHeight(h);
			
			draw( getCurSelected() ? getCurSelected().group : _lastColorType );
			/*
			_header.height = _height;
			_header.width = _width;
			*/
		}
		
		private function draw(type:int):void
		{
			_lastColorType = type;
			var name:String = ColorData.TITLE_BG + type; 
			var cd:ColorData = ColorData.getColor(name);
			DrawingUtil.drawRect(_header, _width, _height, cd, 0, 0);
		}
		
		override public function init():void
		{
			//super.init();
			
			var cdOver:ColorData = ColorData.getColor(ColorData.BUTTON_OVER, true);
			var color:uint = GradientColorData(cdOver.fill).colors[0];
			
			_header = addChild(new Sprite()) as Sprite;
			draw(_lastColorType);
			var g:Graphics = _header.graphics;
			g.beginFill(color);//0x595959);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			
			// create tf for text scroll panel
			var props:Object = {color: 0xFFFFFF,
				size: 16,
				align: TextFormatAlign.LEFT,
				autoSize: TextFieldAutoSize.LEFT,
				letterSpacing:-1,
				multiline: true,
				wordWrap: true,
				//bold:false,
				width:_width - _tfPadding*2,
				html:true
			};
			
			_tf = addChild(CMapUtils.createTextField("", props)) as TextField;
			_tf.x = _tf.y = _tfPadding;
			_tf.filters = [new DropShadowFilter(1, 90, 0x000000, 1, 2, 2, 0.35)];
			//_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedCDChange, false, 0, true);
			//_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedLineChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.ELEMENT_TITLE_CHANGE, handleElementTitleChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.ELEMENT_GROUP_CHANGE, handleElementGroupChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.LINE_LABEL_CHANGE, handleLineLabelChange, false, 0, true);
			//_controlPanel.controller.model.addEventListener(ModelEvent.LINE_VALUE_CHANGE, handleLineValueChange, false, 0, true);
			update(TYPE_NULL, false);
			
			if (_minHeight > -1)
				setSize(-1, _minHeight);
		}
		
		private function getTitle(type:int):String
		{
			var s:String = "";
			if (type == TYPE_LINE) // Line
			{
				var line:InfluenceLineDisplay = _curNotable as InfluenceLineDisplay; 
				var nameER:String = getCDTitle(line.influencer, false, true);
				var influence:String = line.getLineLabelText();
				/*
				if (line.influenceValue == 0 || line.influenceValue == LineValueData.UNDEFINED_VALUE)
					influence = "To"
				else
					influence = (line.influenceValue > 0 ? "INCREASES" : "DECREASES") + " ("+line.influenceLabel+")";
				*/
				var nameEE:String = getCDTitle(line.influencee, false, true);
				s = nameER + "<br/><b>" + influence + "</b><br/>" + nameEE;
			}
			else if (type == TYPE_CD) // CD
			{
				var cd:ConceptDisplay = _curNotable as ConceptDisplay; 
				s = getCDTitle(cd);	
			}
			
			return s;
		}
		
		private function getCDTitle(cd:ConceptDisplay, forPropertyDisplay:Boolean = false, forLineDisplay:Boolean = false):String
		{
			var title:String = ""
			if (cd is ConceptMainDisplay)
			{
				title = cd.title != "" ? cd.title : "[Component]";
				title =  forPropertyDisplay || forLineDisplay ? title : "<b>" + title + "</b>";
			}
			else // cd is ConceptPropertyDisplay
			{
				var cpd:ConceptPropertyDisplay = cd as ConceptPropertyDisplay;
				title = getCDTitle(cpd.mainDisplay, true, forLineDisplay) + ":";
				title = title + (forLineDisplay ? (cd.title != "" ? cd.title : "[Property]") : "<b>" + (cd.title != "" ? cd.title : "[Property]") + "</b>");
			}
			return title;
		}
		
		private function update(type:int, updateLayout:Boolean = true):void
		{
			//trace("TitlePanel >> update, _curNotable:"+_curNotable+", type:"+ type)
			if (_curNotable)
			{
				enabled = true;
				var s:String = getTitle(type)
				_tf.visible = true;
				_tf.htmlText = s;
				setSize(-1, Math.ceil(_tf.height + _tfPadding*2));
			}
			else
			{
				enabled = false;
				_tf.visible = false;
				setSize(-1, 10);
			}	
			
			if (updateLayout)
				_controlPanel.updateLayout();
		}
		
		private function handleElementTitleChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			if (_curNotable)
			{
				if (_curNotable is InfluenceLineDisplay)
					update(TYPE_LINE);
				else
					update(TYPE_CD);
			}
		}
		
		private function handleElementGroupChange(e:ModelEvent):void
		{
			var curCd:ConceptDisplay = getCurCd();
			if (_curNotable && _curNotable == curCd)
				draw(curCd.group);
		}
		
		private function handleLineLabelChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			if (line)
			{
				_curNotable = line;
				update(TYPE_LINE)
			}
		}
		
		private function handleLineValueChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			if (line)
			{
				_curNotable = line;
				update(TYPE_LINE)
			}
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			var cd:ConceptDisplay = getCurCd();
			var selected:INotable = getCurSelected();
			
			//trace("TitlePanel >> handleSelectedChange, line:"+line+", cd:"+cd+", selected:"+selected);
			_curNotable = selected;
			if (_curNotable)
			{
				if (_curNotable == line)
					update(TYPE_LINE)
				else if (_curNotable == cd)	
					update(TYPE_CD)
				else
					update(TYPE_NULL);
			}
			else
				update(TYPE_NULL);
		}
		
		/*
		private function handleSelectedLineChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			trace("TitlePanel >> handleSelectedCDChange, line:"+line);
			if (line)
			{
				_curNotable = line;
				update(TYPE_LINE)
			}
			else if (!getCurCd())
			{
				_curNotable = null;
				update(TYPE_LINE);
			}
			
		}
		
		private function handleSelectedCDChange(e:ModelEvent):void
		{
			var cd:ConceptDisplay = getCurCd();
			trace("TitlePanel >> handleSelectedCDChange, cd:"+cd);
			if (cd)
			{
				_curNotable = cd;
				update(TYPE_CD);
			}
			else if (!getCurLine())
			{
				_curNotable = null;
				update(TYPE_CD);
			}
		}
		*/
	}
}