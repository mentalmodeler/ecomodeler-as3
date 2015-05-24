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
	
	public class ConceptDisplay extends Sprite implements INotable
	{
		public var tempLine:Sprite;
		
		protected static var colorsIdx:int = 0;
		protected static var creationIdx:int = 0;
		protected static var _draggingLine:ConceptDisplay;
		protected static var _draggingCd:ConceptDisplay;
		
		protected var _draw:UIButton;
		protected var _close:UIButton;
		protected var _label:ConceptDisplayLabel;
		protected var _hit:InteractiveElement;
		protected var _fillHolder:InteractiveElement;
		protected var _outline:Sprite;
		protected var _lineLinkOutline:Sprite;
		protected var _fill:Sprite;
		protected var _mainDisplay:ConceptMainDisplay
		
		protected var _controller:CMapController;
		protected var _tweens:Vector.<GTween>;
		protected var _buttonPos:Object = {};
		
		protected var _idx:int;
		protected var _color:uint;
		protected var _width:int;
		protected var _height:int;
		protected var _outlineStroke:int;
		protected var _ellipse:int;
		protected var _resizeOffsetX:Number;
		protected var _resizeOffsetY:Number;
		
		protected var _isDown:Boolean = false;
		protected var _isOver:Boolean = false;
		protected var _isSelected:Boolean = false;
		protected var _buttonsFrozen:Boolean = false;
		protected var _group:int = 0;
		public function get group():int { return _group; }
		public function set group(value:int):void { _group = value; draw(_width, _height);}
		
		protected var _textProps:Object;
		
		protected var _notes:String = "";
		public function get notes():String { return _notes; }
		public function set notes(value:String):void { _notes = value; }
		
		public function get prefillText():String { return _textProps.prefillText; }
		
		override public function get width():Number { return _width > 0 ? _width : super.width; }
		override public function get height():Number { return _height > 0 ? _height : super.height; }
		
		public function get isOver():Boolean { return _isOver };
		override public function get name():String { return _idx.toString(); }
		
		public function get title():String { return _label.text == _textProps.prefillText ? "" : _label.text; }
		public function get id():int { return _idx; }
		
		public function ConceptDisplay(controller:CMapController)
		{
			_controller = controller;
			focusRect = false;
		}
		
		override public function toString():String
		{
			return _idx + " " + (title == "" ? prefillText : title);
		}
		
		public static function set creationIndex(value:int):void
		{
			creationIdx = value;
		}
		
		public function get drawWidth():Number { return width; }
		public function get drawHeight():Number { return height; }
		public function get drawX():Number { return x; }
		public function get drawY():Number { return y; }
		public function get mainDisplay():ConceptMainDisplay { return this as ConceptMainDisplay; }
		public function set mainDisplay(cmd:ConceptMainDisplay):void { _mainDisplay = cmd; }
		
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
			
			if (group != -1)
				_group = group;
			mouseEnabled = false;
			//filters = [CMapConstants.CD_DROP_SHADOW];
			
			_notes = notes;
			
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
			_lineLinkOutline = _fillHolder.addChild(new Sprite()) as Sprite;
			_fill = _fillHolder.addChild(new Sprite()) as Sprite;
			
			if (title == "")
				title = _textProps.prefillText;
			_label = addChild(new ConceptDisplayLabel(_idx, _width, _height, title, _textProps.prefillText/*_controller.nodePrefillText*/, _textProps)) as ConceptDisplayLabel;
			_label.updateMaxSize(_width, _height);
			
			positionButtons(false);
			draw(_width, _height);
			toggleButtons(false, true);
			updateSize(_label.minWidth, _label.minHeight);
			
			addEventListener(MouseEvent.ROLL_OVER, handleRollOverOut, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, handleRollOverOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			
			addEventListener(Event.CHANGE, handleLabelChange, false, 0, true);
			
			_controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
		}
		
		protected function getFillColor():ColorData
		{
			var type:String = ColorData.CD_FILL + _group.toString();
			return ColorData.getColor(type);	
		}
		
		protected function getLineLinkColor():ColorData
		{
			var type:String = ColorData.CD_LINE_LINK + _group.toString();
			return ColorData.getColor(type);
		}
		
		protected function getOutlineColor(isSelected:Boolean = false):ColorData
		{
			if (isSelected)
				return ColorData.getColor(ColorData.CD_OUTLINE_OVER + _group);	
			else
				return ColorData.getColor(ColorData.CD_OUTLINE)
		}
		
		protected function handleLabelChange(e:Event):void
		{
			if (e.target == _label)
			{
				e.preventDefault();
				e.stopImmediatePropagation();
				_controller.model.elementTitleChange();
			}
		}
		
		protected function handleSelectedChange(e:ModelEvent):void
		{
			setAsSelected(_controller.model.curSelected == this);
			
			if (_controller.model.curSelected is InfluenceLineDisplay)
			{
				var line:InfluenceLineDisplay = _controller.model.curSelected as InfluenceLineDisplay;
				_lineLinkOutline.visible = (line.influencer == this || line.influencee == this)
			}
			else
				_lineLinkOutline.visible = false;
		}
		
		protected function draw(w:int, h:int):void
		{
			_outlineStroke = CMapConstants.CD_OUTLINE_STROKE;
			_ellipse = CMapConstants.CD_ELLIPSE;
			var stroke:int = (_outlineStroke + CMapConstants.CD_STATUSFILL_STROKE) * 2;
			
			DrawingUtil.drawRect(_hit, w + CMapConstants.BUTTON_WIDTH, h, ColorData.getColor(ColorData.CD_HIT), 0, _ellipse);
			_hit.x = - CMapConstants.BUTTON_HEIGHT/2;
			
			DrawingUtil.drawRect(_outline, w, h, getOutlineColor(_isSelected), _outlineStroke, _ellipse);
			
			_fill.x = stroke/2;
			_fill.y = stroke/2;
			DrawingUtil.drawRect(_fill, w - stroke, h - stroke, getFillColor(), 0, Math.max(0, _ellipse - stroke/2));
			
			DrawingUtil.drawRect(_lineLinkOutline, w, h, getLineLinkColor(), 2, 0);
			var lineWidth:int = 3;
			/*
			_lineLinkOutline.x = stroke/2 - lineWidth;
			_lineLinkOutline.y = stroke/2 - lineWidth;
			DrawingUtil.drawRect(_lineLinkOutline, w - (stroke-lineWidth*2), h - (stroke-lineWidth*2), getLineLinkColor(), 0, 0);
			*/
			_lineLinkOutline.visible = false;
		}
		
		protected function addButtons():Object
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
			
			return props;
		}
		
		protected function isValidDrawSource(cd:ConceptDisplay):Boolean
		{
			// implement in subclass
			return false;
		}
		
		protected function update():void
		{
			//_hit.visible = _isOver;
			toggleButtons(_isOver && _draggingLine == null);
			
			var doSelectedColor:Boolean = _isSelected || (_isOver && _draggingLine != null && _draggingLine != this && isValidDrawSource(_draggingLine))
			var colorData:ColorData
			if (doSelectedColor)
				colorData = getOutlineColor(true);
			else
				colorData = getOutlineColor();
			
			DrawingUtil.drawRect(_outline, _width, _height, colorData ,_outlineStroke, _ellipse);
		}
		
		protected function handleRollOverOut(e:MouseEvent):void
		{
			_isOver = e.type == MouseEvent.ROLL_OVER;
			update();
		}
		
		protected function toggleButtons(show:Boolean, bImmediate:Boolean = false):Object
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
				
				return {time:time, delay:delay, ease:ease};
			}
			return {};
		}
		
		protected function clearTweens():void
		{
			for each (var gTween:GTween in _tweens)
				gTween.paused = true;
			_tweens = new Vector.<GTween>();
		}
		
		protected function handleMouseDown(e:MouseEvent):Boolean
		{
			var doDrag:Boolean = false;
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
					doDrag = true;
					handleDragMouseDown(null);
					break;
				case _label:
					_label.updateTF(e.stageX, e.stageY)
					handleDragMouseDown(null);
					doDrag = true;
					break;
				case _hit:
					break;
			}
			
			if (stage && stage.focus != _label.tf)
				stage.focus = this;
			
			return doDrag;
		}
		
		protected function getDragConceptDisplay():ConceptDisplay { return this; }
		
		protected function handleDragMouseDown(event:MouseEvent):void
		{
			if (!_isDown && getDragConceptDisplay())
			{
				freezeButtons(true);
				_isDown = true;
				_controller.startDragConcept(getDragConceptDisplay());
				
				if (stage)
				{
					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleStageDragMouseMove, false, 0, true);
					stage.addEventListener(MouseEvent.MOUSE_UP, handleStageDragMouseUp, false, 0, true);
				}
				
				_draggingCd = this;
				update();
			}
		}
		
		protected function handleStageDragMouseMove(event:MouseEvent):void
		{
			// implement in subclass
		}
		
		protected function handleStageDragMouseUp(event:MouseEvent):void
		{
			if (_isDown && getDragConceptDisplay())
			{
				freezeButtons(false);
				_isDown = false;
				if (stage)
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDragMouseUp);
				_controller.stopDragConcept(getDragConceptDisplay());
				_draggingCd = null;
				update();
			}
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
			
			if (CMapConstants.cdMinHeight == 0 && h > 0)
				CMapConstants.cdMinHeight = h;
		}
		
		protected function positionButtons(buttonsShown:Boolean):void
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
				_buttonPos.closeHide.x = 1;//_close.x;
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
				_buttonPos.drawHide.x = _width - _draw.width - 1;
				_buttonPos.drawHide.y = _draw.y;
			}
			else
				_buttonPos.drawHide = new Point(_width - _draw.width, _draw.y);
			
			if (!buttonsShown)
			{
				_draw.x = _buttonPos.drawHide.x;
				_draw.y = _buttonPos.drawHide.y;
				_close.x = _buttonPos.closeHide.x;
				_close.y = _buttonPos.closeHide.y;
			}
		}
		
		public function freezeButtons(value:Boolean):void
		{
			_buttonsFrozen = value;
			_draw.freeze(value);
			_close.freeze(value);
		}
		
		protected function handleDrawMouseDown(event:MouseEvent):void
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
		
		protected function handleStageDrawMouseUp(event:MouseEvent):void
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
		
		protected function createDrawLabel():Sprite
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
		
		protected function createCloseLabel():Sprite
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
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleStageDrawMouseUp);
			
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