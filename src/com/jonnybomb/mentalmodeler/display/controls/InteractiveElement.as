package com.jonnybomb.mentalmodeler.display.controls
{
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class InteractiveElement extends MovieClip
	{
		public var validHandlers:Array = [MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP];
		
		protected var _isOver:Boolean = false;
		protected var _isDown:Boolean = false;
		
		public function get isOver():Boolean { return _isOver; }
		public function get isDown():Boolean { return _isDown; }
		
		public function InteractiveElement()
		{
		}
		
		public function finalize():void
		{
			removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut);
			removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			
			validHandlers = null;
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			mouseEnabled = value;
			buttonMode = value;
			
			if (value)
			{
				addEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			}
			else
			{
				removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOverOut);
				removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOverOut);
				removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
				if (stage)
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			}
			
			_isOver = false;
			_isDown = false;
		
			update();
		}
		
		// override in subclasses 
		protected function update():void {}
		protected function onMouseDown():void {}
		protected function onMouseUp():void {}
			
		private function handleMouseOverOut(event:MouseEvent):void
		{
			if (!isValidHandler(event.type))
				return;
			
			_isOver = event.type == MouseEvent.MOUSE_OVER;
			update();
		}
		
		private function handleMouseDown(event:MouseEvent):void
		{
			if (!isValidHandler(event.type))
				return;
			
			_isDown = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			
			onMouseDown();
			update();
		}
		
		private function handleMouseUp(event:MouseEvent):void
		{
			if (!isValidHandler(event.type))
				return;
			
			if (_isDown)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				_isDown = false;
				
				onMouseUp();
				update();
			}
		}
		
		private function isValidHandler(type:String):Boolean
		{
			return validHandlers.indexOf(type) != -1;
		}
	}
}