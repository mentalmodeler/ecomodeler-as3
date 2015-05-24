package com.mincomps.data
{
	public class MinCompsColorExtended
	{
		/**
		 * 6-digit hex RGB value
		 */
		public var color:uint = 0;
		/**
		 * Number from 0 to 1
		 */
		public var alpha:Number = 1;
		
		/**
		 * Initializes with color and alpha
		 * @param	_color - can be uint value or string (0x######)
		 * @param	_alpha - is Number from 0 to 1, as is used in Flash
		 */
		public function MinCompsColorExtended( _color:*, _alpha:Number = NaN ) :void
		{
			if ( _color is uint ) color = _color;
			else if ( _color is String ) fromString( _color );
			if ( !isNaN(_alpha) ) alpha = _alpha;
		}
		
		/**
		 * Return a copy of this instance
		 * @return cloned ColorExtended
		 */
		public function clone():MinCompsColorExtended
		{
			return new MinCompsColorExtended( color, alpha );
		}
		
		/**
		 * Converts to a string, either 0x###### or 0x######## for including alpha
		 * @param	includeAlpha
		 * @return
		 */
		public function toString( includeAlpha:Boolean = false ):String
		{
			return color.toString(16) + ( includeAlpha ? (alpha * 255).toString(16).slice(8,10) : "" );
		}
		
		/**
		 * Takes a string that is formatted as such: "0x######"
		 * @param	colorStr
		 */
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