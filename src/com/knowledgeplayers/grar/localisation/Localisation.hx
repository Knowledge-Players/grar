package com.knowledgeplayers.grar.localisation;

import com.knowledgeplayers.grar.event.LocaleEvent;
import nme.events.EventDispatcher;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLLoaderDataFormat;
import nme.events.IOErrorEvent;
import nme.events.Event;

import com.knowledgeplayers.grar.util.XmlLoader;

class Localisation extends EventDispatcher
{
	public var name(default, null): String;

	private var tradHash: Hash<String>;

	public function new(name: String)
	{
		super();
		tradHash = new Hash<String>();
		this.name = name;
	}
	
	public function setLocaleFile(path: String) {
		var xml = XmlLoader.load(path, onLoadComplete);
		#if !flash
			parseContent(xml);
		#end
	}

	// Can't use haxe.xml.Fast because Excel XML isn't reconized
	function parseContent(content: Xml) : Void
	{
		var table: Xml = null;
		for(element in content.firstElement().elements()){
			if(element.nodeName == "Worksheet")
				table = element.firstElement();	
		}

		for(row in table.elements()){
			if(row.nodeName == "Row"){
				var key: String="";
				var value: String="";
				for(cell in row.elements()){
					if(cell.nodeName == "Cell"){
						for(data in cell.elements()){
							if(data.nodeName == "Data"){
								if(key != ""){
									value = data.firstChild().toString();
								}
								else{
									key = data.firstChild().toString();
								}
							}
						}
					}
				}
				if(key != "" && value != ""){
					tradHash.set(key, value);
				}
			}
		}
		dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
	}

	public function getItem(key : String) : String
	{
		return tradHash.get(key);
	}
	
	// Handlers
	
	private function onLoadComplete(event: Event) : Void 
	{
		parseContent(XmlLoader.getXml(event));
	}
}