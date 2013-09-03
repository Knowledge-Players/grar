package com.knowledgeplayers.grar.display.component.container;

import nme.display.BitmapData;
import nme.display.MovieClip;
import nme.display.Shape;
import nme.display.Bitmap;
import nme.events.Event;
import com.knowledgeplayers.grar.util.DisplayUtils;
import aze.display.TilesheetEx;
import haxe.xml.Fast;
import nme.display.Sprite;

class SimpleContainer extends WidgetContainer{

	private var contentMask:Bitmap;
    private var xml:Fast;
    private var bmpData:BitmapData;
    private var contentData:BitmapData;

	public function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
        this.xml = xml;
		super(xml, tilesheet);

		//displayContent();
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	override public function maskSprite(sprite: Sprite, maskWidth: Float = 1, maskHeight: Float = 1, maskX: Float = 0, maskY: Float = 0):Void
	{

		if(contentMask != null){
			sprite.addChild(contentMask);
			sprite.mask = contentMask;
		}
		else
			super.maskSprite(sprite, maskWidth, maskHeight, maskX, maskY);
	}

	override public function clear()
	{
	}

	public function onAdded(e: Event): Void
	{

        if(xml.has.mask){
            addEventListener("SET_MASK",setMaskSpriteSheet);
            bmpData= DisplayUtils.getBitmapDataFromLayer(this.tilesheet, xml.att.mask);

            contentMask = new Bitmap(bmpData) ;
            contentData = new BitmapData(bmpData.width, bmpData.height, true, 0x0);
            contentMask.cacheAsBitmap = true;
        }
	}

    private function setMaskSpriteSheet(e:Event):Void{

        if(xml.has.mask){
            contentData.draw(content);
            removeEventListener("SET_MASK",setMaskSpriteSheet);
            var bmp = new Bitmap(contentData);
            bmp.cacheAsBitmap = true;

            addChild(contentMask);
            addChild(bmp);
            bmp.mask = contentMask;
            removeChild(content);
            }

        }

}
