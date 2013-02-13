package com.knowledgeplayers.grar.factory;

import nme.display.Bitmap;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.events.Event;
import com.knowledgeplayers.grar.util.LoadData;
import aze.display.SparrowTilesheet;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.button.AnimationButton;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.component.ScrollBar;
import haxe.xml.Fast;
import nme.Assets;
import nme.Lib;

/**
 * Factory to create UI components
 */

class UiFactory {
    private static var tilesheet: TilesheetEx;
    private static var layerPath:String;

    private function new()
    {

    }

    /**
     * Create a button
     * @param	buttonType : Type of the button
     * @param	tile : Tile containing the button icon
     * @param	action : Event to dispatch when the button is clicked. No effects for DefaultButton type
     * @return the created button
     */

    public static function createButton(buttonType: String, tile: String, ?action: String): DefaultButton
    {
        var creation: DefaultButton = null;
        switch(buttonType.toLowerCase()) {
            case "text": creation = new TextButton(tilesheet, tile, action);
            case "event": creation = new CustomEventButton(action, tilesheet, tile);
            case "anim": creation = new AnimationButton(tilesheet, tile, action);
            default: creation = new DefaultButton(tilesheet, tile);
        }

        return creation;
    }

    /**
     * Create a scrollbar
     * @param	width : Width of the scrollbar
     * @param	height : Height of the scrollbar
     * @param	ratio : Ratio of the cursor
     * @param	tileBackground : Tile containing background image
     * @param	tileCursor : Tile containing cursor image
     * @return the fresh new scrollbar
     */

    public static function createScrollBar(width: Float, height: Float, ratio: Float, tileBackground: String, tileCursor: String): ScrollBar
    {
        return new ScrollBar(width, height, ratio, tilesheet, tileBackground, tileCursor);
    }

    /**
     * Create a button from XML infos
     * @param	xml : fast xml node with infos
     * @return the button
     */

    public static function createButtonFromXml(xml: Fast): DefaultButton
    {
        return createButton(xml.att.type, xml.att.id, (xml.has.action ? xml.att.action : null));
    }

    /**
     * Set the spritesheet file containing all the UI images
     * @param	pathToXml : path to the XML file
     */

    public static function setSpriteSheet(pathToXml: String): Void
    {
        layerPath = pathToXml.substr(0, pathToXml.indexOf("."));

        XmlLoader.load(layerPath+".xml",onXmlLoaded,parseContent);
    }


    private static function parseContent(content: Xml): Void
    {
        onXmlLoaded();
    }


    public static function onXmlLoaded(e:Event=null):Void{

        Lib.trace("---------- on xml loaded : "+LoadData.getInstance().getElementDisplayInCache(layerPath+".png"));
        tilesheet = new SparrowTilesheet(cast(LoadData.getInstance().getElementDisplayInCache(layerPath+".png"),Bitmap).bitmapData, XmlLoader.getXml(e).toString());

    }
}