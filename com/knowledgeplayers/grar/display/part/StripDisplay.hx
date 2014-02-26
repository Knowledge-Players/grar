package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.Item;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.component.container.BoxDisplay;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.strip.pattern.BoxPattern;
import com.knowledgeplayers.grar.structure.part.TextItem;
import haxe.xml.Fast;
import flash.display.DisplayObject;

/**
 * Display for the strip parts, like a comic
 */
class StripDisplay extends PartDisplay {

	private var boxes:Map<String, BoxDisplay>;
	private var currentBox:BoxPattern;
	private var currentBoxItem:Item;

	public function new(part:Part)
	{
		super(part);
		boxes = new Map<String, BoxDisplay>();
	}

	override public function next(?target: DefaultButton):Void
	{
		if(Lambda.count(currentBox.buttons) == 0)
			startPattern(currentBox);
		else
			exitPart();
	}

	// Private

	override private function createDisplay():Void
	{
		super.createDisplay();

		for(elem in part.elements){
			if(elem.isText()){
				addChild(displays.get(cast(elem, TextItem).ref));
				for(image in cast(elem, TextItem).images)
					addChild(displays.get(image));
			}
		}
	}

	override private function createElement(elemNode:Fast):Widget
	{
		var elem: Widget = super.createElement(elemNode);
		if(elemNode.name.toLowerCase() == "box"){
			elem = new BoxDisplay(elemNode, spritesheets.get(elemNode.att.spritesheet));
			boxes.set(elemNode.att.ref, cast(elem, BoxDisplay));
		}
		return elem;
	}

	override private function startPattern(pattern:Pattern):Void
	{
		super.startPattern(pattern);
		currentBox = cast(pattern, BoxPattern);

		var nextItem: Item = pattern.getNextItem();
		if(nextItem != null){
			currentBoxItem = nextItem;
			setupItem(nextItem);

			for(token in nextItem.tokens)
				GameManager.instance.activateToken(token);
		}
		else if(currentBox.nextPattern != "")
			goToPattern(currentBox.nextPattern);
	}

	override private function setBackground(background:String):Void
	{
        if (currentBox != null)
		    super.setBackground(currentBox.background);
	}

	override private function setText(item:TextItem, isFirst:Bool = true):Void
	{
		for(elem in part.elements){
			if(elem.isText()){
				var textItem = cast(elem, TextItem);
				cast(displays.get(textItem.ref), ScrollPanel).setContent(Localiser.instance.getItemContent(textItem.content));
			}
		}
		displayPart();
	}

	override private function setupItem(item:Item, ?isFirst:Bool = true, ?groupName: String):Void
	{
		currentItem = item;
		if(isFirst)
			setBackground(item.background);

		if(item.isText()){
			var text = cast(item, TextItem);
			setSpeaker(text.author, text.transition);
			setText(text, isFirst);
		}
	}

	override private function displayPart():Void
	{
		if(currentBox != null){
	        var box: BoxDisplay = boxes.get(currentBox.id);
			var nextItem: Item = currentBoxItem;
			while(nextItem != null){
				if(nextItem != null){
					box.textFields.get(nextItem.ref).setContent(Localiser.instance.getItemContent(nextItem.content));
					if(Std.is(nextItem, TextItem))
						GameManager.instance.playSound(cast(nextItem, TextItem).sound);
				}

				nextItem = currentBox.getNextItem();
			}
			if(Lambda.count(currentBox.buttons) == 0){
				box.onComplete = onBoxVisible;
				addChild(box);
			}
			else{
				addChild(box);
				for(key in currentBox.buttons.keys()){
					if(!displays.exists(key))
						throw "[StripDisplay] There is no Button with ref \""+key+"\"";
					addChild(displays.get(key));
				}
			}
		}
		else{
			super.displayPart();
			nextElement();
		}
	}

	private function onBoxVisible():Void
	{
		if(Lambda.count(currentBox.buttons) == 0 && currentBox.nextPattern != ""){
			currentBox.restart();
			goToPattern(currentBox.nextPattern);
		}
	}

	override private function createImage(itemNode:Fast):Widget
	{
		var spritesheet = itemNode.has.spritesheet?itemNode.att.spritesheet:"ui";
		if(itemNode.name.toLowerCase() == "background"){
			var img = new Image(itemNode, spritesheets.get(spritesheet));
			addChild(img);
			return img;
		}
		else{
			return super.createImage(itemNode);
		}
	}
}