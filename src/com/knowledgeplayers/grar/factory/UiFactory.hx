package com.knowledgeplayers.grar.factory;

import nme.Assets;
import com.knowledgeplayers.grar.display.GameManager;
import nme.filters.DropShadowFilter;
import nme.Lib;
import nme.filters.BitmapFilter;
import nme.geom.Point;
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
import com.knowledgeplayers.grar.display.component.button.MenuButton;
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
    public static var tilesheet (default, null):TilesheetEx;

    private static var layerPath:String;

    private function new()
    {}

    /**
     * Create a button
     * @param	buttonType : Type of the button
     * @param	tile : Tile containing the button icon
     * @param	action : Event to dispatch when the button is clicked. No effects for DefaultButton type
     * @return the created button
     */

    public static function createButton(buttonType:String, ref:String, tile:String, ?tileDown:String, ?tileOver:String, x:Float = 0, y:Float = 0, scale:Float = 1, ?icon:String, iconX:Float = 0, iconY:Float = 0, ?action:String, ?iconStatus:String, ?mirror:String, ?style:String):DefaultButton
    {
        var creation:DefaultButton =
        switch(buttonType.toLowerCase()) {
            case "text": new TextButton(tilesheet, tile, action, style);
            case "event": new CustomEventButton(tilesheet, tile, action);
            case "anim": new AnimationButton(tilesheet, tile, action);
            case "menu": new MenuButton(tilesheet, tile, action, iconStatus);
            default: new DefaultButton(tilesheet, tile);
        }
        creation.ref = ref;
        creation.x = x;
        creation.y = y;
        creation.scale = scale;
        if(mirror == "horizontal")
            creation.mirror = 1;
        if(mirror == "vertical")
            creation.mirror = 2;
        if(tileDown != null)
            creation.setStateIcon(ButtonState.DOWN, tileDown);
        if(tileOver != null)
            creation.setStateIcon(ButtonState.OVER, tileOver);
        if(icon != null)
            creation.setIcon(new TileSprite(icon), new Point(iconX, iconY));

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

    public static function createScrollBar(width:Float, height:Float, ratio:Float, tileBackground:String, tileCursor:String):ScrollBar
    {
        return new ScrollBar(width, height, ratio, tilesheet, tileBackground, tileCursor);
    }

    /**
     * Create a button from XML infos
     * @param	xml : fast xml node with infos
     * @return the button
     */

    public static function createButtonFromXml(xml:Fast):DefaultButton
    {

        var x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
        var y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
        var scale = xml.has.scale ? Std.parseFloat(xml.att.scale) : 1;
        var action = xml.has.action ? xml.att.action : null;
        var icon = xml.has.icon ? xml.att.icon : null;
        var iconX = xml.has.iconX ? Std.parseFloat(xml.att.iconX) : 0;
        var iconY = xml.has.iconY ? Std.parseFloat(xml.att.iconY) : 0;
        var iconStatus = xml.has.status ? xml.att.status : null;
        var idOver = xml.has.idOver ? xml.att.idOver : null;
        var idDown = xml.has.idDown ? xml.att.idDown : null;
        var mirror = xml.has.mirror ? xml.att.mirror : null;
        var style = xml.has.style ? xml.att.style : null;

        return createButton(xml.att.type, xml.att.ref, xml.att.id, idDown, idOver, x, y, scale, icon, iconX, iconY, action, iconStatus, mirror, style);
    }

    /**
    * Create a tilesprite from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a tilesprite
    **/

    public static function createImageFromXml(xml:Fast):TileSprite
    {
        var image = new TileSprite(xml.att.id);
        image.x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
        image.y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;
        image.scaleX = xml.has.scaleX ? Std.parseFloat(xml.att.scaleX) : 1;
        image.scaleY = xml.has.scaleY ? Std.parseFloat(xml.att.scaleY) : 1;

        return image;
    }

    /**
    * Create a textfield from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a textfield
    **/

    public static function createTextFromXml(xml:Fast):ScrollPanel
    {
        var text = new ScrollPanel(Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height));
        text.x = xml.has.x ? Std.parseFloat(xml.att.x) : 0;
        text.y = xml.has.y ? Std.parseFloat(xml.att.y) : 0;

        if(xml.has.background)
            text.setBackground(xml.att.background);
        return text;
    }

    /**
    * Create a bitmap filter from an XML descriptor
    * @param    xml : Fast descriptor
    * @return a bitmap filter
    **/
    //TODO FILTERMANAGER

    public static function createFilterFromXml(xml:Fast):BitmapFilter
    {
        var filterNode = Std.string(xml.att.filter).split(":");

        var filter:BitmapFilter =
        switch(Std.string(filterNode[0]).toLowerCase()){
            case "dropshadow":
                var params = Std.string(filterNode[1]).split(",");
                new DropShadowFilter(Std.parseFloat(params[0]), Std.parseFloat(params[1]), Std.parseInt(params[2]), Std.parseFloat(params[3]), Std.parseFloat(params[4]), Std.parseFloat(params[5]));

        }

        return filter;
    }

    /**
     * Set the spritesheet file containing all the UI images
     * @param	pathToXml : path to the XML file
     */

    public static function setSpriteSheet(pathToXml:String):Void
    {
        layerPath = pathToXml.substr(0, pathToXml.indexOf("."));

        //XmlLoader.load(layerPath + ".xml", onXmlLoaded, parseContent);
        #if flash
            LoadData.instance.loadSpritesheet("ui", layerPath + ".xml", onXmlLoaded);

        #else
        onXmlLoaded();
        #end

    }

    private static function onXmlLoaded(e:Event = null):Void
    {

        #if flash
        tilesheet = e.target.spritesheet;
        #else
        tilesheet = new SparrowTilesheet(Assets.getBitmapData(layerPath + ".png"), Assets.getText(layerPath + ".xml"));
        #end
        GameManager.instance.game.uiLoaded = true;
    }

}