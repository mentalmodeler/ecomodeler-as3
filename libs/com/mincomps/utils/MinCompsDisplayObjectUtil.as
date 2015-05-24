package com.mincomps.utils
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;

	public class MinCompsDisplayObjectUtil
	{
		public static const CLASSNAME_AVM2LOADER:String = "com.pearson.testnav.utils.file::AVM2Loader";
		public static const CLASSNAME_AVM1MOVIE:String = "flash.display::AVM1Movie";
		
		private static var _childrenFoundByType:Array = [];
		
		public static function findParentByType(dObj:DisplayObject, type:*):*
		{
			var parent:DisplayObjectContainer = dObj.parent;
			
			while(parent && !(parent is type))
				parent = parent.parent
			
			if (parent is type)
				return parent as type;	
			else
				return null;
		}
		
		public static function findChildrenByType(doc:DisplayObjectContainer, type:*):Array
		{
			if (!doc) return [];
			_childrenFoundByType = [];
			doFindChildrenByType(doc, type);
			return _childrenFoundByType;
		}
		
		private static function doFindChildrenByType(doc:DisplayObjectContainer, type:*):void
		{
			var child:DisplayObject;
			var i:int = 0;
			var len:int = doc.numChildren;
			while (i<len)
			{
				child = doc.getChildAt(i++)
				if (child is type)
					_childrenFoundByType.push(child);
				if (child is DisplayObjectContainer)
					doFindChildrenByType(child as DisplayObjectContainer, type);
			}
		}
		
		public static function createScale9Grid(dObj:DisplayObject, paddingX:int, paddingY:int):Rectangle
		{
			return new Rectangle(paddingX, paddingY, dObj.width - paddingX*2, dObj.height - paddingY*2);
		}
		
		public static function localToLocal(dObj1:DisplayObject, dObj2:DisplayObject):Point
		{
			if (dObj1.parent)
			{
				var globalPoint:Point = dObj1.parent.localToGlobal(new Point(dObj1.x, dObj1.y));
				return dObj2.globalToLocal(globalPoint);
			}
			return null;
		}
		
		public static function finalizeAndRemove(dObj:DisplayObject):void
		{
			doFinalizeAndRemove(dObj, true);
		}
		
		public static function remove(dObj:DisplayObject):void
		{
			doFinalizeAndRemove(dObj, false);
		}
		
		private static function doFinalizeAndRemove(dObj:DisplayObject, doFinalize:Boolean):void
		{
			if (dObj != null)
			{
				if (doFinalize && "finalize" in dObj)
				{
					try { dObj["finalize"](); }
					catch(e:Error) { trace("ERROR! DisplayObjectUtil >> finalizeAndRemove\n\tcannot call finalize on "+dObj+"\n\t"+e); }
				}
				
				if (dObj is Bitmap && Bitmap(dObj).bitmapData)
				{
					try { Bitmap(dObj).bitmapData.dispose(); }
					catch(e:Error) { trace("ERROR! DisplayObjectUtil >> finalizeAndRemove\n\tcannot dispose bitmapData on "+dObj+"\n\t"+e); }
				}	
				
				if ("filters" in dObj && dObj["filters"] is Array)
				{
					try { dObj.filters = []; }
					catch(e:Error) { trace("ERROR! DisplayObjectUtil >> finalizeAndRemove\n\tcannot clear filters on "+dObj+"\n\t"+e); }
				}
				
				if ("graphics" in dObj && "clear" in dObj["graphics"])
				{
					try { dObj["graphics"]["clear"](); }
					catch(e:Error) { trace("ERROR! DisplayObjectUtil >> finalizeAndRemove\n\tcannot clear graphics on "+dObj+"\n\t"+e); }
				}
					
				if (dObj.parent)
				{
					if ( dObj.parent is Loader)
					{
						try { Loader(dObj.parent).unloadAndStop(true); }
						catch(e:Error) { trace("ERROR! DisplayObjectUtil >> finalizeAndRemove\n\tcannot unloadAndStop child from loader parent, "+dObj+"\n\t"+e); }
					}
					else
					{
						try { dObj.parent.removeChild(dObj); }
						catch(e:Error) { trace("ERROR! DisplayObjectUtil >> finalizeAndRemove\n\tcannot remove child, "+dObj+"\n\t"+e); }
					}
				}
			}
		}
		
		/**
		 * Recursive methods. These are still around for backwards compatibility but phased out in favor of non-recursive finalizeAndRemove and remove methods above
		 */
		public static function removeChildrenAndFinalize(doc:DisplayObjectContainer):void
		{
			removeChildren(doc, true);
		}
		
		/**
		 * Recursive methods. These are still around for backwards compatibility but phased out in favor of non-recursive finalizeAndRemove and remove methods above
		 */
		public static function removeChildren(doc:DisplayObjectContainer, doFinalize:Boolean = false):void
		{
			if (doc == null)
				return;
			
			var docClassName:String = getQualifiedClassName(doc);
			var childClassName:String;
			var child:DisplayObject;
			
			// don't iterate through AVM2Loader's children and instead remove children using unloadAndStop
			if (docClassName == CLASSNAME_AVM2LOADER && ("unloadAndStop" in doc))
			{
				try { doc["unloadAndStop"](); }
				catch(e:Error) { trace("ERROR! DisplayObjectUtil >> removeChildren\n\tcan not call unloadAndStop on "+doc+"\n\t"+e); }
			}
			
			while (docClassName != CLASSNAME_AVM2LOADER && doc.numChildren > 0)
			{
				child = doc.getChildAt(0);
				if (child)
				{
					childClassName = getQualifiedClassName(child);
					if (child is DisplayObjectContainer)
						removeChildren(child as DisplayObjectContainer, doFinalize);
					
					if (childClassName == CLASSNAME_AVM2LOADER && ("unloadAndStop" in child))
					{
						try { child["unloadAndStop"](); }
						catch(e:Error) { trace("ERROR! DisplayObjectUtil >> removeChildren\n\tcan not call unloadAndStop on "+child+"\n\t"+e); }
					}
					
					if (doFinalize && ("finalize" in child))
					{
						try { child["finalize"](); }
						catch(e:Error) { trace("ERROR! DisplayObjectUtil >> removeChildren\n\tcannot call finalize on "+child+"\n\t"+e); }
					}
					
					try
					{
						if (child is Bitmap)
							(child as Bitmap).bitmapData.dispose();
						
						child.filters = [];
						
						if (childClassName == CLASSNAME_AVM1MOVIE && ("unloadAndStop" in doc))
							doc["unloadAndStop"]();
						else
							doc.removeChild(child);
					}
					catch(e:Error) { trace("ERROR! DisplayObjectUtil >> removeChildren\n\tcannot remove child "+child+"\n\t"+e); }
				}
			}
		}
		
		/**
		 * Doesn't work right now
		 * @param	dObj
		 * @return
		 */
		public static function getGlobalFromLocal(dObj:DisplayObject):Point
		{
			if (dObj.parent)
				var rPoint:Point = getGlobalFromLocal(dObj.parent);
			return new Point ((rPoint ? rPoint.x : 0) + dObj.x, (rPoint ? rPoint.y : 0) + dObj.y);
		}
		
		public static function sendToFront( dObj:DisplayObject ):void
		{
			if ( dObj.parent )
				dObj.parent.addChild( dObj );
		}
		
		public static function sendToBack( dObj:DisplayObject ):void
		{
			if ( dObj.parent )
				dObj.parent.addChildAt( dObj, 0 );
		}
	}
}