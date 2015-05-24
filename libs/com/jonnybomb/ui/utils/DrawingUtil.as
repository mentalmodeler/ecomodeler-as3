package com.jonnybomb.ui.utils
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	
	import com.jonnybomb.mentalmodeler.utils.math.MathUtil;

	public class DrawingUtil
	{
		public static const DEFAULT_ELLIPSE_OBJ:Object = {tr:0, tl:0, br:0, bl:0};
		
		public static function drawSquiggly(s:Sprite, w:int, color:uint = 0xFF0000, lineThickness:Number = 0.25):void
		{
			var segmentW:int = 2;
			var segmentH:int = 2;	
			var g:Graphics = s.graphics;
			
			g.lineStyle(lineThickness, color);
			g.moveTo(0, 0)
				
			var nX:int = 0;
			var nY:int = 0;
			while(nX + segmentW <= w)
			{
				nX += segmentW;
				nY = (nY < segmentH) ? segmentH : 0;
				g.lineTo(nX, nY); 
			}
			
			var remainder:int = w - nX;
			if (remainder > 0)
			{
				var pct:Number = remainder / segmentW;
				nX += remainder;
				nY = (nY < segmentH) ? segmentH : 0;
				nY = (nY == 0) ? segmentH - segmentH * pct : segmentH * pct;
				g.lineTo(nX, nY);
			}
				
			g.endFill();
		}
		
		public static function drawRect(s:Sprite, w:int, h:int, colors:ColorData, _stroke:int = 0, ellipse:int = 0):void
		{
			//trace("DrawingUtil >> drawRect\n\tw:"+w+"\n\th:"+h+"\n\t_stroke:"+_stroke+"\n\tellipse:"+ellipse+"\n\tcolors:"+colors);
			s.graphics.clear();
			var matrix:Matrix = new Matrix();
			
			//adjust size for stroke
			var wFill:int;
			var hFill:int;
			var eFill:int;
			var offset:int;
			
			if (colors.stroke)
			{
				wFill = w - _stroke * 2;
				hFill = h - _stroke * 2;
				eFill = int(ellipse) - _stroke; // * 2;
				eFill = eFill < 0 ? 0 : eFill;
				offset = _stroke;
			}
			else
			{
				wFill = w;
				hFill = h;
				eFill = int(ellipse);
				offset = 0;
			}
			
			//============== fill ==============
			if (colors.fill)
			{
				if (colors.fill is GradientColorData)
				{
					// fill is a gradient
					var gFill:GradientColorData = GradientColorData(colors.fill);
					matrix.createGradientBox(wFill, hFill, gFill.rotation, offset, offset); 
					s.graphics.beginGradientFill(gFill.gradType, gFill.colors, gFill.alphas, gFill.ratios, matrix);
					
				}
				else 
				{
					// fill is solid
					var cFill:ColorExtended = ColorExtended(colors.fill);
					s.graphics.beginFill(cFill.color, cFill.alpha);	
				}
				
				s.graphics.drawRoundRect(offset, offset, wFill, hFill, eFill, eFill);
				s.graphics.endFill();
			}
			
			//============== stroke ==============
			if (colors.stroke)
			{
				if (colors.stroke is GradientColorData)
				{
					// stroke is a gradient
					var gStroke:GradientColorData = GradientColorData(colors.stroke);
					matrix.createGradientBox(w, h, gStroke.rotation, 0, 0);
					s.graphics.beginGradientFill(gStroke.gradType, gStroke.colors, gStroke.alphas, gStroke.ratios, matrix);
				}
				else 
				{
					// stroke is solid
					var cStroke:ColorExtended = ColorExtended(colors.stroke)
					s.graphics.beginFill(cStroke.color, cStroke.alpha);
				}
				
				// cut-out inside to make fill appear as stroke
				s.graphics.drawRoundRect(0, 0, w, h, ellipse, ellipse);
				s.graphics.drawRoundRect(offset, offset, wFill, hFill, eFill, eFill);
				s.graphics.endFill();
			}
		}
		
		public static function drawComplexRect(s:Sprite, w:int, h:int, colors:ColorData, _stroke:int = 0, ellipseObj:Object = null):void
		{
			//trace("DrawingUtil >> drawComplexRect\n\tw:"+w+"\n\th:"+h+"\n\t_stroke:"+_stroke+"\n\tcolors:"+colors);
			s.graphics.clear();
			
			if (ellipseObj == null)
				ellipseObj = DEFAULT_ELLIPSE_OBJ;
			
			var matrix:Matrix = new Matrix();
			
			//adjust size for stroke
			var wFill:int;
			var hFill:int;
			var eFillObj:Object = {};
			var offset:int;
			var prop:String;
			
			if (colors.stroke)
			{
				wFill = w - _stroke * 2;
				hFill = h - _stroke * 2;
				
				for (prop in ellipseObj)
				{
					eFillObj[prop] = ellipseObj[prop] - _stroke;// * 2;
					eFillObj[prop] = eFillObj[prop] < 0 ? 0 : eFillObj[prop];
				}
				offset = _stroke;
			}
			else
			{
				wFill = w;
				hFill = h;
				
				for (prop in ellipseObj)
					eFillObj[prop] = ellipseObj[prop];
				
				offset = 0;
			}
			
			//============== fill ==============
			if (colors.fill)
			{
				if (colors.fill is GradientColorData)
				{
					// fill is a gradient
					var gFill:GradientColorData = GradientColorData(colors.fill);
					matrix.createGradientBox(wFill, hFill, gFill.rotation, offset, offset); 
					s.graphics.beginGradientFill(gFill.gradType, gFill.colors, gFill.alphas, gFill.ratios, matrix);
					
				}
				else 
				{
					// fill is solid
					var cFill:ColorExtended = ColorExtended(colors.fill);
					s.graphics.beginFill(cFill.color, cFill.alpha);	
				}
				
				s.graphics.drawRoundRectComplex(offset, offset, wFill, hFill, eFillObj.tl, eFillObj.tr, eFillObj.bl, eFillObj.br);
				s.graphics.endFill();
			}
			
			//============== stroke ==============
			if (colors.stroke)
			{
				if (colors.stroke is GradientColorData)
				{
					// stroke is a gradient
					var gStroke:GradientColorData = GradientColorData(colors.stroke);
					matrix.createGradientBox(w, h, gStroke.rotation, 0, 0);
					s.graphics.beginGradientFill(gStroke.gradType, gStroke.colors, gStroke.alphas, gStroke.ratios, matrix);
				}
				else 
				{
					// stroke is solid
					var cStroke:ColorExtended = ColorExtended(colors.stroke)
					s.graphics.beginFill(cStroke.color, cStroke.alpha);
				}
				
		
				// cut-out inside to make fill appear as stroke
				s.graphics.drawRoundRectComplex(0, 0, w, h, ellipseObj.tl, ellipseObj.tr, ellipseObj.bl, ellipseObj.br);
				s.graphics.drawRoundRectComplex(offset, offset, wFill, hFill, eFillObj.tl, eFillObj.tr, eFillObj.bl, eFillObj.br);
				s.graphics.endFill();
			}
		}
	}
}