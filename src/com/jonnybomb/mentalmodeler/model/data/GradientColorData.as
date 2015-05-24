package com.jonnybomb.mentalmodeler.model.data
{
	import flash.display.GradientType;

	public class GradientColorData extends Object
	{
		public var colors:Array;
		public var alphas:Array;
		public var ratios:Array;
		public var gradType:String;
		
		private var _rotation:Number = 90;
		
		public function GradientColorData(colors:Array, alphas:Array, ratios:Array, rot:Number = -1, gradType:String = "")
		{
			this.colors = colors;
			this.alphas = alphas;
			this.ratios = ratios;
			
			if (gradType == "")
				this.gradType =GradientType.LINEAR;
			
			if (rot >= 0)
				_rotation = rot;
		}
		
		//public function get type():String { return ColorData.TYPE_GRADIENT };
		public function get rotation():Number { return Math.PI/180 * _rotation };
		public function set rotation(value:Number):void { _rotation = value };
	}
}