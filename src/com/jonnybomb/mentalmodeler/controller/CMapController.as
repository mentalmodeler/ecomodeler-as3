package com.jonnybomb.mentalmodeler.controller
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.EcoModeler;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptMainDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptPropertyDisplay;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.display.LineLabelEditorDisplay;
	import com.jonnybomb.mentalmodeler.display.LineValueMenuDisplay;
	import com.jonnybomb.mentalmodeler.display.controlpanel.ViewPanel;
	import com.jonnybomb.mentalmodeler.display.controls.ConceptsContainer;
	import com.jonnybomb.mentalmodeler.display.controls.alert.Alert;
	import com.jonnybomb.mentalmodeler.display.controls.alert.AlertContentDefault;
	import com.jonnybomb.mentalmodeler.display.controls.alert.AlertContentDetails;
	import com.jonnybomb.mentalmodeler.events.ControllerEvent;
	import com.jonnybomb.mentalmodeler.model.CMapModel;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	import com.jonnybomb.mentalmodeler.utils.xml.XMLUtil;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class CMapController extends EventDispatcher
	{
		// not used in TNCL version
		private var _io:IOController;
		
		public static const UPDATE_LINES:String = "updateLines"
		
		public var nodePrefillText:String = CMapConstants.NODE_PREFILL_TEXT;	
		public var addNodeLabel:String = CMapConstants.ADD_NODE_LABEL;	
		public var maxNodes:int = -1;
		public var strokeWeight:int = 1;
		public var strokeColor:int = -1;
		public var fillColor:int = -1;
		public var showInsetShadow:Boolean = false;
		
		private var _lineValueMenu:LineValueMenuDisplay;
		private var _lineLabelEditor:LineLabelEditorDisplay;
		private var _model:CMapModel;
		private var _container:ConceptsContainer;
		private var _bgOutline:Sprite;
		private var _bgFill:Sprite;
		private var _tempLineArrowhead:Shape;
		private var _rect:Rectangle;
		private var _bounds:Rectangle;
		private var _addX:Number;
		private var _maxW:int = 0; //CMapConstants.WIDTH_START;
		private var _maxH:int = 0; //CMapConstants.HEIGHT_START;
		
		public static var debugTF:TextField;
		
		private var _standAlone:Boolean;
		
		public function get model():CMapModel { return _model; }
		public function get maxW():int { return _maxW; }
		public function get maxH():int { return _maxH; }
		public function get standAlone():Boolean { return _standAlone; }
		public function get container():ConceptsContainer { return _container }
		public function get stage():Stage { return _container ? _container.stage : null; }
		
		public function set addX(value:Number):void { _addX = value; }
		
		public function CMapController(container:ConceptsContainer, standAlone:Boolean)
		{
			_standAlone = standAlone;
			_model = new CMapModel();
			_container = container;
			_bgFill = _container.addChildAt(new Sprite(), 0) as Sprite;
			_bgOutline = _container.addChildAt(new Sprite(), 0) as Sprite;
			_bgFill.mouseEnabled = _bgOutline.mouseEnabled = false;
			
			_io = new IOController(_model, this);
			
			if (stage)
			{
				stage.addEventListener(Event.RESIZE, handleStageResize, false, 0, true);
				handleStageResize(null);
			}
		}
		
		public function init():void
		{
			Security.allowDomain("*");
			
			if (ExternalInterface.available)
			{
				//Alert.show(new AlertContentDefault("External Interface is available", "OK", false), null);	
				ExternalInterface.addCallback("doLoad", eiDoLoad);
				ExternalInterface.addCallback("doSave", eiDoSave);
			}
			else if (!model.canSaveAndLoad)
				Alert.show(new AlertContentDefault("External Interface not available", "OK", false), null);	
			
			updateHTMLSize(CMapConstants.WIDTH_START, CMapConstants.HEIGHT_START);
		}
		
		public function addDebug():void
		{
			var props:Object = {color: 0x000000, size: 11, align: TextFormatAlign.LEFT, letterSpacing: 0, autoSize: TextFieldAutoSize.LEFT,
								multiline: true, mouseEnabled: true, wordWrap: true, width: 400, height: 20, background: true, backgroundColor: 0xFFFFFF };
			debugTF = _container.parent.addChild(CMapUtils.createTextField("Debug", props)) as TextField;
			debugTF.x = debugTF.y = 10;
			debugTF.addEventListener(MouseEvent.MOUSE_DOWN, handleDebugTFMouseDown, false, 0, true);
			debugTF.filters = [CMapConstants.CD_DROP_SHADOW];
			debugTF.visible = false;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleDebugKeyDown, false, 0, true);
		}
		
		public static function log(s:String):void
		{
			if (debugTF) debugTF.text = debugTF.text + "\n" + s;
			else trace(s);
		}
		private function handleDebugTFMouseDown(e:Event):void { if(debugTF) debugTF.text = ""; }
		private function handleDebugKeyDown(e:KeyboardEvent):void
		{
			if (e.shiftKey && debugTF && e.charCode == 76)
				debugTF.visible = !debugTF.visible; 
		}
		
		private function handleStageResize(e:Event):void
		{ 
			var sideExtra:int = 500;
			_bounds = new Rectangle(0, 0, stage.stageWidth - CMapConstants.NOTES_WIDTH + sideExtra, stage.stageHeight - CMapConstants.MENU_HEIGHT + sideExtra);
			dispatchEvent( new ControllerEvent(ControllerEvent.STAGE_RESIZE, {event:e}) );
		}
		
		public function updateHTMLSize(w:int, h:int):void
		{
			//("CmapController >> updateHTMLSize, w:"+w+", h:"+h);
			if (EcoModeler.IN_SUITE)
				dispatchEvent( new ControllerEvent(ControllerEvent.UPDATE_POSITIONS, {w:w, h:h}) );
			else if (ExternalInterface.available)
				ExternalInterface.call("updateFlashSize", w, h);
			
		}
		
		public function get rect():Rectangle { return _rect ? _rect.clone() : null; }
		public function set rect(value:Rectangle):void
		{
			_rect = value;
			updateAreaUsed();
			
			if (maxW > _rect.width)
				_rect.width = maxW;
			if (maxH > _rect.height)
				_rect.height = maxH;
			
			// set drag bounds
			_bounds = new Rectangle(_rect.x, _rect.y, _rect.width, _rect.height);
			
			//trace("Controller >> set rect\n\tstrokeWeight:"+strokeWeight+", strokeColor:"+strokeColor+", fillColor:"+fillColor+", showInsetShadow:"+showInsetShadow);
		}
		
		public function setGroupName(name:String, idx:int):void { _model.setGroupName(name, idx); }
		
		public function setComponentSoloView(view:int, show:Boolean):void
		{
			//trace("setComponentSoloView, view:"+view+", show:"+show)
			var reset:Boolean = view == ViewPanel.VIEW_LINES_NONE;
			var offAlpha:Number = 0.15;
			var cds:Vector.<ConceptDisplay> = model.cds;
			var lines:Vector.<InfluenceLineDisplay> = model.lines;
			var curCD:ConceptDisplay = model.curCd;
			var cd:ConceptDisplay;
			var line:InfluenceLineDisplay;
			for each (cd in cds)
				cd.alpha = reset || cd == curCD ? 1 : offAlpha;	
			
			if (reset || view == ViewPanel.VIEW_LINES_FROM)
			{
				for each (line in lines)
				{
					line.enabled = reset || line.influencer == curCD;
					if (line.influencer == curCD)
						line.influencee.alpha = 1;
				}
			}
			else if (reset || view == ViewPanel.VIEW_LINES_TO)
			{
				for each (line in lines)
				{
					line.enabled = reset || line.influencee == curCD;
					if (line.influencee == curCD)
						line.influencer.alpha = 1;
				}
			}
		}
		
		public function getState():XML
		{
			return _model.getXMLToSave();
		}
		
		public function loadMap():void
		{	doLoadMap();
			//Alert.show(new AlertContentDefault(CMapConstants.MESSAGE_LOAD_OVERWRITE, "LOAD FILE", true), doLoadMap);
		}
		public function saveMap():void { Alert.show(new AlertContentDetails(), doSaveMap); }
		public function saveScreenshot():void { doSaveScreenshot();/*Alert.show(new AlertContentDetails(), doSaveScreenshot);*/ }
		public function doLoadMap():void { _io.loadFileRef(); }
		public function doSaveMap():void { _io.saveFileRef(); }
		public function doSaveScreenshot():void { _io.savePNG(); }
		public function print():void { _io.print(); }
		
		public function eiDoLoad(xml:String):void
		{
			//Alert.show(new AlertContentDefault("calling doLoad", "OK", false), null);
			onMapLoaded(new XML(xml));
		}
		
		public function eiDoSave():String
		{
			// Alert.show(new AlertContentDefault("calling doSave", "OK", false), null);
			return _model.stringToSave;
			/*
			if (ExternalInterface.available)
			ExternalInterface.call("saveXML", _model.stringToSave);
			*/
		}
		
		public function onMapLoaded(xml:XML):void
		{
			removeAll();
			
			var components:XMLList = xml[CMapConstants.COMPONENTS_NODE_NAME][CMapConstants.COMPONENT_NODE_NAME];
			var component:XML;
			var newCreationIndex:int = XMLUtil.getHighestIdIndex(components) + 1;
			ConceptDisplay.creationIndex = newCreationIndex;
			
			var info:XML = xml.info[0];
			// add author and description to model
			CMapModel.author = XMLUtil.getTextNodeContent(info, "author", true);
			CMapModel.description = XMLUtil.getTextNodeContent(info, "description", true);
			
			var groupNames:XMLList = xml.groupNames.groupName;
			for each(var nameNode:XML in groupNames)
				_model.setGroupName(nameNode.text().toString(), parseInt(nameNode.@index));
			/*
			for (var i:int = 0; i<groupNames.length(); i++)
				_model.setGroupName(groupNames[i].text().toString(), i);
			*/
			
			// add concept displays
			for each (component in components)
				addNewConcept(component);
			
			// once all concept displays are added, we can add the influence line displays	
			var er:ConceptDisplay;
			var ee:ConceptDisplay;
			var lineValueLabel:String;
			var list:XMLList;
			var id:int;
			var eeId:int;
			var lineStringValue:String;
			components = xml.descendants(CMapConstants.COMPONENT_NODE_NAME);
			for each (component in components)
			{
				id = parseInt(XMLUtil.getTextNodeContent(component, "id"));
				if (!isNaN(id))
				{
					er = _model.getConceptById(id);
					if (er != null)
					{	
						list = component[CMapConstants.INFLUENCES_NODE_NAME][CMapConstants.INFLUENCE_NODE_NAME];
						var node:XML;
						for each (node in list)
						{
							eeId = parseInt(XMLUtil.getTextNodeContent(node, "id"));
							if (!isNaN(eeId))
							{
								ee = _model.getConceptById(eeId);
								lineStringValue = XMLUtil.getTextNodeContent(node, CMapConstants.INFLUENCE_VALUE_NODE_NAME);
								var lvd:LineValueData = CMapUtils.getLineValueDataByStringValue(lineStringValue, CMapConstants.LINE_VALUES);
								//log("lineStringValue:"+lineStringValue ); 
								var label:String = XMLUtil.getTextNodeContent(node, "label");
								var notes:String = XMLUtil.getTextNodeContent(node, "notes");
								if (ee != null)
									drawInfluenceLine(er, ee, lvd, false, notes, label);
							}
						}
					}
				}
			}
			updateAreaUsed();
			dispatchEvent(new ControllerEvent(ControllerEvent.MAP_LOADED));
		}
		
		public function updateAddNodeEnabled():void
		{
			var isEnabled:Boolean = maxNodes != -1 && _model.cds.length >= maxNodes; 
			if (isEnabled)
				dispatchEvent(new ControllerEvent(ControllerEvent.DISABLE_ADD_NODE));
			else
				dispatchEvent(new ControllerEvent(ControllerEvent.ENABLE_ADD_NODE));
		}
		
		private function getNewConceptStartPoint():Point
		{
			var posIncr:int = CMapConstants.CD_ADD_POS_INCR;
			var nX:Number = Math.max(CMapConstants.CD_ADD_POS_OFFSET, _addX - CMapConstants.CD_WIDTH/2);
			var startY:Number = CMapConstants.CD_ADD_POS_OFFSET + _container.vScroll; //CMapConstants.MENU_HEIGHT + CMapConstants.CD_ADD_POS_OFFSET; // + CMapConstants.CD_HEIGHT/2;
			var nY:Number = startY;
			var maxHeight:Number = (_rect ? _rect.height : stage.stageHeight) - CMapConstants.CD_HEIGHT/2;
			var _cds:Vector.<ConceptDisplay> = _model.cds;
			var cd:ConceptDisplay;
			
			for each (cd in _cds)
			{
				if (cd.y == nY)
					nY = posIncr + cd.y;
				
				
				if (nY > maxHeight)
				{
					nY = startY;
					nX += posIncr;
				}
			}
			return new Point(nX, nY);
		}
			
		public function addNewConcept(data:XML = null):void
		{
			//trace("addNewConcept, data:"+(data ? data.toXMLString() : "null"));
			
			var _cds:Vector.<ConceptDisplay> = _model.cds;
			
			// updated for ecomodeler
			var cd:ConceptDisplay = _container.concepts.addChild(new ConceptMainDisplay(this)) as ConceptDisplay;
			//var cd:ConceptDisplay = _container.concepts.addChild(new ConceptDisplay(this)) as ConceptDisplay;
			
			var idx:int = XMLUtil.hasTextNodeWithContent(data, "id") != "" ? parseInt(XMLUtil.getTextNodeContent(data, "id")) : -1;
			var title:String = XMLUtil.hasTextNodeWithContent(data, "name") != "" ? XMLUtil.getTextNodeContent(data, "name") : ""; //nodePrefillText;
			var notes:String = XMLUtil.getTextNodeContent(data, "notes");
			var group:int = XMLUtil.hasTextNodeWithContent(data, "group") != "" ? parseInt(XMLUtil.getTextNodeContent(data, "group")) : -1;
			
			cd.init(idx, title, notes, group);
			_cds.push(cd);
			updateAddNodeEnabled();
			
			var startPoint:Point = getNewConceptStartPoint();
			
			cd.x = startPoint.x;
			if ( !isNaN(parseFloat(XMLUtil.getTextNodeContent(data, "x"))) )
				cd.x = parseFloat(XMLUtil.getTextNodeContent(data, "x"));
			
			cd.y = startPoint.y;
			if ( !isNaN(parseFloat(XMLUtil.getTextNodeContent(data, "y"))) )
				cd.y = parseFloat(XMLUtil.getTextNodeContent(data, "y"));
			
			// add properties if present
			if (data && CMapConstants.PROPERTIES_NODE_NAME in data)
			{
				var concepts:XMLList = data[CMapConstants.PROPERTIES_NODE_NAME][CMapConstants.COMPONENT_NODE_NAME]
				for each (var concept:XML in concepts)
					addConceptProperty(cd as ConceptMainDisplay, concept); 
			}
					
			//cd.x = XMLUtil.isNumber(data, "@x") ? parseFloat(data.@x) : startPoint.x;
			//cd.y = XMLUtil.isNumber(data, "@y") ? parseFloat(data.@y) : startPoint.y;
			//return {w:cd.x + CMapConstants.CD_WIDTH/2, h:cd.y + CMapConstants.CD_HEIGHT/2};
		}
		
		public function addConceptProperty(cmd:ConceptMainDisplay, data:XML = null):void
		{
			//trace("CMAPController >> addConceptProperty, cmd:"+cmd);
			
			var _cds:Vector.<ConceptDisplay> = _model.cds;
			
			// updated for ecomodeler
			var cd:ConceptPropertyDisplay = _container.concepts.addChild(new ConceptPropertyDisplay(this)) as ConceptPropertyDisplay;
			//var cd:ConceptDisplay = _container.concepts.addChild(new ConceptDisplay(this)) as ConceptDisplay;
			
			var idx:int = XMLUtil.hasTextNodeWithContent(data, "id") != "" ? parseInt(XMLUtil.getTextNodeContent(data, "id")) : -1;
			var title:String = XMLUtil.hasTextNodeWithContent(data, "name") != "" ? XMLUtil.getTextNodeContent(data, "name") : ""; //nodePrefillText;
			var notes:String = XMLUtil.getTextNodeContent(data, "notes");
			
			cd.init(idx, title, notes, cmd.group);
			_cds.push(cd);
			cmd.addPropertyDisplay(cd);
			
			// update any lines to or from this main display
			var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
			for each (var line:InfluenceLineDisplay in _lines)
				if ( line.connectsTo(cmd) ) line.draw();
		}
		
		public function removeConcept(cd:ConceptDisplay):void
		{
			if (!cd)
				return;
			
			var _cds:Vector.<ConceptDisplay> = _model.cds;
			var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
			
			// remove all lines to and from this node
			var count:int = 0;
			var len:int = _lines.length;
			var line:InfluenceLineDisplay;
			while (count < _lines.length)
			{
				//trace("\tcount:"+count);
				line = _lines[count];
				//if (line.influencer == cd || line.influencee == cd)
				if ( line.connectsTo(cd) )
				{
					line.finalize();
					_container.lines.removeChild(line);
					_lines.splice(count, 1);
					//trace("\t\tdestroy line:"+line);
				}
				else
					count++;
			}
			
			// if this was the currently selected node, mark it as not before we remove it
			if (_model.curCd == cd)
				setAsCurrentCD();
			
			var cpd:ConceptPropertyDisplay;
			if (cd is ConceptPropertyDisplay) // remove the propert from its parent display
			{
				cpd = cd as ConceptPropertyDisplay;
				cpd.mainDisplay.removePropertyDisplay(cpd);
				
				//if removing a property, we need to redraw lines to that parent display and any other existing property displays of that parent display
				for each (line in _lines)
					if ( line.connectsTo(cpd.mainDisplay) ) line.draw();
			}
			else if (cd is ConceptMainDisplay) // finalize and remove all the properties of the parent display
			{
				var spliceIdx:int;
				var cmd:ConceptMainDisplay = cd as ConceptMainDisplay;
				var cpds:Vector.<ConceptPropertyDisplay> = cmd.propertyDisplays;
				for each (cpd in cpds)
				{
					cpd.finalize();
					_container.concepts.removeChild(cpd);
					spliceIdx = _cds.indexOf(cpd);
					_cds.splice(spliceIdx, 1);
				}
			}
			
			cd.finalize();
			_container.concepts.removeChild(cd);
			var cdIdx:int = _cds.indexOf(cd);
			_cds.splice(cdIdx, 1);
			
			updateAreaUsed(true);
		}
		
		/*
		public function startResizeConcept(cd:ConceptDisplay):void
		{
			setAsCurrentCD(cd);
			if (stage)
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleRedrawLines, false, 0, true);
		}
		
		public function stopResizeConcept(cd:ConceptDisplay):void
		{
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleRedrawLines);
		}
		*/
		
		public function startDragConcept(cd:ConceptDisplay):void
		{
			setAsCurrentCD(cd);
			
			if (_bounds)
				_model.curCd.startDrag(false, getDragBounds(cd));
			else
				_model.curCd.startDrag();
			
			if (stage)
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleRedrawLines, false, 0, true);
		}
		
		public function stopDragConcept(cd:ConceptDisplay):void
		{
			var _curCd:ConceptDisplay = _model.curCd;
			if (_curCd)
				_curCd.stopDrag()
			if (_curCd != cd)
			{
				cd.stopDrag();
				_model.curCd= null;
			}
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleRedrawLines);
			updateAreaUsed();
		}
		
		public function startDrawTempLine(cd:ConceptDisplay):void
		{
			setAsCurrentCD(cd);
			if (stage)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleDrawTempLine, false, 0, true);
				_tempLineArrowhead = cd.tempLine.addChild(drawArrowhead()) as Shape;
				handleDrawTempLine(null);
			}
		}
		
		public function stopDrawTempLine(cd:ConceptDisplay):void
		{
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleDrawTempLine);
			
			// clear line
			var g:Graphics = cd.tempLine.graphics;
			g.clear();
			
			// remove arrowhead
			if (_tempLineArrowhead)
				DisplayObjectUtil.remove(_tempLineArrowhead);
			
			var _curCd:ConceptDisplay = _model.curCd;
			if (_curCd && cd == _curCd)
			{
				var hitCd:ConceptDisplay = findHit();
				if (hitCd)
					drawInfluenceLine(_curCd, hitCd, CMapConstants.LINE_VALUE_DEFAULT, true);
			}
		}
		
		private function getDragBounds(cd:ConceptDisplay):Rectangle
		{
			var bounds:Rectangle = _bounds.clone();
			bounds.width -= cd.width;
			bounds.height -= cd.height;
			return bounds;
		}
		
		private function updateAreaUsed(force:Boolean = false):void
		{
			//log("updateAreaUsed, force:"+force+", _maxW:"+_maxW+", _maxH:"+_maxH);
			
			var cds:Vector.<ConceptDisplay> = _model.cds;
			var cd:ConceptDisplay;
			var maxW:int = 0;
			var maxH:int = 0;
			var changed:Boolean = false;
			var cdW:int = CMapConstants.CD_WIDTH; ///2;
			var cdH:int = CMapConstants.CD_HEIGHT; ///2;
			var adjX:Number = _container.x;
			var adjY:Number = _container.y;
			for each (cd in cds)
			{
				if (cd.x + cdW + adjX > maxW)
					maxW = cd.x + cdW + adjX;
				if (cd.y + cdH + adjY > maxH)
					maxH = cd.y + cdH + adjY;
				if (_maxW != maxW)
				{
					_maxW = maxW
					changed = true;
				}
				if (_maxH != maxH)
				{
					_maxH = maxH;
					changed = true;
				}
				
				//log("\tAFTER, _maxW:"+_maxW+", _maxH:"+_maxH+", changed:"+changed);
				
				//if (force || changed)
					//updateHTMLSize(_maxW, _maxH);
			}
			if (force || changed)
				updateHTMLSize(_maxW, _maxH);
		}
		
		private function drawInfluenceLine(er:ConceptDisplay, ee:ConceptDisplay, startValue:LineValueData, setEeToOver:Boolean, notes:String = "", label:String = "" ):void
		{
			if (!isAlreadyInfluencedBy(ee, er))
			{
				//trace("drawInfluenceLine, er:"+er.id+", ee:"+ee.id);
				var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
				var line:InfluenceLineDisplay = _container.lines.addChild(new InfluenceLineDisplay(this, er, ee, startValue, label)) as InfluenceLineDisplay;
				if (notes != "")
					line.notes = notes;
				
				//if (label != "")
					//line.label = label;
				
				if (makesDualRelationship(ee, er))
				{
					line.setDualRelationship(true, true);
					var dualLine:InfluenceLineDisplay = getDualRelationshipOtherLine(ee, er);
					dualLine.setDualRelationship(true, false);
					dualLine.draw();
				}
				line.draw();
				_lines.push(line);
			}
			
			if (setEeToOver)
				ee.setToOverState();
		}
		
		public function showLineLabelEditor(globalPoint:Point, line:InfluenceLineDisplay):void
		{
			if (!_lineLabelEditor)
				_lineLabelEditor = _container.addChild(new LineLabelEditorDisplay(this)) as LineLabelEditorDisplay;
			
			//trace("CmapController >> showLineValueMenu\n\tx:"+x+", y:"+y+", selectedIdx:"+selectedIdx+", line:"+line);
			_model.curLine = line;
			line.toggleLineLabelShown(false);
			_lineLabelEditor.show(_container.globalToLocal(globalPoint), line);
		}
		
		public function showLineValueMenu(x:Number, y:Number, selectedIdx:Number, line:InfluenceLineDisplay):void
		{
			if (!_lineValueMenu)
				_lineValueMenu = _container.addChild(new LineValueMenuDisplay(this)) as LineValueMenuDisplay;
			
			//trace("CmapController >> showLineValueMenu\n\tx:"+x+", y:"+y+", selectedIdx:"+selectedIdx+", line:"+line);
			_model.curLine = line;
			var h:int = CMapConstants.LINE_VALUE_HEIGHT;
			var localPoint:Point = _container.globalToLocal(new Point(x, y));
			if (selectedIdx < 0)
				selectedIdx = 2.5
			var yAdj:Number = selectedIdx > -1 ? selectedIdx * (h - CMapConstants.LINE_VALUE_BORDER) : 0;
			var _y:Number = localPoint.y - h/2; 
			var yBot:Number = _y - yAdj + _lineValueMenu.height;
			var top:int = 0;//CMapConstants.MENU_HEIGHT + 5;
			if (_y - yAdj < top)
				_y = top;
			else if (yBot > stage.stageHeight)
				_y = _y - yAdj - (yBot - (stage.stageHeight - CMapConstants.MENU_HEIGHT)) + h;
			else		
				_y = _y - yAdj;
			_lineValueMenu.show(localPoint.x, _y);
		}
		
		public function doRemoveLine(line:InfluenceLineDisplay):void
		{
			removeLine(line);
			_model.curLine = null
		}
		
		public function set lineValue(lvd:LineValueData):void
		{
			var _curLine:InfluenceLineDisplay = _model.curLine;
			if (!_curLine)
				return;
			
			if (lvd.label == CMapConstants.LINE_VALUE_REMOVE_LABEL)
			{
				removeLine(_curLine);
				_model.curLine = null;
			}
			else if (lvd.label != "")
				_curLine.value = lvd;
			
			_model.lineLabelChange();
			//_model.lineValueChange();
			//_model.curLine = null;
		}
		
		public function removeLineFromLineDeleteButton(line:InfluenceLineDisplay):void
		{
			var _curLine:InfluenceLineDisplay = _model.curLine;
			var isCurLine:Boolean = _curLine  && line == _curLine && line == _model.curSelected;  
			//trace("removeLineFromLineDeleteButton, _curLine:"+_curLine+", line:"+line+", isCurLine:"+isCurLine+", _model.curSelected:"+_model.curSelected);
			removeLine(_curLine);
			if (isCurLine)
				_model.curLine = null;
		}
		
		private function removeLine(line:InfluenceLineDisplay):void
		{
			var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
			
			if (makesDualRelationship(line.influencee, line.influencer))
			{
				var otherLine:InfluenceLineDisplay = getDualRelationshipOtherLine(line.influencee, line.influencer);
				otherLine.setDualRelationship(false);
				otherLine.draw();
			}
			_container.lines.removeChild(line);
			line.finalize();
			_lines.splice(_lines.indexOf(line), 1);
		}
		
		public function setAsCurrentCD(cd:ConceptDisplay = null):void
		{
			//trace("CMapController >> setAsCurrentCD, cd:"+ cd);
			
			var _curCd:ConceptDisplay = _model.curCd;
			if (_curCd != null)
				_curCd.setAsSelected(false);
			
			if (cd != null)
			{
				cd.setAsSelected(true);
				_container.concepts.setChildIndex(cd, _container.concepts.numChildren - 1);
			}
			_model.curCd = cd;
		}
		
		public function setAsCurrentLine(line:InfluenceLineDisplay = null):void
		{
			var _curLine:InfluenceLineDisplay = _model.curLine;
			
			//if (_curLine != null)
				//_curLine.setAsSelected(false);
			
			if (line != null)
			{
				//line.setAsSelected(true);
				//trace("_container.lines.numChildren:"+_container.lines.numChildren);
				_container.lines.setChildIndex(line, _container.lines.numChildren - 1);
			}
			_model.curLine = line;
		}
		
		private function removeAll():void
		{
			// remove concept displays, which also removes lines
			var _cds:Vector.<ConceptDisplay> = _model.cds;
			while (_cds.length > 0)
				removeConcept(_cds[0]);
		}
		
		private function getDualRelationshipOtherLine(ee:ConceptDisplay, er:ConceptDisplay):InfluenceLineDisplay
		{
			var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
			var line:InfluenceLineDisplay;
			var otherLine:InfluenceLineDisplay;
			for each (line in _lines)
			{
				//if (line.influencer == ee && line.influencee == er)
				if (line.influencer.mainDisplay == ee.mainDisplay && line.influencee.mainDisplay == er.mainDisplay)
				{
					otherLine = line;
					break
				}
			}
			return otherLine;	
		}
		
		private function isAlreadyInfluencedBy(ee:ConceptDisplay, er:ConceptDisplay):Boolean
		{
			var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
			var line:InfluenceLineDisplay
			for each (line in _lines)
			{
				if (line.influencer.mainDisplay == er.mainDisplay && line.influencee.mainDisplay == ee.mainDisplay)
					return true;
			}
			return false;
		}
		
		private function makesDualRelationship(ee:ConceptDisplay, er:ConceptDisplay):Boolean
		{
			var makesDualRelationship:Boolean = false;
			var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
			var line:InfluenceLineDisplay
			for each (line in _lines)
			{
				// if (line.influencer == ee && line.influencee == er)
				if (line.influencer.mainDisplay == ee.mainDisplay && line.influencee.mainDisplay == er.mainDisplay)
				{
					makesDualRelationship = true;
					break;
				}
			}
			return makesDualRelationship;
		}
		
		private function findHit():ConceptDisplay
		{
			var _cds:Vector.<ConceptDisplay> = _model.cds;
			var cd:ConceptDisplay;
			for each (cd in _cds)
			{
				if (cd.isOver && cd != _model.curCd)
					return cd;
			}
			return null;
		}
		
		// -------------------- event handlers --------------------
		public function  handleRedrawLines(e:Event = null):void
		{
			var _lines:Vector.<InfluenceLineDisplay> = _model.lines;
			
			var line:InfluenceLineDisplay;
			for each(line in _lines)
			{
				if (line.connectsTo(_model.curCd))
					line.draw();
			}
		}
		
		private function  handleDrawTempLine(e:Event):void
		{
			var _curCd:ConceptDisplay = _model.curCd;
			if (!_curCd)
				return;
			var s:Sprite = _curCd.tempLine;
			var g:Graphics = _curCd.tempLine.graphics;
			var curCdCenter:Point = new Point(_curCd.width/2, _curCd.height/2); 
			g.clear();
			g.lineStyle(CMapConstants.INFLUENCE_LINE_THICKNESS, CMapConstants.INFLUENCE_LINE_COLOR);
			g.moveTo(curCdCenter.x, curCdCenter.y);
			g.lineTo(s.mouseX, s.mouseY);
			
			// position and rotate the arrow head
			var deltaX:Number = s.mouseX - curCdCenter.x;
			var deltaY:Number = s.mouseY - curCdCenter.y;
			var radians:Number = Math.atan2(deltaY, deltaX);
			_tempLineArrowhead.rotation =  radians * 180 / Math.PI;
			_tempLineArrowhead.x = s.mouseX;
			_tempLineArrowhead.y = s.mouseY;
		}
		
		private function drawArrowhead():Shape
		{
			var s:Shape = new Shape;
			var g:Graphics = s.graphics;
			var h:int = CMapConstants.ARROWHEAD_HEIGHT;
			var w:int = CMapConstants.ARROWHEAD_WIDTH;
			g.beginFill(CMapConstants.INFLUENCE_LINE_COLOR);
			g.lineTo(-h, -w/2);
			g.lineTo(-h, w/2);
			g.lineTo(0, 0);
			g.endFill();
			return s;
		}
		
		public function finalize():void
		{
			if (_model)
				_model.finalize();
			
			DisplayObjectUtil.remove(_bgFill);
			DisplayObjectUtil.remove(_bgOutline);
			DisplayObjectUtil.remove(_tempLineArrowhead);
			DisplayObjectUtil.remove(_lineValueMenu);
			DisplayObjectUtil.finalizeAndRemove(_container);
			
			_model = null;
			_container = null;
			_bgFill = null;
			_bgOutline = null;
			_lineValueMenu = null
			_tempLineArrowhead = null
			_rect = null;
			_bounds = null;
		}
	}
}