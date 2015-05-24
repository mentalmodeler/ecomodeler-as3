package com.jonnybomb.ui.utils
{
	import flash.utils.getQualifiedClassName;
	
	public class ObjectUtil
	{
		public static function deleteValues(o:Object, recurse:Boolean = true):void
		{
			if (o != null && isObject(o))
			{
				for (var key:String in o)
				{
					try
					{
						if (recurse && isObject(o[key]) == "Object")
							deleteValues(o[key] as Object);
						o[key] = null
						//delete o[key];
					}
					catch(err:Object) { trace("deleteValues >> cannot delete value for key:"+key); }
				}
			}
		}
		
		static public function clearAndFinalizeList( list:* ):void
		{
			try
			{
				if ( list is Array || list is Vector.<*> )
				{
					while ( list.length > 0 )
					{
						var entry:* = list.pop();
						if ( entry && "finalize" in entry && entry.finalize is Function )
							entry.finalize();
					}
				}
			}
			catch ( e:Error )
			{
				trace( "Error occured in ObjectUtil.clearAndFinalizeList: " + e );
				trace( e.getStackTrace() );
			}
		}		
		
		public static function doTrace(o:Object, title:String = "", tabs:String = "" , recurse:Boolean = true):void
		{
			if (isObject(o))
			{
				trace(tabs + title + " >> " + o);
				tabs += "\t";
				for (var s:String in o)
				{
					trace(tabs + "o["+s+"]:"+o[s]);
					if (recurse && isObject(o[s]))
						doTrace(o[s], s, tabs)
				}
			}
		}
		
		private static function isObject(o:Object):Boolean
		{
			return getQualifiedClassName(o) == "Object";
		}
	}
}