package com.knowledgeplayers.grar.localisation;

import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.grar.event.LocaleEvent;
import haxe.xml.Fast;
import nme.events.Event;
import nme.events.EventDispatcher;

/**
 * Localisation
 */
class Localisation extends EventDispatcher {
	/**
     * Name of the localisation
     */
	public var name(default, null):String;

	private var tradHash:Hash<String>;

	/**
     * Constructor
     * @param	name : Name of the localisation (aka language)
     */

	public function new(name:String)
	{
		super();
		tradHash = new Hash<String>();
		this.name = name;
	}

	/**
     * Set the path to the file for this locale
     * @param	path : path to the locale folder
     */

	public function setLocaleFile(path:String)
	{
		parseContent(AssetsStorage.getXml(path));
	}

	/**
     * Get the localised text for an item
     * @param	key : key of the item
     * @return the localised text
     */

	public function getItem(key:String):String
	{
		return tradHash.get(key);
	}

	private function parseContent(content:Xml):Void
	{
		if(content.firstElement().nodeName == "Workbook")
			parseExcelContent(content);
		else
			parseXmlContent(content);
		dispatchEvent(new LocaleEvent(LocaleEvent.LOCALE_LOADED));
	}

	private function parseXmlContent(content:Xml):Void
	{
		var locale = new Fast(content).node.Localisation;
		for(elem in locale.nodes.Element){
			tradHash.set(elem.node.key.innerData, elem.node.value.innerData);
		}
	}

	// Can't use haxe.xml.Fast because Excel XML isn't supported

	private function parseExcelContent(content:Xml):Void
	{
		var table:Xml = null;
		for(element in content.firstElement().elements()){
			if(element.nodeName == "Worksheet")
				table = element.firstElement();
		}

		for(row in table.elements()){
			if(row.nodeName == "Row"){
				var key:String = "";
				var value:String = "";
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
	}
}