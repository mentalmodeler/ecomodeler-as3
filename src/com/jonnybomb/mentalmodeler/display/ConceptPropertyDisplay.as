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
	
	public class ConceptPropertyDisplay extends ConceptDisplay
	{
		public function ConceptPropertyDisplay(controller:CMapController)
		{
			super(controller);
			_textProps = { user:0xFFFFFF,
						   prefill:0xCCCCCC,
						   bold:false,
						   prefillText:CMapConstants.PROP_PREFILL_TEXT,
						   letterSpacing:0,
						   insetBevel:false
			};
		}
		
		override public function get title():String { return _label.text == _textProps.prefillText ? "" : _label.text; }
		override public function get drawWidth():Number { return _mainDisplay.width; }
		override public function get drawHeight():Number { return _mainDisplay.drawHeight; }
		override public function get drawX():Number { return _mainDisplay.x; }
		override public function get drawY():Number { return _mainDisplay.y; }
		
		override public function get mainDisplay():ConceptMainDisplay { return _mainDisplay; }
		override public function set mainDisplay(cmd:ConceptMainDisplay):void { _mainDisplay = cmd; draw(_width, _height);}
		
		override protected function handleMouseDown(e:MouseEvent):Boolean
		{
			var hitHandled:Boolean = super.handleMouseDown(e);
			if (hitHandled)
				_controller.setAsCurrentCD(this);
			else
				if  (e.target == _label) _label.updateTF(e.stageX, e.stageY)
			return false;
		}
		
		override protected function getDragConceptDisplay():ConceptDisplay
		{ 
			return null; //_mainDisplay; 
		}
		
		override protected function handleStageDragMouseMove(event:MouseEvent):void
		{
			if (_isDown)
			{
				if (_mainDisplay.propertyDisplays.length > 0)
					_mainDisplay.updateProperties();
			}
		}
		
		override protected function handleLabelChange(e:Event):void
		{
			if (e.target == _label)
			{
				e.preventDefault();
				e.stopImmediatePropagation();
				_controller.model.elementTitleChange();
			}
		}
		
		override protected function isValidDrawSource(cd:ConceptDisplay):Boolean
		{ 
			if (cd == _mainDisplay)
				return false;
			else
				return !_mainDisplay.hasProperty(cd);
		}
		
		override protected function getFillColor():ColorData
		{
			return ColorData.getColor(ColorData.CD_PROP_FILL + (_mainDisplay ? _mainDisplay.group : 0));
		}
		
		override protected function getOutlineColor(isSelected:Boolean = false):ColorData
		{
			if (isSelected)
				return ColorData.getColor(ColorData.CD_OUTLINE_OVER  + (_mainDisplay ? _mainDisplay.group : 0))	
			else
				return ColorData.getColor(ColorData.CD_PROP_OUTLINE)
		}
		
		override public function finalize():void
		{
			super.finalize();
			_mainDisplay = null;
			
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