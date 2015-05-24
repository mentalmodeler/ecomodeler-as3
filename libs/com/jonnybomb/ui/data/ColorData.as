package com.jonnybomb.ui.data
{
	import flash.utils.Dictionary;

	public class ColorData extends Object
	{
		public static var CD_FILL:String = "cdFill";
		public static var CD_STATUS_FILL:String = "cdStatusFill";
		public static var CD_OUTLINE:String = "cdOutline";
		public static var CD_OUTLINE_OVER:String = "cdOutlineOver";
		public static var CD_HIT:String = "cdHit";
		public static var BUTTON_UP:String = "buttonUp";
		public static var BUTTON_OVER:String = "buttonOver";
		public static var BUTTON_BEVEL:String = "buttonBevel";
		public static var BUTTON_DOWN:String = "buttonDown";
		public static var BUTTON_SELECTED:String = "buttonSelected";
		public static var BUTTON_SELECTED_BEVEL:String = "buttonSelectedBevel";
		public static var BUTTON_SELECTED_GLOW:String = "buttonSelectedGlow";
		public static var CHECKBOX_UP:String = "checkboxUp";
		public static var CHECKBOX_OVER:String = "checkboxOver";
		public static var CHECKBOX_BEVEL:String = "checkboxBevel";
		
		public static var ALERT:String = "alert";
		
		public static var TYPE_SOLID:String = "typeSolid";
		public static var TYPE_GRADIENT:String = "typeGradient";
		
		public static var colorsDict:Dictionary = new Dictionary();
		
		private var _stroke:Object;
		private var _fill:Object;
		
		public function ColorData(cStroke:Object = null, cFill:Object = null)
		{
			if (cStroke) stroke = cStroke;
			if (cFill) fill = cFill;
		}
		
		public function finalize():void
		{
			_stroke = null;
			_fill = null;
		}
		
		public function get stroke():Object { return _stroke };
		public function set stroke(stroke:Object):void
		{
			if ((stroke is ColorExtended) || (stroke is GradientColorData) || stroke == null)
				_stroke = stroke;
			else
				throw new Error("ColorData >> stroke is not ColorExtended or GradientColorData");	
		}
		
		public function get fill():Object { return _fill };
		public function set fill(fill:Object):void
		{
			if ((fill is ColorExtended) || (fill is GradientColorData) || fill == null)
				_fill = fill;
			else
				throw new Error("ColorData >> fill is not ColorExtended or GradientColorData");	
		}
		
		public static function getColor(s:String, clone:Boolean = false):ColorData
		{
			if (!clone && colorsDict[s])
				return colorsDict[s];
				
			var cd:ColorData;
			switch (s)
			{
				case ALERT:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new GradientColorData([0xFFFFFF, 0xCCCCCC], [1, 1], [0, 255]); 
					break;
				
				case CD_FILL:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xFFFFFF, 0xE6E6E6], [1, 1], [0, 255]); 
					break;
			
				case CD_STATUS_FILL:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xFFFFFF, 1);
					break;
				
				case CD_OUTLINE:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xFFFFFF, 1);
					break;
				
				case CD_OUTLINE_OVER:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0x83A603/*0xB0D856 0x83A603*/, 1);
					break;
				
				case BUTTON_UP:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new GradientColorData([0x000000, 0x333333], [1, 1], [90, 255]); 
					break;
				
				case BUTTON_OVER:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000/*0x141A33*/, 1); 
					cd.fill = new GradientColorData([0x557302, 0x83A603], [1, 1], [90, 255]); 
					break;
				
				case BUTTON_SELECTED:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xFFFFFF, 1); 
					cd.fill = new GradientColorData([0xE0C502, 0xFAE302], [1, 1], [90, 255]); 
					break;
				
				case BUTTON_BEVEL:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xFF0000, 0); 
					cd.fill = new GradientColorData([0xFFFFFF, 0xFFFFFF, 0xFFFFFF], [0.6, 0.4, 0.2], [0, 10, 110]); 
					break;
				
				case BUTTON_SELECTED_GLOW:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xFF0000, 1); 
					cd.fill = new ColorExtended(0x00FF00, 1);
					break;
				
				case BUTTON_SELECTED_BEVEL:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xFF0000, 0); 
					cd.fill = new GradientColorData([0xFFFFFF, 0xFFFFFF, 0xFFFFFF], [0.9, 0.6, 0.4], [0, 10, 110]); 
					break;
				
				case CHECKBOX_UP:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new GradientColorData([0x000000, 0x333333], [1, 1], [90, 255]); 
					break;
				
				case CHECKBOX_OVER:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000/*0x141A33*/, 1); 
					cd.fill = new GradientColorData([0x557302, 0x83A603], [1, 1], [90, 255]); 
					break;
				
				case BUTTON_SELECTED:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xFFFFFF, 1); 
					cd.fill = new GradientColorData([0xE0C502, 0xFAE302], [1, 1], [90, 255]); 
					break;
				
				case CHECKBOX_BEVEL:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xFF0000, 0); 
					cd.fill = new GradientColorData([0xFFFFFF, 0xFFFFFF, 0xFFFFFF], [0.6, 0.4, 0.2], [0, 10, 110]); 
					break;
				
				case CD_HIT:
					cd = new ColorData();
					cd.fill = new ColorExtended(0xFF0000, 0);
					break;
			}
			
			if (!clone)
				colorsDict[s] = cd;
			
			return cd;
		}
	}
}