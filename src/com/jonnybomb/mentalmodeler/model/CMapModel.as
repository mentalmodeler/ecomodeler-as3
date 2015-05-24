package com.jonnybomb.mentalmodeler.model
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptMainDisplay;
	import com.jonnybomb.mentalmodeler.display.ConceptPropertyDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.xml.XMLUtil;
	
	import flash.events.EventDispatcher;
	
	import flashx.textLayout.events.ModelChange;

	public class CMapModel  extends EventDispatcher
	{
		private static const XML_HEADER:String = "<?xml version='1.0' encoding='UTF-8'?>";
		
		public static const VERSION:String = "0.1";
		public static var author:String = "";
		public static var description:String = "";
		
		private var _cds:Vector.<ConceptDisplay>;
		private var _lines:Vector.<InfluenceLineDisplay>;
		private var _curLine:InfluenceLineDisplay;
		private var _curCd:ConceptDisplay;
		
		private var _groupNames:Vector.<String> = new <String>["", "", "", "", "", ""];
		public function get groupNames():Vector.<String> { return _groupNames.concat(); }
		
		public var canSaveAndLoad:Boolean;
		
		private var _curSelected:INotable;
		public function get curSelected():INotable { return _curSelected; }
		public function get curSelectedIsCd():Boolean { return _curSelected is ConceptDisplay; }
		public function get curSelectedIsLine():Boolean { return _curSelected is InfluenceLineDisplay; }
		
		public function get cds():Vector.<ConceptDisplay> { return _cds; }
		public function get lines():Vector.<InfluenceLineDisplay> { return _lines; }
		
		public function get curLine():InfluenceLineDisplay { return _curLine; }
		public function set curLine(value:InfluenceLineDisplay):void
		{
			//trace("BEFORE Model >> set curLine, curLine:"+curLine);//+", _prevLine:"+_prevLine);
			//_prevLine = _curLine;
			_curLine = value;
			_curSelected = _curLine
			//_curCd = null;
			//trace("AFTER Model >> set curLine, curLine:"+curLine);//+", _prevLine:"+_prevLine);
			dispatchEvent(new ModelEvent(ModelEvent.SELECTED_LINE_CHANGE));
			dispatchEvent(new ModelEvent(ModelEvent.SELECTED_CHANGE));
			//dispatchEvent(new ModelEvent(ModelEvent.SELECTED_CD_CHANGE));
			/*
			if (_curLine)
			{
				_curCd = null;
				dispatchEvent(new ModelEvent(ModelEvent.SELECTED_CD_CHANGE));
			}
			*/
		}
		
		public function get curCd():ConceptDisplay { return _curCd; }
		public function set curCd(value:ConceptDisplay):void
		{ 
			//trace("BEFORE Model >> set curCd, _curCd:"+_curCd);//+", _prevCd:"+_prevCd);
			//_prevCd = _curCd;
			_curCd = value;
			_curSelected = _curCd;
			//_curLine = null;
			//trace("AFTER Model >> set curCd, _curCd:"+_curCd);//+", _prevCd:"+_prevCd);
			dispatchEvent(new ModelEvent(ModelEvent.SELECTED_CD_CHANGE));
			dispatchEvent(new ModelEvent(ModelEvent.SELECTED_CHANGE));
			//dispatchEvent(new ModelEvent(ModelEvent.SELECTED_LINE_CHANGE));
			/*
			if (_curCd)
			{
				_curLine = null;
				dispatchEvent(new ModelEvent(ModelEvent.SELECTED_LINE_CHANGE));
			}
			*/
		}
		
		public function CMapModel()
		{
			_cds = new Vector.<ConceptDisplay>();
			_lines = new Vector.<InfluenceLineDisplay>();
		}
		
		public function setGroupName(name:String, idx:int):void
		{
			if (idx >= 0 && idx < _groupNames.length)
				_groupNames[idx] = name;
		}
			
		
		public function elementGroupChange():void { dispatchEvent(new ModelEvent(ModelEvent.ELEMENT_GROUP_CHANGE)); }
		public function elementTitleChange():void { dispatchEvent(new ModelEvent(ModelEvent.ELEMENT_TITLE_CHANGE)); }
		public function lineLabelChange():void{ dispatchEvent(new ModelEvent(ModelEvent.LINE_LABEL_CHANGE)); }
		//public function lineValueChange():void { dispatchEvent(new ModelEvent(ModelEvent.LINE_VALUE_CHANGE)); }
		
		public function finalize():void
		{
			for each (var cd:ConceptDisplay in _cds)
				DisplayObjectUtil.finalizeAndRemove(cd);
			
			for each (var line:InfluenceLineDisplay in _lines)
				DisplayObjectUtil.finalizeAndRemove(line);
			
			_cds = null;
			_lines = null;
			_curLine = null;
			_curCd = null;
		}
		
		public function hasLine(compLine:InfluenceLineDisplay):Boolean
		{
			var doesHave:Boolean = false;
			for each (var line:InfluenceLineDisplay in _lines)
			{
				if (compLine == line)
				{
					doesHave = true;
					break;
				}
			}
			return doesHave;
		}
		
		public function getConceptById(id:int):ConceptDisplay
		{
			var cd:ConceptDisplay;
			for each (cd in _cds)
				if (cd.id == id) return cd;
			return null;
		}
		
		public function get stringToSave():String
		{
			var xml:XML = getXMLToSave();
			return XML_HEADER + xml.toXMLString();
		}
		
		public function getXMLToSave():XML
		{
			var appNodeName:String = CMapConstants.APP_NODE_NAME;
			var componentsNodeName:String = CMapConstants.COMPONENTS_NODE_NAME;
			var propertiesNodeName:String = CMapConstants.PROPERTIES_NODE_NAME;
			var relationshipsNodeName:String = CMapConstants.INFLUENCES_NODE_NAME;
			var relationshipNodeName:String = CMapConstants.INFLUENCE_NODE_NAME;
			var influencedIdNodeName:String = CMapConstants.INFLUENCED_ID_NODE_NAME;
			var influencedNameNodeName:String = CMapConstants.INFLUENCED_NAME_NODE_NAME;
			
			var cd:ConceptDisplay;
			var line:InfluenceLineDisplay;
			var linesCopy:Vector.<InfluenceLineDisplay> = _lines.concat();
			var a:Array = [];
			var er:Object;
			var ee:Object;
			var i:int;
			var len:int;
			var node:XML;
			var relationship:XML;
			var relationships:XML;
			var properties:XML;
			var xml:XML = <{appNodeName}></{appNodeName}>
			var info:XML = <info><version>{VERSION}</version><date>{new Date().toString()}</date><author>{XMLUtil.cdata(author)}</author><description>{XMLUtil.cdata(description)}</description></info>
			var groupNames:XML = <groupNames></groupNames>;
			var concepts:XML = <{componentsNodeName}></{componentsNodeName}>;
			
			xml.appendChild(info);
			
			for (i = 0; i < _groupNames.length; i++)
				groupNames.appendChild(<groupName index={i}>{XMLUtil.cdata(_groupNames[i])}</groupName>)
			xml.appendChild(groupNames);
			
			// create concepts wrapper node
			xml.appendChild(concepts);
			
			for each (cd in _cds)
			{
				// only run this loop for ConceptMainDisplay, not ConceptPropertyDisplay
				if (cd is ConceptMainDisplay)
				{
					// populate node details
					node = getConceptDisplayNode(cd, linesCopy);
					
					// create properties wrapper node
					properties = <{propertiesNodeName}></{propertiesNodeName}>;
					var cmd:ConceptMainDisplay = cd as ConceptMainDisplay;
					for each(var cpd:ConceptPropertyDisplay in cmd.propertyDisplays)
						properties.appendChild( getConceptDisplayNode(cpd, linesCopy) );
					
					if (properties.children().length() > 0)
						node.appendChild(properties);
					
					// add this concept to concepts wrapper
					concepts.appendChild(node);
				}
			}
			
			//trace("save >> xml:\n"+xml.toXMLString());
			return xml;
		}
		
		private function traceLines(l:Vector.<InfluenceLineDisplay>):void
		{
			trace("linesCopy");
			for(var i:int = 0; i<l.length; i++)
			{
				var line:InfluenceLineDisplay = lines[i]
				trace("\t"+i+" >> line.influencer:"+line.influencer.id+", line.influencee:"+line.influencee.id); 
			}
		}
		
		private function getConceptDisplayNode(cd:ConceptDisplay, linesCopy:Vector.<InfluenceLineDisplay>):XML
		{
			var componentNodeName:String = CMapConstants.COMPONENT_NODE_NAME;
			var node:XML = <{componentNodeName}><id>{cd.id}</id><name>{XMLUtil.cdata(cd.title)}</name><notes>{XMLUtil.cdata(cd.notes)}</notes><group>{cd.group}</group><x>{cd.x}</x><y>{cd.y}</y></{componentNodeName}>;
			var relationships:XML = getRelationships(cd, linesCopy);
			if (relationships.children().length() > 0)
				node.appendChild(relationships);
			return node;
		}
		
		private function getRelationships(cd:ConceptDisplay, linesCopy:Vector.<InfluenceLineDisplay>):XML
		{
			var relationshipsNodeName:String = CMapConstants.INFLUENCES_NODE_NAME;
			var relationshipNodeName:String = CMapConstants.INFLUENCE_NODE_NAME;
			var influencedIdNodeName:String = CMapConstants.INFLUENCED_ID_NODE_NAME;
			var influencedNameNodeName:String = CMapConstants.INFLUENCED_NAME_NODE_NAME;
			
			var relationships:XML = <{relationshipsNodeName}></{relationshipsNodeName}>;
			var len:int = linesCopy.length;
			var i:int = 0;
			while(i < len)
			{
				// iterate through lines to see if this node is the influencer of any of these lines
				var line:InfluenceLineDisplay = linesCopy[i];
				//trace(i+" >> line, line.influencer:"+line.influencer.id+", line.influencee:"+line.influencee.id); 
				if (line.influencer == cd && line.influencee)
				{
					// this node does have influence line, so add it and its details
					var relationship:XML = <{relationshipNodeName}>
					<{influencedIdNodeName}>{line.influencee.id}</{influencedIdNodeName}>
					<{influencedNameNodeName}>{XMLUtil.cdata(line.influencee.title)}</{influencedNameNodeName}>
					<label>{XMLUtil.cdata(line.label)}</label>
					<notes>{XMLUtil.cdata(line.notes)}</notes>
					</{relationshipNodeName}>;
					
					relationships.appendChild(relationship);
					linesCopy.splice(i, 1);
					len = linesCopy.length;
				}
				else
					i++;
			}
			return relationships
		}
		
		/*
		public function getXMLToSave():XML
		{
			var appNodeName:String = CMapConstants.APP_NODE_NAME;
			var componentNodeName:String = CMapConstants.COMPONENT_NODE_NAME;
			var influenceNodeName:String = CMapConstants.INFLUENCE_NODE_NAME;
			
			var cd:ConceptDisplay;
			var line:InfluenceLineDisplay;
			var lines:Vector.<InfluenceLineDisplay> = _lines.concat();
			var a:Array = [];
			var er:Object;
			var ee:Object;
			var i:int;
			var len:int;
			var xml:XML = new XML(<{appNodeName}></{appNodeName}>);
			var node:XML;
			
			for each (cd in _cds)
			{
				node = <{componentNodeName} id={cd.id} x={cd.x} y={cd.y} w={cd.width} h={cd.height}>{XMLUtil.cdata(cd.title)}</{componentNodeName}>;
				len = lines.length;
				i = 0;
				while(i < len)
				{
					line = lines[i];
					if (line.influencer == cd && line.influencee)
					{
						//node.appendChild(<{influenceNodeName} id={line.influencee.id} value={line.value}>{XMLUtil.cdata(line.influencee.title)}</{influenceNodeName}>);
						node.appendChild(<{influenceNodeName} id={line.influencee.id}/>);
						lines.splice(i, 1);
						len = lines.length;
					}
					else
						i++;
				}
				xml.appendChild(node);
			}
			return xml;
		}
		*/
	}
}