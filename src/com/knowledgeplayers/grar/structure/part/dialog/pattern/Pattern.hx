package com.knowledgeplayers.grar.structure.part.dialog.pattern;

import com.knowledgeplayers.grar.factory.ItemFactory;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import haxe.xml.Fast;

class Pattern 
{
	public var patternContent (default, default): Array<Item>;
	public var name (default, default): String;
	
	private var itemIndex: Int = 0;

	public function new(name: String)
	{
		this.name = name;
		patternContent = new Array<Item>();
	}
	
	public function init(xml: Fast) : Void
	{
		for (itemNode in xml.nodes.Item) {
			var item: Item = ItemFactory.createItemFromXml(itemNode);
			patternContent.push(item);
		}
	}
	
	public function getNextItem() : Null<Item>
	{
		if(itemIndex < patternContent.length){
			itemIndex++;
			return patternContent[itemIndex-1];
		}
		else
			return  null; 
	}
	
	
}