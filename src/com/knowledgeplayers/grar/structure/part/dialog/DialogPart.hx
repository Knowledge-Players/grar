package com.knowledgeplayers.grar.structure.part.dialog;

import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.dialog.item.ChoiceItem;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.CollectPattern;
import haxe.xml.Fast;
import nme.Lib;

import com.knowledgeplayers.grar.structure.part.StructurePart;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.Pattern;
import com.knowledgeplayers.grar.factory.PatternFactory;

/**
 * ...
 * @author jbrichardet
 */

class DialogPart extends StructurePart
{
	public var patterns: Array<Pattern>;

	public function new() 
	{
		super();
		
		patterns = new Array<Pattern>();
	}
	
	override public function getNextItem() : Null<Item> 
	{
		var item:Item = null;
		if(itemIndex < patterns.length){
			item = patterns[itemIndex].getNextItem();
			if (item == null) {
				itemIndex++;
				return getNextItem();
			}
		}
		if(item == null){
			isDone = true;
		}
		
		return item;
	}
	
	override public function isDialog() : Bool 
	{
		return true;
	
	}
	
	public function getNextVerticalIndex() : Null<ChoiceItem> 
	{
		var item: ChoiceItem = null;
		if (Std.is(patterns[itemIndex], CollectPattern)) {
			var collect: CollectPattern = cast(patterns[itemIndex], CollectPattern);
			item = collect.progressVertically();
			
			if (item != null && item.hasToken()) {
				var event = new TokenEvent(TokenEvent.ADD, item.tokenId, item.tokenType, item.target);
				dispatchEvent(event);
			}
		}
		
		return item;
	}

	// Private
	 
	override private function parseContent(content: Xml) : Void
	{
		var partFast: Fast = new Fast(content).node.Part;
		for (patternNode in partFast.nodes.Pattern) 
		{
			var pattern: Pattern = PatternFactory.createPatternFromXml(patternNode, patternNode.att.Id);
			pattern.init(patternNode);
			patterns.push(pattern);
		}
		fireLoaded();
	}
	
}