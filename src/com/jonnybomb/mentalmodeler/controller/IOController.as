package com.jonnybomb.mentalmodeler.controller
{
	import com.adobe.images.PNGEncoder;
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptMainDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptPropertyDisplay;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.display.controls.alert.Alert;
	import com.jonnybomb.mentalmodeler.display.controls.alert.AlertContentDefault;
	import com.jonnybomb.mentalmodeler.model.CMapModel;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.printing.PrintJob;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	public class IOController extends EventDispatcher
	{
		private var _model:CMapModel;
		private var _controller:CMapController;
		private var _fileRef:FileReference;
		private var _filter:Array = [new FileFilter(CMapConstants.FILE_FILTER_NAME, "*" + CMapConstants.FILE_EXTENSION)];
		//private var _file:File;
		
		public function IOController(model:CMapModel, controller:CMapController)
		{
			XML.ignoreWhitespace = true;
			_model = model;
			_controller = controller;
		}
		
		////////////////
		// printing   //
		////////////////
		
		public function print():void
		{
			var clip:Sprite;
			var printJob:PrintJob = new PrintJob();
			var numPages:int = 0;
			var printArea:Rectangle;
			var printHeight:Number;
			var printY:int = 0;
			
			if ( printJob.start() ) {
				
				if (!clip)
				{
					clip = createPrintable(printJob.pageWidth, printJob.pageHeight);
					//_controller.container.addChild(clip);
				}
				/* Resize movie clip to fit within page width */
				if (clip.width > printJob.pageWidth) {
					clip.width = printJob.pageWidth;
					clip.scaleY = clip.scaleX;
				}
				
				/* Store reference to print area in a new variable! Will save on scaling calculations later... */
				printArea = new Rectangle(0, 0, printJob.pageWidth/clip.scaleX, printJob.pageHeight/clip.scaleY);
				
				numPages = Math.ceil(clip.height / printJob.pageHeight);
				
				/* Add pages to print job */
				for (var i:int = 0; i < numPages; i++) {
					printJob.addPage(clip, printArea);
					printArea.y += printArea.height;
				}
				
				/* Send print job to printer */
				printJob.send();
				
				/* Delete job from memory */
				printJob = null;
				
			}
		}
		
		private function updatePrintY(y:Number, h:Number, pageH:Number = 734):Number
		{ 
			var nY:Number = y;
			if (pageH - (y % pageH) < h)
				nY = Math.ceil(y / pageH) * pageH + 10;
			return nY;
		}
		
		private function createPrintable(w:int = 576, h:int = 734):Sprite
		{
			var orig:Array = [w, h];
			
			var cds:Vector.<ConceptDisplay> = _controller.model.cds;
			var lines:Vector.<InfluenceLineDisplay> = _controller.model.lines;
			var s:Sprite = new Sprite();
			var model:CMapModel = _controller.model;
			
			// draw screen
			var w1:int = Math.max(_controller.maxW, _controller.stage.stageWidth);
			var h1:int = Math.max(_controller.maxH, _controller.stage.stageHeight);
			w1 -= CMapConstants.NOTES_WIDTH;
			h1 -= CMapConstants.MENU_HEIGHT;
			var bmd:BitmapData = new BitmapData(w1, h1, true, 0);
			var g:Graphics = _controller.container.graphics;
			g.beginFill(0xFFFFFF, 1);
			g.drawRect(CMapConstants.NOTES_WIDTH, CMapConstants.MENU_HEIGHT, w1, h1);
			//g.drawRect(0, 0, w, h);
			g.endFill();
			_controller.container
			bmd.draw(_controller.container);
			g.clear();
			var bm:Bitmap = new Bitmap(bmd, "auto", true);
			var bmRatio:Number = bm.height / bm.width;
			var pageRatio:Number = w / h;
			if (pageRatio > bmRatio)
			{
				bm.width = h - 20;
				bm.scaleY = bm.scaleX;
			}
			else
			{
				bm.height = w - 20;
				bm.scaleX = bm.scaleY;
			}
			
			bm.y = bm.width + (h - bm.width)/2;
			bm.x = (w - bm.height)/2
			bm.rotation = -90;
			s.addChild(bm);
			
			var tf:TextField;
			var nY:int = h + 10;
			var props:Object = {};
			var elemSpacer:int = 7;
			var propSpacer:int = 12;
			
			tf = CMapUtils.createTextField("COMPONENTS", getTfOverrides("type header"));
			nY = updatePrintY(nY, tf.height);
			tf.y = nY;
			s.addChild(tf);
			nY += tf.height + elemSpacer;
			w -= 20; 
			
			for each (var cd:ConceptDisplay in cds)
			{
				if (cd is ConceptMainDisplay)
				{
					var a:Array = [ { text:cd.title, override:getTfOverrides("cd name", w, h) },
						{ text:"GROUP", override:getTfOverrides("cd group label", w, h) },
						{ text:model.groupNames[cd.group], override:getTfOverrides("cd group", w, h) },
						{ text:"NOTES", override:getTfOverrides("cd notes label", w, h) },
						{ text:cd.notes, override:getTfOverrides("cd notes", w, h) } ];
					
					for (var i:int=0 ;i<a.length; i++)
					{
						var o:Object = a[i];
						props = o.override;
						tf = CMapUtils.createTextField(o.text, props);
						tf.x = props.offsetX;
						nY = updatePrintY(nY, tf.height);
						tf.y = nY;
						s.addChild(tf);
						nY += tf.height
						
						if (i == 0 || i == 2 || i == 4)
							nY += elemSpacer;
					}
					var cpd:ConceptPropertyDisplay;
					if (ConceptMainDisplay(cd).propertyDisplays.length > 0)
					{
						o = { text:"PROPERTIES", override:getTfOverrides("prop label") };
						props = o.override;
						tf = CMapUtils.createTextField(o.text, props);
						tf.x = props.offsetX;
						nY = updatePrintY(nY, tf.height);
						tf.y = nY;
						s.addChild(tf);
						
						for (i = 0; i<ConceptMainDisplay(cd).propertyDisplays.length; i++)
						{
							cpd = ConceptMainDisplay(cd).propertyDisplays[i];
							a = [	{ text:cpd.title, override:getTfOverrides("prop name", w, h) },
								{ text:"NOTES", override:getTfOverrides("prop notes label", w, h) },	
								{ text:cpd.notes, override:getTfOverrides("prop notes", w, h) } ];
							for (var j:int=0 ;j<a.length; j++)
							{
								o = a[j];
								props = o.override;
								tf = CMapUtils.createTextField(o.text, props);
								tf.x = props.offsetX;
								nY = updatePrintY(nY, tf.height);
								tf.y = nY;
								s.addChild(tf);
								nY += tf.height;
							}
							nY += elemSpacer;
						}
					}
					nY += propSpacer;
				}
			}
			
			nY += 30;
			tf = CMapUtils.createTextField("LINES", getTfOverrides("type header"));
			s.addChild(tf);
			nY = updatePrintY(nY, tf.height);
			tf.y = nY;
			nY += tf.height + elemSpacer;
			
			for each (var line:InfluenceLineDisplay in lines)
			{
				a = [ { text:line.title, override:getTfOverrides("cd name", w, h) },
					{ text:"FROM", override:getTfOverrides("cd notes label", w, h) },
					{ text:getLineEeErText(line.influencer), override:getTfOverrides("cd notes", w, h) },
					{ text:"TO", override:getTfOverrides("cd notes label", w, h) },
					{ text:getLineEeErText(line.influencee), override:getTfOverrides("cd notes", w, h) },
					{ text:"NOTES", override:getTfOverrides("cd notes label", w, h) },
					{ text:line.notes, override:getTfOverrides("cd notes", w, h) } ];
				
				for (i=0 ;i<a.length; i++)
				{
					o = a[i];
					props = o.override;
					tf = CMapUtils.createTextField(o.text, props);
					tf.x = props.offsetX;
					nY = updatePrintY(nY, tf.height);
					tf.y = nY;
					s.addChild(tf);
					nY += tf.height
					
					if (i == 0 || i == 2 || i == 4 || i == 6)
						nY += elemSpacer;
				}
				nY += propSpacer;
			}
			
			g = s.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect(0, 0, orig[0], orig[1] * (Math.ceil(nY/orig[1])));
			return s;	
		}
		
		private function getLineEeErText(cd:ConceptDisplay):String
		{
			var title:String = ""
			if (cd is ConceptMainDisplay)
				title = cd.title;
			else if (cd is ConceptPropertyDisplay)
				title = cd.mainDisplay.title + ":" + cd.title;
			return title;
		}
		
		private function getTfOverrides(type:String, w:int = 576, h:int = 734):Object
		{
			var pageDimensions:Array = [w, h];
			var o:Object; 
			switch (type)
			{
				case "type header":
					o = {   size: 13,
					bold: true,		
					color: 0x000000,
					align: TextFormatAlign.CENTER,
						width: pageDimensions[0],
						offsetX: 0,
						background: false,
						backgroundColor: 0x000000,
						wordWrap: true,
						multiline: true
				};
					break;
				case "cd name":
					o = {   size: 18,
					color: 0x000000,
					align: TextFormatAlign.LEFT,
						width: pageDimensions[0],
						offsetX: 0,
						background: false,
						backgroundColor: 0x000000,
						wordWrap: true,
						multiline: true
				};
					break;
				case "prop label":
				case "cd group label":
				case "cd notes label":
					o = {   size: 10,
					color: 0x989898,
					align: TextFormatAlign.LEFT,
						width: 90,
						offsetX: 0,
						bold: true,
						background: true,
						backgroundColor: 0xe6e6e6,
						wordWrap: true,
						multiline: true
				};
					break;
				case "cd notes":
				case "cd group":
					o = {   size: 11,
					color: 0x000000,
					align: TextFormatAlign.LEFT,
						width: pageDimensions[0],
						offsetX: 0,
						background: false,
						backgroundColor: 0x000000,
						wordWrap: true,
						multiline: true
				};
					break;
				case "prop notes label":
					o = {   size: 10,
					color: 0x989898,
					align: TextFormatAlign.LEFT,
						width: 47,
						offsetX: 95,
						bold: true,
						background: true,
						backgroundColor: 0xe6e6e6,
						wordWrap: true,
						multiline: true
				};
					break;
				case "prop name":
					o = {   size: 14,
					color: 0x000000,
					align: TextFormatAlign.LEFT,
						width: pageDimensions[0] - 95,
						offsetX: 95,
						background: false,
						backgroundColor: 0x000000,
						wordWrap: true,
						multiline: true
				};
					break;
				case "prop notes":
					o = {   size: 11,
					color: 0x000000,
					align: TextFormatAlign.LEFT,
						width: pageDimensions[0] - 110,
						offsetX: 95,
						background: false,
						backgroundColor: 0x000000,
						wordWrap: true,
						multiline: true
				};
					break;
			}
			return o;
		}
		
		////////////////
		// PNG Export //
		////////////////
		
		public function savePNG():void
		{
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.COMPLETE, handlePngSave, false, 0, true);
			_fileRef.addEventListener(Event.CANCEL,handlePngSaveCancel, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handlePngSaveError, false, 0, true);
			
			try
			{
				Alert.show(new AlertContentDefault(CMapConstants.MESSAGE_SCREENSHOT_SELECT), null);
				
				var w:int = Math.max(_controller.maxW, _controller.stage.stageWidth);
				var h:int = Math.max(_controller.maxH, _controller.stage.stageHeight);
				w -= CMapConstants.NOTES_WIDTH;
				h -= CMapConstants.MENU_HEIGHT;
				var bmd:BitmapData = new BitmapData(w, h, true, 0);
				var g:Graphics = _controller.container.graphics;
				g.beginFill(0xFFFFFF, 1);
				g.drawRect(CMapConstants.NOTES_WIDTH, CMapConstants.MENU_HEIGHT, w, h);
				//g.drawRect(0, 0, w, h);
				g.endFill();
				_controller.container
				bmd.draw(_controller.container);
				g.clear();
				var byteArray:ByteArray = PNGEncoder.encode(bmd);
				_fileRef.save(byteArray, ".png");
				
			}
			catch (e:IllegalOperationError)
			{
				removeSavePNGHandlers();
				_fileRef = null;
			}
			catch (e:SecurityError)
			{
				removeSavePNGHandlers();
				_fileRef = null;
			}
		}
		
		private function handlePngSave(e:Event):void
		{
			removeSavePNGHandlers();
			_fileRef = null;
		}
		
		private function handlePngSaveCancel(e:Event):void
		{
			removeSavePNGHandlers();
			_fileRef = null;
		}
		
		private function handlePngSaveError(e:IOErrorEvent):void
		{
			removeSavePNGHandlers();
			_fileRef = null;
		}
		
		private function removeSavePNGHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.COMPLETE, handlePngSave, false);
			_fileRef.removeEventListener(Event.CANCEL,handlePngSaveCancel, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handlePngSaveError, false);
		}
		
		/////////////////////////
		// File Reference Save //
		/////////////////////////
		
		public function saveFileRef():void
		{
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.COMPLETE, handleFileRefSave, false, 0, true);
			_fileRef.addEventListener(Event.CANCEL,handleFileRefSaveCancel, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleFileRefSaveError, false, 0, true);
			
			try
			{
				Alert.show(new AlertContentDefault(CMapConstants.MESSAGE_SAVE_SELECT), null);
				_fileRef.save(_model.stringToSave, CMapConstants.FILE_EXTENSION);
			}
			catch (e:IllegalOperationError)
			{
				removeFileRefSaveHandlers();
				_fileRef = null;
			}
			catch (e:SecurityError)
			{
				removeFileRefSaveHandlers();
				_fileRef = null;
			}
		}
		
		private function handleFileRefSave(e:Event):void
		{
			removeFileRefSaveHandlers();
			_fileRef = null;
		}
		
		private function handleFileRefSaveCancel(e:Event):void
		{
			removeFileRefSaveHandlers();
			_fileRef = null;
		}
		
		private function handleFileRefSaveError(e:IOErrorEvent):void
		{
			removeFileRefSaveHandlers();
			_fileRef = null;
		}
		
		private function removeFileRefSaveHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.COMPLETE, handleFileRefSave, false);
			_fileRef.removeEventListener(Event.CANCEL,handleFileRefSaveCancel, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handleFileRefSaveError, false);
		}
		
		/////////////////////////
		// File Reference Load //
		/////////////////////////
		
		public function loadFileRef():void
		{
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.SELECT, handleFileRefSelect, false, 0, true);
			_fileRef.addEventListener(Event.CANCEL,handleFileRefSelectCancel, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleFileRefSelectIOError, false, 0 , true);
			try
			{
				Alert.show(new AlertContentDefault(CMapConstants.MESSAGE_LOAD_SELECT), null);
				_fileRef.browse(_filter);
			}
			catch (e:IllegalOperationError)
			{
				removeFileRefSelectHandlers();
				_fileRef = null;
			}
			catch (e:SecurityError)
			{
				removeFileRefSelectHandlers();
				_fileRef = null;
			}
		}
		
		private function handleFileRefSelect(e:Event):void
		{
			removeFileRefSelectHandlers();
			_fileRef.addEventListener(Event.COMPLETE, handleFileRefLoadComplete, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleFileRefLoadError, false, 0, true);
			_fileRef.load();
		}
		
		private function handleFileRefSelectCancel(e:Event):void
		{
			removeFileRefSelectHandlers()
			_fileRef = null;
		}
		
		private function handleFileRefSelectIOError(e:Event):void
		{
			removeFileRefSelectHandlers()
			_fileRef = null;
		}
		
		private function removeFileRefSelectHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.SELECT, handleFileRefSelect, false);
			_fileRef.removeEventListener(Event.CANCEL,handleFileRefSelectCancel, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handleFileRefSelectIOError, false);
		}
		
		private function handleFileRefLoadComplete(e:Event):void
		{
			var data:ByteArray = _fileRef.data;
			_controller.onMapLoaded(new XML(data.readUTFBytes(data.bytesAvailable)))
			removeFileRefLoadHandlers();
			_fileRef = null;
		}
		
		private function handleFileRefLoadError(e:IOErrorEvent):void
		{
			removeFileRefLoadHandlers();
			_fileRef = null;
		}
		
		private function removeFileRefLoadHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.COMPLETE, handleFileRefLoadComplete, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handleFileRefLoadError, false);
		}
		
		///////////////
		// File Save //
		///////////////
		/*
		public function saveFile():void
		{
			_file = new File();
			_file.addEventListener(Event.SELECT, handleFileSaveSelect, false, 0 , true);
			_file.addEventListener(Event.CANCEL, handleFileSaveSelectCancel, false, 0, true);
			_file.addEventListener(IOErrorEvent.IO_ERROR, handleFileSaveSelectIOError, false, 0 , true);
			
			try
			{
				_file.browseForSave("Save As");
			}
			catch (e:IllegalOperationError)
			{
				removeFileSaveSelectListeners();
				_file = null;
			}
			catch (e:SecurityError)
			{
				removeFileSaveSelectListeners();
				_file = null;
			}
		}
		
		private function handleFileSaveSelect(e:Event):void
		{
			var xmlString:String = "";
			var stream:FileStream = new FileStream();
			var file:File = e.target as File;
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(xmlString);
			stream.close();
			
			removeFileSaveSelectListeners();
			_file = null;
		}
		
		private function handleFileSaveSelectCancel(e:Event):void
		{ 
			removeFileSaveSelectListeners();
			_file = null;
		}
		
		private function handleFileSaveSelectIOError(e:IOErrorEvent):void
		{ 
			removeFileSaveSelectListeners();
			_file = null;
		}
		
		private function removeFileSaveSelectListeners():void
		{
			if (!_file)
				return
			_file.removeEventListener(Event.SELECT, handleFileSaveSelect, false);
			_file.removeEventListener(Event.CANCEL, handleFileSaveSelectCancel, false);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, handleFileSaveSelectIOError, false);
		}
		
		///////////////
		// File Load //
		///////////////
		
		public function loadFile():void
		{
			_file = new File();
			_file.addEventListener(Event.SELECT, handleFileSelect, false, 0 , true);
			_file.addEventListener(Event.CANCEL, handleFileSelectCancel, false, 0, true);
			_file.addEventListener(IOErrorEvent.IO_ERROR, handleFileSelectIOError, false, 0 , true);
			
			try
			{
				_file.browseForOpen("Select CMap file.", _filter);
			}
			catch (e:IllegalOperationError)
			{
				removeFileSelectListeners();
			}
			catch (e:SecurityError)
			{
				removeFileSelectListeners();
			}
		}
		
		private function handleFileSelect(e:Event):void
		{
			var stream:FileStream = new FileStream();
			var file:File = e.target as File;
			stream.open(file, FileMode.READ);
			var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
			var xml:XML = new XML(fileData);
			
			removeFileSelectListeners();
			_file = null;
		}
		
		private function handleFileSelectCancel(e:Event):void
		{ 
			removeFileSelectListeners();
			_file = null;
		}
		
		private function handleFileSelectIOError(e:IOErrorEvent):void
		{ 
			removeFileSelectListeners();
			_file = null;
		}
		
		private function removeFileSelectListeners():void
		{
			if (!_file)
				return
			_file.removeEventListener(Event.SELECT, handleFileSelect, false);
			_file.removeEventListener(Event.CANCEL, handleFileSelectCancel, false);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, handleFileSelectIOError, false);
		}
		*/
	}
}