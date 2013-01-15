package com.knowledgeplayers.grar.display.container;

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
    private var cursor:TileLayer;
	private var cursorSprite: Sprite;
    private var cursorHeight:Float;
	private var page:Float;
    private var ratio:Float;
	private var layer: TileLayer;
	private var maxHeight: Float;

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
    public function new(width:Float, height:Float, ratio:Float, tilesheet: TilesheetEx,  tileBackground: String, tileCursor: String )
    {
		super();
		
		this.ratio = ratio;
		this.layer = new TileLayer(tilesheet);
		
		var background = new TileGroup();
		background.addChild(new TileSprite(tileBackground+"_end.png"));
		background.addChild(new TileSprite(tileBackground+"_middle.png"));
		background.addChild(new TileSprite(tileBackground+"_end.png"));
		layer.addChild(background);

		cursorHeight = height * ratio;
		
		cursor = new TileLayer(layer.tilesheet);
		cursorSprite = new Sprite();
		var cursorGroup = new TileGroup();
		cursorGroup.addChild(new TileSprite(tileCursor+"_end.png"));
		cursorGroup.addChild(new TileSprite(tileCursor+"_middle.png"));
		cursorGroup.addChild(new TileSprite(tileCursor+"_end.png"));
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
	
	/**
	 * Move the cursor. Can't go out of bound
	 * @param	delta : distance to move the cursor
	 */
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
	
	/**
	 * Abstract function to scroll the text
	 * @param	destination : where to scroll
	 */
    dynamic public function scrolled(destination:Float) { }
	
	// Private

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