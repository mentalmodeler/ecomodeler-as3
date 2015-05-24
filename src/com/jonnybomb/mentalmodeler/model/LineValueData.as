package com.jonnybomb.mentalmodeler.model
{
	import com.jonnybomb.mentalmodeler.CMapConstants;

	public class LineValueData
	{
		//public static const NULL_VALUE:Number = 999;
		public static const UNDEFINED_VALUE:Number = 0;
		public static const REMOVE_VALUE:Number = 1000;
		
		public var value:Number = 0;
		public var stringValue:String = CMapConstants.INFLUENCE_STRING_VALUE_UNDEFINED;
		public var label:String = "";
		public var size:int = 15;
		public var color:uint = 0x000000;
		public var x:Number = 0;
		public var y:Number = 0;
		public var letterSpacing:Number = 0;
		
		public function LineValueData(stringValue:String = CMapConstants.INFLUENCE_STRING_VALUE_UNDEFINED, value:Number = UNDEFINED_VALUE, label:String = "", size:int = 15, color:uint = 0x000000, x:Number = 0, y:Number = 0, letterSpacing:int = 0)
		{
			this.stringValue = stringValue;
			this.value = value;
			this.label = label;
			this.size = size;
			this.color = color;
			this.x = x;
			this.y = y;
			this.letterSpacing = letterSpacing;
			//trace(this);
		}
		
		public function toString():String
		{
			return "LineValueData >> value:"+value+", label:"+label+", size:"+size+", color:"+color+", x:"+x+", y:"+y+", letterSpacing:"+letterSpacing;
		}
	}
}