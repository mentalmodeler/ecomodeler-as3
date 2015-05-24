package com.jonnybomb.mentalmodeler
{
	import com.jonnybomb.mentalmodeler.display.controls.LineValue;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	public class CMapConstants
	{
		// fonts
		[Embed(source="../../../compile-time-assets/fonts/verdana.ttf", embedAsCFF="false", fontName="VerdanaEmbedded", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", mimeType="application/x-font")]
		public static var VerdanaBook:Class;
		
		[Embed(source="../../../compile-time-assets/fonts/verdanab.ttf", embedAsCFF="false", fontName="VerdanaEmbedded", fontWeight="bold", fontStyle="normal", advancedAntiAliasing="true", mimeType="application/x-font")]
		public static var VerdanaBold:Class;
		
		public static var cdMinHeight:int = 0;
		public static const DUAL_LINE_OFFSET:int = 30;
		
		public static const FONT_FAMILY:String = "VerdanaEmbedded";
		public static const APP_NODE_NAME:String = "ecoModeler";
		public static const COMPONENT_NODE_NAME:String = "concept"; //"component";
		public static const COMPONENTS_NODE_NAME:String = "concepts"; //"component";
		public static const PROPERTIES_NODE_NAME:String = "properties"; //"component";
		public static const INFLUENCE_NODE_NAME:String = "relationship"; //"influence";
		public static const INFLUENCES_NODE_NAME:String = "relationships";
		public static const INFLUENCED_ID_NODE_NAME:String = "id";
		public static const INFLUENCED_NAME_NODE_NAME:String = "name";
		public static const INFLUENCE_VALUE_NODE_NAME:String = "influence";
		
		public static const UP_COLOR_GRAD:Array = [0x7f7f7f, 0x666666];
		public static const OVER_COLOR_GRAD:Array = [0xE5655B, 0xCC331E]; //[0xF2BA17, 0xE69215];
		
		//public static const GROUP_PREFILL:String = "Enter group name";
		/*
		public static const GROUPS:Vector.<Object> = new <Object>[ {},
																   {},
																   {},
																   {},
																   {},
																   {},
																 ];
		*/
		public static const INFLUENCE_VALUE_POSITIVE_HIGH:Number = 1;
		public static const INFLUENCE_VALUE_POSITIVE_MEDIUM:Number = 0.62;
		public static const INFLUENCE_VALUE_POSITIVE_LOW:Number = 0.25;
		public static const INFLUENCE_VALUE_NEGATIVE_HIGH:Number = -1;
		public static const INFLUENCE_VALUE_NEGATIVE_MEDIUM:Number = -0.62;
		public static const INFLUENCE_VALUE_NEGATIVE_LOW:Number = -0.25;
		
		public static const INFLUENCE_STRING_VALUE_POSITIVE_HIGH:String = "H+";
		public static const INFLUENCE_STRING_VALUE_POSITIVE_MEDIUM:String = "M+";
		public static const INFLUENCE_STRING_VALUE_POSITIVE_LOW:String = "L+";
		public static const INFLUENCE_STRING_VALUE_NEGATIVE_HIGH:String = "H-";
		public static const INFLUENCE_STRING_VALUE_NEGATIVE_MEDIUM:String = "M-";
		public static const INFLUENCE_STRING_VALUE_NEGATIVE_LOW:String = "L-";
		public static const INFLUENCE_STRING_VALUE_UNDEFINED:String = "undefined";
		public static const INFLUENCE_STRING_VALUE_NULL:String = "null";
		
		public static var FILE_FILTER_NAME:String = "EcoModeler file";
		public static var FILE_EXTENSION:String = ".emp";
		
		public static var DEFAULT_LINE_TITLE:String = "To"
		public static var LINE_LABEL_EDITOR_MAX_TEXT_WIDTH:int = 300;
		public static var LINE_LABEL_EDITOR_MAX_TEXT_HEIGHT:int = 42;
		public static var LINE_LABEL_EDITOR_PADDING:int = 3;
		public static var LINE_LABEL_EDITOR_STROKE:int = 3;
		public static var LINE_LABEL_EDITOR_ELLIPSE:int = 12;
		public static var LINE_LABEL_EDITOR_DS:DropShadowFilter = new DropShadowFilter(3, 90, 0x000000, 1, 10, 10, 0.5, BitmapFilterQuality.MEDIUM);
		
		public static const CD_SELECTED_GLOW:GlowFilter = new GlowFilter(0xFF0000, 1, 5, 5, 2, BitmapFilterQuality.MEDIUM);
		public static const CD_DROP_SHADOW:DropShadowFilter = new DropShadowFilter(3, 90/*75*/, 0x000000, 1, 8, 8, 0.5, BitmapFilterQuality.MEDIUM, false, true);
		public static const INSET_BEVEL:BevelFilter = new BevelFilter(1, 270, 0xFFFFFF, 0, 0x000000, 0.5, 1, 1, 2, BitmapFilterQuality.LOW, BitmapFilterType.OUTER);
		public static const BG_INSET_SHADOW:GlowFilter = new GlowFilter(0x000000, 1, 16, 16, 0.35, BitmapFilterQuality.MEDIUM, true, false);
		public static const UI_DROP_SHADOW:DropShadowFilter = new DropShadowFilter(1, 180, 0x000000, 1, 6, 6, 0.4, BitmapFilterQuality.MEDIUM);
		public static const WIDTH_START:int = 650;
		public static const HEIGHT_START:int = 400;
		
		public static const ALERT_PADDING:int = 30;
		public static const ALERT_SPACING:int = 30;
		public static const ALERT_BLOCKER_ALPHA:Number= 0.7;
		public static const ALERT_STROKE:int = 2;
		public static const ALERT_ELLIPSE:int = 10;
		
		public static const MESSAGE_LOAD_OVERWRITE:String = "Loading a file will delete any current edits. If you want to save you current file, please save this file before loading another.<br><br>What would you like to do?";
		public static const MESSAGE_LOAD_SELECT:String = "Please use the browse dialog to select a EcoModeler(.emp) file to load.";
		public static const MESSAGE_SAVE_SELECT:String = "Please use the save dialog to save your EcoModeler work as an .emp file.";
		public static const MESSAGE_SCREENSHOT_SELECT:String = "Please use the save dialog to export a screenshot(.png) of your EcoModeler work.";
		public static const LINE_PREFILL_TEXT:String = "Enter line description" ; // "Enter name";
		public static const NODE_PREFILL_TEXT:String = "Enter component" ; // "Enter name";
		public static const PROP_PREFILL_TEXT:String = "Enter property";
		public static const NOTES_PREFILL_TEXT:String = "Enter notes";
		public static const ADD_NODE_LABEL:String = "ADD COMPONENT";
		
		public static const LINE_LABEL_PADDING:int = 25;
		
		public static const ADD_BUTTON_POS_PADDING:int = 20;
		public static const CD_POS_START_PCT:Number = 0.8;
		public static const LINEFILL_COLOR:int = 0xFFFF00;
		public static const INFLUENCE_LINE_THICKNESS:int = 2;
		public static const INFLUENCE_LINE_COLOR:int = 0x000000; //0x154B88;
		public static const ARROWHEAD_WIDTH:int = 16;
		public static const ARROWHEAD_HEIGHT:int = 13;
		public static const RADIUS_FILL:int = 30;
		public static const RADIUS_LINEFILL:int = 40;
		public static const COLORS:Array = [0xFFAA00, 0xC2B93E, 0x808F5D];
		public static const CD_TEXT_PADDING:uint = 10;
		public static const CD_MAX_NUM_LINES:uint = 3;
		public static const CD_WIDTH:int = 180;//170; //90; //164;
		public static const CD_WIDTH_MAX:int = 220; //170; //164;
		public static const CD_LABEL_PADDING:int = 10;
		public static const CD_HEIGHT:int = 35; //64;
		public static const CD_OUTLINE_STROKE:int = 1;
		public static const CD_STATUSFILL_STROKE:int = 3;
		public static const CD_ELLIPSE:int = 0; //20;
		public static const CD_SIZE_ADJ:int = 20;
		public static const CD_ADD_POS_OFFSET:int = 5;
		public static const CD_ADD_POS_INCR:int = 20;
		public static const DRAW_WIDTH:int = 88;
		public static const DRAW_HEIGHT:int = 25;
		public static const CLOSE_WIDTH_HEIGHT:int = 25;
		public static const BUTTON_STROKE:int = 1;
		public static const DRAW_ELLIPSE:int = 20; //50;
		public static const CLOSE_ELLIPSE:int = 25; //30
		public static const BUTTON_WIDTH:int = 30;
		public static const BUTTON_HEIGHT:int = 25;
		public static const BUTTON_ELLIPSE:int = 6;//10;
		public static const LINE_CLOSE_ELLIPSE:int = 6;//10;
		public static const LINE_CLOSE_SIDE:int = 20;
		public static const DISABLED_ALPHA:Number = 0.15;
		
		public static const LINES_OFFSET:int = 50;
		public static const LINE_VALUE_WIDTH:int = 60; //LINE_CLOSE_SIDE; //60;
		public static const LINE_VALUE_INDICATOR_WIDTH:int = LINE_CLOSE_SIDE; //36;
		public static const LINE_VALUE_HEIGHT:int = 26;
		public static const LINE_VALUE_BORDER:int = 2;
		public static const LINE_VALUE_DEFAULT:LineValueData = new LineValueData(INFLUENCE_STRING_VALUE_UNDEFINED, LineValueData.UNDEFINED_VALUE, "?", 15, 0x000000, -1, -1);
		public static const LINE_VALUE_REMOVE:LineValueData = new LineValueData(INFLUENCE_STRING_VALUE_NULL, LineValueData.REMOVE_VALUE, LINE_VALUE_REMOVE_LABEL, 15, 0x000000, -1, -1);
		public static const LINE_VALUES:Vector.<LineValueData> = new <LineValueData>[ new LineValueData(INFLUENCE_STRING_VALUE_POSITIVE_HIGH, INFLUENCE_VALUE_POSITIVE_HIGH, "+++", 15, 0x0351A6, 0, -1), //0x023973
																					  new LineValueData(INFLUENCE_STRING_VALUE_POSITIVE_MEDIUM, INFLUENCE_VALUE_POSITIVE_MEDIUM, "++", 15, 0x0351A6, 0, -1),
																					  new LineValueData(INFLUENCE_STRING_VALUE_POSITIVE_LOW, INFLUENCE_VALUE_POSITIVE_LOW, "+", 15, 0x0351A6, 0, -1), //0x5688D8
																					  new LineValueData(INFLUENCE_STRING_VALUE_NEGATIVE_LOW, INFLUENCE_VALUE_NEGATIVE_LOW, "-", 17, 0xBF5513, 1, -1, 3), //0xD87756
																					  new LineValueData(INFLUENCE_STRING_VALUE_NEGATIVE_MEDIUM, INFLUENCE_VALUE_NEGATIVE_MEDIUM, "--", 17, 0xBF5513, 1, -1, 3),
																					  new LineValueData(INFLUENCE_STRING_VALUE_NEGATIVE_HIGH, INFLUENCE_VALUE_NEGATIVE_HIGH, "---", 17, 0xBF5513, 1, -1, 3) //0x8C400E
																					];
		/*
		public static const LINE_VALUES:Vector.<LineValueData> = new <LineValueData>[ new LineValueData(INFLUENCE_STRING_VALUE_POSITIVE_HIGH, INFLUENCE_VALUE_POSITIVE_HIGH, "+++ Increase Greatly", 15, 0x0351A6, 0, -1), //0x023973
		new LineValueData(INFLUENCE_STRING_VALUE_POSITIVE_MEDIUM, INFLUENCE_VALUE_POSITIVE_MEDIUM, " ++ Increase ", 15, 0x0351A6, 0, -1),
		new LineValueData(INFLUENCE_STRING_VALUE_POSITIVE_LOW, INFLUENCE_VALUE_POSITIVE_LOW, "  + Increase Slight", 15, 0x0351A6, 0, -1), //0x5688D8
		new LineValueData(INFLUENCE_STRING_VALUE_NEGATIVE_LOW, INFLUENCE_VALUE_NEGATIVE_LOW, "  - Decrease Slightly", 17, 0xBF5513, 1, -1, 3), //0xD87756
		new LineValueData(INFLUENCE_STRING_VALUE_NEGATIVE_MEDIUM, INFLUENCE_VALUE_NEGATIVE_MEDIUM, " -- Decrease ", 17, 0xBF5513, 1, -1, 3),
		new LineValueData(INFLUENCE_STRING_VALUE_NEGATIVE_HIGH, INFLUENCE_VALUE_NEGATIVE_HIGH, "--- Decrease Greatly", 17, 0xBF5513, 1, -1, 3) //0x8C400E
		];
		*/
		
		public static const LINE_VALUE_REMOVE_LABEL:String = "REMOVE";
		public static const LINE_VALUE_FILL:uint = 0xFFFFFF;
		public static const LINE_VALUE_FILL_SELECTED:uint = 0xFF0000;
		public static const LINE_VALUE_FILL_OVER:uint = 0xFFFF00;
		public static const LINE_VALUE_STROKE:uint = 0x333333;
		public static const LINE_VALUE_TEXT:uint = 0xFFFFFF;
		
		public static const MENU_HEIGHT:int = 30; //30;
		
		public static const NOTES_WIDTH:int = 180; //30;
	}
}