package com.knowledgeplayers.grar.util;

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
    private var arrayOfUrlImgs:Array<String>;
    private var elementBitmap:Bitmap;
    private var mloader:Loader;
    private var z:Float;
    private var nameElementDisplay:String;
    private var eventCaller:String;
    private var numData:Float = 0;
    private var nbDatas:Float = 0;
    private var nbXml:Float = 0;
    private var numXml:Float = 0;

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

        var arrayDisplayXml:Array<String> = new Array<String>();

        parseChildrenXml(structureXml, arrayDisplayXml, "display");

        arrayDisplayXml = removeDuplicates(arrayDisplayXml);

        var lgArray:Int = arrayDisplayXml.length;
        nbXml = lgArray;

        for(i in 0...lgArray){
            XmlLoader.load(arrayDisplayXml[i], onXmlDisplayLoaded, parseContent);
        }

    }

    /**
    * Get the display loaded
    * @param    name : Name of the wanted element
    * @return the element or null if it doesn't exist
    **/

    public function getElementDisplayInCache(_name:String):Null<DisplayObject>
    {
        var element:DisplayObject = null;
        for(_key in cacheElementsDisplay.keys()){
            if(_key == _name){
                element = cacheElementsDisplay.get(_key);
            }
        }

        return element;
    }

    // Privates

    private function new()
    {

        super();
        cacheElementsDisplay = new Hash<DisplayObject>();

        arrayOfUrlImgs = new Array<String>();
    }

    /**
    * Parse all the nodes of Xml and get the attribute needed
    * @param    xml : Xml node @:autoBuild parse
    * @param    array : Array where to store the results
    * @param    att : Attribut to find
    **/

    private function parseChildrenXml(_xml:Xml, _array:Array<String>, _att:String):Void
    {

        for(elt in _xml.elements()){
            for(user in _xml.elementsNamed(elt.nodeName)){

                if(user.get(_att) != null)
                    _array.push(user.get(_att));

                if(user.firstChild() != null)
                    parseChildrenXml(user, _array, _att);

            }
        }

    }

    /**
    * Remove duplicates from an Array<String>
    * @param    ar : The array to clean
    * @return the array without duplicates
    **/

    private function removeDuplicates(ar:Array<String>):Array<String>
    {
        var result:Array<String> = ar.slice(0, ar.length);
        var t;

        for(a1 in 0...result.length){
            t = ar[a1];

            for(a2 in 0...result.length){
                if(result[a2] == result[a1]){
                    if(a2 != a1){
                        result.splice(a2, 1);
                    }
                }
            }
        }
        return result;
    }

    private function onXmlDisplayLoaded(e:Event = null):Void
    {
        var xmlSprite = XmlLoader.getXml(e);
        parseContent(xmlSprite);
    }

    private function parseContent(content:Xml):Void
    {
        numXml++;
        for(node in content.elements()){

            if(node.exists("imagePath")){

                arrayOfUrlImgs.push(node.get("imagePath"));
            }
            for(nd in node.elements()){
                if(nd.nodeName != "SubTexture"){
                    if(nd.exists("src")){
                        if(Std.string(nd.get("src")).indexOf(".xml") == -1){
                            if(Std.string(nd.get("src")).charAt(0) != "0")
                                arrayOfUrlImgs.push(nd.get("src"));
                        }

                    }
                    if(nd.exists("background")){
                        if(Std.string(nd.get("background")).indexOf(".") != -1){
                            if(Std.string(nd.get("background")).charAt(0) != "0")
                                arrayOfUrlImgs.push(nd.get("background"));
                        }
                    }
                    if(nd.exists("buttonIcon") && nd.get("buttonIcon").indexOf(".") > 0){
                        arrayOfUrlImgs.push(nd.get("buttonIcon"));
                    }
                }
            }

        }

        if(numXml == nbXml){
            arrayOfUrlImgs = removeDuplicates(arrayOfUrlImgs);
            var lgImgsArray:Int = arrayOfUrlImgs.length;
            nbDatas = lgImgsArray;

            for(i in 0...lgImgsArray){
                loadData(arrayOfUrlImgs[i]);
            }
        }

    }

    private function loadData(?path:String = ""):Void
    {

        if(!checkElementsDisplayInCache(path)){
            #if flash
                var urlR = new URLRequest(path);
                var mloader = new Loader();
                mloader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteLoading);
                mloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                mloader.load(urlR);
            #else
            var elementDisplay = new Bitmap(Assets.getBitmapData(path));
            cacheElementsDisplay.set(path, elementDisplay);
            #end
        }

    }

    private function onIOError(error:IOErrorEvent):Void
    {
        Lib.trace("File requested doesn't exist: " + error.toString().substr(error.toString().indexOf("/")));
    }

    private function onCompleteLoading(event:Event):Void
    {
        numData++;
        var arrayName = Std.string(event.currentTarget.url).split("/");

        nameElementDisplay = arrayName[arrayName.length - 2] + "/" + arrayName[arrayName.length - 1];
        cacheElementsDisplay.set(nameElementDisplay, event.currentTarget.content);

        if(nbDatas == numData){
            dispatchEvent(new Event("DATA_LOADED", true));
        }
    }

    private function checkElementsDisplayInCache(_name:String):Bool
    {
        var existInCache = false;

        for(key in cacheElementsDisplay.keys()){
            if(key == _name){
                existInCache = true;
            }
        }

        return existInCache;
    }
}
