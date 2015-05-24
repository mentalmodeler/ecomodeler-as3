package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptMainDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.events.ControllerEvent;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.ui.components.radiobutton.RadioButton;
	import com.jonnybomb.ui.components.radiobutton.RadioButtonData;
	import com.jonnybomb.ui.components.radiobutton.RadioButtonGroup;
	
	import flash.events.Event;
	
	public class GroupPanel extends AbstractPanel
	{
		private var _radioGroup:RadioButtonGroup;
		
		public function GroupPanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
		}
		
		override public function init():void
		{
			super.init();
			
			// add radio buttons
			var preFillText:String = "Enter group name.";
			var padding:int = 10;
			var totalWidth:int = _width - padding*2;
			var items:Vector.<RadioButtonData> = new <RadioButtonData>[];
			for (var i:int=0; i<6; i++)
			{
				var type:String = ColorData.CD_FILL + i;
				var gcd:GradientColorData = ColorData.getColor(type).fill as GradientColorData;
				var color:uint = gcd.colors[1];
				//RadioButtonData(value:Object = null, label:String = "", selected:Boolean = false, contentRendererData:Object = null)
				var rbd:RadioButtonData = new RadioButtonData(i, "", i==0, {preFillText: preFillText, color:color});
				items.push(rbd);
			}
				
			var format:Object = {};
			format[RadioButtonGroup.SPACING_VERT] = 6;
			format[RadioButtonGroup.DOT_SPACING_HORZ] = 5;
			format[RadioButtonGroup.TOTAL_WIDTH] = totalWidth;
			_radioGroup = addChild(new RadioButtonGroup(items, GroupRadioButtonContentRenderer, format)) as RadioButtonGroup;
			_radioGroup.x = padding;
			_radioGroup.y = HEADER_HEIGHT + padding;
			_body.height = HEADER_HEIGHT + _radioGroup.height + padding*2 
			_radioGroup.addEventListener(Event.CHANGE, handleRadioButtonChange, false, 0, true);
			
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
			_controlPanel.controller.addEventListener(ControllerEvent.MAP_LOADED, handleMapLoaded, false, 0, true);
			addEventListener(GroupRadioButtonContentRenderer.GROUP_NAME_CHANGE, handleGroupNameChange, false, 0, true);
			
			enabled = false;
		}
		
		private function handleMapLoaded(e:ControllerEvent):void
		{
			var groupNames:Vector.<String> = _controlPanel.controller.model.groupNames;
			for (var i:int = 0; i < groupNames.length; i++)
			{
				var rb:RadioButton = _radioGroup.getItemAt(i);
				if (rb)
					rb.update( {label:groupNames[i]} )
			}
			
		}
		
		private function handleGroupNameChange(e:Event):void
		{
			var renderer:GroupRadioButtonContentRenderer = e.target as GroupRadioButtonContentRenderer;
			if (renderer)
			{
				var rb:RadioButton = renderer.parent as RadioButton;
				if (rb)
					_controlPanel.controller.setGroupName(renderer.text, _radioGroup.getItemIndex(rb))
					//trace("\tidx:"+idx+", renderer.text:"+renderer.text);
			}
		}
		
		private function handleRadioButtonChange(e:Event):void
		{
			var curCd:ConceptDisplay = getCurCd();
			var curSelected:INotable = getCurSelected();
			
			//trace("handleRadioButtonChange, selectedView:"+selectedView+", curCd:"+curCd+", curSelected:"+curSelected);
			
			if (curSelected && curCd && curSelected == curCd && curCd is ConceptMainDisplay)
			{
				curCd.group = selectedView;
				_controlPanel.controller.model.elementGroupChange();
			}
		}
		
		public function get selectedView():int
		{
			var view:int = 0;
			if (_radioGroup && _radioGroup.selectedValue)
				view = int(_radioGroup.selectedValue);
			return view;
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			var curCd:ConceptDisplay = getCurCd();
			var curSelected:INotable = getCurSelected();
			
			//trace("handleSelectedChange, selectedView:"+selectedView+", curCd:"+curCd+", curSelected:"+curSelected);
			
			if (curSelected && curCd && curSelected == curCd && curCd is ConceptMainDisplay)
			{
				enabled = true;
				_radioGroup.selectItemAt(curCd.group);
			}
			else
				enabled = false;
		}
	}
}