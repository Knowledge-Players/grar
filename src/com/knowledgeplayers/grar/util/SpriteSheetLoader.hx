package com.knowledgeplayers.grar.util;

import nme.net.URLRequest;
import nme.display.Loader;
import nme.events.IOErrorEvent;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.events.Event;
import aze.display.TilesheetEx;
import haxe.xml.Fast;
import aze.display.SparrowTilesheet;
import nme.events.EventDispatcher;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.Assets;
import nme.Lib;

class SpriteSheetLoader extends EventDispatcher {
    public var name: String;
    public var spriteSheet: TilesheetEx;
    private var elementDisplay: DisplayObject;
    private var xmlSprite: Xml;

    public function new()
    {
        super();
    }

    public function init(pName: String, src: String)
    {
        name = pName;

        XmlLoader.load(src, onXmlSpriteSheetLoaded, parseXmlSprite);
    }

    private function onXmlSpriteSheetLoaded(e: Event): Void
    {
        parseXmlSprite(XmlLoader.getXml(e));
    }

    private function parseXmlSprite(xmlSprite: Xml): Void
    {
        this.xmlSprite = xmlSprite;
        var fast = new Fast(xmlSprite).node.TextureAtlas;
        loadData(fast.att.imagePath);
    }

    private function loadData(?path: String = ""): Void
    {
        #if flash
                    var urlR = new URLRequest("assets/"+path);


                    var mloader = new Loader();
                    mloader.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteLoading);
                    mloader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
                    mloader.load(urlR);


                #else

        elementDisplay = new Bitmap(Assets.getBitmapData(path));
        spriteSheet = new SparrowTilesheet(cast(elementDisplay, Bitmap).bitmapData, xmlSprite.toString());
        dispatchEvent(new Event(Event.COMPLETE));

        #end

    }

    private function onIOError(error: IOErrorEvent): Void
    {
        Lib.trace("[SpriteSheetLoader] File requested doesn't exist: " + error.toString().substr(error.toString().indexOf("/")));
    }

    private function onCompleteLoading(event: Event): Void
    {

        elementDisplay = event.currentTarget.content;
        spriteSheet = new SparrowTilesheet(cast(elementDisplay, Bitmap).bitmapData, xmlSprite.toString());
        dispatchEvent(new Event(Event.COMPLETE));

    }

}
