package com.jonnybomb.mentalmodeler.display.controls.alert
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	public class Alert extends Sprite
	{
		public static function set parent(value:DisplayObjectContainer):void { _parent = value; }
		private static var _instance:Alert;
		private static var _allowInstantiation:Boolean = false;
		private static var _parent:DisplayObjectContainer;
		
		private var _blocker:Sprite;
		private var _modal:Sprite;
		private var _content:IAlertContent;
		private var _contentIO:InteractiveObject;
		private var _callback:Function;
		
		public function Alert()
		{
			if (!_allowInstantiation)
				throw new Error("Alert is a singleton. Access instance through Alert.instance");
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
		}
		
		public static function show(content:IAlertContent, callback:Function):void
		{
			//trace("Alert >>  static show, content:"+content+", callback:"+callback);
			if (!_instance)
			{
				if (!_parent)
					throw new Error("Alert _parent must be defined to show Alert.");
				else
				{
					_allowInstantiation = true;
					_instance = _parent.addChild(new Alert()) as Alert;
					_allowInstantiation = false;
					_instance.init();
				}
			}
			_instance.show(content, callback);
		}
		
		public static function close():void
		{
			//trace("Alert >>  static close");
			if (_instance)
				_instance.close();
		}
		
		private function init():void
		{
			visible = false;
			_blocker = addChild(new Sprite()) as Sprite;
			_blocker.mouseEnabled  = true;
			_blocker.buttonMode = false;
			var g:Graphics = _blocker.graphics;
			g.beginFill(0xd2d2d2/*0x000000*/, CMapConstants.ALERT_BLOCKER_ALPHA);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			g.endFill();
			
			_modal = addChild(new Sprite()) as Sprite;
			var ds:DropShadowFilter = CMapConstants.CD_DROP_SHADOW.clone() as DropShadowFilter;
			ds.knockout = false;
			_modal.filters = [ds];
		}
		
		private function handleContentMouseDown(e:MouseEvent):void
		{
			//trace(" handleContentMouseDown, _content.cancelButton:"+_content.cancelButton+", e.target:"+e.target+", _content.cancelButton == e.target:"+(_content.cancelButton == e.target));
			
			var doCallback:Function;
			if (_callback != null && e.target == _content.actionButton)
				doCallback = _callback;
			
			if (e.target == _content.actionButton || e.target == _content.cancelButton)
				close();
			
			if (doCallback != null)
				doCallback();
		}
		
		private function show(content:IAlertContent, callback:Function):void
		{
			if (_instance)
				_instance.close();
			
			if (!content)
				return;
			
			_contentIO = content as InteractiveObject;
			if (!_contentIO)
				return
			
			_content = content;
			
			if (callback != null)
				_callback = callback;
			
			_contentIO.addEventListener(MouseEvent.MOUSE_DOWN, handleContentMouseDown, false, 0, true);
			
			var stageW:Number = stage.stageWidth;
			var stageH:Number = stage.stageHeight;
			var padding:int = CMapConstants.ALERT_PADDING;
			
			drawModal(_contentIO.width, _contentIO.height);
			
			_contentIO.x = _contentIO.y = padding;
			_modal.addChild(_contentIO);
			
			handleResizeStage(null);
			
			visible = true;
		}
		
		private function close():void
		{
			//trace("Alert >>  property close");
			visible = false;
			if (_content)
			{
				DisplayObjectUtil.removeChildrenAndDestroy(_contentIO as DisplayObjectContainer);
				if (_contentIO.parent)
					_contentIO.parent.removeChild(_contentIO);
				_content = null;
				_contentIO = null;
			}
			
			if (_callback != null)
				_callback = null;
		}
		
		private function drawModal(w:int, h:int):void
		{
			var padding:int = CMapConstants.ALERT_PADDING;
			_modal.graphics.clear();
			DrawingUtil.drawRect(_modal, w + padding*2, h + padding*2, ColorData.getColor(ColorData.ALERT), CMapConstants.ALERT_STROKE, CMapConstants.ALERT_ELLIPSE);
		}
		
		private function handleResizeStage(e:Event):void
		{
			var stageW:Number = stage.stageWidth;
			var stageH:Number = stage.stageHeight;
			
			if (_blocker)
			{
				_blocker.width = stageW;
				_blocker.height = stageH;
			}
			
			if (_modal)
			{
				_modal.x = (stageW - _modal.width) / 2;
				_modal.y = (stageH - _modal.height) / 2;
			}
		}
		
		private function handleAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false);
			stage.addEventListener(Event.RESIZE, handleResizeStage, false, 0, true);
		}
	}
}