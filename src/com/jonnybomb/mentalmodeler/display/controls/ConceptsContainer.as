package com.jonnybomb.mentalmodeler.display.controls
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.EcoModeler;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.events.ControllerEvent;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.mincomps.components.ScrollPanel;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
	public class ConceptsContainer extends Sprite
	{
		public var concepts:Sprite;
		public var lines:Sprite;
		public var tempLine:Sprite;
		private var _bg:Sprite;
		//public var menu:Sprite;
		
		private var _x:int;
		private var _y:int;
		private var _controller:CMapController;
		private var _scrollPanel:ScrollPanel;
		
		public function get vScroll():Number { return _scrollPanel != null ? _scrollPanel.vScroll : 0; }
		
		public function ConceptsContainer(x:int, y:int)
		{
			_x = x;
			_y = y;
		}
		
		public function set controller(value:CMapController):void
		{
			if (!_controller)
			{
				_controller = value;
				
				init();
				
				_controller.addEventListener(ControllerEvent.STAGE_RESIZE, handleStageResize, false, 0, true);
				handleStageResize(null);
			
				if (EcoModeler.IN_SUITE)
					_controller.addEventListener(ControllerEvent.UPDATE_POSITIONS, handleUpdatePositions, false, 0, true);
			}
		}
		
		private function init():void
		{
			this.x = _x;
			this.y = _y;
			
			//trace("this.x:"+this.x+", this.y:"+this.y);
			
			_bg = addChild(new Sprite()) as Sprite;
			
			var stage:Stage = _controller.stage;
			
			if (EcoModeler.IN_SUITE)
				_scrollPanel = addChild(createScrollPanel(0, 0, stage.stageWidth - x, stage.stageHeight - y)) as ScrollPanel;
			
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0xFF0000, 0);
			s.graphics.drawRect(0, 0, 1, 1);
			s.graphics.endFill();
			
			if (EcoModeler.IN_SUITE)
			{
				_scrollPanel.content.addChild(s);
				lines = _scrollPanel.content.addChild(new Sprite()) as Sprite;
				tempLine = _scrollPanel.content.addChild(new Sprite()) as Sprite;
				concepts = _scrollPanel.content.addChild(new Sprite()) as Sprite;
			}
			else
			{
				lines = addChild(new Sprite()) as Sprite;
				tempLine = addChild(new Sprite()) as Sprite;
				concepts = addChild(new Sprite()) as Sprite;
			}
			//menu = addChild(new Sprite()) as Sprite;
			
			filters = [CMapConstants.UI_DROP_SHADOW];
			
			_bg.addEventListener(MouseEvent.MOUSE_DOWN, handleBgMouseDown, false, 0, true);
		}
		
		private function handleUpdatePositions(e:ControllerEvent):void
		{
			var w:Number = e.data.w;
			var h:Number = e.data.h;
			_scrollPanel.draw();
		}
		
		private function createScrollPanel(x:int, y:int, w:int, h:int):ScrollPanel
		{
			var s:ScrollPanel = new ScrollPanel();
			s.x = x;
			s.y = y;
			//s.color = 0xFF0000; //Constants.SCROLL_AREA_COLOR;
			//s.autoHideScrollBar = false;
			s.autoDisable = true;
			s.externalDropShadow = false;
			s.borderThickness = 0;
			s.setSize(w, h);
			s.draw();
			//s.addEventListener(Event.CHANGE, handleScrollChange, false, 0, true);
			return s;
		}
		
		private function handleBgMouseDown(e:MouseEvent):void
		{
			_controller.setAsCurrentCD(null);
			_controller.setAsCurrentLine(null);
		}
		
		private function handleStageResize(e:ControllerEvent):void
		{
			var stage:Stage = _controller.stage;
			var w:Number = stage.stageWidth - x;
			var h:Number = stage.stageHeight - y;
			var g:Graphics = _bg.graphics;
			g.clear();
			g.beginFill(0xFFFFFF, 1);
			g.drawRect(0, 0, w, h);
			g.endFill();
			
			if (EcoModeler.IN_SUITE)
			{
				_scrollPanel.setSize(w, h);
				_scrollPanel.draw();
			}
		}
		
		public function finalize():void
		{
			DisplayObjectUtil.remove(lines);
			DisplayObjectUtil.remove(tempLine);
			DisplayObjectUtil.remove(concepts);
			DisplayObjectUtil.remove(_scrollPanel);
			//DisplayObjectUtil.remove(menu);
			
			concepts = null;
			lines = null;
			tempLine = null;
			_scrollPanel = null;
			//menu = null
		}
	}
}