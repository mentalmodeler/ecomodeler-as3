package com.jonnybomb.mentalmodeler.utils.xml
{
	public class XMLUtil
	{
		public function XMLUtil()
		{
		}
		
		public static function isInt(xml:XML, prop:String):Boolean
		{
			var meetsCriteria:Boolean = false;
			if (xml != null && prop in xml && xml[prop] != "" && !isNaN(parseInt(xml[prop])))
				meetsCriteria = true;
			return meetsCriteria;
		}
		
		public static function isNumber(xml:XML, prop:String):Boolean
		{
			var meetsCriteria:Boolean = false;
			if (xml != null && prop in xml && xml[prop] != "" && !isNaN(parseFloat(xml[prop])))
				meetsCriteria = true;
			return meetsCriteria;
		}
		
		public static function isNotEmptyString(xml:XML, prop:String):Boolean
		{
			var meetsCriteria:Boolean = false;
			if (xml != null && prop in xml && xml[prop] != "")
				meetsCriteria = true;
			return meetsCriteria;
		}
		
		public static function hasTextNodeWithContent(xml:XML, nodeName:String = "", bTrace:Boolean = false):Boolean
		{
			var meetsCriteria:Boolean = false;
			if (nodeName != "")
			{
				if (xml != null && xml.hasOwnProperty(nodeName) && xml[nodeName][0].text()[0] && xml[nodeName][0].text()[0].toString() != "")
					meetsCriteria = true;
			}
			else
			{
				if (xml != null && xml.text()[0] && xml.text()[0] != "")
					meetsCriteria = true;
			}
			return meetsCriteria;
		}
		
		public static function getTextNodeContent(xml:XML, nodeName:String = "", bTrace:Boolean = false):String
		{
			var s:String = "";
			if (hasTextNodeWithContent(xml, nodeName, bTrace))
			{
				if (nodeName != "")
					s = xml[nodeName][0].text()[0].toString();
				else
					s = xml.text()[0].toString();
			}
			return s;
		}
		
		public static function getHighestIdIndex(list:XMLList):int
		{
			//trace("XMLUtil >> getHighestIdIndex");	
			var idx:int = 0;
			var node:XML;
			for each (node in list)
			{
				if ("id" in node && hasTextNodeWithContent(node, "id") && parseInt(getTextNodeContent(node, "id")) > idx)
					idx = parseInt(getTextNodeContent(node, "id"))
				
				//trace("\tidx:"+idx);	
				/*
				if (isInt(node, "@id") && parseInt(node.@id) > idx)
					idx = parseInt(node.@id)
				*/
			}
			return idx;
		}
		
		public static function cdata(s:String):XML
		{
			var x:XML = new XML("<![CDATA[" + s + "]]>");
			return x;
		}
	}
}