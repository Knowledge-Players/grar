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

	private var contentMask:Sprite;
    private var xml:Fast;

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

        var bmpData = DisplayUtils.getBitmapDataFromLayer(this.tilesheet, xml.att.mask);

// contentMask = new Bitmap(bmpData);

        contentMask = new Sprite() ;
        contentMask.graphics.beginBitmapFill(bmpData);
        contentMask.graphics.drawRect(0, 0, bmpData.width, bmpData.height);
        contentMask.graphics.endFill();

        var contentData = new BitmapData(bmpData.width, bmpData.height, true, 0x0);
        contentData.draw(content);

        var bmp = new Bitmap(contentData);
        addChild(contentMask);
       // addChild(bmp);
        content.mask = contentMask;
       //removeChild(content);
        }
	}

}
