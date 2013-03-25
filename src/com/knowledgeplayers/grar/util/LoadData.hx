package com.knowledgeplayers.grar.util;

import aze.display.TilesheetEx;
import haxe.xml.Fast;
import aze.display.SparrowTilesheet;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Loader;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.events.IOErrorEvent;
import nme.Lib;
import nme.net.URLRequest;

/**
 * Data loader for external resources
 */
class LoadData extends EventDispatcher {

    /**
     * Instance of the LoadData
     */
    public static var instance (getInstance, null):LoadData;

    private var cacheElementsDisplay:Hash<DisplayObject>;
    private var imagesUrls:Array<String>;
    private var numDataLoaded:Float = 0;
    private var nbDatas:Float = 0;
    private var nbXml:Float = 0;
    private var numXmlLoaded:Float = 0;

    /**
     * @return the instance of the loaderdatas
     */

    public static function getInstance():LoadData
    {
        if(instance == null)
            instance = new LoadData();
        return instance;
    }

    /**
    * Load all the displays of sample_structure.xml
    * @param    structureXml : Xml to parse
    **/

    public function loadDisplayXml(?structureXml:Xml = null):Void
    {
        var arrayDisplayXml = parseChildrenXml(structureXml, "display");

        if(arrayDisplayXml.length > 0){
            arrayDisplayXml = removeDuplicates(arrayDisplayXml);

            nbXml += arrayDisplayXml.length;

            for(xml in arrayDisplayXml){
                XmlLoader.load(xml, onXmlDisplayLoaded, parseContent);
            }
        }
    }

    public function loadSpritesheet(pName:String, src:String, listener:Event -> Void)
    {
        var loader = new SpriteSheetLoader();
        loader.addEventListener(Event.COMPLETE, listener);

        loader.init(pName, src);
    }

    /**
    * Get the display loaded
    * @param    name : Name of the wanted element
    * @return the element or null if it doesn't exist
    **/

    public function getElementDisplayInCache(_name:String):Null<DisplayObject>
    {
        return cacheElementsDisplay.get(_name);
    }

    // Privates

    private function new()
    {
        super();
        cacheElementsDisplay = new Hash<DisplayObject>();
        imagesUrls = new Array<String>();
    }

    /**
    * Parse all the nodes of Xml and get the attribute needed
    * @param    xml : Xml node @:autoBuild parse
    * @param    att : Attribut to find
    * @return an array with the results
    **/

    private function parseChildrenXml(_xml:Xml, _att:String):Array<String>
    {
        var array:Array<String> = new Array<String>();
        for(elt in _xml.elements()){
            if(elt.nodeName == "Part" && elt.get("file") != null){
                XmlLoader.load(elt.get("file"), function(e:Event)
                {
                    loadDisplayXml(XmlLoader.getXml(e));
                }, loadDisplayXml);
            }
            if(elt.get(_att) != null)
                array.push(elt.get(_att));
            if(elt.firstChild() != null)
                array = array.concat(parseChildrenXml(elt, _att));
        }
        return array;
    }

    /**
    * Remove duplicates from an Array<String>
    * @param    ar : The array to clean
    * @return the array without duplicates
    **/

    private function removeDuplicates(array:Array<String>):Array<String>
    {
        var uniques = new Array<String>();

        for(elem in array){
            var isUnique = true;
            for(unique in uniques){
                if(elem == unique)
                    isUnique = false;
            }
            if(isUnique)
                uniques.push(elem);
        }

        return uniques;
    }

    private function onXmlDisplayLoaded(e:Event = null):Void
    {
        parseContent(XmlLoader.getXml(e));
    }

    private function parseContent(content:Xml):Void
    {
        numXmlLoaded++;
        for(node in content.elements()){

            if(node.exists("imagePath")){

                imagesUrls.push(node.get("imagePath"));
            }
            for(nd in node.elements()){
                if(nd.nodeName != "SubTexture"){
                    if(nd.exists("src")){
                        if(Std.string(nd.get("src")).indexOf(".xml") == -1){
                            if(Std.string(nd.get("src")).charAt(0) != "0")
                                imagesUrls.push(nd.get("src"));

                        }
                        else{
                            XmlLoader.load(nd.get("src"), function(e:Event)
                            {
                                parseXmlSpritesheet(XmlLoader.getXml(e));
                            }, parseXmlSpritesheet);
                        }

                    }
                    if(nd.exists("background")){
                        if(Std.string(nd.get("background")).indexOf(".") != -1){
                            if(Std.string(nd.get("background")).charAt(0) != "0")
                                imagesUrls.push(nd.get("background"));
                        }
                    }
                    if(nd.exists("buttonIcon") && nd.get("buttonIcon").indexOf(".") > 0){
                        imagesUrls.push(nd.get("buttonIcon"));
                    }

                }
                if(nd.nodeName == "Token"){
                    for(nI in nd.elements()){
                        if(Std.string(nI.get("src")).charAt(0) != "0")
                            imagesUrls.push(nI.get("src"));
                    }
                };
            }


        }

        if(numXmlLoaded == nbXml){
            refreshCache();
        }

    }

    private function parseXmlSpritesheet(xml:Xml):Void
    {
        var fast = new Fast(xml).node.TextureAtlas;
        imagesUrls.push(fast.att.imagePath);
        refreshCache();
    }

    private function refreshCache():Void
    {
        imagesUrls = removeDuplicates(imagesUrls);
        nbDatas += imagesUrls.length;

        while(imagesUrls.length > 0){
            var object = imagesUrls.pop();
            if(!cacheElementsDisplay.exists(object)){
                #if flash
                    var urlR = new URLRequest(object);
                    var mloader = new Loader();
                    mloader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteLoading);
                    mloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                    mloader.load(urlR);
                #else
                var elementDisplay = new Bitmap(Assets.getBitmapData(object));
                cacheElementsDisplay.set(object, elementDisplay);
                #end
            }
        }
    }

    private function onIOError(error:IOErrorEvent):Void
    {
        Lib.trace("[LoadData] File requested doesn't exist: " + error.toString().substr(error.toString().indexOf("/")));
    }

    private function onCompleteLoading(event:Event):Void
    {
        numDataLoaded++;
        var path = Std.string(event.currentTarget.url).split("/");

        // TODO repérer le Main.swf
        var rootIndex = -1;
        for(i in 0...path.length){
            if(path[i] == "bin")
                rootIndex = i;
        }
        path = path.slice(rootIndex + 1, path.length);
        var nameElementDisplay = path.join("/");
        cacheElementsDisplay.set(nameElementDisplay, event.currentTarget.content);

        if(nbDatas == numDataLoaded){
            dispatchEvent(new Event("DATA_LOADED", true));
        }
    }
}

/**
 * Loader of spritesheets form XML
 */
class SpriteSheetLoader extends EventDispatcher {
    public var name:String;
    public var spritesheet:TilesheetEx;

    public function new()
    {
        super();
    }

    public function init(pName:String, src:String)
    {
        name = pName;

        XmlLoader.load(src, onXmlSpriteSheetLoaded, parseXmlSprite);
    }

    private function onXmlSpriteSheetLoaded(e:Event):Void
    {
        parseXmlSprite(XmlLoader.getXml(e));
    }

    private function parseXmlSprite(xmlSprite:Xml):Void
    {
        var fast = new Fast(xmlSprite).node.TextureAtlas;
        var elementDisplay = LoadData.instance.getElementDisplayInCache(fast.att.imagePath);
        spritesheet = new SparrowTilesheet(cast(elementDisplay, Bitmap).bitmapData, xmlSprite.toString());
        dispatchEvent(new Event(Event.COMPLETE));
    }
}
