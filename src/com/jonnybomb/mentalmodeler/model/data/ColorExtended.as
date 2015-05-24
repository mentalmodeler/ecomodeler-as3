package com.jonnybomb.mentalmodeler.model.data
{
	public class ColorExtended
	{
		public var color:uint = 0;
		public var alpha:Number = 1;

		public function ColorExtended( _color:*, _alpha:Number = NaN ) :void
		{
			if ( _color is uint ) color = _color;
			else if ( _color is String ) fromString( _color );
			if ( !isNaN(_alpha) ) alpha = _alpha;
		}
		
		public function clone():ColorExtended
		{
			return new ColorExtended( color, alpha );
		}
		
		public function toString( includeAlpha:Boolean = false ):String
		{
			return color.toString(16) + ( includeAlpha ? (alpha * 255).toString(16).slice(8,10) : "" );
		}
		
		public function fromString( colorStr:String ):void 
		{
			if ( colorStr.charAt(0) == "#") colorStr = colorStr.substring(1, colorStr.length);
			if ( colorStr.charAt(1).toLowerCase() != "x" ) colorStr = "0x" + colorStr;
			if ( colorStr.length == 8 ) 
				color = uint( colorStr );
			else if ( colorStr.length == 10 )
			{
				color = uint( colorStr.slice( 0, 8 ) );
				alpha = uint( "0x0000" + colorStr.slice( 8, 10 ) ) / 255;
			}
		}
		
	}

}