package com.knowledgeplayers.grar.util;

import aze.display.SparrowTilesheet;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
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
 * Loader of spritesheets form XML
 */
class SpriteSheetLoader extends EventDispatcher {
    public var name:String;
    public var spriteSheet:TilesheetEx;

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
        spriteSheet = new SparrowTilesheet(cast(elementDisplay, Bitmap).bitmapData, xmlSprite.toString());
        dispatchEvent(new Event(Event.COMPLETE));
    }
}
