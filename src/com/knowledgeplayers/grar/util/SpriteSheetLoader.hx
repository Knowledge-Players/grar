package com.knowledgeplayers.grar.util;
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

    public function new() {
        super();
    }
    public function init (pName:String, src:String) {
        Lib.trace(src);
        name = pName;
        XmlLoader.load(src, onXmlSpriteSheetLoaded, parseXmlSprite);
    }

    private function onXmlSpriteSheetLoaded (e:Event):Void
    {
        parseXmlSprite(XmlLoader.getXml(e));
    }

    private function parseXmlSprite (xmlSprite:Xml): Void
    {
        var fast = new Fast(xmlSprite).node.TextureAtlas;
        spriteSheet =  new SparrowTilesheet( cast(LoadData.getInstance().getElementDisplayInCache(fast.att.imagePath),Bitmap).bitmapData, xmlSprite.toString());
        dispatchEvent(new Event("loaded"));
    }

}
