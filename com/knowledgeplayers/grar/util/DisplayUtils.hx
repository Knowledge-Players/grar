package com.knowledgeplayers.grar.util;

import Array;
import flash.geom.Matrix;
import flash.display.GradientType;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

/**
 * Utility class for display
 */
class DisplayUtils {

	public static var templates: Map<String, Xml> = new Map<String, Xml>();

	private function new()
	{}

	/**
    * Set the background of a sprite
    * @param bkg : String with an Int representing the color of the background or an ID of the BitmapData
    * @param container : Sprite where the background will be set
    * @param width : Force width of the background. If 0, the width will be the width of the container
    * @param height : Force height of the background. If 0, the height will be the height of the container
    * @return the bitmap of the background if there was any
    **/

	public static function setBackground(bkg:String, container:Sprite, width:Float = 0, height:Float = 0, alpha:Float = 1, x:Float = 0, y:Float = 0):Null<Bitmap>
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
    * @param    x : x of the top left corner
    * @param    y : y of the top left corner
    **/
	public static inline function initSprite(?sprite:Sprite, width:Float = 1, height:Float = 1, color:Int = 0, alpha:Float = 1, x:Float = 0, y:Float = 0,radius:Float=0):Sprite
	{
		var s: Sprite = sprite != null ? sprite : new Sprite();
		s.graphics.beginFill(color, alpha);
        s.graphics.drawRoundRect(x, y, width, height,radius,radius);
		s.graphics.endFill();
		return s;
	}

	/**
    * Init a sprite with a vertical top to bottom gradient filled rectangle
    * @param    sprite : Sprite to init
    * @param    width : Width of the rectangle
    * @param    height : Height of the rectangle
    * @param    colors : Colors of the gradient.
    * @param    alphas : Alpha of the gradient.
    * @param    x : x of the top left corner
    * @param    y : y of the top left corner
    **/
	// TODO merge with initSprite
	public static function initGradientSprite(?sprite: Sprite, width: Float = 1, height: Float = 1, colors: Array<Int>, alphas: Array<Float>, x: Float = 0, y: Float = 0,radius:Float=0): Sprite
	{
		if(colors.length == 1)
			return initSprite(sprite, width, height, colors[0], alphas[0], x, y);
		else{
			var s: Sprite = sprite != null ? sprite : new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, Math.PI/2, 0, 0);
			s.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, [0x00, 0xFF], matrix);
            s.graphics.drawRoundRect(x, y, width, height,radius,radius);
			s.graphics.endFill();
			return s;
		}
	}

	/**
	* Mask the given sprite with the rectangle specified
	* @param    sprite : Sprite to mask
	* @param    maskWidth : Width of the mask
	* @param    maskHeight : Height of the mask
	* @param    maskX : x of the top left corner of the mask
	* @param    maskY : y of the top left corner of the mask
	**/
	public static inline function maskSprite(sprite: Sprite, maskWidth: Float = 1, maskHeight: Float = 1, maskX: Float = 0, maskY: Float = 0):Void
	{
		if(maskWidth > 0 && maskHeight > 0){
			var mask = new Sprite();
			initSprite(mask, maskWidth, maskHeight, 0, 1, maskX == 0 ? sprite.x : maskX, maskY == 0 ? sprite.y : maskY);
			if(sprite.parent != null){
				if(sprite.mask != null && sprite.parent.contains(sprite.mask))
					sprite.parent.removeChild(sprite.mask);
				sprite.parent.addChild(mask);
			}
			sprite.mask = mask;
		}
	}

	public static inline function drawElipse(?sprite:Sprite, colors:Array<Int>, ?alphas:Array<Float>, radius: Array<Float>, x: Float = 0, y: Float = 0):Sprite
	{
		var s: Sprite;
		if(sprite == null)
			s = new Sprite();
		else
			s = sprite;

		if(colors.length > 1){
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(radius[0], radius[0], Math.PI/2, 0, 0);
			s.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, [0x00, 0xFF], matrix);
		}
		else
			s.graphics.beginFill(colors[0], alphas[0]);

		if(radius.length == 1){
			s.graphics.drawCircle(x, y, radius[0]);
		}
		else{
			s.graphics.drawEllipse(x, y, radius[0], radius[1]);
		}
		s.graphics.endFill();

		return s;
	}

	/**
    * @param    tilesheet : Tilesheet with all tiles
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

	/**
	* Load the templates files. Update templates hash accordingly
	* @param    templateList : List of the template to add
	**/
	public static function loadTemplates(templatesList:List<Xml>):Void
	{
		for(temp in templatesList)
			templates.set(temp.firstElement().get("ref"), temp);
	}
}