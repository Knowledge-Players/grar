package com.knowledgeplayers.grar.structure.part.dialog.pattern;

import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import com.knowledgeplayers.grar.factory.ItemFactory;
import nme.Lib;

import haxe.xml.Fast;

class ActivityPattern extends Pattern 
{
	/**
	 * Item that will triger an activity
	 */
	public var event: RemarkableEvent;
	
	public function new(name: String)
	{
		super(name);
	}
	
	override public function init(xml:Fast) : Void 
	{
		for (itemNode in xml.nodes.Item) {
			var item: Item = ItemFactory.createItemFromXml(itemNode);
			if (Std.is(item, RemarkableEvent))
				event = cast(item, RemarkableEvent);
			else
				item.content = itemNode.att.Content;
			patternContent.push(item);
		}
	}
}