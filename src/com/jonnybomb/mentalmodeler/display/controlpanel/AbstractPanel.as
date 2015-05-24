package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	public class AbstractPanel extends Sprite
	{
		protected static const HEADER_HEIGHT:int = 25;//36;
		protected static const TF_PADDING:int = 5;
		protected static const HEADER_CD:ColorData = new ColorData(null, new GradientColorData([0x7f7f7f, 0x666666], [1, 1], [0, 255]));
		protected static const COVER_CD:ColorData = new ColorData(null, new ColorExtended(0xcccccc, 0));//0x4a4a4a, 0.7));
		protected static const BODY_CD:ColorData = new ColorData(null, new ColorExtended(0xf2f2f2)); //new ColorExtended(0xF2F2F2));
		protected static const BODY_DS:DropShadowFilter = new DropShadowFilter(3, 90, 0x000000, 1, 4, 4, 0.45, BitmapFilterQuality.MEDIUM, true);
		
		private var _enabled:Boolean = true;
		protected var _minHeight:Number = -1;
		protected var _maxHeight:Number = -1;
		protected var _controlPanel:ControlPanelDisplay;
		protected var _title:String;
		protected var _tf:TextField;
		protected var _header:Sprite;
		protected var _body:Sprite;
		protected var _cover:Sprite;
		protected var _width:int;
		protected var _height:int;
		protected var _sizeChanged:Boolean = false;
		
		public function AbstractPanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			mouseEnabled = false;
			
			_controlPanel = controlPanel;
			_title = title;
			_width = w;
			_height = h;
		}
		
		protected function normalizeHeight(value:Number):Number {
			if (_minHeight > -1 && value < _minHeight)
				value = _minHeight;
			else if (_maxHeight > -1 && value > _maxHeight)
				value = _maxHeight
			return value;
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			visible = value;
			_enabled = value;
			mouseEnabled = value;
			mouseChildren = value;
			/*
			if (_cover)
			{
				_cover.visible = !value;
				setChildIndex(_cover, numChildren - 1);
			}
			*/
			//alpha = value ? 1 : 0.4;
		}
			
		public function setSize(w:Number, h:Number):void
		{ 
			_sizeChanged = w != _width || h != _height;
			_width = w;
			_height = h;
			_body.height = _cover.height = _height;
			_body.width = _cover.width = _width;
		}
		
		public function init():void
		{
			_body = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_body, _width, HEADER_HEIGHT, BODY_CD);
			
			_cover = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_cover, _width, HEADER_HEIGHT, COVER_CD);
			_cover.visible = false;
			
			// draw header
			_header = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_header, _width, HEADER_HEIGHT, HEADER_CD);
			
			var line:Shape = addChild(createHeaderLine(new Rectangle(0, 0, _width, 2))) as Shape;
			line = addChild(createHeaderLine(new Rectangle(0, 0, _width, 1))) as Shape;
			line.filters = [];
			line.y = HEADER_HEIGHT - 1;
			
			
			// draw title
			var props:Object = {color: 0xFFFFFF,
								size: 13,
								align: TextFormatAlign.LEFT,
								letterSpacing: -1,
								bold: true,
								autoSize: TextFieldAutoSize.LEFT
								};
			_tf = addChild(CMapUtils.createTextField(_title, props)) as TextField;
			_tf.x = TF_PADDING;
			_tf.y = (_header.height - _tf.height)/2;
		}
		
		protected function createBg(rect:Rectangle, color:uint = 0xF2F2F2):Sprite
		{
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(color);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			g.endFill();
			return s;
		}
		
		protected function createHeaderLine(rect:Rectangle, color:uint = 0x00FF00):Shape //0x323232):Shape
		{
			var s:Shape = new Shape;
			return s;
			
			var g:Graphics = s.graphics;
			g.beginFill(color);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			g.endFill();
			//s.filters = [ new BevelFilter(1, 270, 0xFFFFFF, 1, 0x000000, 1, 2, 2, 0.75, BitmapFilterQuality.MEDIUM, BitmapFilterType.INNER, true) ];
			return s;
		}
		
		protected function getCurCd():ConceptDisplay { return _controlPanel.controller.model.curCd; }
		protected function getCurLine():InfluenceLineDisplay { return _controlPanel.controller.model.curLine; }
		protected function getCurSelected():INotable { return _controlPanel.controller.model.curSelected; }
	}
}