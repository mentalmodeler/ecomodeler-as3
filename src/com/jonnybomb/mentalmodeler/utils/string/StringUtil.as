package com.jonnybomb.mentalmodeler.utils.string
{
	public class StringUtil
	{
		public static function replace(string:String, find:String, replace:String):String
		{
			if (string.indexOf(find) != -1)
			{
				var split:Array = string.split(find);
				string = split.join(replace);
			}
			
			return string;
		}
		
		public static function getWords(input:String):Vector.<String>
		{
			var rtn:Vector.<String>;
			if (input.length > 0) {
				rtn = new Vector.<String>();
				// Changing to select everything but spaces
				var arr:Array = input.match(/\b[^\s]+\b/g);
				for each (var str:String in arr) {
					rtn.push(str);
				}
			}
			return rtn;
		}
		
		/**
		 * Gets all indexes of a given string
		 * @param	getStr
		 * @param	original
		 * @return
		 */
		public static function getAllIndexesOf(getStr:String, original:String):Vector.<int>
		{
			var rtn:Vector.<int> = new Vector.<int>();
			var working:String = original;
			var reg:RegExp = new RegExp("\\b" + getStr + "\\b");
			
			while (working.search(reg) > -1) {
				var index:int = working.search(reg);
				rtn.push(index + (rtn.length > 0 ? (rtn[rtn.length-1] +getStr.length) : 0));
				working = working.substring(index + getStr.length);
			}
			
			return rtn;
		}
		
		public static function remove(string:String, remove:*):String
		{
			if (remove is String)
				string =  StringUtil.replace(string, remove, "");
			else if (remove is Array)
			{
				var a:Array = remove as Array
				var i:int;
				var len:int = remove.length;
				for (i=0; i<len; i++)
				{
					if (a[i] is String)
						string = StringUtil.replace(string, a[i], "");
				}
			}
			return string;
		}
		
		public static function formatToMinutesSeconds(i:int):String
		{
			var seconds:int = i % 60;
			var minutes:int = i / 60;
			
			return addLeadingZeros(minutes.toString(), 2) + ":" + addLeadingZeros(seconds.toString(), 2);
		}
		
		public static function addLeadingZeros(s:String, len:int):String
		{
			while (s.length < len)
				s = "0" + s;
			
			return s;
		}
		
		/**
		 * @param text
		 * @param displayableChars
		 * @return 
		 * Takes an input string and a number for the max characters to be displayed
		 * and replaces the remaining characters with "..."
		 */		
		public static function getTrimmedTextWithEllipsis(text:String, displayableChars:uint):String
		{
			var totalCharacters:uint = text.length;
			
			if (totalCharacters > displayableChars)
			{
				text = text.replace("...", "");
				text = text.substr(0, displayableChars) + "...";
			}
			
			return text;
		}
		
		/**
		 * @param camelcaseword
		 * @return 
		 * replaces the camel case alphabet/word with an underscore and 
		 * returns the newly formed string
		 */		
		public static function convertCamelCaseToUnderscore(camelcaseword:String):String
		{
			var replace:String = camelcaseword.replace(new RegExp('(?<=\\w)([A-Z])', 'g'), '_$1').toLowerCase();;
			return replace;
		}
		
		/** 
		 * @param urlstr
		 * @return 
		 * extracts the file token at the end of a url string passed		 
		 */ 
		public static function getUrlFileName(urlstr:String):String
		{
			var fileWithExtension:RegExp = /(?<=\/)(\w+)((\.\w+(?=\?))|(\.\w+)$)/g;
			return urlstr.match(fileWithExtension)[0];			
		}
		
		
	}
}