package com.jonnybomb.mentalmodeler.events
{
	import flash.events.Event;
	
	public class ModelEvent extends Event
	{
		public static const SELECTED_CHANGE:String = "selectedChange";
		public static const SELECTED_CD_CHANGE:String = "selectedCdChange";
		public static const SELECTED_LINE_CHANGE:String = "selectedLineChange";
		public static const ELEMENT_TITLE_CHANGE:String = "elementTitleChange";
		public static const ELEMENT_GROUP_CHANGE:String = "elementGroupChange";
		public static const LINE_LABEL_CHANGE:String = "lineLabelChange";
		public static const LINE_VALUE_CHANGE:String = "lineValueChange";
		
		private var _data:Object;
		
		public function ModelEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
		public override function clone():Event 
		{ 
			return new ControllerEvent(type, _data, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ControllerEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}