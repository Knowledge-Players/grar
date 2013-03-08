package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import nme.events.EventDispatcher;
import com.knowledgeplayers.grar.display.component.ScrollPanel;
import aze.display.TileSprite;
import aze.display.SparrowTilesheet;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.button.AnimationButton;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.component.ScrollBar;
import com.knowledgeplayers.grar.util.LoadData;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.events.Event;
import String;

/**
 * Factory to create UI components
 */

class UiFactory {

    /**
    * Tilesheet containing UI elements
    **/
    public static var tilesheet (default, null): TilesheetEx;

    private static var layerPath: String;

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

    public static function createButton(buttonType: String, ref: String, tile: String, x: Float = 0, y: Float = 0, scaleX: Float = 1, scaleY: Float = 1, ?action: String): DefaultButton
    {
        var creation: DefaultButton =
        switch(buttonType.toLowerCase()) {
            case "text": new TextButton(tilesheet, tile, action);
            case "event": new CustomEventButton(action, tilesheet, tile);
            case "anim": new AnimationButton(tilesheet, tile, action);
            default: new DefaultButton(tilesheet, tile);
        }
        creation.ref = ref;
        creation.x = x;
        creation.y = y;
        creation.scaleX = scaleX;
        creation.scaleY = scaleY;

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
        var x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
        var y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
        var scaleX = xml.has.scaleX ? Std.parseFloat(xml.att.scaleX) : 1;
        var scaleY = xml.has.scaleY ? Std.parseFloat(xml.att.scaleY) : 1;
        var action = xml.has.action ? xml.att.action : null;
        return createButton(xml.att.type, xml.att.ref, xml.att.id, x, y, scaleX, scaleY, action);
    }

    public static function createImageFromXml(xml: Fast): TileSprite
    {
        var image = new TileSprite(xml.att.id);
        image.x = Std.parseFloat(xml.att.x);
        image.y = Std.parseFloat(xml.att.y);
        image.scaleX = Std.parseFloat(xml.att.scaleX);
        image.scaleY = Std.parseFloat(xml.att.scaleY);
        return image;
    }

    public static function createTextFromXml(xml: Fast): ScrollPanel
    {
        var text = new ScrollPanel(Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height));
        text.x = Std.parseFloat(xml.att.x);
        text.y = Std.parseFloat(xml.att.y);
        text.content = KpTextDownParser.parse(xml.att.ref);

        if(xml.has.background)
            text.setBackground(xml.att.background);
        return text;
    }

    /**
     * Set the spritesheet file containing all the UI images
     * @param	pathToXml : path to the XML file
     */

    public static function setSpriteSheet(pathToXml: String): Void
    {
        layerPath = pathToXml.substr(0, pathToXml.indexOf("."));

        XmlLoader.load(layerPath + ".xml", onXmlLoaded, parseContent);
    }

    private static function parseContent(content: Xml): Void
    {
        onXmlLoaded();
    }

    public static function onXmlLoaded(e: Event = null): Void
    {
        tilesheet = new SparrowTilesheet(cast(LoadData.getInstance().getElementDisplayInCache(layerPath + ".png"), Bitmap).bitmapData, XmlLoader.getXml(e).toString());

    }



}