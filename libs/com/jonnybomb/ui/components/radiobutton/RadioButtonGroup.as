package com.jonnybomb.ui.components.radiobutton
{
	import com.jonnybomb.ui.UI;
	import com.jonnybomb.ui.components.UIButton;
	import com.jonnybomb.ui.utils.DisplayObjectUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * @author DCD - Jonathan Elbom
	 */
	
	public class RadioButtonGroup extends Sprite
	{
		public static const SPACING_VERT:String = "_spacingVert";
		public static const DOT_SPACING_HORZ:String = "_dotSpacingHorz";
		public static const TOTAL_WIDTH:String = "_totalWidth";
		
		private var _spacingVert:int = 5;
		private var _dotSpacingHorz:int = 3;
		private var _totalWidth:int = 100;
		
		private var _selectedItem:RadioButton;
		private var _items:Vector.<RadioButton> = new Vector.<RadioButton>();;
		private var _nY:int;
		private var _rbContentRenderer:Class = DefaultRadioButtonContentRenderer;
		private var _resetButton:UIButton;
		
		public function RadioButtonGroup(items:Vector.<RadioButtonData> = null, rbContentRenderer:Class = null, overrides:Object = null)
		{
			_nY = 0;
			
			if (rbContentRenderer != null)
				_rbContentRenderer = rbContentRenderer;
			
			if (overrides != null)
				doOverrides(overrides);
			
			if (items)
				addItems(items);
		}
		
		public function get selectedValue():Object { return _selectedItem ? _selectedItem.value : null }
		public function get selectedItem():RadioButton { return _selectedItem; }
		public function get resetButton():UIButton { return _resetButton; }
		public function set resetButton(value:UIButton):void
		{ 
			_resetButton = value;
			_resetButton.addEventListener(MouseEvent.CLICK, handleResetClick, false, 0, true);
			_resetButton.enabled = selectedItem != null;
		}
		
		private function handleResetClick(e:MouseEvent):void
		{
			selectItem(null);
		}
		
		public function getItemIndex(item:RadioButton):int { return _items.indexOf(item); }
		public function getItemAt(idx:int):RadioButton { return _items[idx]; }
		
		public function selectItemAt(index:int):void
		{
			if (_items.length > index)
				selectItem(_items[index]);
		}
		
		public function selectItemByValue(value:Object):void
		{
			var i:int = 0;
			var rb:RadioButton;
			var len:int = _items.length;
			var rbSelected:RadioButton;
			while(i < len || !rbSelected)
			{
				rb = _items[i];
				if (value == rb.value)
					rbSelected = rb;
				i++;
			}
			
			if (rbSelected)
				selectItem(rbSelected);
		}
		
		public function selectItem(item:RadioButton):void
		{
			if (_selectedItem)
				_selectedItem.selected = false;
			_selectedItem = item;
			if (_selectedItem)	
				_selectedItem.selected = true;
			if (_resetButton)
				_resetButton.enabled = _selectedItem != null;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function finalize():void
		{
			removeAllRadioButtons();
			DisplayObjectUtil.finalizeAndRemove(_resetButton);
			
			_resetButton = null;
			_items = null;
			_rbContentRenderer = null;
			_selectedItem = null;
		}
		
		private function doOverrides(overrides:Object):void
		{
			for (var prop:String in overrides)
			{
				try
				{
					if (this[prop] != null)
						this[prop] = overrides[prop];
				}
				catch(e:Error) {trace("doOverrides >> Property "+prop+" not defined, so cannot override\n\t"+e); }
			}
		}
		
		private  function addItem(rbd:RadioButtonData):Number
		{
			rbd.totalWidth = _totalWidth;
			var rb:RadioButton = addChild(createRadioButton(rbd)) as RadioButton;
			_items.push(rb);
			rb.y = _nY;
			_nY += Math.round( rb.height + _spacingVert );
			if (rbd.selected)
				rb.selected = true;
			
			return rb.width
		}
		
		private function addItems(items:Vector.<RadioButtonData>):void
		{
			removeAllRadioButtons();
			var maxWidth:Number = 0;
			var rbd:RadioButtonData;
			var itemWidth:Number;
			for each (rbd in items)
			{
				itemWidth = addItem(rbd);
				if (itemWidth > maxWidth) maxWidth = itemWidth;
			}
				
			for each (var rb:RadioButton in _items)
				rb.setHitHelperWidth(maxWidth);
		}
		
		private function createRadioButton(rbd:RadioButtonData):RadioButton
		{
			var rb:RadioButton = new RadioButton(rbd, _rbContentRenderer, this, _dotSpacingHorz)
			return rb;
		}
		
		private function removeAllRadioButtons():void
		{
			var rb:RadioButton;
			for each (rb in _items)
				DisplayObjectUtil.finalizeAndRemove(rb);
			_items = new Vector.<RadioButton>();
		}
	}
}