package com.jonnybomb.mentalmodeler.utils.math
{
	public class MathUtil
	{
		public static function logx(val:Number, base:Number = 10):Number
		{
			return Math.log(val) / Math.log(base);
		}
		
		public static function roundToDecimal(num:Number, precision:int):Number
		{
			var decimal:Number = Math.pow(10, precision);
			return Math.round(decimal* num) / decimal;
		}
		
		public static function normalize(value:Number, min:Number, max:Number):Number
		{
			return (value < min) ? min : (value > max) ? max : value;
		}
		
		public static function isNormalized(value:Number, min:Number, max:Number):Boolean
		{
			return value >= min && value <= max;
		}
		
		public static function ceiling(value:Number):int
		{
			return (value % 1) ? int(value) + 1 : int(value);
		}
		
		public static function max(value1:Number, value2:Number):Number
		{
			return (value1 >  value2) ? value1 : value2;
		}
		
		public static function min(value1:Number, value2:Number):Number
		{
			return (value1 <  value2) ? value1 : value2;
		}
	}
}