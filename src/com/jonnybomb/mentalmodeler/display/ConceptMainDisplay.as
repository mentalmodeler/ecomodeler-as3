package com.jonnybomb.mentalmodeler.display
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Quadratic;
	import com.gskinner.motion.plugins.AutoHidePlugin;
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controls.ConceptDisplayLabel;
	import com.jonnybomb.mentalmodeler.display.controls.InteractiveElement;
	import com.jonnybomb.mentalmodeler.display.controls.ResizeButton;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	AutoHidePlugin.install();
	
	public class ConceptMainDisplay extends ConceptDisplay
	{
		private var _add:UIButton;
		private var _shadow:Shape;
		private var _drawHeight:Number;
		private var _propertyDisplays:Vector.<ConceptPropertyDisplay>;
		public function get propertyDisplays():Vector.<ConceptPropertyDisplay> { return _propertyDisplays; }
		
		public function ConceptMainDisplay(controller:CMapController)
		{
			super(controller);
			_propertyDisplays = new <ConceptPropertyDisplay>[];
			_textProps = { user:0x000000,
						   prefill:0x999999,
						   bold:true,
						   prefillText:CMapConstants.NODE_PREFILL_TEXT,
						   letterSpacing:0,
						   insetBevel:true
			};
		}
		override public function get title():String { return _label.text == _textProps.prefillText ? "" : _label.text; }
		override public function get drawWidth():Number { return width; }
		override public function get drawHeight():Number { return (!_drawHeight || _drawHeight == 0) ? height : _drawHeight; }
		
		override public function set group(value:int):void
		{ 
			super.group = value;
			
			var _lines:Vector.<InfluenceLineDisplay> = _controller.model.lines;
			for each (var line:InfluenceLineDisplay in _lines)
			{
					if (line.influencer.mainDisplay == this)
						line.group = group;
			}
			
			for each (var cpd:ConceptPropertyDisplay in _propertyDisplays)
				cpd.group = value;
		}
		
		override public function init(idx:int = -1, title:String = "", notes:String = "", group:int = -1):void
		{
			super.init(idx, title, notes, group);
			
			_shadow = addChildAt(new Shape(), 0) as Shape;
			var g:Graphics = _shadow.graphics;
			g.beginFill(0xFF0000, 1);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			
			_shadow.filters = [CMapConstants.CD_DROP_SHADOW];
		}
		
		public function addPropertyDisplay(cpd:ConceptPropertyDisplay):void
		{
			cpd.mainDisplay = this;
			_propertyDisplays.push(cpd);
			updateProperties();
		}
		
		public function removePropertyDisplay(cpd:ConceptPropertyDisplay):void
		{
			var cpdIdx:int = _propertyDisplays.indexOf(cpd);
			_propertyDisplays.splice(cpdIdx, 1);
			updateProperties();
		}
		
		public function updateProperties():void
		{
			var nX:Number = x;
			var nY:Number = y + height - 1;
			for each (var propDisplay:ConceptPropertyDisplay in _propertyDisplays)
			{
				propDisplay.x = nX;
				propDisplay.y = nY;
				nY += propDisplay.height - 1;
			}
			_drawHeight = nY - y;
			_shadow.height = _drawHeight;
		}
		
		public function hasProperty(cd:ConceptDisplay):Boolean
		{
			if (cd is ConceptPropertyDisplay)
				return _propertyDisplays.indexOf(cd) > -1;
			else
				return false; 
		}
		
		override protected function isValidDrawSource(cd:ConceptDisplay):Boolean
		{
			return !hasProperty(_draggingLine)
		}
		
		override protected function handleSelectedChange(e:ModelEvent):void
		{
			super.handleSelectedChange(e);
			
			// depth sort properties if present
			if (_controller.model.curSelected == this && _propertyDisplays.length > 0)
			{
				var cContainer:Sprite = _controller.container.concepts;
				// set each property to be at a depth just below the main display
				for each (var propDisplay:ConceptPropertyDisplay in _propertyDisplays)
					cContainer.setChildIndex(propDisplay, cContainer.numChildren - 2)
			}
		}
		
		override protected function handleStageDragMouseMove(event:MouseEvent):void
		{
			if (_isDown)
			{
				if (_propertyDisplays.length > 0)
					updateProperties();
			}
		}
		
		override protected function handleMouseDown(e:MouseEvent):Boolean
		{
			var doDrag:Boolean = super.handleMouseDown(e);
			
			if (doDrag)
				handleDragMouseDown(null);
			else if (e.target == _add)
				_controller.addConceptProperty(this);
			
			return false;
		}
		
		override protected function addButtons():Object
		{
			super.addButtons();
			
			// create add property button
			var label:Sprite = createAddLabel();
			var bEllispe:int = CMapConstants.BUTTON_ELLIPSE;
			var props:Object = super.addButtons();
			props[UIButton.ELLIPSE] = {tr:bEllispe, tl:bEllispe, br:0, bl:0};
			props[UIButton.WIDTH] = CMapConstants.BUTTON_WIDTH; //label.width + 10;
			_add = addChild(new UIButton(props)) as UIButton;
			label.x = (CMapConstants.BUTTON_WIDTH - label.width) / 2; //5;
			label.y = (props[UIButton.HEIGHT] - label.height) / 2 + 1;
			_add.addLabel(label);
			
			return props;
		}
		
		override protected function draw(w:int, h:int):void
		{
			super.draw(w, h);
			
			// redraw hit area for add property button
			DrawingUtil.drawRect(_hit, w + CMapConstants.BUTTON_WIDTH, h  + CMapConstants.BUTTON_HEIGHT/2, ColorData.getColor(ColorData.CD_HIT), 0, _ellipse);
			_hit.x = - CMapConstants.BUTTON_HEIGHT/2;
			_hit.y = -  CMapConstants.BUTTON_HEIGHT/2;
		}
		
		override protected function toggleButtons(show:Boolean, bImmediate:Boolean = false):Object
		{
			var props:Object = super.toggleButtons(show, bImmediate);
			
			// toggle add property buttons
			if (!_buttonsFrozen)
			{
				var aPoint:Point = show ? _buttonPos.addShow : _buttonPos.addHide;
				_tweens.push(new GTween(_add, props.time, {x:aPoint.x, y:aPoint.y}, {delay:props.delay, ease:props.ease}));
			}
			return props;
		}
		
		override protected function positionButtons(buttonsShown:Boolean):void
		{
			super.positionButtons(buttonsShown);
			
			// store positions for add property button
			var startX:Number = (_width - _add.width)/2;
			_add.x = int(startX);
			_add.y = int(-_add.height + 1);
			
			if (_buttonPos.addShow)
			{
				_buttonPos.addShow.x = _add.x;
				_buttonPos.addShow.y = _add.y;
			}
			else
				_buttonPos.addShow = new Point(_add.x, _add.y);
			if (_buttonPos.addHide)
			{
				_buttonPos.addHide.x = _add.x
				_buttonPos.addHide.y = _add.y + _add.height;
			}
			else
				_buttonPos.addHide = new Point(_add.x, _add.y + _add.height);
			
			if (!buttonsShown)
			{
				_add.x = _buttonPos.addHide.x;
				_add.y = _buttonPos.addHide.y;
			}
		}
		
		override public function freezeButtons(value:Boolean):void
		{
			super.freezeButtons(value);
			_add.freeze(value);
			
			for each (var cpd:ConceptPropertyDisplay in _propertyDisplays)
				cpd.freezeButtons(value);
		}
		
		private function createAddLabel():Sprite
		{
			var sp:Sprite  = new Sprite;
			var rad:int = 8;
			var side:int = rad * 2 * 0.7;
			var thickness:int = rad * 2 * 0.18;
			var s:Shape= new Shape();
			var g:Graphics = s.graphics;
			g.beginFill(0xFFFFFF);
			g.drawCircle(0, 0, rad);
			g.drawRect(-thickness/2, -side/2, thickness, side);
			g.drawRect(-side/2, -thickness/2, (side-thickness)/2, thickness);
			g.drawRect(thickness/2, -thickness/2, (side-thickness)/2, thickness);
			g.endFill();
			sp.addChild(s);
			s.x = s.y = rad;
			/*
			var tf:TextField = createTF("Add Property", 12);
			tf.x = s.width + 5;
			tf.y = s.y - tf.height/2;
			sp.addChild(tf);
			*/
			sp.filters = [CMapConstants.INSET_BEVEL];
			return sp;
		}
		
		private function createTF(text:String, size:int = 14, family:String = "VerdanaEmbedded", color:uint = 0xFFFFFF, bold:Boolean = true):TextField
		{
			var format:TextFormat = new TextFormat();
			format.color = color;
			format.font = family;
			format.bold = bold;
			format.size = size;
			format.letterSpacing = -0.5;
			
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
		
		override public function finalize():void
		{
			super.finalize();
			
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDragMouseUp);
			
			DisplayObjectUtil.finalizeAndRemove(_add);
			DisplayObjectUtil.remove(_shadow);
			
			_add = null;
			_shadow = null;
			_propertyDisplays = null;
			
			/*
			clearTweens()
			
			removeEventListener(MouseEvent.ROLL_OVER, handleRollOverOut, false);
			removeEventListener(MouseEvent.ROLL_OUT, handleRollOverOut, false);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
			_controller.model.removeEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false);
			//_controller.model.removeEventListener(ModelEvent.SELECTED_CD_CHANGE, handleCurCdChange, false);
			
			if (stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDragMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDrawMouseUp);
			}
			
			DisplayObjectUtil.finalizeAndRemove(_draw);
			DisplayObjectUtil.finalizeAndRemove(_close);
			DisplayObjectUtil.finalizeAndRemove(_hit);
			DisplayObjectUtil.finalizeAndRemove(_fillHolder);
			DisplayObjectUtil.finalizeAndRemove(_label)
			DisplayObjectUtil.remove(_fill);
			DisplayObjectUtil.remove(_outline);
			
			for (var key:String in _buttonPos)
				_buttonPos.key = null;
			
			_controller = null;
			_draggingLine = null;
			_draggingCd = null;
			_hit = null;
			_outline = null;
			_fill = null;
			_fillHolder = null;
			_draw = null;
			_close = null;
			_label = null;
			_buttonPos = null;
			_tweens = null;
			*/
		}
	}
}