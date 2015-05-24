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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	AutoHidePlugin.install();
	
	public class ConceptDisplayBackup extends Sprite implements INotable
	{
		public var tempLine:Sprite;
		
		private static var colorsIdx:int = 0;
		private static var creationIdx:int = 0;
		private static var _draggingLine:ConceptDisplay;
		private static var _draggingCd:ConceptDisplay;
		
		private var _draw:UIButton;
		private var _close:UIButton;
		private var _label:ConceptDisplayLabel;
		private var _hit:InteractiveElement;
		private var _fillHolder:InteractiveElement;
		private var _outline:Sprite;
		private var _fill:Sprite;
		
		private var _controller:CMapController;
		private var _tweens:Vector.<GTween>;
		private var _buttonPos:Object = {};
		
		private var _idx:int;
		private var _color:uint;
		private var _width:int;
		private var _height:int;
		private var _outlineStroke:int;
		private var _ellipse:int;
		private var _resizeOffsetX:Number;
		private var _resizeOffsetY:Number;
		
		private var _isDown:Boolean = false;
		private var _isOver:Boolean = false;
		private var _isSelected:Boolean = false;
		private var _buttonsFrozen:Boolean = false;
		private var _group:int = -1;
		
		private var _notes:String = "";
		public function get notes():String { return _notes; }
		public function set notes(value:String):void { _notes = value; }
			
		
		override public function get width():Number { return _width > 0 ? _width : super.width; }
		override public function get height():Number { return _height > 0 ? _height : super.height; }
		
		public function get isOver():Boolean { return _isOver };
		override public function get name():String { return _idx.toString(); }
		
		public function get title():String { return _label.text == _controller.nodePrefillText ? "" : _label.text; }
		public function get id():int { return _idx; }
		
		public function ConceptDisplay(controller:CMapController)
		{
			_controller = controller;
			focusRect = false;
		}
		
		public static function set creationIndex(value:int):void
		{
			creationIdx = value;
		}
		
		public function setAsSelected(value:Boolean):void
		{
			_isSelected = value;
			update();
		}
		
		public function setToOverState():void
		{
			_isOver = true;
			toggleButtons(true);
		}
		
		public function init(idx:int = -1, title:String = "", notes:String = "", group:int = -1):void
		{
			_idx = (idx == -1) ? creationIdx++ : idx;
			
			_group = group;
			mouseEnabled = false;
			filters = [CMapConstants.CD_DROP_SHADOW];
			
			_notes = notes;
			//_width = w > 0 ? w : CMapConstants.CD_WIDTH;
			//_height = h > 0 ? h : CMapConstants.CD_HEIGHT;
			
			tempLine = addChild(new Sprite()) as Sprite;
			tempLine.mouseChildren = false;
			tempLine.mouseEnabled = false;
			
			_hit = addChild(new InteractiveElement()) as InteractiveElement;
			_hit.mouseChildren = false;
			_hit.enabled = true;
			_hit.buttonMode = false;
			
			addButtons();
			
			_fillHolder = addChild(new InteractiveElement()) as InteractiveElement;
			_fillHolder.mouseChildren = false;
			_fillHolder.enabled = true;
			
			_outline = _fillHolder.addChild(new Sprite()) as Sprite;
			_fill = _fillHolder.addChild(new Sprite()) as Sprite;
			
			// label
			_label = addChild(new ConceptDisplayLabel(_idx, _width, _height, title, _controller.nodePrefillText)) as ConceptDisplayLabel;
			_label.updateMaxSize(_width, _height);
			
			// resize button
			//_resize = addChild(new ResizeButton()) as ResizeButton;
			
			// position the buttons
			positionButtons(false);
			
			// draw
			draw(_width, _height);
			
			toggleButtons(false, true);
			
			updateSize(_label.minWidth, _label.minHeight);
			
			// add event listeners
			addEventListener(MouseEvent.ROLL_OVER, handleRollOverOut, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, handleRollOverOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			
			addEventListener(Event.CHANGE, handleLabelChange, false, 0, true);
			
			_controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
			//_controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleCurCdChange, false, 0, true);
		}
		
		private function handleLabelChange(e:Event):void
		{
			if (e.target == _label)
			{
				e.preventDefault();
				e.stopImmediatePropagation();
				_controller.model.elementTitleChange();
			}
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			setAsSelected(_controller.model.curSelected == this)
		}
		
		private function draw(w:int, h:int):void
		{
			_outlineStroke = CMapConstants.CD_OUTLINE_STROKE;
			_ellipse = CMapConstants.CD_ELLIPSE;
			var stroke:int = (_outlineStroke + CMapConstants.CD_STATUSFILL_STROKE) * 2;
			
			DrawingUtil.drawRect(_hit, w + CMapConstants.BUTTON_WIDTH, h, ColorData.getColor(ColorData.CD_HIT), 0, _ellipse);
			_hit.x = - CMapConstants.BUTTON_HEIGHT/2;
			
			DrawingUtil.drawRect(_outline, w, h, ColorData.getColor(ColorData.CD_OUTLINE), _outlineStroke, _ellipse);
			
			_fill.x = stroke/2;
			_fill.y = stroke/2;
			DrawingUtil.drawRect(_fill, w - stroke, h - stroke, ColorData.getColor(ColorData.CD_FILL), 0, Math.max(0, _ellipse - stroke/2));
		}
		
		private function addButtons():void
		{
			// button props
			var bEllispe:int = CMapConstants.BUTTON_ELLIPSE;
			var props:Object = {};
			props[UIButton.WIDTH] = CMapConstants.BUTTON_WIDTH;
			props[UIButton.HEIGHT] = CMapConstants.BUTTON_HEIGHT;
			props[UIButton.ELLIPSE] = {tr:bEllispe, tl:0, br:bEllispe, bl:0};
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			
			// draw button
			_draw = addChild(new UIButton(props)) as UIButton;
			_draw.addLabel(createDrawLabel());
			
			//close button
			props[UIButton.ELLIPSE] = {tr:0, tl:bEllispe, br:0, bl:bEllispe};
			_close = addChild(new UIButton(props)) as UIButton;
			_close.addLabel(createCloseLabel());
		}
		
		private function update():void
		{
			//_hit.visible = _isOver;
			toggleButtons(_isOver && _draggingLine == null);
			
			var doSelectedColor:Boolean = _isSelected || (_isOver && _draggingLine != this && _draggingLine != null);
			var colorData:ColorData
			if (doSelectedColor)
			{
				colorData = ColorData.getColor(ColorData.CD_OUTLINE_OVER);
				var glow:GlowFilter = new GlowFilter(ColorExtended(colorData.fill).color, 1, 12, 12, 0.5, BitmapFilterQuality.MEDIUM);
				//filters = [glow, CMapConstants.CD_DROP_SHADOW];
			}
			else
			{
				colorData = ColorData.getColor(ColorData.CD_OUTLINE);
				//filters = [CMapConstants.CD_DROP_SHADOW];
			}
			
			DrawingUtil.drawRect(_outline, _width, _height, colorData ,_outlineStroke, _ellipse);
		}
		
		private function handleRollOverOut(e:MouseEvent):void
		{
			_isOver = e.type == MouseEvent.ROLL_OVER;
			update();
		}
		
		private function toggleButtons(show:Boolean, bImmediate:Boolean = false):void
		{
			if (!_buttonsFrozen)
			{
				//show ? _resize.show() : _resize.hide();
				clearTweens();
				
				var time:Number = bImmediate ? 0.01 : 0.2;
				var delay:Number = show ? 0 : 0;
				var ease:Function = Quadratic.easeOut;
				var dPoint:Point = show ? _buttonPos.drawShow : _buttonPos.drawHide;
				var cPoint:Point = show ? _buttonPos.closeShow : _buttonPos.closeHide;
				var alpha:Number = show ? 1 : 1;
				
				_tweens.push(new GTween(_draw, time, {x:dPoint.x, y:dPoint.y}, {delay:delay, ease:ease}));
				_tweens.push(new GTween(_close, time, {x:cPoint.x, y:cPoint.y}, {delay:delay, ease:ease}));
			}
		}
		
		private function clearTweens():void
		{
			for each (var gTween:GTween in _tweens)
				gTween.paused = true;
			_tweens = new Vector.<GTween>();
		}
		
		private function handleMouseDown(e:MouseEvent):void
		{
			var removed:Boolean = false;
			switch (e.target)
			{
				case _draw:
					handleDrawMouseDown(null);
					break;
				case _close:
					//_controller.setAsCurrentCD(this);
					//trace("ConceptDisplay >> "+id+" >> close");
					_controller.removeConcept(this);
					break;
				case _fillHolder:
					handleDragMouseDown(null);
					break;
				case _label:
					_label.updateTF(e.stageX, e.stageY)
					handleDragMouseDown(null);
					break;
				/*
				case _resize:
					_controller.setAsCurrentCD(this);
					handleResizeMouseDown(null);
					break;
				*/
				case _hit:
					break;
			}
			
			if (stage && stage.focus != _label.tf)
				stage.focus = this;
		}
		
		public function updateSize(w:int, h:int):void
		{
			var changed:Boolean = _width != w || _height != h;
			if (changed)
			{
				_width = w < CMapConstants.CD_WIDTH ? CMapConstants.CD_WIDTH : w > CMapConstants.CD_WIDTH_MAX ? CMapConstants.CD_WIDTH_MAX : w;
				_height = h;
				
				_label.updateMaxSize(_width, _height);
				draw(_width, _height);
				update();
				positionButtons(_isOver || _isDown);
				_controller.handleRedrawLines();
			}
		}
		
		private function positionButtons(buttonsShown:Boolean):void
		{
			clearTweens();
			
			var startX:Number = 0 - _close.width + 1; //(_width - _close.width)/2;
			_close.x = int(startX);
			_close.y = int(_height - _close.height)/2; //int(-_close.height + 1);
			
			if (_buttonPos.closeShow)
			{
				_buttonPos.closeShow.x = _close.x;
				_buttonPos.closeShow.y = _close.y;
			}
			else
				_buttonPos.closeShow = new Point(_close.x, _close.y);
			if (_buttonPos.closeHide)
			{
				_buttonPos.closeHide.x = 0;//_close.x;
				_buttonPos.closeHide.y = _close.y;
			}
			else
				_buttonPos.closeHide = new Point(0, _close.y); //_close.x, _close.y + _close.height);
			
			startX = _width - 1; //(_width - _close.width)/2;
			_draw.x = int(startX);
			_draw.y = (_height - _draw.height)/2; //int(_height - 1);
			if (_buttonPos.drawShow)
			{
				_buttonPos.drawShow.x = _draw.x
				_buttonPos.drawShow.y = _draw.y;
			}
			else
				_buttonPos.drawShow = new Point(_draw.x, _draw.y);
			if (_buttonPos.drawHide)
			{
				_buttonPos.drawHide.x = _width - _draw.width;
				_buttonPos.drawHide.y = _draw.y;
			}
			else
				_buttonPos.drawHide = new Point(_width - _draw.width, _draw.y);
			
			if (!buttonsShown)
			{
				trace("!buttonsShown");
				_draw.x = _buttonPos.drawHide.x;
				_draw.y = _buttonPos.drawHide.y;
				_close.x = _buttonPos.closeHide.x;
				_close.y = _buttonPos.closeHide.y;
			}
			/*
			var startX:Number = (_width - _close.width)/2;
			_close.x = int(startX);
			_close.y = int(-_close.height + 1);
			
			if (_buttonPos.closeShow)
			{
				_buttonPos.closeShow.x = _close.x;
				_buttonPos.closeShow.y = _close.y;
			}
			else
				_buttonPos.closeShow = new Point(_close.x, _close.y);
			if (_buttonPos.closeHide)
			{
				_buttonPos.closeHide.x = _close.x
				_buttonPos.closeHide.y = _close.y + _close.height;
			}
			else
				_buttonPos.closeHide = new Point(_close.x, _close.y + _close.height);
			
			startX = (_width - _close.width)/2;
			_draw.x = int(startX);
			_draw.y = int(_height - 1);
			if (_buttonPos.drawShow)
			{
				_buttonPos.drawShow.x = _draw.x
				_buttonPos.drawShow.y = _draw.y;
			}
			else
				_buttonPos.drawShow = new Point(_draw.x, _draw.y);
			if (_buttonPos.drawHide)
			{
				_buttonPos.drawHide.x = _draw.x
				_buttonPos.drawHide.y = _draw.y - _draw.height;
			}
			else
				_buttonPos.drawHide = new Point(_draw.x, _draw.y - _draw.height);
			
			if (!buttonsShown)
			{
				_draw.x = _buttonPos.drawHide.x;
				_draw.y = _buttonPos.drawHide.y;
				_close.x = _buttonPos.closeHide.x;
				_close.y = _buttonPos.closeHide.y;
			}
			*/
		}
		
		private function freezeButtons(value:Boolean):void
		{
			_buttonsFrozen = value;
			//_resize.freeze(value);
			_draw.freeze(value);
			_close.freeze(value);
		}
		
		/*
		private function handleResizeMouseDown(e:MouseEvent):void
		{
			if (!_isDown)
			{
				freezeButtons(true);
				_isDown = true;
				_resizeOffsetX = _width - mouseX;
				_resizeOffsetY = _height - mouseY;
				if (stage)
				{
					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleResizeStageMouseMove, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_UP, handleResizeStageMouseUp, false, 0, true);
				}
				_controller.startResizeConcept(this);
			}
		}
		
		private function handleResizeStageMouseMove(e:MouseEvent):void
		{
			if (_isDown)
			{
				var w:int = mouseX + _resizeOffsetX;
				if (w < CMapConstants.CD_WIDTH)
					w = CMapConstants.CD_WIDTH;
				if (w < _label.minWidth)
					w = _label.minWidth;
				
				var h:int = mouseY + _resizeOffsetY;
				if (h < CMapConstants.CD_HEIGHT)
					h = CMapConstants.CD_HEIGHT;
				if (h < _label.minHeight)
					h = _label.minHeight;
				
				var rect:Rectangle = _controller.rect;
				if (rect)
				{
					if (w > rect.width - x)
						w = rect.width - x;
					if (h > rect.height - y)
						h= rect.height - y;
				}
				
				updateSize(w, h);
			}
		}
		
		private function handleResizeStageMouseUp(e:MouseEvent):void
		{
			if (_isDown)
			{
				freezeButtons(false);
				_isDown = false;
				if (stage)
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleResizeStageMouseMove, false);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleResizeStageMouseUp, false);
				}
				_controller.stopResizeConcept(this);
			}
		}
		*/
		
		private function handleDragMouseDown(event:MouseEvent):void
		{
			if (!_isDown)
			{
				freezeButtons(true);
				_isDown = true;
				_controller.startDragConcept(this);
				if (stage)
					stage.addEventListener(MouseEvent.MOUSE_UP, handleStageDragMouseUp, false, 0, true);
				_draggingCd = this;
				update();
			}
		}
		
		private function handleStageDragMouseUp(event:MouseEvent):void
		{
			if (_isDown)
			{
				freezeButtons(false);
				_isDown = false;
				if (stage)
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDragMouseUp);
				_controller.stopDragConcept(this);
				_draggingCd = null;
				update();
			}
		}
		
		private function handleDrawMouseDown(event:MouseEvent):void
		{
			if (!_isDown)
			{
				_isDown = true;
				if (stage)
					stage.addEventListener(MouseEvent.MOUSE_UP, handleStageDrawMouseUp, false, 0, true);
				_controller.startDrawTempLine(this);
				_draggingLine = this;
				update();
			}
		}
		
		private function handleStageDrawMouseUp(event:MouseEvent):void
		{
			if (_isDown)
			{
				_isDown = false;
				if (stage)
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDrawMouseUp);
				
				_controller.stopDrawTempLine(this);
				_draggingLine = null;
				update();
			}
		}
		
		private function createDrawLabel():Sprite
		{
			var thickness:Number = 0.18; //0.15
			var radius:int = 8;
			var icon:Sprite = new Sprite();
			var g:Graphics = icon.graphics;
			g.beginFill(0xFFFFFF);
			g.drawCircle(0, 0, radius);
			g.moveTo(0, Math.round(radius * 0.66) );
			g.lineTo(-Math.round(radius * 0.5), 0);
			g.lineTo(-Math.round(radius * thickness), 0);
			g.lineTo(-Math.round(radius * thickness), - Math.round(radius * 0.66));
			g.lineTo(Math.round(radius * thickness), - Math.round(radius * 0.66));
			g.lineTo(Math.round(radius * thickness), 0);
			g.lineTo(Math.round(radius * 0.5), 0);
			g.lineTo(0, Math.round(radius * 0.66) )
			g.endFill();
			icon.filters = [CMapConstants.INSET_BEVEL]
			icon.x = _draw.width / 2; 
			icon.y = _draw.height / 2;
			icon.rotation = -90;
			
			return icon;
		}
		
		private function createCloseLabel():Sprite
		{
			var size:int = 5;
			var icon:Sprite = new Sprite();
			icon.graphics.lineStyle(3, 0xFFFFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			icon.graphics.moveTo(-size, -size);
			icon.graphics.lineTo(size, size);
			icon.graphics.moveTo(size, -size);
			icon.graphics.lineTo(-size, size);
			icon.filters = [CMapConstants.INSET_BEVEL]
			icon.x = _close.width / 2; 
			icon.y = _close.height / 2;
			
			return icon;
		}
		
		public function finalize():void
		{
			clearTweens()
			
			removeEventListener(MouseEvent.ROLL_OVER, handleRollOverOut, false);
			removeEventListener(MouseEvent.ROLL_OUT, handleRollOverOut, false);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
			_controller.model.removeEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false);
			//_controller.model.removeEventListener(ModelEvent.SELECTED_CD_CHANGE, handleCurCdChange, false);
			
			if (stage)
			{
				/*
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleResizeStageMouseMove, false);
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleResizeStageMouseUp, false);
				*/
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDragMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDrawMouseUp);
			}
			
			DisplayObjectUtil.finalizeAndRemove(_draw);
			DisplayObjectUtil.finalizeAndRemove(_close);
			//DisplayObjectUtil.finalizeAndRemove(_resize);
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
			//_resize = null;
			_label = null;
			_buttonPos = null;
			_tweens = null;
		}
	}
}