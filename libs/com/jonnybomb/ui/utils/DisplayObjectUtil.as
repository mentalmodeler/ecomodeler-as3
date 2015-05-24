package com.jonnybomb.ui.utils
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;

	public class DisplayObjectUtil
	{
		public static const CLASSNAME_AVM2LOADER:String = "com.pearson.testnav.utils.file::AVM2Loader";
		public static const CLASSNAME_AVM1MOVIE:String = "flash.display::AVM1Movie";
		
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
		
		public static function finalizeAndRemove(dObj:DisplayObject):void
		{
			doFinalizeAndRemove(dObj, true);
		}
		
		public static function remove(dObj:DisplayObject):void
		{
			doFinalizeAndRemove(dObj, false);
		}
		
		public static function removeAllChildren(doc:DisplayObjectContainer, finalize:Boolean = false):void
		{
			if (doc != null)
			{
				var child:DisplayObject;
				var len:int = doc.numChildren;
				for (var i:int = len-1; i>=0; i--)
					doFinalizeAndRemove(doc.getChildAt(i), finalize);
			}
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
					try { dObj.parent.removeChild(dObj); }
					catch(e:Error) { trace("ERROR! DisplayObjectUtil >> finalizeAndRemove\n\tcannot remove child, "+dObj+"\n\t"+e); }
				}
			}
		}
		
		public static function removeChildrenAndDestroy(doc:DisplayObjectContainer):void
		{
			removeChildren(doc, true);
		}
		
		public static function removeChildren(doc:DisplayObjectContainer, doDestroy:Boolean = false):void
		{
			if (doc == null)
				return;
			
			var bTrace:Boolean = false;
			var child:DisplayObject;
			while (getQualifiedClassName(doc) != CLASSNAME_AVM2LOADER && doc.numChildren > 0)
			{
				child = doc.getChildAt(0);
				if (child)
				{
					if (child is DisplayObjectContainer)
						removeChildren(child as DisplayObjectContainer, doDestroy);
					
					if (getQualifiedClassName(child) == CLASSNAME_AVM2LOADER && ("unloadAndStop" in child))
					{
						try { child["unloadAndStop"](); }
						catch(e:Error) { trace("ERROR! DisplayObjectUtil >> removeChildren\n\tcan not call unloadAndStop on "+child+"\n\t"+e); }
					}
					
					if (doDestroy && ("destroy" in child))
					{
						try
						{
							if (bTrace) trace("\t\t==> destroy "+child);
							child["destroy"]();
						}
						catch(e:Error) { trace("ERROR! DisplayObjectUtil >> removeChildren\n\tcannot call destroy on "+child+"\n\t"+e); }
					}
					
					try
					{
						child.filters = [];
						doc.removeChild(child); 
					}
					catch(e:Error) { trace("ERROR! DisplayObjectUtil >> removeChildren\n\tcannot remove child "+child+"\n\t"+e); }
				}
			}
		}
	}
}