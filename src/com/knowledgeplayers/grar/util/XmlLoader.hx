package com.knowledgeplayers.grar.util;

import nme.Assets;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLLoaderDataFormat;
import nme.events.IOErrorEvent;
import nme.events.Event;
import nme.events.EventDispatcher;

/**
 * Utility class for XML loading
 */
class XmlLoader extends EventDispatcher {
    /**
     * Load an XML file
     * @param	path : path to the file
     * @param	listener : Function to call when the file is loaded (flash only)
     * @return the content of the file (except in flash)
     */
    public static function load(path: String, ?listener: Event -> Void, ?parser: Xml -> Void): Void
    {
        #if flash
			var fileLoader: URLLoader = new URLLoader();
			fileLoader.dataFormat = URLLoaderDataFormat.TEXT;
			fileLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			fileLoader.addEventListener(Event.COMPLETE, listener);
			fileLoader.load(new URLRequest(path));
		#else
        parser(Xml.parse(Assets.getText("xml/" + path)));
        #end
    }

    /**
     * Extract an XML object from a Event.COMPLETE
     * @param	event : Event dispatched by an URLloader
     * @return the loaded XML
     */

    public static function getXml(event: Event): Xml
    {
        var loader: URLLoader = cast(event.currentTarget, URLLoader);
        return Xml.parse(loader.data);
    }

    // Private

    private function new()
    {
        super();
    }

    private static function onIOError(error: IOErrorEvent): Void
    {
        cast(error.currentTarget, URLLoader).close();
        nme.Lib.trace("File requested doesn't exist: " + error.toString().substr(error.toString().indexOf("/")));
    }
}