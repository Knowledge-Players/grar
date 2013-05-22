package com.knowledgeplayers.grar.util;

import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;

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

	public static function setBackground(bkg:String, container:Sprite, ?width:Float, ?height:Float, alpha:Float = 1, x:Float = 0, y:Float = 0):Null<Bitmap>
	{

		if(Std.parseInt(bkg) != null){
			initSprite(container, width, height, Std.parseInt(bkg), alpha, x, y);
			return null;
		}
		else{
			var bitmap = new Bitmap(AssetsStorage.getBitmapData(bkg));
			bitmap.x = x;
			bitmap.y = y;
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
    * @param    color : Color of the rectangle
    * @param    alpha : Alpha of the color
    **/

	public static function initSprite(sprite:Sprite, width:Float = 1, height:Float = 1, color:Int = 0, alpha:Float = 1, x:Float = 0, y:Float = 0):Void
	{
		sprite.graphics.beginFill(color, alpha);
		sprite.graphics.drawRect(x, y, width, height);
		sprite.graphics.endFill();
	}

	/**
    * @param    layer : Layer with all tiles
    * @param    tileId : Id of the tile to get
    * @return the bitmapData in the given tile
    **/

	public static function getBitmapDataFromLayer(tilesheet:TilesheetEx, tileId:String):BitmapData
	{
		var tmpLayer = new TileLayer(tilesheet);
		var tile = new TileSprite(tmpLayer, tileId);
		tmpLayer.addChild(tile);
		tmpLayer.render();
		var bmpData = new BitmapData(Math.round(tile.width), Math.round(tile.height), true, 0);
		var tmpSprite = new Sprite();
		tmpSprite.addChild(tmpLayer.view);
		tmpLayer.view.x = tile.width / 2;
		tmpLayer.view.y = tile.height / 2;
		bmpData.draw(tmpSprite);
		return bmpData;
	}
}