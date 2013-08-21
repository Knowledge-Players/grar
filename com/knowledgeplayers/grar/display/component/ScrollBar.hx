package com.knowledgeplayers.grar.display.component;

import nme.ui.Mouse;
import nme.geom.ColorTransform;
import nme.display.Bitmap;
import nme.display.BitmapData;
import com.knowledgeplayers.grar.util.DisplayUtils;
import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Rectangle;

/**
 * Scrollbar for text overflow
 */

class ScrollBar extends Sprite
{
	public var ratio(default, set_ratio):Float;

	private var cursorSprite:Sprite;
	private var bgSprite: Sprite;
	private var page:Float;
	private var maxHeight:Float;

	/**
	 * Constructor
	 * @param	width : Width of the scrollbar
	 * @param	height : Height of the scrollbar
	 * @param	ratio : Ratio of the cursor
	 * @param	tileBackground : Tile containing background image
	 * @param	tileCursor : Tile containing cursor image
	 *
	 * @see UiFactory
	 */

	public function new(width:Float, tilesheet:TilesheetEx, tile:String, ?bgTile: String, scale9Grid: Rectangle, ?bgScale9Grid: Rectangle, ?cursorColor: String, ?bgColor: String)
	{
		super();

		bgSprite = new Sprite();
		var bgData: BitmapData = DisplayUtils.getBitmapDataFromLayer(tilesheet, bgTile != null ? bgTile : tile);
		if(bgColor != null){
			var color = new ColorTransform();
			color.color = Std.parseInt(bgColor);
			bgData.colorTransform(new Rectangle(0,0,bgData.width,bgData.height), color);
		}
		var bgBmp = new ScaleBitmap(bgData, true);
		bgBmp.bitmapScale9Grid = bgScale9Grid != null ? bgScale9Grid : scale9Grid;
		bgBmp.bitmapWidth = width;
		bgSprite.addChild(bgBmp);

		cursorSprite = new Sprite();
		var cursorData: BitmapData = DisplayUtils.getBitmapDataFromLayer(tilesheet, tile);
		if(cursorColor != null){
			var color = new ColorTransform();
			color.color = Std.parseInt(cursorColor);
			cursorData.colorTransform(new Rectangle(0,0,cursorData.width,cursorData.height), color);
		}


		var bmp = new ScaleBitmap(cursorData, true);
		bmp.bitmapScale9Grid = scale9Grid;
		bmp.bitmapWidth = width;
		cursorSprite.addChild(bmp);
        cursorSprite.mouseChildren = false;

        cursorSprite.buttonMode = true;
        cursorSprite.addEventListener(MouseEvent.MOUSE_DOWN, cursorStart);
        addEventListener(MouseEvent.MOUSE_UP, cursorStop);
        addEventListener(MouseEvent.MOUSE_OUT, cursorStop);
		addChild(bgSprite);
		addChild(cursorSprite);


		mouseEnabled = true;
	}

	public function setHeight(height: Float):Void
	{
		cast(bgSprite.getChildAt(0), ScaleBitmap).bitmapHeight = height;
	}

	public function set_ratio(ratio:Float):Float
	{
		cast(cursorSprite.getChildAt(0), ScaleBitmap).bitmapHeight = height * ratio;
		return this.ratio = ratio;
	}

	/**
	 * Move the cursor. Can't go out of bound
	 * @param	delta : distance to move the cursor
	 */

	public function moveCursor(delta:Float)
	{
		if(cursorSprite.y - delta < 0){
			cursorSprite.y = 0;
		}
		else if(cursorSprite.y + cursorSprite.height - delta > height){
			cursorSprite.y = height - cursorSprite.height;
		}
		else{
			cursorSprite.y -= delta * (cursorSprite.height / height);
		}
	}



	/**
	 * Abstract function to scroll the text
	 * @param	destination : where to scroll
	 */

	dynamic public function scrolled(destination:Float)
	{ }

	// Private

	private function onScroll(e:MouseEvent)
	{
		scrolled(cursorSprite.y / (height));

	}

	private function cursorStart(e:MouseEvent)
	{
		cursorSprite.startDrag(false, new Rectangle(0, 0, 0,bgSprite.height-cursorSprite.height ));
		addEventListener(MouseEvent.MOUSE_UP, cursorStop);
        addEventListener(MouseEvent.MOUSE_OUT, cursorStop);
		parent.addEventListener(MouseEvent.MOUSE_MOVE, onScroll);
	}

	private function cursorStop(e:MouseEvent)
	{
		cursorSprite.stopDrag();
		removeEventListener(MouseEvent.MOUSE_UP, cursorStop);
        removeEventListener(MouseEvent.MOUSE_OUT, cursorStop);
		parent.removeEventListener(MouseEvent.MOUSE_MOVE, onScroll);
	}
}