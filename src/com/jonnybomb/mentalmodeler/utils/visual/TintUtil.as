package com.jonnybomb.mentalmodeler.utils.visual
{
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;

	public class TintUtil
	{
		public static function tint(dObj:DisplayObject, color:uint):void
		{
			var ct:ColorTransform = dObj.transform.colorTransform;
			ct.color = color;
			dObj.transform.colorTransform = ct;
		}
		
		public static function removeTint(dObj:DisplayObject):void
		{
			dObj.transform.colorTransform = new ColorTransform();
		}
	}
}