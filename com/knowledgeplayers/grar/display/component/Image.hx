package com.knowledgeplayers.grar.display.component;

import aze.display.TilesheetEx;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import openfl.Assets;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import flash.display.Bitmap;
import haxe.xml.Fast;

/**
* Image widget
**/
class Image extends Widget{

	public var bitmap (default, null):Bitmap;

	public function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
		super(xml);
		if(xml != null){
			createImg(xml, tilesheet);

			if(xml.has.width)
				width = Std.parseFloat(xml.att.width);
			if(xml.has.height)
				height = Std.parseFloat(xml.att.height);
		}
	}

	private function createImg(xml:Fast, ?tilesheet: TilesheetEx):Void
	{
		if(xml.has.src){
			#if flash
	                bitmap = new Bitmap(AssetsStorage.getBitmapData(xml.att.src));
	            #else
			bitmap = new Bitmap(Assets.getBitmapData(xml.att.src));
			#end
		}
		else
			bitmap = new Bitmap(DisplayUtils.getBitmapDataFromLayer(tilesheet != null ?tilesheet : UiFactory.tilesheet, xml.att.tile));

		if(xml.has.mirror){
			mirror = switch(xml.att.mirror.toLowerCase()){
				case "horizontal": 1;
				case "vertical": 2;
				case _ : throw '[KpDisplay] Unsupported mirror $xml.att.mirror';
			}
		}
		addChild(bitmap);
	}
}
