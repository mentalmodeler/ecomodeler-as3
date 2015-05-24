package com.jonnybomb.mentalmodeler.display.controls
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Back;
	import com.gskinner.motion.easing.Linear;
	import com.gskinner.motion.easing.Quadratic;
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	public class ResizeButton extends Sprite
	{
		private static const SIDE:int = 25;
		private static const BEVEL:BevelFilter = new BevelFilter(1, 45, 0xffffff, 0.65, 0x000000, 0.75, 1, 1, 0.75, BitmapFilterQuality.LOW, BitmapFilterType.OUTER, true);
		private static const GLOW:GlowFilter = new GlowFilter(0x154B88, 1, 3, 3, 5, BitmapFilterQuality.LOW, true);
		
		private var _button:UIButton;
		private var _mask:Sprite;
		private var _tween:GTween;
		private var _frozen:Boolean = false;
		
		public function ResizeButton()
		{
			init();
		}
		
		public function finalize():void
		{
			if (_tween)
				_tween.paused = true;
			
			if (_button)
			{
				_button.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
				_button.removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false);
				_button.removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false);
			}
			
			DisplayObjectUtil.finalizeAndRemove(_button);
			DisplayObjectUtil.remove(_mask);
			
			_tween = null;
			_button = null;
			_mask = null;
		}
		
		public function freeze(value:Boolean):void
		{ 
			_frozen = value;
			_button.freeze(value);
		}
		
		public function show():void { tween(true); }
		public function hide():void{ tween(false); }
		private function tween(show:Boolean):void
		{
			if (_frozen)
				return;
			
			if (_tween)
				_tween.paused = true;
			
			var time:Number = 0.2;
			var ease:Function = Quadratic.easeOut;
			var loc:int = show ? 0 : SIDE/2;
			_tween = new GTween(_mask, time, {x:loc, y:loc}, {ease:ease});
		}
		
		private function init():void
		{
			/*
			var ratios:Array = [128, 180, 215, 255]; //[0, 105, 180, 255];
			var up:ColorData = ColorData.getColor(ColorData.BUTTON_UP);
			var over:ColorData =  ColorData.getColor(ColorData.BUTTON_OVER)
			up.fill.rotation = 45;
			up.fill.ratios = ratios;
			over.fill.rotation = 45;
			over.fill.ratios = ratios;
			*/
			
			var bEllispe:int = CMapConstants.BUTTON_ELLIPSE - 4;
			var props:Object = {};
			props[UIButton.STROKE] = 0;
			props[UIButton.WIDTH] = SIDE;
			props[UIButton.HEIGHT] = SIDE;
			props[UIButton.ELLIPSE] = {tr:0, tl:0, br:bEllispe, bl:0};
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			//props[UIButton.STATE_COLORS] = {up:up, over:over};
			_button = addChild(new UIButton(props)) as UIButton;
			
			_button.addLabel(drawGrips());
			_button.x = -SIDE;
			_button.y = -SIDE;
			_button.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			_button.addEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false, 0, true);
			_button.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false, 0, true);
		
			_mask = addChild(new Sprite()) as Sprite;
			var g:Graphics = _mask.graphics;
			g.beginFill(0xff0000, 1);
			g.lineTo(0, -SIDE);
			g.lineTo(-SIDE, 0);
			g.lineTo(0, 0);
			g.endFill();
			_mask.x = SIDE/2;
			_mask.y = SIDE/2;
			_button.mask = _mask;
			
			updateStroke(false);
		}
		
		private function drawGrips():Sprite
		{
			var s:Sprite = new Sprite;
			var g:Graphics = s.graphics;
			g.lineStyle(1, 0x000000);
			var offset:int = 2;
			var pos:int = 5;
			for (var i:int=0; i<3; i++)
			{
				g.moveTo(-offset, -pos);
				g.lineTo(-pos, -offset);
				pos += 6;
			}
			s.x = SIDE;
			s.y = SIDE;
			s.filters = [BEVEL];
			return s;
		}
		
		private function updateStroke(over:Boolean):void
		{
			GLOW.color = over ? 0x873E15 : 0x154B88;
			filters = [GLOW];
		}
		
		private function handleMouseOverOut(e:MouseEvent):void
		{
			updateStroke(e.type == MouseEvent.MOUSE_OVER);
		}
		
		private function handleMouseDown(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			e.preventDefault();
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
	}
}