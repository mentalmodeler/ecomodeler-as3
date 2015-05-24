package com.jonnybomb.mentalmodeler.display.controls
{
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	public class UIButton extends Sprite
	{
		public static const SELECTED_CHANGE:String = "UIButtonSelectedChange";
		
		public static const WIDTH:String = "_width";
		public static const HEIGHT:String = "_height";
		public static const ELLIPSE:String = "_ellipse";
		public static const STROKE:String = "_stroke";
		public static const ENABLED:String = "_enabled";
		public static const HAS_BEVEL:String = "_hasBevel";
		public static const STATE_COLORS:String = "_stateColors";
		public static const USE_DROP_SHADOW:String = "_useDropShadow";
		public static const DISABLED_ALPHA:String = "_disabledAlpha";
		public static const DROP_SHADOW:String = "_dropShadow";
		public static const BEVEL_FILTER:String = "_bevelFilter";
		public static const SELECTED_GLOW_FILTER:String = "_selectedGlowFilter";
		public static const HAS_DOWN_STATE:String = "_hasDownState";
		public static const USE_GRAPHIC_DOWN_STATE:String = "_useGraphicDownState";
		public static const HAS_LABEL_DOWN_STATE:String = "_hasLabelDownState";
		public static const MOUSE_DOWN_DISTANCE:String = "_mouseDownDistance";
		public static const USE_CONTINUAL_DOWN_FIRING:String = "_useContinualDownFiring";
		public static const HAS_SELECTED_STATE:String = "_hasSelectedState";
		public static const HAS_TOGGLE_GRAPHIC:String = "_hasToggleGraphic";
		public static const HAS_GLOSSY_BEVEL:String = "_hasGlossBevel";
		
		private static const DEFAULT_BEVEL:BevelFilter = new BevelFilter(1, 90, 0xFFFFFF, 1, 0x000000, 0, 2, 2, 0.5, BitmapFilterQuality.LOW, BitmapFilterType.INNER, true);
		private static const DEFAULT_SELECTED_GLOW:GlowFilter = new GlowFilter(0x000000, 1, 8, 8, 0.8, BitmapFilterQuality.MEDIUM, true, true);
		private static const DEFAULT_DS:DropShadowFilter = new DropShadowFilter(2, 90, 0x000000, 0.5, 5, 5, 1, 1);
		
		private var _up:Sprite;
		private var _over:Sprite;
		private var _down:Sprite;
		private var _bevel:Sprite;
		private var _selectedGlow:Sprite;
		private var _toggleUp:Sprite;
		private var _toggleOver:Sprite;
		private var _holder:Sprite;
		private var _labelHolder:Sprite;
		private var _hitHelper:Sprite;
		
		protected var _isOver:Boolean = false;
		protected var _isDown:Boolean = false;
		protected var _isSelected:Boolean = false;
		protected var _downTimer:Timer;
		protected var _timerDelay:int = 200;
		
		// customizable properties
		protected var _width:Number = 28;
		protected var _height:Number = 28;
		protected var _stroke:Number = 1;
		protected var _ellipse:* = 11;
		protected var _disabledAlpha:Number = 0.4;
		protected var _enabled:Boolean = true;
		protected var _useDropShadow:Boolean = true;
		protected var _hasBevel:Boolean = true;
		protected var _hasDownState:Boolean = true;
		protected var _useGraphicDownState:Boolean = false;
		protected var _hasLabelDownState:Boolean = true;
		protected var _mouseDownDistance:int = 2;
		protected var _useContinualDownFiring:Boolean = false;
		protected var _hasSelectedState:Boolean = false;
		protected var _hasToggleGraphic:Boolean = false;
		protected var _hasGlossyBevel:Boolean = true;
		protected var _dropShadow:DropShadowFilter = DEFAULT_DS; //new DropShadowFilter(2, 90, 0x000000, 0.5, 5, 5, 1, 1);
		protected var _bevelFilter:BevelFilter = DEFAULT_BEVEL; //new BevelFilter(1, 90, 0xFFFFFF, 1, 0x000000, 0, 2, 2, 0.5, BitmapFilterQuality.LOW, BitmapFilterType.INNER, true);
		protected var _selectedGlowFilter:GlowFilter = DEFAULT_SELECTED_GLOW; //new GlowFilter(0x000000, 0.8, 8, 8, 1, BitmapFilterQuality.MEDIUM, true, true);
		
		protected var _hitHelperColors:ColorData = new ColorData(null, new ColorExtended(0xFF0000, 0));
		protected var _stateColors:Object = {
			up: ColorData.getColor(ColorData.BUTTON_UP),
			over: ColorData.getColor(ColorData.BUTTON_OVER)
		};
		
		public function get bevel():Sprite { return _bevel };
		public function get buttonWidth():Number { return _width };
		public function get buttonHeight():Number { return _height };
		public function get isOver():Boolean { return _isOver; }
		public function get isDown():Boolean { return _isDown; }
		public function get label():DisplayObject { return (_labelHolder && _labelHolder.numChildren > 0) ? _labelHolder.getChildAt(0) : null; }
		
		public function addGlossyBevel():void
		{
			_bevelFilter = null;
			_bevel.filters = [];
			_bevel.scrollRect = new Rectangle(0, 0, _width, _height/2);
			_bevel.visible = false;
		}
		
		public function UIButton(overrides:Object = null, doDraw:Boolean = true)
		{
			visible = false;
			mouseChildren = false;
			
			if (overrides != null)
				doOverrides(overrides);
			
			if (doDraw && _stateColors != null)
			{
				init();//draw();
				redraw();
			}
			
			addEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false, 0, true);
			
			if (_hasDownState || _useContinualDownFiring || _hasSelectedState)
			{
				addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
				
				if (_useContinualDownFiring)
				{
					// continual firing down button stuff
					_downTimer = new Timer(_timerDelay);
					_downTimer.addEventListener(TimerEvent.TIMER, handleDownTimer, false, 0, true);
				}
			}
		}
		
		public function setSize(w:int = -1, h:int = -1, doRedraw:Boolean = true):void
		{
			if (w > 0)
				_width = w;
			if (h > 0)
				_height = h;
			if (doRedraw)
				redraw();
		}
		
		public function setColor(states:Vector.<Object>, doRedraw:Boolean = true):void
		{
			for each (var o:Object in states)
			{
				if ( o.hasOwnProperty("state") && o.hasOwnProperty("color") && _stateColors.hasOwnProperty(o.state) ) 
					_stateColors[o.state] = o.color;
			}
			if (doRedraw)
				redraw();
		}
		
		public function finalize():void //destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut);
			removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			
			if (_downTimer)
			{
				_downTimer.reset();
				_downTimer.removeEventListener(TimerEvent.TIMER, handleDownTimer);
				_downTimer = null;
			}
			
			DisplayObjectUtil.removeChildrenAndDestroy(this);
			
			_dropShadow = null;
			_bevelFilter = null;
			_selectedGlowFilter = null;
			_hitHelperColors = null;
			_stateColors = null;
			_up = null;
			_over = null;
			_down = null;
			_bevel = null;
			_selectedGlow = null;
			_toggleUp = null;
			_toggleOver = null;
			_holder = null;
			_labelHolder = null;
			_hitHelper = null;
		}
		
		public function freeze(value:Boolean):void
		{
			_enabled = !value;
			mouseEnabled = !value;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			buttonMode = value;
			mouseEnabled = value;
			
			if (_useDropShadow)
				_holder.filters = value ? [_dropShadow] : [];
			
			alpha = value ? 1 : _disabledAlpha;
			//_labelHolder.alpha = value ? 1 : _disabledAlpha;
			
			if (_isOver && !_enabled)
				_isOver = false;
			
			if (_hasDownState || _useContinualDownFiring)
			{
				if (_useContinualDownFiring)
				{
					if (_downTimer && _downTimer.running)
					{
						_downTimer.stop();
						_downTimer.reset();
					}
					
					if (_isDown)
						dispatchEvent(new Event(Event.COMPLETE));
				}
				
				if (!_enabled && stage)
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				
				if (_isDown)
					_isDown = false
			}
			
			update();
		}
		
		public function set selected(value:Boolean):void
		{
			if (!_hasSelectedState)
				return;
			
			var dirty:Boolean = _isSelected != value;
			_isSelected = value;
			update();
			
			if (dirty)
				dispatchEvent(new Event(SELECTED_CHANGE, true, true));
			
		}
		
		public function get selected():Boolean
		{
			return _isSelected;
		}
		
		public function addLabel(dObj:DisplayObject):void
		{
			_labelHolder.addChild(dObj);
		}
		
		public function clearLabel():void
		{
			if (_labelHolder)
			{
				while(_labelHolder.numChildren > 0)
					_labelHolder.removeChildAt(0);
			}
		}
		
		public function getProp(s:String):*
		{
			return this[s];
		}
		
		protected function update():void
		{
			if (_isOver)
			{
				_up.visible = false;
				_over.visible = true;
				
				if (_hasToggleGraphic)
				{
					_toggleUp.visible = false;
					_toggleOver.visible = true;
				}
				
				if (_hasDownState)
				{
					if (_isDown)
					{
						if (_useGraphicDownState)
						{
							_over.visible = false;
							_down.visible = true;
						}
						else
						{
							_holder.y = _mouseDownDistance;
							if (_useDropShadow)
								_holder.filters = [];
						}
						
						if (_hasSelectedState)
							_selectedGlow.visible = !_isSelected;
					}
					else
					{
						if (_isSelected){ /* do nothing */ }	
						else if (_useGraphicDownState)
							_down.visible = false;
						else
							_holder.y = 0;
					}
				}
				
				if (_hasLabelDownState)
				{
					if (_isDown)
					{
						if (!_useGraphicDownState)
							_labelHolder.y = _mouseDownDistance;
					}
					else
					{
						if (!_isSelected && !_useGraphicDownState)
							_labelHolder.y = 0;
					}
				}
			}
			else
			{
				_up.visible = true;
				_over.visible = false;
				
				if (_hasToggleGraphic)
				{
					_toggleUp.visible = true;
					_toggleOver.visible = false;
				}
				
				if (_hasSelectedState)
				{
					_selectedGlow.visible = _isSelected;
					if (_isSelected)
					{
						_up.visible = false;
						_over.visible = true;
					}
				}
				if (_hasDownState)
				{
					if (_isSelected)
					{
						_holder.y = _mouseDownDistance;
					}
					else
					{
						if (_useGraphicDownState)
							_down.visible = false;
						else
							_holder.y = 0;
					}
				}
				/*
				if (_isSelected && _hasDownState)
				{
					if (_useGraphicDownState)
					{
						_down.visible = false;
					}
				}
				else if (_hasDownState)
				{
					if (_useGraphicDownState)
						_down.visible = false;
					else
						_holder.y = 0;
				}
				*/
				
				if (_hasLabelDownState)
					_labelHolder.y = !_isSelected ? 0 : _mouseDownDistance;
			}
			
			_holder.filters = (_useDropShadow && !_isSelected && (!_isDown || !_isOver)) ? [_dropShadow] : []; 
			/*
			if (_useDropShadow && !_isSelected && (!_isDown || !_isOver))
				_holder.filters = [_dropShadow]; 
			*/
		}
		
		protected function doOverrides(overrides:Object):void
		{
			//trace("UIButton >> doOverride");
			for (var prop:String in overrides)
			{
				//trace("\t"+prop+": "+overrides[prop]);
				//if (this.hasOwnProperty(prop))
				if (this[prop] != null)
				{
					this[prop] = overrides[prop];
					//trace("\t\t"+prop+": "+this[prop]);
				}
			}
		}
		
		protected function onDrawn():void { /*override in subclass*/ }
		protected function onRedrawn():void { /*override in subclass*/ }
		
		// ======================== event handlers ========================
		
		public function handleMouseOverOut(event:MouseEvent):void
		{
			_isOver = (event.type == MouseEvent.MOUSE_OVER);
			update();
		}
		
		// continually firing down button handlers
		private function handleDownTimer(event:TimerEvent):void
		{
			if (_isDown)
				dispatchEvent(new Event(Event.CHANGE));
			else
			{
				_downTimer.stop();
				_downTimer.reset();
			}
		}
		
		private function handleMouseDown(event:MouseEvent):void
		{
			_isDown = true;
			dispatchEvent(new Event(Event.CHANGE));
			
			if (_useContinualDownFiring)
				_downTimer.start();
			
			if (_hasDownState || _hasSelectedState)
				update();
			
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
		}
		
		private function handleMouseUp(event:MouseEvent):void
		{
			if (_isDown)
			{
				if (stage)
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				_isDown = false;
				
				if (_hasSelectedState && event.target == this)
				{	
					selected = !_isSelected;
					//_isSelected = !_isSelected;
				}
				
				if (_useContinualDownFiring)
				{
					_downTimer.stop();
					_downTimer.reset();
					
					dispatchEvent(new Event(Event.COMPLETE));
				}
				
				update();
			}
		}
		
		// ======================== draw methods ========================
		
		protected function getToggleColorData(cd:ColorData):ColorData
		{
			var newCd:ColorData = new ColorData();
			if (cd.stroke)
			{
				newCd.fill = cd.stroke;
				newCd.stroke = cd.stroke;
			}
			return newCd;
		}
		
		public function redraw():void
		{
			drawRect(_hitHelper, _width, _height + _mouseDownDistance, _hitHelperColors, _stroke, _ellipse);
			
			// if we have up colors, draw up state
			if (_stateColors.up)
			{
				drawRect(_up, _width, _height, _stateColors.up, _stroke, _ellipse);
				if (_hasToggleGraphic)
					drawRect(_toggleUp, _width, _height, getToggleColorData(_stateColors.up), _stroke, _ellipse);
			}
			
			// if we have over colors, draw over state
			if (_stateColors.over)
			{
				drawRect(_over, _width, _height, _stateColors.over, _stroke, _ellipse);
				if (_hasToggleGraphic)
					drawRect(_toggleOver, _width, _height, getToggleColorData(_stateColors.over), _stroke, _ellipse);
			}
			
			// if we have down colors and a graphic down state is desired, draw down state
			if (_hasDownState && _useGraphicDownState)
			{
				if ( _stateColors.down != null)
					drawRect(_down, _width, _height, _stateColors.down, _stroke, _ellipse);
			}
			
			// if top bevel is desired, created it
			if (_hasBevel)
			{
				// assign bevel ColorData if not explicit set
				if (_stateColors.bevel == null)
					_stateColors.bevel = ColorData.getColor(ColorData.BUTTON_BEVEL);
				drawRect(_bevel, _width, _height, _stateColors.bevel, _stroke, _ellipse);
				
				if (_hasGlossyBevel)
					addGlossyBevel();
			}
			
			// if top bevel is desired, created it
			if (_hasSelectedState)
				drawRect(_selectedGlow, _width, _height, ColorData.getColor(ColorData.BUTTON_SELECTED_GLOW), _stroke, _ellipse);
			
			onRedrawn();
		}
		
		protected function init():void
		{
			// create hit helper
			_hitHelper = addChild(new Sprite()) as Sprite;
			
			if (_hasToggleGraphic)
			{
				_toggleUp = addChild(new Sprite()) as Sprite;
				_toggleOver = addChild(new Sprite()) as Sprite;
				_toggleUp.y = _toggleOver.y = _mouseDownDistance;
			}
			
			_holder = addChild(new Sprite()) as Sprite;
			
			// if we have up colors, create up state
			if (_stateColors.up)
				_up = _holder.addChild(new Sprite()) as Sprite;
			
			// if we have over colors, create over state
			if (_stateColors.over)
				_over = _holder.addChild(new Sprite()) as Sprite;
			
			// if we have down colors and a graphic down state is desired, create down state
			if (_hasDownState && _useGraphicDownState)
			{
				if ( _stateColors.down != null)
					_down = _holder.addChild(new Sprite()) as Sprite;
			}
			
			// if top bevel is desired, created it
			if (_hasBevel)
			{
				// assign bevel ColorData if not explicit set
				if (_stateColors.bevel == null)
					_stateColors.bevel = ColorData.getColor(ColorData.BUTTON_BEVEL);
				
				_bevel = _holder.addChild(new Sprite()) as Sprite;
			}
			
			// if top bevel is desired, created it
			if (_hasSelectedState)
			{
				_selectedGlow = _holder.addChild(new Sprite()) as Sprite;
				_selectedGlow.filters = [_selectedGlowFilter];
			}
			
			// create label holder
			_labelHolder = addChild(new Sprite()) as Sprite;
			
			onDrawn();
			
			enabled = _enabled;
			visible = true;
		}
		
		/*
		protected function draw():void
		{
			// create hit helper
			_hitHelper = addChild(new Sprite()) as Sprite;
			drawRect(_hitHelper, _width, _height + _mouseDownDistance, _hitHelperColors, _stroke, _ellipse);
			
			if (_hasToggleGraphic)
			{
				_toggleUp = addChild(new Sprite()) as Sprite;
				_toggleOver = addChild(new Sprite()) as Sprite;
				_toggleUp.y = _toggleOver.y = _mouseDownDistance;
			}
			
			_holder = addChild(new Sprite()) as Sprite;
			
			// if we have up colors, create up state
			if (_stateColors.up)
			{
				_up = _holder.addChild(new Sprite()) as Sprite;
				drawRect(_up, _width, _height, _stateColors.up, _stroke, _ellipse);
				
				if (_hasToggleGraphic)
					drawRect(_toggleUp, _width, _height, getToggleColorData(_stateColors.up), _stroke, _ellipse);
			}
			
			// if we have over colors, create over state
			if (_stateColors.over)
			{
				_over = _holder.addChild(new Sprite()) as Sprite;
				drawRect(_over, _width, _height, _stateColors.over, _stroke, _ellipse);
				
				if (_hasToggleGraphic)
					drawRect(_toggleOver, _width, _height, getToggleColorData(_stateColors.over), _stroke, _ellipse);
			}
			
			// if we have down colors and a graphic down state is desired, create down state
			if (_hasDownState && _useGraphicDownState)
			{
				if ( _stateColors.down != null)
				{
					_down = _holder.addChild(new Sprite()) as Sprite;
					drawRect(_down, _width, _height, _stateColors.down, _stroke, _ellipse);
				}
				else
					_useGraphicDownState = false;
			}
			
			// if top bevel is desired, created it
			if (_hasBevel)
			{
				// assign bevel ColorData if not explicit set
				if (_stateColors.bevel == null)
					_stateColors.bevel = ColorData.getColor(ColorData.BUTTON_BEVEL);
				
				_bevel = _holder.addChild(new Sprite()) as Sprite;
				drawRect(_bevel, _width, _height, _stateColors.bevel, _stroke, _ellipse);
				_bevel.filters = _bevelFilter != null ? [_bevelFilter] : [];
				
				if (_hasGlossyBevel)
					addGlossyBevel();
			}
			
			// if top bevel is desired, created it
			if (_hasSelectedState)
			{
				//_selectedGlow = _holder.addChild(new Sprite()) as Sprite;
				//drawRect(_selectedGlow, _width, _height, ColorData.getColor(ColorData.TN_75_BUTTON_SELECTED_GLOW), _stroke, _ellipse);
				//_selectedGlow.filters = [_selectedGlowFilter];
			}
			
			// create label holder
			_labelHolder = addChild(new Sprite()) as Sprite;
			
			onDrawn();
			
			enabled = _enabled;
			visible = true;
		}
		*/
			
		private function drawRect(s:Sprite, w:Number, h:Number, c:ColorData, stroke:int, ellipse:*):void
		{
			if (isNaN(_ellipse) && _ellipse is Object)
				DrawingUtil.drawComplexRect(s, w, h, c, stroke, ellipse);
			else if (!isNaN(_ellipse))
				DrawingUtil.drawRect(s, w, h, c, stroke, ellipse);
		}
		
		/*
		protected function draw():void
		{
			// create hit helper
			_hitHelper = addChild(new Sprite()) as Sprite;
			drawRect(_hitHelper, _width, _height + _mouseDownDistance, _hitHelperColors, _stroke, _ellipse);
			
			if (_hasToggleGraphic)
			{
				_toggleUp = addChild(new Sprite()) as Sprite;
				_toggleOver = addChild(new Sprite()) as Sprite;
				_toggleUp.y = _toggleOver.y = _mouseDownDistance;
			}
			
			_holder = addChild(new Sprite()) as Sprite;
			
			// if we have up colors, create up state
			if (_stateColors.up)
			{
				_up = _holder.addChild(new Sprite()) as Sprite;
				drawRect(_up, _width, _height, _stateColors.up, _stroke, _ellipse);
				
				if (_hasToggleGraphic)
					drawRect(_toggleUp, _width, _height, getToggleColorData(_stateColors.up), _stroke, _ellipse);
			}
			
			// if we have over colors, create over state
			if (_stateColors.over)
			{
				_over = _holder.addChild(new Sprite()) as Sprite;
				drawRect(_over, _width, _height, _stateColors.over, _stroke, _ellipse);
				
				if (_hasToggleGraphic)
					drawRect(_toggleOver, _width, _height, getToggleColorData(_stateColors.over), _stroke, _ellipse);
			}
			
			// if we have down colors and a graphic down state is desired, create down state
			if (_hasDownState && _useGraphicDownState)
			{
				if ( _stateColors.down != null)
				{
					_down = _holder.addChild(new Sprite()) as Sprite;
					drawRect(_down, _width, _height, _stateColors.down, _stroke, _ellipse);
				}
				else
					_useGraphicDownState = false;
			}
			
			// if top bevel is desired, created it
			if (_hasBevel)
			{
				// assign bevel ColorData if not explicit set
				if (_stateColors.bevel == null)
					_stateColors.bevel = ColorData.getColor(ColorData.BUTTON_BEVEL);
				
				_bevel = _holder.addChild(new Sprite()) as Sprite;
				drawRect(_bevel, _width, _height, _stateColors.bevel, _stroke, _ellipse);
				_bevel.filters = _bevelFilter != null ? [_bevelFilter] : [];
				
				if (_hasGlossyBevel)
					addGlossyBevel();
			}
			
			// if top bevel is desired, created it
			if (_hasSelectedState)
			{
				//_selectedGlow = _holder.addChild(new Sprite()) as Sprite;
				//drawRect(_selectedGlow, _width, _height, ColorData.getColor(ColorData.TN_75_BUTTON_SELECTED_GLOW), _stroke, _ellipse);
				//_selectedGlow.filters = [_selectedGlowFilter];
			}
		
			// create label holder
			_labelHolder = addChild(new Sprite()) as Sprite;
			
			onDrawn();
			
			enabled = _enabled;
			visible = true;
		}*/
	}
}