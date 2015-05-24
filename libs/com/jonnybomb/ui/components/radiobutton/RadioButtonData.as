package com.jonnybomb.ui.components.radiobutton
{
	import com.jonnybomb.ui.utils.ObjectUtil;
	import flash.display.DisplayObject;
	
	/**
	 * @author DCD - Jonathan Elbom
	 */
	
	public class RadioButtonData
	{
		public var value:Object = null;
		public var selected:Boolean = false;
		public var totalWidth:int = 0;
		
		private var _contentRendererData:Object = null;
		private var _label:String = "";
		
		public function RadioButtonData(value:Object = null, label:String = "", selected:Boolean = false, contentRendererData:Object = null)
		{
			this.value = value;
			this.contentRendererData = contentRendererData;
			this.selected = selected;
			this.label = label;
		}
		
		public function finalize():void
		{
			if (value != null)
				ObjectUtil.deleteValues(value);
			value = null;
			
			ObjectUtil.deleteValues(contentRendererData);
			contentRendererData = null;
		}
		
		public function set contentRendererData(value:Object):void { _contentRendererData = value; }
		public function get contentRendererData():Object
		{ 
			if (_contentRendererData != null && !("label" in _contentRendererData))
				_contentRendererData.label = label;
			
			return _contentRendererData;
		}
		
		public function set label(value:String):void { _label = value; }
		public function get label():String
		{ 
			var s:String = _label.concat();
			//if (s == "" && "toString" in value)
			//	s = value["toString"]();
			return s;
		}
	}
}