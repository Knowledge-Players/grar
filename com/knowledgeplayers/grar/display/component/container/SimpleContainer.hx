package com.knowledgeplayers.grar.display.component.container;

import flash.display.DisplayObject;
import com.knowledgeplayers.grar.event.DisplayEvent;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.events.Event;
import com.knowledgeplayers.grar.util.DisplayUtils;
import aze.display.TilesheetEx;
import haxe.xml.Fast;
import flash.display.Sprite;

using StringTools;

class SimpleContainer extends WidgetContainer{

	private var contentMask:Bitmap;
    private var xml:Fast;
    private var bmpData:BitmapData;
    private var contentData:BitmapData;
	private var tilesheetName: String;
	private var totalChildren: Int;
	private var loadedChildren: Int;

	public function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
        this.xml = xml;
		totalChildren = loadedChildren = 0;
		super(xml, tilesheet);
		if(xml.has.spritesheet)
			tilesheetName = xml.att.spritesheet;
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
		if(tilesheetName != null){
			var ancestor = parent;
			while(!Std.is(ancestor, PartDisplay) && ancestor != null)
				ancestor = ancestor.parent;
			if(ancestor == null)
				throw "[TileImage] Unable to find spritesheet '"+tilesheetName+"' for image '"+ref+"'.";
			tilesheet = cast(ancestor, PartDisplay).spritesheets.get(tilesheetName);
			layer.tilesheet = tilesheet;
			layer.removeAllChildren();
			for(child in xml.elements){
				createElement(child);
			}
		}
		dispatchEvent(new DisplayEvent(DisplayEvent.LOADED));
	}

	public function setMask(e: Event):Void
	{
		loadedChildren++;
        if(loadedChildren == totalChildren && xml.has.mask){
            bmpData= DisplayUtils.getBitmapDataFromLayer(this.tilesheet, xml.att.mask);

            contentMask = new Bitmap(bmpData) ;
            if(xml.has.scale){
                contentMask.scaleX = Std.parseFloat(xml.att.scale);
                contentMask.scaleY = Std.parseFloat(xml.att.scale);
            }

            contentData = new BitmapData(bmpData.width, bmpData.height, true, 0x0);

            contentMask.cacheAsBitmap = true;

	        contentData.draw(content);
	        var bmp = new Bitmap(contentData);
	        if(xml.has.scale){
		        bmp.scaleX =   Std.parseFloat(xml.att.scale);
		        bmp.scaleY =   Std.parseFloat(xml.att.scale);
	        };
	        bmp.cacheAsBitmap = true;
	        bmp.mask = contentMask;
            bmp.smoothing = true;
	        var sprite = new Sprite();

	        sprite.addChild(contentMask);
	        sprite.addChild(bmp);

	        var text = null;
	        while (content.numChildren > 0){
		        var child = content.removeChildAt(content.numChildren-1);
		        if(Std.is(child, ScrollPanel))
					text = child;
	        }

	        content.addChild(sprite);
	        if(text != null)
	            content.addChild(text);

        }
	}

	override public function createElement(elemNode:Fast):Widget
	{
		var widget = super.createElement(elemNode);
		if(elemNode.name.toLowerCase() == "div"){
			widget = new SimpleContainer(elemNode);
			totalChildren++;
			widget.addEventListener(DisplayEvent.LOADED, setMask);
			addElement(widget);
		}
		return widget;
	}

	override private function createText(textNode:Fast):Widget
	{
		var panel = super.createText(textNode);
		if(textNode.has.content && textNode.att.content.startsWith("$")){
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				var display: DisplayObject = parent;
				while(display != null && !Std.is(display, KpDisplay)){
					display = display.parent;
				}
				if(display != null){
					var kpParent: KpDisplay = cast(display, KpDisplay);
					kpParent.dynamicFields.push({field: cast(panel, ScrollPanel), content: textNode.att.content.substr(1)});
				}
				// Warn its parent about its change
				dispatchEvent(new Event(Event.CHANGE));
			}, 1000);
		}
		return panel;
	}
}
