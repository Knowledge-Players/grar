package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.factory.ItemFactory;
import haxe.xml.Fast;

class GroupItem extends Item {

	public var elements (default, default):List<Item>;

	public function new(xml: Fast){
		super(xml);
		elements = new List<Item>();
		if(xml != null){
			for(item in xml.elements){
				switch(item.name.toLowerCase()){
					case "text":
						elements.add(ItemFactory.createItemFromXml(item));
					case "dynamic":
						elements.add(new DynamicItem(item));
				}
			}
		}
	}
}