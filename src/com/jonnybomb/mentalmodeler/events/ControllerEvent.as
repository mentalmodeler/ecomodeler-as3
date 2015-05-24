package com.jonnybomb.mentalmodeler.events
{
	import flash.events.Event;
	
	public class ControllerEvent extends Event
	{
		public static const DISABLE_ADD_NODE:String = "disableAddNode";
		public static const ENABLE_ADD_NODE:String = "enableAddNode";
		public static const STAGE_RESIZE:String = "stageResize";
		public static const UPDATE_POSITIONS:String = "updatePositions";
		public static const MAP_LOADED:String = "mapLoaded";
		
		private var _data:Object;
		
		public function ControllerEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
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