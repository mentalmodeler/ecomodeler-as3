package com.jonnybomb.mentalmodeler.model.data
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	
	import flash.utils.Dictionary;

	public class ColorData extends Object
	{
		public static var CD_FILL:String = "cdFill";
		public static var CD_FILL_0:String = "cdFill0";
		public static var CD_FILL_1:String = "cdFill1";
		public static var CD_FILL_2:String = "cdFill2";
		public static var CD_FILL_3:String = "cdFill3";
		public static var CD_FILL_4:String = "cdFill4";
		public static var CD_FILL_5:String = "cdFill5";
		
		public static var TITLE_BG:String = "titleBg";
		public static var TITLE_BG_0:String = "titleBg0";
		public static var TITLE_BG_1:String = "titleBg1";
		public static var TITLE_BG_2:String = "titleBg2";
		public static var TITLE_BG_3:String = "titleBg3";
		public static var TITLE_BG_4:String = "titleBg4";
		public static var TITLE_BG_5:String = "titleBg5";
		
		public static var CD_LINE_LINK:String = "cdLineLink";
		public static var CD_LINE_LINK_0:String = "cdLineLink0";
		public static var CD_LINE_LINK_1:String = "cdLineLink1";
		public static var CD_LINE_LINK_2:String = "cdLineLink2";
		public static var CD_LINE_LINK_3:String = "cdLineLink3";
		public static var CD_LINE_LINK_4:String = "cdLineLink4";
		public static var CD_LINE_LINK_5:String = "cdLineLink5";
		
		public static var CD_OUTLINE_OVER:String = "cdOutlineOver";
		public static var CD_OUTLINE_OVER_0:String = "cdOutlineOver0";
		public static var CD_OUTLINE_OVER_1:String = "cdOutlineOver1";
		public static var CD_OUTLINE_OVER_2:String = "cdOutlineOver2";
		public static var CD_OUTLINE_OVER_3:String = "cdOutlineOver3";
		public static var CD_OUTLINE_OVER_4:String = "cdOutlineOver4";
		public static var CD_OUTLINE_OVER_5:String = "cdOutlineOver5";
		
		public static var CD_PROP_FILL:String = "cdPropFill";
		public static var CD_PROP_FILL_0:String = "cdPropFill0";
		public static var CD_PROP_FILL_1:String = "cdPropFill1";
		public static var CD_PROP_FILL_2:String = "cdPropFill2";
		public static var CD_PROP_FILL_3:String = "cdPropFill3";
		public static var CD_PROP_FILL_4:String = "cdPropFill4";
		public static var CD_PROP_FILL_5:String = "cdPropFill5";
		
		public static var LINE_LABEL_EDITOR_OUTLINE:String = "lineLabelEditorOutline";
		public static var LINE_LABEL_EDITOR_FILL:String = "lineLabelEditorFill";
		public static var CD_STATUS_FILL:String = "cdStatusFill";
		public static var CD_OUTLINE:String = "cdOutline";
		public static var CD_PROP_OUTLINE:String = "cdPropOutline";
		public static var CD_PROP_OUTLINE_OVER:String = "cdPropOutlineOver";
		public static var CD_HIT:String = "cdHit";
		public static var ALERT_BUTTON_UP:String = "alertButtonUp";
		public static var ALERT_BUTTON_OVER:String = "alertButtonOver";
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
				case TITLE_BG_0:
					cd = new ColorData();
					cd.fill =  new GradientColorData([0x992C1E, 0xE53E29], [1, 1], [30, 255]); 
					break;
				case TITLE_BG_1:
					cd = new ColorData();
					cd.fill =  new GradientColorData([0x994F1E, 0xE57429], [1, 1], [30, 255]); 
					break;
				case TITLE_BG_2:
					cd = new ColorData();
					cd.fill =  new GradientColorData([0x1E4799, 0x2971E5], [1, 1], [30, 255]); 
					break;
				case TITLE_BG_3:
					cd = new ColorData();
					cd.fill =  new GradientColorData([0x99991E, 0xE5E529], [1, 1], [30, 255]); 
					break;
				case TITLE_BG_4:
					cd = new ColorData();
					cd.fill =  new GradientColorData([0x991E99, 0xE529E5], [1, 1], [30, 255]); 
					break;
				case TITLE_BG_5:
					cd = new ColorData();
					cd.fill =  new GradientColorData([0x1E9970, 0x14D192], [1, 1], [30, 255]); 
					break;
				case CD_FILL_0:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xFFFFFF, 0xE6E6E6], [1, 1], [60, 255]); 
					break;
				case CD_FILL_1:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xFFFFFF, 0xFFD0B2], [1, 1], [60, 255]); 
					break;
				case CD_FILL_2:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xFFFFFF, 0xB2CFFF], [1, 1], [60, 255]); 
					break;
				case CD_FILL_3:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xFFFFFF, 0xFFFFB2], [1, 1], [60, 255]); 
					break;
				case CD_FILL_4:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xFFFFFF, 0xFFB2FF], [1, 1], [60, 255]); 
					break;
				case CD_FILL_5:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xFFFFFF, 0xB2FFE5], [1, 1], [60, 255]); 
					break;
				case CD_PROP_FILL:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xB2B2B2, 0x7F7F7F], [1, 1], [0, 255]); 
					break;
				case CD_PROP_FILL_0:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xB2B2B2, 0x7F7F7F], [1, 1], [0, 255]); 
					break;
				case CD_PROP_FILL_1:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xB2B2B2, 0x7F6258], [1, 1], [0, 255]); 
					break;
				case CD_PROP_FILL_2:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xB2B2B2, 0x58627F], [1, 1], [0, 255]); 
					break;
				case CD_PROP_FILL_3:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xB2B2B2, 0x7F7F58], [1, 1], [0, 255]); 
					break;
				case CD_PROP_FILL_4:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xB2B2B2, 0x7F587F], [1, 1], [0, 255]); 
					break;
				case CD_PROP_FILL_5:
					cd = new ColorData();
					cd.fill = new GradientColorData([0xB2B2B2, 0x587F72], [1, 1], [0, 255]); 
					break;
				case CD_LINE_LINK:
					cd = new ColorData();
					cd.fill = new ColorExtended(0xE53E29, 1);
					break;
				case CD_LINE_LINK_0:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xE53E29, 1);
					//cd.fill = new ColorExtended(0xA6E529, 0.5);
					break;
				case CD_LINE_LINK_1:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xE57429, 1);
					//cd.fill = new ColorExtended(0xE52929, 0.5);
					break;
				case CD_LINE_LINK_2:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x2971E5,1);
					//cd.fill = new ColorExtended(0x2929E5, 0.5);
					break;
				case CD_LINE_LINK_3:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xE5E529,1);
					//cd.fill = new ColorExtended(0x29E5E5, 0.5);
					break;
				case CD_LINE_LINK_4:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0xE529E5, 1);
					//cd.fill = new ColorExtended(0xE5E529, 0.5);
					break;
				case CD_LINE_LINK_5:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x14D192, 1);	
					//cd.fill = new ColorExtended(0xE529E5, 0.5);	
					break;
				case CD_OUTLINE_OVER:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xE53E29, 1);
					break;
				case CD_OUTLINE_OVER_0:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xE53E29, 1);
					break;
				case CD_OUTLINE_OVER_1:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xE57429, 1);
					break;
				case CD_OUTLINE_OVER_2:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0x2971E5, 1);
					break;
				case CD_OUTLINE_OVER_3:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xE5E529, 1);
					break;
				case CD_OUTLINE_OVER_4:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xE529E5, 1);
					break;
				case CD_OUTLINE_OVER_5:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0x14D192, 1);	
					break;
				case LINE_LABEL_EDITOR_OUTLINE:
					cd = new ColorData();
					cd.fill = new ColorExtended(0x333333, 1); 
					break;
				case LINE_LABEL_EDITOR_FILL:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x333333, 1); 
					cd.fill = new ColorExtended(0xFFFFFF, 1); 
					break;
				case ALERT:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x656565, 1); 
					cd.fill = new GradientColorData(CMapConstants.UP_COLOR_GRAD/*[0xcccccc, 0x999999]*/, [1, 1], [0, 255]); 
					//cd.stroke = new ColorExtended(0x000000, 1); 
					//cd.fill = new GradientColorData([0xFFFFFF, 0xCCCCCC], [1, 1], [0, 255]); 
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
				case CD_PROP_OUTLINE:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xB2B2B2, 1);
					break;
				case CD_PROP_OUTLINE_OVER:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000, 1); 
					cd.fill = new ColorExtended(0xFFFFFF, 1);
					break;
				case ALERT_BUTTON_UP:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x424242, 1); 
					cd.fill = new GradientColorData([0xcccccc, 0xaaaaaa], [1, 1], [90, 255]);
					break;
				case ALERT_BUTTON_OVER:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x424242, 1); 
					cd.fill = new GradientColorData(CMapConstants.OVER_COLOR_GRAD/*[0xF2BA17, 0xE69215]*/, [1, 1], [90, 255]);
					break;
				case BUTTON_UP:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x666666, 1); 
					cd.fill = new GradientColorData([0x7f7f7f, 0x666666], [1, 1], [90, 255]);
					//cd.stroke = new ColorExtended(0x000000, 1); 
					//cd.fill = new GradientColorData([0x000000, 0x333333], [1, 1], [90, 255]); 
					break;
				case BUTTON_OVER:
					cd = new ColorData();
					cd.stroke = new ColorExtended(0x000000/*0x141A33*/, 1); 
					cd.fill = new GradientColorData(CMapConstants.OVER_COLOR_GRAD/*[0xF2BA17, 0xE69215]*/, [1, 1], [90, 255]); /*0x557302, 0x83A603*/
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
					cd.fill = new GradientColorData(CMapConstants.OVER_COLOR_GRAD/*[0x557302, 0x83A603]*/, [1, 1], [90, 255]); 
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