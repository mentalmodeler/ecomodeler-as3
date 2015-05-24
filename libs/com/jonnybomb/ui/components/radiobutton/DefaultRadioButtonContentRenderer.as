package com.jonnybomb.ui.components.radiobutton
{
	import com.jonnybomb.ui.utils.DisplayObjectUtil;
	
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * @author DCD - Jonathan Elbom
	 */
	
	public class DefaultRadioButtonContentRenderer extends Sprite implements IRadioButtonContentRenderer
	{
		public function DefaultRadioButtonContentRenderer()
		{
			super();
		}
		
		public function finalize():void
		{
			while(numChildren > 0)
				DisplayObjectUtil.remove(getChildAt(0));
		}
		
		public function update(data:Object):void {}
		
		public function build(data:Object, w:int = -1, h:int = -1):void
		{
			var format:TextFormat = new TextFormat();
			format.color = 0x000000;
			format.size = 13;
			format.font = "VerdanaEmbedded"; //"FontEmbedded";
			format.bold = false;
			format.italic = false;
			format.kerning = 0;
			format.letterSpacing = -0.5;
			
			var tf:TextField = addChild(new TextField()) as TextField;
			tf.embedFonts = true;
			tf.defaultTextFormat = format;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.wordWrap = false;
			tf.multiline = false;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.mouseWheelEnabled = false;
			tf.text = data.label;
		}
	}
}