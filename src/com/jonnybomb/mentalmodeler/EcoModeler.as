package com.jonnybomb.mentalmodeler
{
	import adobe.utils.XMLUI;
	
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptMainDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptPropertyDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.display.MenuDisplay;
	import com.jonnybomb.mentalmodeler.display.controls.ConceptsContainer;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.display.controls.alert.Alert;
	import com.jonnybomb.mentalmodeler.display.controls.alert.AlertContentDefault;
	import com.jonnybomb.mentalmodeler.model.CMapModel;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.xml.XMLUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	public class EcoModeler extends Sprite
	{
		public static const IN_SUITE:Boolean = false;
		
		private var _initCompleteCallback:Function;
		private var _container:ConceptsContainer;
		private var _controller:CMapController;
		private var _menu:MenuDisplay;
		private var _controlPanelDisplay:ControlPanelDisplay;
		private var _parentPBox:DisplayObject
		private var _standAlone:Boolean = false;
		private var _width:int = 0;
		private var _height:int = 0;
		
		private var _canSaveAndLoad:Boolean = true;
		
		public function EcoModeler()
		{
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			visible = false;
		}
		
		override public function get width():Number
		{
			return _controller.rect.width;
		}
		
		private function handleAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			_standAlone = parent == stage;
			if (_standAlone)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			
				init(null);
			}
		}
		
		private function init(xml:XML):void
		{
			//trace("MentalModeler, init, xml:"+((xml != null ) ? xml.toXMLString() : "null"));
			_container = addChild(new ConceptsContainer(CMapConstants.NOTES_WIDTH, CMapConstants.MENU_HEIGHT)) as ConceptsContainer;
			_controller = new CMapController(_container, _standAlone);
			_controller.model.canSaveAndLoad = !IN_SUITE;
			_container.controller = _controller;
			if (IN_SUITE)
				_controlPanelDisplay = addChildAt(new ControlPanelDisplay(_controller, 0, 0, CMapConstants.NOTES_WIDTH), 0) as ControlPanelDisplay;
			else
				_controlPanelDisplay = addChildAt(new ControlPanelDisplay(_controller, 0, CMapConstants.MENU_HEIGHT, CMapConstants.NOTES_WIDTH), 0) as ControlPanelDisplay;
			Alert.parent = this;
			
			if (_standAlone)
			{
				//var rect:Rectangle = new Rectangle(0, 0, 800, 600); 
				build(null);
			}
		}
		
		public function build(rect:Rectangle):void
		{
			//trace("CMapMM, build, rect:"+((rect != null ) ? rect : "null"));
			
			if (rect)
			{
				if (_width > 0)
					rect.width = _width;
				if (_height > 0)
					rect.height = _height;
				_controller.rect = rect;
			}
			else if (_width > 0 && _height > 0)
			{
				rect = new Rectangle(0, 0, _width, _height);	
				_controller.rect = rect;
			}
			
			_menu = addChild(new MenuDisplay(_controller)) as MenuDisplay; //_container.menu.addChild(new MenuDisplay(_controller)) as MenuDisplay;
			
			_controller.updateAddNodeEnabled();
			visible = true;
			
			_controller.init();
						
			return;
			
			// debug
			var s:Sprite = addChild(new Sprite()) as Sprite;
			var g:Graphics = s.graphics;
			g.beginFill(0xFF0000);
			g.drawRoundRect(0, 0, 20, 20, 6, 6);
			g.endFill();
			s.addEventListener(MouseEvent.CLICK, handleTestClick, false, 0, true);
			s.x = s.y = 10;
		}
		
		
		private function handleTestClick(e:MouseEvent):void
		{
			//var xml:XML = <app><node id="1" x="53.15" y="40" w="187" h="268"><![CDATA[aaa aa aaaaa aa aaaa a a aaaaaa aa a a aaaaaaaa a aa aaaaaaaaaa a a a aaaaaaa a a aaaaa a aaa]]></node><node id="2" x="310.15" y="354" w="347" h="99"><![CDATA[bbb bbb b bbbbbb b b b bbbbbb bb bbb b b b b bbbb b bbbb bb bbbbbb b bbb b b b bbbbbbb b bbbbb b bbbbb bbbbbb bbbbb bbbbb]]></node><node id="0" x="384.15" y="44" w="164" h="64"><![CDATA[ccc cc cccccccc ccc cc cc cccc ccc ccc c]]></node></app>;
			/*
			var xml:XML = <app><node id="2" x="310.15" y="354" w="347" h="99"><![CDATA[bbb bbb b bbbbbb b b b bbbbbb bb bbb b b b b bbbb b bbbb bb bbbbbb b bbb b b b bbbbbbb b bbbbb b bbbbb bbbbbb bbbbb bbbbb]]></node></app>;
			_controller.onMapLoaded(xml);
			*/
		}
		
		public function updateSize(rect:Rectangle):void
		{
			_controller.rect = rect;
			_menu.handleResize(null);
		}
		
		// ----------------------------- IInteractive Object API -----------------------------
		public function finalize():void
		{
			if (_controller)
				_controller.finalize();
			
			DisplayObjectUtil.finalizeAndRemove(_menu);
			
			_container = null;
			_parentPBox = null
			_initCompleteCallback = null;
			_container = null;
			_controller = null;
			_menu = null;
		}
		
		public function restoreState(xml:XML):void
		{
			_controller.onMapLoaded(xml);
		}
		
		public function getState():XML
		{ 
			return _controller.getState();
		}
	}
}