package com.mincomps.data
{
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Dictionary;

	
	public class MinCompsColorData extends Object
	{
		// Standard TN 7.5 Button
		public static var TN_75_BUTTON_UP:String = "tn75ButtonUp";
		public static var TN_75_BUTTON_OVER:String = "tn75ButtonOver";
		public static var TN_75_BUTTON_BEVEL:String = "tn75ButtonBevel";
		public static var TN_75_BUTTON_SELECTED_GLOW:String = "tn75ButtonSelectedGlow";
		
		// ScrollBar
		public static var TN_75_SCROLLBAR_THUMB:String = "tn75ScrollbarThumb";
		public static var TN_75_SCROLLBAR_BUTTON:String = "tn75ScrollbarButton";
		public static var TN_75_SCROLLBAR_TRACK:String = "tn75ScrollbarTrack";
		public static var TN_75_SCROLLBAR_ARROW:String = "tn75ScrollbarArrow";
		
		public static var GRADIENT_TEXT_MASK:String = "gradientTextMask";
		
		public static var TYPE_SOLID:String = "typeSolid";
		public static var TYPE_GRADIENT:String = "typeGradient";
		
		public static var colorsDict:Dictionary = new Dictionary();
		
		private var _stroke:Object;
		private var _fill:Object;
		
		public function MinCompsColorData(cStroke:Object = null, cFill:Object = null)
		{
			if (cStroke) stroke = cStroke;
			if (cFill) fill = cFill;
		}
		
		public function get stroke():Object { return _stroke };
		public function set stroke(stroke:Object):void
		{
			if ((stroke is MinCompsColorExtended) || (stroke is MinCompsGradientColorData) || stroke == null)
				_stroke = stroke;
			else
				throw new Error("ColorData >> stroke is not MinCompsColorExtended or MinCompsGradientColorData");	
		}
		
		public function get fill():Object { return _fill };
		public function set fill(fill:Object):void
		{
			if ((fill is MinCompsColorExtended) || (fill is MinCompsGradientColorData) || fill == null)
				_fill = fill;
			else
				throw new Error("ColorData >> fill is not MinCompsColorExtended or MinCompsGradientColorData");	
		}
		
		public static function getColor(s:String):MinCompsColorData
		{
			if (colorsDict[s])
				return colorsDict[s];
				
			var cd:MinCompsColorData;
			switch (s)
			{
				case TN_75_BUTTON_UP:
					cd = new MinCompsColorData();
					cd.stroke = new MinCompsColorExtended(0x154B88, 1);
					cd.fill = new MinCompsGradientColorData([0x4B89C0, 0x4180B8, 0x386FA0, 0x548EC2], [1, 1, 1, 1], [0, 105, 180, 255]); 
					break;
			
				case TN_75_BUTTON_OVER:
					cd = new MinCompsColorData();
					cd.stroke = new MinCompsColorExtended(0x873E15, 1);
					cd.fill = new MinCompsGradientColorData([0xE17138, 0xDC5F1F, 0xC74A03, 0xDA5915], [1, 1, 1, 1], [0, 105, 180, 255]); 
					break;
				
				case TN_75_BUTTON_BEVEL:
					cd = new MinCompsColorData();
					cd.stroke = new MinCompsColorExtended(0x000000, 0); 
					cd.fill = new MinCompsColorExtended(0x000000, 1); 
					break;
				
				case TN_75_BUTTON_SELECTED_GLOW:
					cd = new MinCompsColorData();
					cd.stroke = new MinCompsColorExtended(0xFF0000, 1); 
					cd.fill = new MinCompsColorExtended(0xFF0000, 1); 
					break;
				
				case TN_75_SCROLLBAR_THUMB:
					cd = new MinCompsColorData();
					//cd.stroke = new MinCompsColorExtended(0xFF0000, 0);
					cd.stroke = new MinCompsColorExtended(0x404040, 1);
					cd.fill = new MinCompsGradientColorData([0xD9D9D9, 0xD9D9D9, 0xBFBFBF, 0xBFBFBF], [1, 1, 1, 1], [0, 90/*102*/, 165/*153*/, 255], 0);
					break;
				
				case TN_75_SCROLLBAR_BUTTON:
					cd = new MinCompsColorData();
					cd.stroke = new MinCompsColorExtended(0x404040, 1);
					cd.fill = new MinCompsGradientColorData([0xD9D9D9, 0xD9D9D9, 0xBFBFBF, 0xBFBFBF], [1, 1, 1, 1], [0, 90/*102*/, 165/*153*/, 255], 0);
					break;
				
				case TN_75_SCROLLBAR_TRACK:
					cd = new MinCompsColorData();
					cd.stroke = new MinCompsColorExtended(0x404040, 1);
					cd.fill = new MinCompsColorExtended(0x8C8C8C, 1);
					break;
				
				case TN_75_SCROLLBAR_ARROW:
					cd = new MinCompsColorData();
					cd.fill = new MinCompsColorExtended(0x404040, 1);
					break;
				
				case GRADIENT_TEXT_MASK:
					cd = new MinCompsColorData();
					cd.fill = new MinCompsGradientColorData([0x00FF00, 0x00FF00, 0x00FF00], [1, 1, 0], [0, 225, 255]);
					cd.fill.rotation = 0;
					break;
			}
			
			//colorsDict[s] = cd;
			return cd;
		}
	}
}