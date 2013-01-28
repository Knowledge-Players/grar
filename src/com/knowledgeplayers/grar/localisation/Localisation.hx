package com.knowledgeplayers.grar.localisation;

import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.events.Event;
import nme.events.EventDispatcher;

/**
 * Localisation
 */
class Localisation extends EventDispatcher {
    /**
     * Name of the localisation
     */
    public var name(default, null): String;

    private var tradHash: Hash<String>;

    /**
     * Constructor
     * @param	name : Name of the localisation (aka language)
     */

    public function new(name: String)
    {
        super();
        tradHash = new Hash<String>();
        this.name = name;
    }

    /**
     * Set the path to the file for this locale
     * @param	path : path to the locale folder
     */

    public function setLocaleFile(path: String)
    {
        XmlLoader.load(path, onLoadComplete, parseContent);
    }

    /**
     * Get the localised text for an item
     * @param	key : key of the item
     * @return the localised text
     */

    public function getItem(key: String): String
    {
        return tradHash.get(key);
    }

    // Can't use haxe.xml.Fast because Excel XML isn't reconized

    private function parseContent(content: Xml): Void
    {
        var table: Xml = null;
        for(element in content.firstElement().elements()){
            if(element.nodeName == "Worksheet")
                table = element.firstElement();
        }

        for(row in table.elements()){
            if(row.nodeName == "Row"){
                var key: String = "";
                var value: String = "";
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

    // Handlers

    private function onLoadComplete(event: Event): Void
    {
        parseContent(XmlLoader.getXml(event));
    }
}