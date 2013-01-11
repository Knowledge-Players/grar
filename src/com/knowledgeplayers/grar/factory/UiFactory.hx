package com.knowledgeplayers.grar.factory;

import aze.display.SparrowTilesheet;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.button.AnimationButton;
import com.knowledgeplayers.grar.display.button.CustomEventButton;
import com.knowledgeplayers.grar.display.button.DefaultButton;
import com.knowledgeplayers.grar.display.button.TextButton;
import com.knowledgeplayers.grar.display.container.ScrollBar;
import haxe.xml.Fast;
import nme.Assets;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class UiFactory 
{
	private static var tilesheet: TilesheetEx;
	
	private function new() 
	{
		
	}
	
	public static function createButton(buttonType: String, tile: String, ?action: String) : DefaultButton
	{		
		var creation: DefaultButton = null;
		switch(buttonType.toLowerCase()) {
			case "text": creation = new TextButton(tilesheet, tile, action);
			case "event": creation = new CustomEventButton(action, tilesheet, tile);
			case "anim": creation = new AnimationButton(tilesheet, tile, action);
			default: creation = new DefaultButton(tilesheet, tile);
		}
		
		return creation;
	}
	
	public static function createScrollBar(width: Float, height: Float, ratio: Float, tileBackground: String, tileCursor: String ) : ScrollBar
	{		
		return new ScrollBar(width, height, ratio, tilesheet, tileBackground, tileCursor);
	}
	
	public static function createButtonFromXml(xml: Fast) : DefaultButton
	{
		return createButton(xml.att.Type, xml.att.Id, (xml.has.Action?xml.att.Action:null));
	}
	
	public static function setSpriteSheet(pathToXml: String) : Void 
	{
		var layerPath = pathToXml.substr(0, pathToXml.indexOf("."));
		tilesheet = new SparrowTilesheet(Assets.getBitmapData(layerPath+".png"), Assets.getText(layerPath+".xml"));
	}
}