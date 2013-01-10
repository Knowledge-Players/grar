package com.knowledgeplayers.grar.factory;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.button.AnimationButton;
import com.knowledgeplayers.grar.display.button.CustomEventButton;
import com.knowledgeplayers.grar.display.button.DefaultButton;
import com.knowledgeplayers.grar.display.button.TextButton;
import haxe.xml.Fast;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class UiFactory 
{
	private function new() 
	{
		
	}
	
	public static function createButton(buttonType: String, layer: String, tile: String, ?action: String) : DefaultButton
	{		
		var creation: DefaultButton = null;
		switch(buttonType.toLowerCase()) {
			case "text": creation = new TextButton(layer, tile, action);
			case "event": creation = new CustomEventButton(action, layer, tile);
			case "anim": creation = new AnimationButton(layer, tile, action);
			default: creation = new DefaultButton(layer, tile);
		}
		
		return creation;
	}
	
	public static function createButtonFromXml(xml: Fast) : DefaultButton
	{
		return createButton(xml.att.Type, xml.att.Spritesheet, xml.att.Id, (xml.has.Action?xml.att.Action:null));
	}
}