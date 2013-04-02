package com.knowledgeplayers.grar.util;

import Math;
import Math;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Sprite;
import aze.display.TileSprite;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.util.LoadData;

/**
 * Utility class for display
 */
class DisplayUtils {
    private function new()
    {}

    /**
     * Get the pressed ID of a button
     * @param	buttonId : ID of the button
     * @return the pressed ID for this button
     */

    public static function getPressedId(buttonId:String):String
    {
        var strings:Array<String> = buttonId.split(".");
        return strings[0] + "_pressed." + strings[1];
    }

    /**
    * Set the background of a sprite
    * @param bkg : String with an Int representing the color of the background or an ID of the BitmapData
    * @param container : Sprite where the background will be set
    * @param width : Force width of the background. If 0, the width will be the width of the container
    * @param height : Force height of the background. If 0, the height will be the height of the container
    * @return the bitmap of the background if there was any
    **/

    public static function setBackground(bkg:String, container:Sprite, width:Float = 0, height:Float = 0):Null<Bitmap>
    {
        if(Std.parseInt(bkg) != null){
            initSprite(container, width, height, Std.parseInt(bkg));
            return null;
        }
        else{
            var bitmap = cast(LoadData.instance.getElementDisplayInCache(bkg), Bitmap);
            if(width != 0)
                bitmap.width = width;
            if(height != 0)
                bitmap.height = height;
            container.addChildAt(bitmap, 0);
            return bitmap;
        }
    }

    /**
    * Init a sprite with a rectangle
    * @param    sprite : Sprite to init
    * @param    width : Width of the rectangle
    * @param    height : Height of the rectangle
    * @color    color : Color of the rectangle
    **/

    public static function initSprite(sprite:Sprite, width:Float = 1, height:Float = 1, color:Int = 0):Void
    {
        sprite.graphics.beginFill(color);
        sprite.graphics.drawRect(0, 0, width, height);
        sprite.graphics.endFill();
    }

    /**
    * @param    layer : Layer with all tiles
    * @param    tileId : Id of the tile to get
    * @return the bitmapData in the given tile
**/

    public static function getBitmapDataFromLayer(layer:TileLayer, tileId:String):BitmapData
    {
        var tmpLayer = new TileLayer(layer.tilesheet);
        var tile = new TileSprite(tileId);
        tmpLayer.addChild(tile);
        tmpLayer.render();
        var bmpData = new BitmapData(Math.round(tile.width), Math.round(tile.height));
        var tmpSprite = new Sprite();
        tmpSprite.addChild(tmpLayer.view);
        tmpLayer.view.x = tile.width / 2;
        tmpLayer.view.y = tile.height / 2;
        bmpData.draw(tmpSprite);
        return bmpData;
    }
}