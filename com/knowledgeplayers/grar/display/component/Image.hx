package com.knowledgeplayers.grar.display.component;

import aze.display.TilesheetEx;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import openfl.Assets;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import flash.filters.BitmapFilter;
import flash.display.Bitmap;
import haxe.xml.Fast;

/**
* Image widget
**/
class Image extends Widget{

	public function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
		if(xml != null){
			createImg(xml, tilesheet);
			super(xml);
		}
	}

	private function createImg(xml:Fast, ?tilesheet: TilesheetEx):Void
	{
		var itemBmp;
		if(xml.has.src){
			#if flash
	                itemBmp = new Bitmap(AssetsStorage.getBitmapData(xml.att.src));
	            #else
			itemBmp = new Bitmap(Assets.getBitmapData(xml.att.src));
			#end
		}
		else
			itemBmp = new Bitmap(DisplayUtils.getBitmapDataFromLayer(tilesheet != null ?tilesheet : UiFactory.tilesheet, xml.att.tile));

		if(xml.has.mirror){
			mirror = switch(xml.att.mirror.toLowerCase()){
				case "horizontal": 1;
				case "vertical": 2;
				case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
			}
		}
		addChild(itemBmp);
	}
}
