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
    public static var instance (getInstance, null): LoadData;

    private var cacheElementsDisplay:Hash<DisplayObject>;
    private var arrayOfUrlImgs:Array<String>;
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

/**
* Load all the displays of sample_structure.xml
**/

    public function loadDisplayXml(?structureXml:Xml=null):Void
    {


        var arrayDisplayXml:Array<String> = new Array<String>();


        parseChildrenXml(structureXml,arrayDisplayXml,"display");

        arrayDisplayXml = removeDuplicates(arrayDisplayXml);

        var lgArray:Int = arrayDisplayXml.length;
        nbXml = lgArray;


        for( i in 0...lgArray ) {
            //Lib.trace("xml load : "+arrayDisplayXml[i]);

            XmlLoader.load(arrayDisplayXml[i],onXmlDisplayLoaded,parseContent);
        }



    }

/**
* Parse all the nodes of Xml and get the attribute needed
**/

    public function parseChildrenXml(_xml:Xml,_array:Array<String>,_att:String):Void{


        for( elt in _xml.elements() ) {
            for( user in _xml.elementsNamed(elt.nodeName) ) {

                if(user.get(_att) !=null)
                    _array.push(user.get(_att));

                if(user.firstChild() != null)
                    parseChildrenXml(user,_array,_att);


            }
        }

    }
/**
* Remove duplicates from an Array<String>
**/

    public function removeDuplicates(ar:Array<String>):Array<String>
    {
        var result:Array<String> = ar.slice(0,ar.length);


        var t;

        for (a1 in 0...result.length)
        {
            t = ar[a1];

            for (a2 in 0...result.length)
            {
                if (result[a2] == result[a1])
                {
                    if (a2 != a1)
                    {
                        result.splice(a2, 1);
                    }
                }
            }
        }
        return result;
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
                           if(Std.string(nd.get("src")).indexOf(".xml")==-1)
                           {
                               if (Std.string(nd.get("src")).charAt(0) !="0")
                                   arrayOfUrlImgs.push(nd.get("src"));
                           }

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
            arrayOfUrlImgs = removeDuplicates(arrayOfUrlImgs);
            var lgImgsArray:Int = arrayOfUrlImgs.length;
            nbDatas =lgImgsArray;

            for( i in 0...lgImgsArray ) {

               // Lib.trace("-------------- image load "+arrayOfUrlImgs[i]);

                loadData(arrayOfUrlImgs[i]);

            }
        }


    }


    private function loadData(?path:String=""):Void
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

                    var elementDisplay = new Bitmap(Assets.getBitmapData(path));
                    cacheElementsDisplay.set(path,elementDisplay);


                #end
            }

    }



    private function onIOError(error: IOErrorEvent): Void
    {
        Lib.trace("File requested doesn't exist: " + error.toString().substr(error.toString().indexOf("/")));
    }

    private function onCompleteLoading(event: Event): Void
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

    private function checkElementsDisplayInCache(_name:String):Bool
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

/**
* Get the display loaded
**/

    public function getElementDisplayInCache(_name:String):DisplayObject
    {
        var element: DisplayObject = null;
        //Lib.trace("_name = "+_name);
        for (_key in cacheElementsDisplay.keys())
        {
           // Lib.trace("getElementDisplayInCache_key = "+_key);

            if(_key == _name)
            {

               // Lib.trace("_key = "+_key);


                 element = cacheElementsDisplay.get(_key);

            }
        }

        return element;
    }



}
