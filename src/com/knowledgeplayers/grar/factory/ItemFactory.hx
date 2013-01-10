package com.knowledgeplayers.grar.factory;
import com.knowledgeplayers.grar.structure.part.dialog.item.ChoiceItem;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import haxe.xml.Fast;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class ItemFactory 
{

	private function new() 
	{
		
	}
	
	public static function createItem(itemType: String, ?xml: Fast) : Null<Item> 
	{
		var creation: Item = null;
		switch(itemType.toLowerCase()) {
			case "": creation = new Item(xml);
			case "choice": creation = new ChoiceItem(xml);
			case "event": creation = new RemarkableEvent(xml);
			default: Lib.trace(itemType + ": Unsupported item type");
		}
		
		return creation;
	}
	
	public static function createItemFromXml(xml: Fast) : Null<Item> 
	{
		return createItem(xml.att.Type, xml);
	}	
}