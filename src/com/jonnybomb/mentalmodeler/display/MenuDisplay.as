package com.jonnybomb.mentalmodeler.display
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.EcoModeler;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.events.ControllerEvent;
	import com.jonnybomb.mentalmodeler.model.CMapModel;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class MenuDisplay extends Sprite
	{
		private var _controller:CMapController;
		private var _bg:Sprite;
		private var _bgBlack:Sprite;
		private var _add:UIButton;
		
		private var _load:UIButton;
		private var _save:UIButton;
		private var _export:UIButton;
		private var _screenshot:UIButton;
		private var _logo:TextField;
		private var _holder:Sprite;
		private var _canSaveLoadExport:Boolean = true;
		
		public function MenuDisplay(controller:CMapController)
		{
			_controller = controller;
			_controller.addEventListener(ControllerEvent.DISABLE_ADD_NODE, handleToggleAddEnabled, false, 0, true);
			_controller.addEventListener(ControllerEvent.ENABLE_ADD_NODE, handleToggleAddEnabled, false, 0, true);
			
			_canSaveLoadExport = _controller.model.canSaveAndLoad
			
			if (stage)
				init();
			else	
				addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			
			if (EcoModeler.IN_SUITE)
				filters = [CMapConstants.UI_DROP_SHADOW];
			
			//init();
			//addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
		}
		
		public function finalize():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false);
			if (stage)
				stage.removeEventListener(Event.RESIZE, handleResize, false);
			
			if (_add)
				_add.removeEventListener(MouseEvent.MOUSE_DOWN, handleClickMouseDown, false)
				
			DisplayObjectUtil.removeAllChildren(_add);
			DisplayObjectUtil.remove(_add);
			//DisplayObjectUtil.remove(_bg);
			
			_controller = null;
			//_bg = null;
			_add = null;
		}
		
		public function handleResize(e:Event):void
		{
			var stage:Stage = _controller.stage;
			if (!stage) return
			
			_bg.width = stage.stageWidth;
			var startX:Number = _logo ? _bgBlack.x + _bgBlack.width/*_logo.x + _logo.width*/ : 0;
			
			if (_canSaveLoadExport)
			{
				if (stage.stageWidth < startX + _add.width + _holder.width + 5)
				{
					_add.x = startX + 5;
					_holder.x = _add.x + _add.width + 1;
				}
				else
				{
					_holder.x = stage.stageWidth - _holder.width - 1;
					_add.x = startX + (_holder.x - startX - _add.width)/2;
				}
				_controller.addX = _add.x + _add.width/2 - CMapConstants.NOTES_WIDTH;
			}
			else
			{
				//_add.x = stage.stageWidth - _add.width - 1;
				var addW:Number = stage.stageWidth - CMapConstants.NOTES_WIDTH;
				_add.setSize(addW, CMapConstants.MENU_HEIGHT);
				var label:DisplayObject = _add.label;
				label.x = (addW - label.width)/2;
				label.y = (CMapConstants.MENU_HEIGHT - label.height)/2;
				//_add.x = (stage.stageWidth - _add.width)/2;
				_bg.width = _add.width;
				_add.x = _bg.x = CMapConstants.NOTES_WIDTH;
				_controller.addX = _add.x + addW/2  - CMapConstants.NOTES_WIDTH; // - CMapConstants.CD_WIDTH/2 - CMapConstants.CD_ADD_POS_OFFSET;
			}
			/*
			var width:Number = 0;
			if (_controller.standAlone && stage)
				width = stage.stageWidth;
			else if (_controller.rect)
				width = _controller.rect.width;
			
			_bg.width = width;
			_add.x = (width - _add.width)/2;
			_controller.addX = _add.x + _add.width/2;
			*/
		}
		
		private function toggleAddEnabled(isEnabled:Boolean):void
		{
			_add.enabled = isEnabled 
			if (isEnabled)
				_add.addEventListener(MouseEvent.MOUSE_DOWN, handleClickMouseDown, false, 0, true);
			else
				_add.removeEventListener(MouseEvent.MOUSE_DOWN, handleClickMouseDown, false);
		}
		
		private function handleToggleAddEnabled(e:ControllerEvent):void { toggleAddEnabled(e.type == ControllerEvent.ENABLE_ADD_NODE); }
		private function handleClickMouseDown(e:Event):void { _controller.addNewConcept(); }
		
		private function init():void
		{
			_bg = addBG();
			_bgBlack = addBG(0x3c3c3c);
			_bgBlack.width = CMapConstants.NOTES_WIDTH;
			
			_holder = addChild(new Sprite()) as Sprite;
			var spacer:int = 1;
			_add = addChild(createButton(createAddLabel())) as UIButton;
			toggleAddEnabled(false);
			if (_canSaveLoadExport)
			{
				_logo = addChildAt(createTF("<font color='#FFFFFF'>Eco</font><font color='#E53E29'>Modeler</font>", 22), 2) as TextField;
				//_logo = addChild(createTF("<font color='#FFFFFF'>Mental</font><font color='#A5C825'>Modeler</font>", 22)) as TextField; //83A603
				_logo.filters = [CMapConstants.INSET_BEVEL];
				_logo.y = -2;
				_logo.x = 5;
				
				_load = _holder.addChild(createButton("LOAD")) as UIButton;
				_load.addEventListener(MouseEvent.CLICK, handleClickLoad, false, 0, true);
				_save = _holder.addChild(createButton("SAVE")) as UIButton;
				_save.addEventListener(MouseEvent.CLICK, handleClickSave, false, 0, true);
				_save.x = _load.x + _load.width + spacer;
				_screenshot = _holder.addChild(createButton("SCREENSHOT")) as UIButton;
				_screenshot.addEventListener(MouseEvent.CLICK, handleClickScreenshot, false, 0, true);
				_screenshot.x = _save.x + _save.width + spacer;
				_export = _holder.addChild(createButton("PRINT")) as UIButton;
				_export.addEventListener(MouseEvent.CLICK, handleClickExport, false, 0, true);
				_export.x = _screenshot.x + _screenshot.width + spacer;
			}
			
			_controller.addEventListener(ControllerEvent.STAGE_RESIZE, handleResize, false, 0, true);
			handleResize(null);
			
			var ds:DropShadowFilter = CMapConstants.UI_DROP_SHADOW.clone() as DropShadowFilter;
			ds.angle = 90;
			//ds.strength = 0.5;
			filters = [ds];
		}
		
		private function handleClickAdd(e:Event):void
		{
			_controller.addNewConcept();
		}
		
		private function handleClickLoad(e:Event):void
		{
			_controller.loadMap();
		}
		
		private function handleClickSave(e:Event):void
		{
			_controller.saveMap();
		}
		
		private function handleClickScreenshot(e:Event):void
		{
			_controller.saveScreenshot();
		}
		
		private function handleClickExport(e:Event):void
		{
			_controller.print();
		}
		
		private function createAddLabel():Sprite
		{
			var sp:Sprite  = new Sprite;
			var rad:int = CMapConstants.MENU_HEIGHT * 0.33; //0.38;
			var side:int = CMapConstants.MENU_HEIGHT * 0.40; //0.55;
			var thickness:int = CMapConstants.MENU_HEIGHT * 0.12;
			var s:Shape = new Shape();
			var g:Graphics = s.graphics;
			g.beginFill(0xFFFFFF);
			g.drawCircle(0, 0, rad);
			g.drawRect(-thickness/2, -side/2, thickness, side);
			g.drawRect(-side/2, -thickness/2, (side-thickness)/2, thickness);
			g.drawRect(thickness/2, -thickness/2, (side-thickness)/2, thickness);
			g.endFill();
			sp.addChild(s);
			s.x = s.y = rad;
			var tf:TextField = createTF(_controller.addNodeLabel, 14);
			tf.x = s.width + 5;
			tf.y = s.y - tf.height/2;
			sp.addChild(tf);
			sp.filters = [CMapConstants.INSET_BEVEL];
			return sp;
		}
		
		private function addBG(color:uint = 0x4c4c4c/*0x191919/*0x323232*/):Sprite
		{
			var w:Number = 100;
			if (stage)
				w = stage.stageWidth;
			var s:Sprite = addChild(new Sprite()) as Sprite;
			var g:Graphics = s.graphics;
			g.beginFill(color, 1);
			g.drawRect(0, 0, w, CMapConstants.MENU_HEIGHT + 1);
			g.endFill();
			
			return s;
		}
		
		private function createButton(label:*, size:int = 12, family:String = "VerdanaEmbedded", color:uint = 0xFFFFFF, bold:Boolean = true):UIButton
		{
			var padding:int = 10;
			var props:Object = {};
			
			if (label is String)
			{
				var tf:TextField = createTF(label as String, size, family, color, bold);
				tf.x = padding;
				tf.y = (CMapConstants.MENU_HEIGHT - tf.height) / 2;
				tf.filters = [CMapConstants.INSET_BEVEL];
				props[UIButton.WIDTH] = tf.width + padding*2;
			}
			else if (label is DisplayObject)
			{
				label.x = padding;
				label.y = (CMapConstants.MENU_HEIGHT - label.height) / 2 + 1;
				label.filters = [CMapConstants.INSET_BEVEL];
				if (!_canSaveLoadExport) // make the add button big
				{
					var w:int = _controller.stage.stageWidth - CMapConstants.NOTES_WIDTH;
					props[UIButton.WIDTH] = w;
					label.x = (w - label.width)/2;
				}
				else
					props[UIButton.WIDTH] = label.width + padding*2;
			}
			var buttonLabel:DisplayObject = (label is String) ? tf : label;
			
			props[UIButton.HEIGHT] = CMapConstants.MENU_HEIGHT;
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			props[UIButton.ELLIPSE] = 0; //{tr:0, tl:0, br:10, bl:10};
			props[UIButton.STROKE] = 0;
			var b:UIButton = new UIButton(props);
			b.addLabel(buttonLabel);
			return b;
		}
		
		private function createTF(text:String, size:int = 14, family:String = "VerdanaEmbedded", color:uint = 0xFFFFFF, bold:Boolean = true):TextField
		{
			var format:TextFormat = new TextFormat();
			format.color = color;
			format.font = family;
			format.bold = bold;
			format.size = size;
			format.letterSpacing = -1;
			
			var tf:TextField = new TextField();
			tf.embedFonts = true;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.wordWrap = false;
			tf.multiline = false;
			tf.defaultTextFormat = format;
			tf.htmlText = text;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			
			return tf;
		}
		
		private function handleAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false);
			init();
			/*
			if (_controller.standAlone)
				stage.addEventListener(Event.RESIZE, handleResize, false, 0, true);
			*/
		}
	}
}