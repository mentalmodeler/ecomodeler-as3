package com.mincomps.data
{
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	public class MinCompsScrollBarConstants
	{
		public static const SIZE:int = 15;
		public static const PAGE_SIZE:int = 15;
		public static const LINE_SIZE:int = 15;
		
		public static var INSET_BEVEL:BevelFilter = new BevelFilter(1, 270, 0xFFFFFF, 1, 0x000000, 0, 1, 1, 1, BitmapFilterQuality.LOW, BitmapFilterType.OUTER)
		public static var TRACK_DROP_SHADOW:DropShadowFilter = new DropShadowFilter(1, 0, 0x000000, 0.5, 4, 4, 1, BitmapFilterQuality.MEDIUM, true);
		public static var INNER_GLOW:GlowFilter = new GlowFilter(0xFFFFFF, 0.6, 2, 2, 2, BitmapFilterQuality.MEDIUM, true);
	}
}