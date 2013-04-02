package com.knowledgeplayers.grar.util;

import nme.Assets;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.events.IOErrorEvent;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;

/**
 * Utility class for XML loading
 */
class XmlLoader extends EventDispatcher {

    #if flash
    private static var cache: Hash<String> = new Hash<String>();
    #end

    /**
     * Load an XML file
     * @param	path : path to the file
     * @param	listener : Function to call when the file is loaded (flash only)
     * @return the content of the file (except in flash)
     */
    public static function load(path:String, ?listener:Event -> Void, ?parser:Xml -> Void):Void
    {
        #if flash
            if(!cache.exists(path)){
                var fileLoader: URLLoader = new URLLoader();
                fileLoader.dataFormat = URLLoaderDataFormat.TEXT;
                fileLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                fileLoader.addEventListener(Event.COMPLETE, function(e: Event){
                    cache.set(path, e.target.data);
                    listener(e);
                });
                fileLoader.load(new URLRequest(path));
            }
            else
                parser(Xml.parse(cache.get(path)));
		#else
            parser(Xml.parse(Assets.getText(path)));
        #end
    }

    /**
     * Extract an XML object from a Event.COMPLETE
     * @param	event : Event dispatched by an URLloader
     * @return the loaded XML
     */

    public static function getXml(event:Event):Xml
    {
        var loader:URLLoader = cast(event.currentTarget, URLLoader);
        return Xml.parse(loader.data);
    }

    // Handler

    private static function onIOError(error:IOErrorEvent):Void
    {
        cast(error.currentTarget, URLLoader).close();
        nme.Lib.trace("[XMLLoader] File requested doesn't exist: " + error.toString().substr(error.toString().indexOf("/")));
    }
}