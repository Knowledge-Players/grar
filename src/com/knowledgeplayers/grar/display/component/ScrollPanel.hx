package com.knowledgeplayers.grar.display.component;

import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import nme.geom.Rectangle;
import nme.events.Event;
import com.knowledgeplayers.grar.util.LoadData;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.Lib;
import nme.Assets;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.factory.UiFactory;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * ScrollPanel to manage text overflow, with auto scrollbar
 */

class ScrollPanel extends Sprite {
    /**
     * Text in the panel
     */
    public var content (default, setContent):Sprite;

    /**
    * If true, the text won't scroll even if it's bigger than the panel
    **/
    public var scrollLock (default, default):Bool;

    private var scrollBar:ScrollBar;
    private var maskWidth:Float;
    private var maskHeight:Float;
    private var scrollable:Bool;
    private var spriteSheet:TilesheetEx;
    private var scaleNine:ScaleNine;

    /**
    * Background of the panel. It can be only a color or a reference to a Bitmap,
    **/
    private var background:String;
    /**
     * Constructor
     * @param	width : Width of the displayed content
     * @param	height : Height of the displayed content
     * @param	scrollLock : Disable scroll. False by default
     */
    // TODO What to do with _spritesheet

    public function new(width:Float, height:Float, ?_scrollLock:Bool = false, ?_spriteSheet:TilesheetEx)
    {
        super();
        maskWidth = width;
        maskHeight = height;
        content = new Sprite();
        this.scrollLock = _scrollLock;
        spriteSheet = _spriteSheet;
        addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
    }

    /**
     * Set the text to the panel
     * @param	content : Text to set
     * @return the text
     */

    public function setContent(content:Sprite):Sprite
    {
        clear();
        this.content = content;
        var posXMask:Float = 0;
        var posYMask:Float = 0;
        if(scaleNine != null){
            content.x = scaleNine.middleTile.x - scaleNine.middleTile.width / 2;
            content.y = scaleNine.middleTile.y - scaleNine.middleTile.height / 2;
            maskWidth = scaleNine.middleTile.width;
            maskHeight = scaleNine.middleTile.height;
            posXMask = content.x;
            posYMask = content.y;
        }

        addChild(content);
        var mask = new Sprite();
        mask.graphics.beginFill(0x000000);
        mask.graphics.drawRect(posXMask, posYMask, maskWidth, maskHeight);
        mask.graphics.endFill();
        content.mask = mask;
        addChild(mask);

        if(maskHeight < content.height && !scrollLock){
            scrollBar = UiFactory.createScrollBar(18, maskHeight, maskHeight / content.height, "scrollbar", "cursor");
            scrollBar.x = maskWidth - scrollBar.width;
            addChild(scrollBar);
            scrollBar.scrolled = scrollToRatio;
            scrollable = true;
        }
        else{
            scrollable = false;
        }

        return content;
    }

    public function setBackground(bkg:String, ?tilesheet:TilesheetEx):Void
    {
        background = bkg;
        if(spriteSheet == null){
            if(Std.parseInt(bkg) != null){
                this.graphics.beginFill(Std.parseInt(bkg));
                this.graphics.drawRect(0, 0, maskWidth, maskHeight);
                this.graphics.endFill();
            }
            else if(background.indexOf(".") < 0){
                if(tilesheet == null)
                    tilesheet = UiFactory.tilesheet;
                var layer = new TileLayer(tilesheet);
                var tile = new TileSprite(background);
                layer.addChild(tile);
                addChildAt(layer.view, 0);
                tile.x += tile.width / 2;
                tile.y += tile.height / 2;
                layer.render();
            }
            else if(LoadData.getInstance().getElementDisplayInCache(background) != null){
                var bkg:Bitmap = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(background), Bitmap).bitmapData);
                bkg.width = maskWidth;
                bkg.height = maskHeight;

                this.addChildAt(bkg, 0);
            }
        }
        else{
            scaleNine = new ScaleNine(maskWidth, maskHeight);
            scaleNine.addEventListener("onScaleInit", onInitScale);
            scaleNine.init(spriteSheet);
        }
    }

    // Private

    private function onInitScale(e:Event):Void
    {
        e.currentTarget.removeEventListener("onScaleInit", onInitScale);
        addChildAt(e.currentTarget, 0);
    }

    private function scrollToRatio(position:Float)
    {
        content.y = -position * content.height;
    }

    private function clear()
    {
        var max = Std.parseInt(background) != null ? 0 : 1;
        while(numChildren > max)
            removeChildAt(numChildren - 1);
    }

    private function onWheel(e:MouseEvent):Void
    {
        if(scrollable){
            if(e.delta > 0 && content.y + e.delta > 0){
                content.y = 0;
            }
            else if(e.delta < 0 && content.y + e.delta < -(content.height - maskHeight)){
                content.y = -(content.height - maskHeight);
            }
            else{
                content.y += e.delta;
            }
            if(scrollBar != null)
                moveCursor(e.delta);
        }
    }

    private function moveCursor(delta:Float)
    {
        scrollBar.moveCursor(delta);
    }

}