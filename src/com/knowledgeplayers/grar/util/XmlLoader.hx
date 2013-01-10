package com.knowledgeplayers.grar.util;

import nme.Assets;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLLoaderDataFormat;
import nme.events.IOErrorEvent;
import nme.events.Event;
import nme.events.EventDispatcher;

class XmlLoader extends EventDispatcher
{
	public static function load(path: String, listener: Event -> Void) : Null<Xml>
	{
		#if flash
			var fileLoader: URLLoader = new URLLoader();
			fileLoader.dataFormat = URLLoaderDataFormat.TEXT;
			fileLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			fileLoader.addEventListener(Event.COMPLETE, listener);
			fileLoader.load(new URLRequest(path));
			return null;
		#else
			return Xml.parse(Assets.getText("xml/" + path));
		#end
	}
	
	public static function getXml(event: Event) : Xml 
	{
		var loader: URLLoader = cast(event.currentTarget, URLLoader);
		return Xml.parse(loader.data);
	}

	// Private 
	
	private function new()
	{
		super();
	}

	private static function onIOError(error: IOErrorEvent) : Void
	{
		cast(error.currentTarget, URLLoader).close();
		nme.Lib.trace("File requested doesn't exist: "+error.toString().substr(error.toString().indexOf("/")));
	}
}