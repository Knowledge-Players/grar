package com.knowledgeplayers.grar.util;

import Std;
import haxe.xml.Fast;
import Std;
import nme.display.Loader;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.net.URLRequest;
import nme.display.Loader;
import nme.net.URLLoader;
import nme.events.IOErrorEvent;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.Lib;


class LoadData extends EventDispatcher {


    public static var instance (getInstance, null): LoadData;
    public var cacheElementsDisplay:Hash<DisplayObject>;
    private var elementDisplay:DisplayObject;
    public var arrayOfUrlImgs:Array<String>;

    private var elementBitmap:Bitmap;
    private var mloader:Loader;
    private var z:Float;
    private var nameElementDisplay:String;
    private var eventCaller:String;
    private var numData:Float=0;
    private var nbDatas:Float=0;
    private var nbXml:Float=0;
    private var numXml:Float=0;

    public function new() {

        super();
        cacheElementsDisplay = new Hash<DisplayObject>();

        arrayOfUrlImgs = new Array<String>();
    }

/**
 * @return the instance of the loaderdatas
 */

    public static function getInstance(): LoadData
    {
        if(instance == null)
            return instance = new LoadData();
        else
            return instance;
    }


    public function loadDisplayXml(?structureXml:Fast=null):Void
    {
        var arrayDisplayXml:Array<String> = new Array<String>();

        var displayNode: Fast = structureXml.node.Grar.node.Display;
        var structureNode: Fast = structureXml.node.Grar.node.Structure;


        for(part in structureNode.nodes.Part){
            if (part.has.display)arrayDisplayXml.push(part.att.display);
            }
        for(node in displayNode.elements){
            if (node.has.display)arrayDisplayXml.push(node.att.display);
            }


        var lgArray:Int = arrayDisplayXml.length;
        nbXml = lgArray;
        for( i in 0...lgArray ) {
            Lib.trace("xml load : "+arrayDisplayXml[i]);
        //if (arrayDisplayXml[i] != "ui/ui.xml")
            XmlLoader.load(arrayDisplayXml[i],onXmlDisplayLoaded,parseContent);

        }


    }

    private function onXmlDisplayLoaded(e:Event=null):Void{

        var xmlSprite = XmlLoader.getXml(e);
        parseContent(xmlSprite);

    }

    private function parseContent(content: Xml): Void
    {
       numXml++;
       for (node in content.elements())
       {

           if (node.exists("imagePath"))
           {

               arrayOfUrlImgs.push("ui/"+node.get("imagePath"));
           }
               for (nd in node.elements())
               {
                   if(nd.nodeName != "SubTexture" )
                   {
                       if (nd.exists("src"))
                       {
                           if (Std.string(nd.get("src")).charAt(0) !="0")
                               arrayOfUrlImgs.push(nd.get("src"));
                       }
                       if (nd.exists("background"))
                       {
                           if (Std.string(nd.get("background")).charAt(0) !="0")
                               arrayOfUrlImgs.push(nd.get("background"));
                       }
                       if (nd.exists("buttonIcon"))
                       {
                           arrayOfUrlImgs.push(nd.get("buttonIcon"));
                       }
                   }


           }



       }
        //Lib.trace(numXml +" -- "+nbXml);
        if(numXml == nbXml)
        {

            var lgImgsArray:Int = arrayOfUrlImgs.length;
            nbDatas =lgImgsArray;

            for( i in 0...lgImgsArray ) {

                Lib.trace("-------------- image load "+arrayOfUrlImgs[i]);

                loadData(arrayOfUrlImgs[i]);

            }
        }


    }


    public function loadData(?path:String=""):Void
    {


            if (!checkElementsDisplayInCache(path))
            {
                #if flash

                    var urlR = new URLRequest("assets/"+path);
                    //Lib.trace("------------- urlR : "+urlR.url);

                    var mloader = new Loader();
                    mloader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteLoading);
                    mloader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                    mloader.load(urlR);


                #else

                    elementDisplay = new Bitmap(Assets.getBitmapData(path));
                    cacheElementsDisplay.set(path,elementDisplay);


                #end
            }

    }



    public function onIOError(error: IOErrorEvent): Void
    {
        Lib.trace("File requested doesn't exist: " + error.toString().substr(error.toString().indexOf("/")));
    }

    public function onCompleteLoading(event: Event): Void
    {
        numData++;
        var arrayName = Std.string(event.currentTarget.url).split("/");

        nameElementDisplay =  arrayName[arrayName.length-2]+"/"+arrayName[arrayName.length-1];
        //Lib.trace("nameElementDisplay = "+nameElementDisplay);
        //Lib.trace(numData+"-- "+nbDatas);
        cacheElementsDisplay.set(nameElementDisplay,event.currentTarget.content);

        if (nbDatas ==numData)
            {
                dispatchEvent(new Event("DATA_LOADED",true));
            }
    }

    public function checkElementsDisplayInCache(_name:String):Bool
    {
        var existInCache = false;

        for (key in cacheElementsDisplay.keys())
        {


            if(key == _name)
            {
            //Lib.trace("_name : " + _name);
            //Lib.trace("elemt : " + key);
            existInCache = true;
            //Lib.trace("existInCache : " + existInCache);
            }

        }

        return existInCache;
    }

    public function getElementDisplayInCache(_name:String):DisplayObject
    {
        var element: DisplayObject = null;

        for (_key in cacheElementsDisplay.keys())
        {
           // Lib.trace("getElementDisplayInCache_key = "+_key);

            if(_key == _name)
            {

                //Lib.trace("_name = "+_name);

                 element = cacheElementsDisplay.get(_key);

            }
        }

        return element;
    }



}
