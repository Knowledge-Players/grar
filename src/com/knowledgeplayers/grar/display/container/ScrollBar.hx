package com.knowledgeplayers.grar.display.container;

import aze.display.SparrowTilesheet;
import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TileSprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.MouseEvent;
import nme.display.InteractiveObject;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.geom.Rectangle;
import nme.Lib;

/**
 * ...
 * @author jgranick
 */

class ScrollBar extends Sprite
{
    private var cursor:TileLayer;
	private var cursorSprite: Sprite;
    private var cursorHeight:Float;
	private var page:Float;
    private var ratio:Float;
	private var layer: TileLayer;
	private var maxHeight: Float;

    public function new(width:Float, height:Float, ratio:Float)
    {
		super();
		
		this.ratio = ratio;
		
		var tilesheet = new SparrowTilesheet(Assets.getBitmapData("items/ui.png"), Assets.getText("items/ui.xml"));
		layer = new TileLayer(tilesheet);
		
		var background = new TileGroup();
		background.addChild(new TileSprite("scrollbar_endup.png"));
		background.addChild(new TileSprite("scrollbar_middle.png"));
		background.addChild(new TileSprite("scrollbar_enddown.png"));
		layer.addChild(background);

		cursorHeight = height * ratio;
		
		cursor = new TileLayer(tilesheet);
		cursorSprite = new Sprite();
		var cursorGroup = new TileGroup();
		cursorGroup.addChild(new TileSprite("cursor_endup.png"));
		cursorGroup.addChild(new TileSprite("cursor_middle.png"));
		cursorGroup.addChild(new TileSprite("cursor_enddown.png"));
		cursor.addChild(cursorGroup);
		cursorSprite.addChild(cursor.view);
		
		addChild(layer.view);
		addChild(cursorSprite);
		
		createBar(layer, background, width, height);
		createBar(cursor, cursorGroup, width, cursorHeight);

		this.height = maxHeight = height;
		this.width = width;
		
		cursorSprite.addEventListener( MouseEvent.MOUSE_DOWN, cursorStart );
    }
	
	public function moveCursor(delta: Float)
	{
		if (cursorSprite.y - delta < 0){
			cursorSprite.y = 0;
		}
		else if (cursorSprite.y + cursorSprite.height - delta > maxHeight) {
			cursorSprite.y = maxHeight - cursorSprite.height;
		}
		else{
			cursorSprite.y -= delta * (cursorSprite.height / maxHeight);
		}
		cursor.render();
	}
	
    dynamic public function scrolled(destination:Float){}

    private function onScroll(e:MouseEvent)
    {
		scrolled(cursorSprite.y / (height));
		
    }

	private function cursorStart(e:MouseEvent)
    {
		cursorSprite.addEventListener( MouseEvent.MOUSE_UP, cursorStop );
		parent.addEventListener( MouseEvent.MOUSE_MOVE, onScroll );
		cursorSprite.startDrag(false, new Rectangle(0,0,0,height-cursorHeight));
    }
	
    private function cursorStop(e:MouseEvent)
    {
        cursorSprite.stopDrag();
        cursorSprite.removeEventListener( MouseEvent.MOUSE_UP, cursorStop );
        parent.removeEventListener( MouseEvent.MOUSE_MOVE, onScroll );
    }
	
	private function createBar(layer: TileLayer, graphics: TileGroup, width: Float, height: Float) : Void 
	{
		var end_up = cast(graphics.children[0], TileSprite);
		end_up.y = end_up.height/2;
		var end_down = cast(graphics.children[2], TileSprite);
		end_down.mirror = 2;
		
		var middle = cast(graphics.children[1], TileSprite);
		middle.scaleY = (height - (end_up.height + end_down.height)) / middle.height;
		middle.y = end_up.y + end_up.height/2 + middle.height / 2;
		
		end_down.y = middle.y + middle.height / 2 + end_down.height / 2;
	
		layer.render();
	}
}