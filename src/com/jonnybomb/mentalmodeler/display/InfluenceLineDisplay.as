package com.jonnybomb.mentalmodeler.display
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Quadratic;
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controls.LineLabel;
	import com.jonnybomb.mentalmodeler.display.controls.LineValue;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.events.ControllerEvent;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.math.MathUtil;
	
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class InfluenceLineDisplay extends Sprite implements INotable
	{
		private static const VERTICAL:int = 0;
		private static const HORIZONTAL:int = 1;
		private static const OFFSET_X:int = 0;
		private static const OFFSET_Y:int = 1;
		private static const SCALE_SHOWN:Number = 1.2
		private static const SCALE_HIDDEN:Number = 0.5;
		
		
		private var _controller:CMapController;
		private var _influencer:ConceptDisplay;
		private var _influencee:ConceptDisplay;
		private var _lineLabel:LineLabel;
		private var _lineValue:LineValue;
		
		private var _edit:UIButton;
		private var _delete:UIButton;
		private var _buttons:Sprite;
		
		private var _arrow:Sprite;
		
		private var _erCenter:Point;
		private var _eeCenter:Point;
		private var _erEdge:Point;
		private var _eeEdge:Point;
		
		private var _comboPct:Number = 0.5;
		private var _lineAngle:Number = 0;
		
		private var _hasInfluencerOffset:Boolean = false;
		private var _hasInfluenceeOffset:Boolean = false;
		private var _lineValueMoved:Boolean = false;
		private var _isDown:Boolean = false;
		private var _isInDualRelationship:Boolean = false;
		private var _isFirstLineInDualRelationship:Boolean = false;
		private var _enabled:Boolean = true;
		private var _tweens:Vector.<GTween>;
		
		private var _notes:String = "";
		public function get notes():String { return _notes; }
		public function set notes(value:String):void { _notes = value; }
		
		protected var _group:int = 0;
		public function get group():int { return _group; }
		public function set group(value:int):void { _group = value; }
		
		override public function get name():String { return "line -> "+_influencer.name+" influencing "+_influencee.name; }
		
		public function get title():String { return _lineLabel.text; }
		public function get influenceLabel():String { return _lineValue.value.label }
		public function get influenceValue():Number { return _lineValue.value.value; }
		public function get influencer():ConceptDisplay { return _influencer; }
		public function get influencee():ConceptDisplay { return _influencee; }
		public function get hasInfluencerOffset():Boolean { return _hasInfluencerOffset; }
		public function get hasInfluenceeOffset():Boolean { return _hasInfluenceeOffset; }
		
		public function InfluenceLineDisplay(controller:CMapController, influencer:ConceptDisplay, influencee:ConceptDisplay, startValue:LineValueData, label:String ="")
		{
			_controller = controller;
			_influencer = influencer;
			_influencee = influencee;
			
			_erCenter = new Point();
			_eeCenter = new Point();
			
			_group = _influencer.mainDisplay.group; 
			
			init(startValue, label);
		}
		
		protected function addButtons():void
		{
			var spacing:int = 10;
			_buttons = addChild(new Sprite()) as Sprite;
			_buttons.visible = false;
			_buttons.scaleX = _buttons.scaleY = SCALE_HIDDEN;
			var ds:DropShadowFilter = CMapConstants.CD_DROP_SHADOW.clone() as DropShadowFilter;
			ds.knockout = false
			_buttons.filters = [ds];
			
			// button props
			var bEllispe:int = CMapConstants.BUTTON_ELLIPSE;
			var props:Object = {};
			props[UIButton.WIDTH] = CMapConstants.BUTTON_WIDTH;
			props[UIButton.HEIGHT] = CMapConstants.BUTTON_HEIGHT;
			props[UIButton.ELLIPSE] = {tr:0, tl:bEllispe, br:0, bl:bEllispe};
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			props[UIButton.DISABLED_ALPHA] = 1;
			
			// delete button
			_delete = _buttons.addChild(new UIButton(props)) as UIButton;
			_delete .addLabel(createDeleteLabel());
			_delete.x = -props[UIButton.WIDTH] + 1;
			_delete.y = -props[UIButton.HEIGHT] / 2;
			
			// edit button
			props[UIButton.ELLIPSE] = {tr:bEllispe, tl:0, br:bEllispe, bl:0};
			_edit = _buttons.addChild(new UIButton(props)) as UIButton;
			_edit.y = -props[UIButton.HEIGHT] / 2;
			_edit.addLabel(createEditLabel());
		}
		
		public function get label():String { return _lineLabel.text; }
		public function set label(value:String):void { setLineLabelText(value); }
		
		public function getLineLabelText(forEditor:Boolean = false):String
		{ 
			return _lineLabel.text != "" ? _lineLabel.text : forEditor ? _lineLabel.preFillText : CMapConstants.DEFAULT_LINE_TITLE;
		}
		
		public function setLineLabelText(s:String):void
		{ 
			_lineLabel.text = s;
			_controller.model.lineLabelChange();
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			alpha = value ? 1: CMapConstants.DISABLED_ALPHA;
			mouseEnabled = value;
			mouseChildren = value;
			buttonMode = value;
		}
		
		public function connectsTo(cd:ConceptDisplay):Boolean
		{ 
			var doesConnectTo:Boolean = false;
			if (_influencee == cd || _influencer == cd)
				doesConnectTo = true;
			else if (cd is ConceptMainDisplay)
			{
				var cmd:ConceptMainDisplay = cd as ConceptMainDisplay;
				for each (var cpd:ConceptPropertyDisplay in cmd.propertyDisplays)
				{
					if (_influencee == cpd || _influencer == cpd)
					{
						doesConnectTo = true;
						break;
					}
				}
			}
			return doesConnectTo;
		}
		
		public function setDualRelationship(isInDualRelationship:Boolean, isFirstLineinDualRelationship:Boolean = false):void
		{
			_isInDualRelationship = isInDualRelationship;
			_isFirstLineInDualRelationship = isFirstLineinDualRelationship;
		}
		
		public function get value():LineValueData { return _lineValue.value; }
		public function set value(lvd:LineValueData):void
		{ 
			_lineValue.value = lvd;
			draw();
		}
		
		private function getOffset(type:int, cd:ConceptDisplay):int
		{
			var offset:int = 0;
			var mult:Number = 1;
			
			var eeCenter:Point = getCenter(_influencee, false);
			var erCenter:Point = getCenter(_influencer, false);
			var angle:Number = Math.abs( getLineAngle(eeCenter, erCenter) );
			
			if (_isInDualRelationship)
			{
				//offset = CMapConstants.cdMinHeight / 2; // CMapConstants.DUAL_LINE_OFFSET
				if (type == OFFSET_X)
				{
					offset = cd.drawWidth * 0.5 * 0.75;
					mult = (angle < 90) ? angle / 90 : (180 - angle) / 90;
				}
				else if (type == OFFSET_Y)
				{
					offset = cd.drawHeight/2 * 0.5 * 0.75;
					mult = (angle < 90) ? (90 - angle) / 90 : (angle - 90) / 90;
				}
			}
			//trace("getOffset, rotation:"+angle+", offset:"+offset+(type == 0 ? ", offsetX" : ", offsetY")+", mult:"+mult);
			//offset = offset * mult;
			return _isFirstLineInDualRelationship ? offset : - offset ;
		}
		
		public function draw():void
		{
			var pct:Number;
			
			// determine line draw to points
			_eeCenter = getCenter(_influencee);
			_erCenter = getCenter(_influencer);
			
			// determine the angle of the line and rotate the arrow head
			_lineAngle =  getLineAngle(_eeCenter, _erCenter);
			_arrow.rotation = _lineAngle
			
			// determine the eeEdge point
			var dist:Number = Point.distance(_eeCenter, _erCenter);
			var eeRadians:Number = Math.atan2(_erCenter.x - _eeCenter.x, _erCenter.y - _eeCenter.y);
			var wOffset:Number = (_erCenter.x > _eeCenter.x) ? 0 - getOffset(OFFSET_X, _influencee) : getOffset(OFFSET_X, _influencee)
			var w:int = _influencee.drawWidth/2 + ((_erCenter.x > _eeCenter.x) ? 0 - getOffset(OFFSET_X, _influencee) : getOffset(OFFSET_X, _influencee)); // ?
			var h:int = _influencee.drawHeight/2 + ((_erCenter.y > _eeCenter.y) ? 0 - getOffset(OFFSET_Y, _influencee) : getOffset(OFFSET_Y, _influencee));
			var cos:Number = Math.cos(eeRadians);
			var hypo:Number = Math.abs(h / cos);
			var opposite:Number = Math.sqrt(Math.pow(hypo, 2) - Math.pow(h, 2));
			var adj:int = 0;
			if (opposite < w)
				pct = (dist - hypo + adj) / dist;
			else
			{
				var sin:Number = Math.sin(eeRadians);
				hypo = Math.abs(w / sin);
				pct = (dist - hypo + adj) / dist;
			}
			_eeEdge = Point.interpolate(_eeCenter, _erCenter, pct);
			
			// determine the erEdge point
			dist = Point.distance(_erCenter, _eeCenter);
			var erRadians:Number = Math.atan2(_eeCenter.x - _erCenter.x, _eeCenter.y - _erCenter.y);
			w = _influencer.drawWidth/2 + ((_eeCenter.x > _erCenter.x) ? - getOffset(OFFSET_X, _influencer) : getOffset(OFFSET_X, _influencer)); // ?
			h = _influencer.drawHeight/2  + ((_eeCenter.y > _erCenter.y) ? - getOffset(OFFSET_Y, _influencer) : getOffset(OFFSET_Y, _influencer)); // ?;
			cos = Math.cos(erRadians);
			hypo = Math.abs(h / cos);
			opposite = Math.sqrt(Math.pow(hypo, 2) - Math.pow(h, 2));
			adj = 0;
			if (opposite < w)
				pct = (dist - hypo + adj) / dist;
			else
			{
				sin = Math.sin(erRadians);
				hypo = Math.abs(w / sin);
				pct = (dist - hypo + adj) / dist;
			}
			_erEdge = Point.interpolate(_erCenter, _eeCenter, pct);
			
			// place the arrow head
			_arrow.x = _eeEdge.x;
			_arrow.y = _eeEdge.y;
			var color:uint = _lineValue.value.color;
			if (_controller.model.curSelected == this)
			{
				//var cdOver:ColorData = ColorData.getColor(ColorData.BUTTON_OVER, true);
				var cdOver:ColorData = ColorData.getColor(ColorData.CD_OUTLINE_OVER + _group);
				color = ColorExtended(cdOver.fill).color;
				
			}
			
			var value:Number = Math.abs(LineValueData(_lineValue.value).value);
			var lines:int = value == 1 ? 4 : value == 0.62 ? 2 : 1;
			graphics.clear();
			
			//draw the line hit area
			graphics.lineStyle(CMapConstants.INFLUENCE_LINE_THICKNESS + 14, 0xff0000, 0);
			graphics.moveTo(_erEdge.x, _erEdge.y);
			graphics.lineTo(_eeEdge.x, _eeEdge.y);
			
			// draw the outer part
			graphics.lineStyle(lines*3, color, 0.3); // CMapConstants.INFLUENCE_LINE_THICKNESS
			graphics.moveTo(_erEdge.x, _erEdge.y);
			graphics.lineTo(_eeEdge.x, _eeEdge.y);
			
			// draw the line
			graphics.lineStyle(lines, color, 0.9);
			graphics.moveTo(_erEdge.x, _erEdge.y);
			graphics.lineTo(_eeEdge.x, _eeEdge.y);
			
			drawArrowHead(color);
			
			//position the line label
			positionLineLabel();
			
			// postion the buttons
			positionButtons();
			
			// place the line value combo
			//positionLineValue();
		
			// debug drawings
			var rad:int = 4;
			/*
			graphics.beginFill(0x0000FF);
			graphics.drawCircle(_eeEdge.x,_eeEdge.y, rad);
			graphics.endFill();
			*/
			graphics.beginFill(color);
			graphics.drawCircle(_erEdge.x,_erEdge.y, rad);
			graphics.endFill();
		}
		
		private function getCenter(cd:ConceptDisplay, withOffset:Boolean = true):Point
		{
			var p:Point = new Point();
			p.x = cd.drawX + cd.drawWidth/2 + (withOffset ? getOffset(OFFSET_X, cd) : 0);
			p.y = cd.drawY + cd.drawHeight/2 + (withOffset ? getOffset(OFFSET_Y, cd) : 0)
			return p;
		}
		
		private function getLineAngle(eeCenter:Point, erCenter:Point):Number
		{
			var deltaX:Number = eeCenter.x - erCenter.x;
			var deltaY:Number = eeCenter.y - erCenter.y;
			var radians:Number = Math.atan2(deltaY, deltaX);
			return  radians * 180 / Math.PI;
		}
		
		private function drawArrowHead(color:uint):void
		{
			var g:Graphics = _arrow.graphics;
			var h:int = CMapConstants.ARROWHEAD_HEIGHT;
			var w:int = CMapConstants.ARROWHEAD_WIDTH;
			g.clear();
			g.beginFill(color);
			g.lineTo(-h, -w/2);
			g.lineTo(-h, w/2);
			g.lineTo(0, 0);
			g.endFill();
		}
		
		private function init(startValue:LineValueData, label:String):void
		{
			//_controlPanel.controller.model.addEventListener(ModelEvent.LINE_VALUE_CHANGE, handleLineValueChange, false, 0, true);
			//CMapController.log("InflunecyLineDisplay >> init\n\tstartValue:"+startValue);
			
			// draw arrow head
			_arrow = addChild(new Sprite()) as Sprite;
			drawArrowHead(startValue.color);
			
			// add label
			_lineLabel = addChild( new LineLabel(label) ) as LineLabel;
			addButtons();
			
			// add line value combo
			_lineValue = new LineValue(startValue);
			//addChild(_lineValue);
			//_lineValue.addEventListener(MouseEvent.MOUSE_DOWN, handleComboMouseDown, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, handleLineMouseOverOut, false, 0 , true);
			addEventListener(MouseEvent.MOUSE_OUT, handleLineMouseOverOut, false, 0 , true);
			
			addEventListener(MouseEvent.MOUSE_DOWN, handleLineMouseDown, false, 0 , true);
			addEventListener(MouseEvent.CLICK, handleLineMouseClick, false, 0 , true);
			
			// handle text label change
			addEventListener(Event.CHANGE, handleLabelChange, false, 0, true);
			
			_controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
			//_controller.model.addEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedChange, false, 0, true);
			//_controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedChange, false, 0, true);
			
			enabled = true;
		}
		
		protected function handleLabelChange(e:Event):void
		{
			if (e.target == _lineLabel)
			{
				e.preventDefault();
				e.stopImmediatePropagation();
				//_controller.model.lineLabelChange();
			}
		}
		
		protected function toggleButtons(show:Boolean, bImmediate:Boolean = false):void
		{
			var _buttonsFrozen:Boolean = false;
			if (!_buttonsFrozen)
			{
				//show ? _resize.show() : _resize.hide();
				clearTweens();
				
				var time:Number = bImmediate ? 0.01 : 0.2;
				var delay:Number = show ? 0 : 0;
				var ease:Function = show ? Quadratic.easeOut : Quadratic.easeIn;
				var scale:Number = show ? SCALE_SHOWN : SCALE_HIDDEN;
				var alpha:Number = show ? 1 : 1;
				var fCallback:Function = show ? onShown : onHidden;
				
				if (show)
					_buttons.visible = true;
				_tweens.push(new GTween(_buttons, time, {scaleX:scale, scaleY:scale}, {delay:delay, ease:ease, onComplete:fCallback}));
			}
		}
		
		private function onShown(tween:GTween):void
		{
		}
		
		private function onHidden(tween:GTween):void
		{
			_buttons.visible = false;
		}
		
		protected function clearTweens():void
		{
			for each (var gTween:GTween in _tweens)
				gTween.paused = true;
			_tweens = new Vector.<GTween>();
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			draw();
		}
		
		private function handleLineMouseOverOut(e:MouseEvent):void
		{
			toggleButtons(e.type == MouseEvent.MOUSE_OVER);
		}
		
		private function handleLineMouseDown(e:MouseEvent):void
		{
				_controller.setAsCurrentLine(this);
				switch(e.target)
				{
					case _edit:	
						var globalPoint:Point = localToGlobal( Point.interpolate(_eeEdge, _erEdge, 0.5) );
						_controller.showLineLabelEditor(globalPoint, this);
						break;
					case _delete:	
						_delete.enabled = false;
						//_controller.setAsCurrentLine(null);
						_controller.removeLineFromLineDeleteButton(this);
						break;
				}
		}	 
		
		private function handleLineMouseClick(e:MouseEvent):void
		{
			/*
			switch(e.target)
			{
				case _edit:	
					var globalPoint:Point = localToGlobal( Point.interpolate(_eeEdge, _erEdge, 0.5) );
					_controller.showLineLabelEditor(globalPoint, this);
					break;
				case _delete:	
					_controller.removeLineFromLineDeleteButton(this);
					break;
			}
			*/
		}
		
		public function toggleLineLabelShown(value:Boolean):void
		{
			_lineLabel.visible = value;
		}
		
		private function getLineValueDragOrientation():int
		{
			var angle:Number = _arrow.rotation;
			if ((angle >= -45 && angle <= 45) || angle <= -135 || angle >= 135) // horz
				return HORIZONTAL;
			else // vert
				return VERTICAL;
		}
		
		private function positionButtons():void
		{
			var p:Point = Point.interpolate(_erEdge, _eeEdge, 0.5);
			_buttons.x = p.x;
			_buttons.y = p.y;
			//var flipped:Boolean = !(_lineAngle >= -90 && _lineAngle <= 90)
			//_buttons.rotation = !flipped ? _lineAngle : 180 + _lineAngle;
		}
		
		private function positionLineLabel():void
		{
			var eeEdge:Point;
			var erEdge:Point;
			var fromPoint:Point;
			var toPoint:Point;
			var padding:int = CMapConstants.LINE_LABEL_PADDING;
			var dist:Number = Point.distance(_eeEdge, _erEdge);
			var pct:Number = padding/dist;
			
			var flipped:Boolean = !(_lineAngle >= -90 && _lineAngle <= 90) 
			
			fromPoint = Point.interpolate(_erEdge, _eeEdge, (!flipped ? 1 - pct : pct));
			toPoint = Point.interpolate(_erEdge, _eeEdge, (!flipped ? pct : 1 - pct));
			dist = Point.distance(fromPoint, toPoint);
			
			_lineLabel.updateWidth(dist);
			_lineLabel.x = fromPoint.x;
			_lineLabel.y = fromPoint.y;
			_lineLabel.rotation = !flipped ? _lineAngle : 180 + _lineAngle;
		}		
		
		private function positionLineValue(bDrag:Boolean = false):void
		{
			var angle:Number = _arrow.rotation;
			var dist:Number;
			var side:int = CMapConstants.LINE_CLOSE_SIDE;
			var padding:int = Math.sqrt(Math.pow(side/2, 2) + Math.pow(side/2, 2));
			if (bDrag)
			{
				if (getLineValueDragOrientation() == HORIZONTAL) // horz
				{
					var mX:Number = MathUtil.normalize(mouseX, MathUtil.min(_eeEdge.x, _erEdge.x), MathUtil.max(_eeEdge.x, _erEdge.x));
					dist = Math.abs(_erEdge.x - _eeEdge.x);
					_comboPct = Math.abs((mX - _eeEdge.x) / dist); 
				}
				else // vert
				{
					var mY:Number = MathUtil.normalize(mouseY, MathUtil.min(_eeEdge.y, _erEdge.y), MathUtil.max(_eeEdge.y, _erEdge.y));
					dist = Math.abs(_erEdge.y - _eeEdge.y);
					_comboPct = Math.abs((mY - _eeEdge.y) / dist); 
				}
			}
			else
				dist = Point.distance(_eeEdge, _erEdge);
			
			var p:Point = Point.interpolate(_erEdge, _eeEdge, _comboPct);
			_lineValue.x = p.x;
			_lineValue.y = p.y;
		}
		
		protected function createEditLabel():Sprite
		{
			var w:int = 6
			var icon:Sprite = new Sprite();
			var g:Graphics = icon.graphics;
			g.lineStyle(1.5, 0xFFFFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			g.moveTo(0, 0);
			g.lineTo(w, 0);
			var nY:Number = 3;
			g.lineTo(w, nY);
			g.lineTo(0, nY);
			g.lineTo(0, 0);
			g.moveTo(0, nY);
			nY = 11;
			g.lineTo(0, nY);
			g.lineTo(w, nY);
			g.lineTo(w/2, 17);
			g.lineTo(0, nY);
			g.moveTo(w, nY);
			g.lineTo(w, 3)
			icon.filters = [CMapConstants.INSET_BEVEL];
			icon.rotation = 35;
			icon.x = 16;
			icon.y = 5;
			return icon;
		}
		
		
		protected function createDeleteLabel():Sprite
		{
			var size:int = 5;
			var icon:Sprite = new Sprite();
			icon.graphics.lineStyle(3, 0xFFFFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			icon.graphics.moveTo(-size, -size);
			icon.graphics.lineTo(size, size);
			icon.graphics.moveTo(size, -size);
			icon.graphics.lineTo(-size, size);
			icon.filters = [CMapConstants.INSET_BEVEL]
			icon.x = _delete.width / 2; 
			icon.y = _delete.height / 2;
			return icon;
		}
		
		public function finalize():void
		{	
			clearTweens();
			
			removeEventListener(MouseEvent.MOUSE_OVER, handleLineMouseOverOut, false);
			removeEventListener(MouseEvent.MOUSE_OUT, handleLineMouseOverOut, false);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleLineMouseDown, false);
			removeEventListener(MouseEvent.CLICK, handleLineMouseClick, false);
			_controller.model.removeEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false);
			//_controller.model.removeEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedChange, false);
			//_controller.model.removeEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedChange, false);
			
			DisplayObjectUtil.finalizeAndRemove(_lineValue);
			DisplayObjectUtil.finalizeAndRemove(_lineLabel);
			DisplayObjectUtil.finalizeAndRemove(_edit);
			DisplayObjectUtil.finalizeAndRemove(_delete);
			DisplayObjectUtil.remove(_arrow);
			DisplayObjectUtil.remove(_buttons);
			
			_controller = null;
			_influencer = null;
			_influencee = null;
			_lineValue = null;
			_arrow = null;
			_erCenter = null;
			_eeCenter = null;
			_eeEdge = null;
			_erEdge = null;
			_lineLabel = null;
			_edit = null;
			_delete = null;
			_buttons = null;
			_tweens = null;
		}
	}
}