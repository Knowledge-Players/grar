package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.structure.part.Item;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.component.container.BoxDisplay;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import aze.display.TileSprite;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.strip.pattern.BoxPattern;
import com.knowledgeplayers.grar.structure.part.strip.StripPart;
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

	public function new(part:StripPart)
	{
		super(part);
		boxes = new Map<String, BoxDisplay>();
	}

	override public function next(?target: DefaultButton):Void
	{
		startPattern(currentBox);
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

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		if(elemNode.name.toLowerCase() == "box"){
			boxes.set(elemNode.att.ref, new BoxDisplay(elemNode, spritesheets.get(elemNode.att.spritesheet)));
		}
	}

	override private function startPattern(pattern:Pattern):Void
	{
		super.startPattern(pattern);
		currentBox = cast(pattern, BoxPattern);

		var nextItem = pattern.getNextItem();
		if(nextItem != null){
			currentBoxItem = nextItem;
			setupItem(nextItem);
			if(nextItem.isText())
				GameManager.instance.playSound(cast(nextItem, TextItem).sound);
			if(nextItem.token != null && nextItem.token != ""){
				for(token in nextItem.token.split(","))
					GameManager.instance.activateToken(token);
			}
		}
		else if(currentBox.nextPattern != "")
			goToPattern(currentBox.nextPattern);
		else{
			exitPart();
		}
	}

	override private function displayBackground(background:String):Void
	{
		super.displayBackground(currentBox.background);
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

	override private function setupItem(item:Item, ?isFirst:Bool = true):Void
	{
		if(isFirst)
			displayBackground(item.background);

		if(item.isText()){
			var text = cast(item, TextItem);
			setSpeaker(text.author, text.transition);
			setText(text, isFirst);
		}
	}

	override private function displayPart():Void
	{
		var box: BoxDisplay = boxes.get(currentBox.name);
		if(!box.textFields.exists(currentBoxItem.ref))
			throw "[StripDisplay] There is no TextField with ref \""+currentBoxItem.ref+"\"";
		else
			box.textFields.get(currentBoxItem.ref).setContent(Localiser.instance.getItemContent(currentBoxItem.content));
		var tfCount = 1;
		while(tfCount < Lambda.count(box.textFields)){
			var nextItem = currentBox.getNextItem();
			if(nextItem != null){
				currentBoxItem = nextItem;
				box.textFields.get(currentBoxItem.ref).setContent(Localiser.instance.getItemContent(currentBoxItem.content));
			}
			tfCount++;
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

	private function onBoxVisible():Void
	{
		if(Lambda.count(currentBox.buttons) == 0 && currentBox.nextPattern != ""){
			currentBox.restart();
			goToPattern(currentBox.nextPattern);
		}
	}

	override private function createImage(itemNode:Fast):Void
	{
		var spritesheet = itemNode.has.spritesheet?itemNode.att.spritesheet:"ui";
		if(itemNode.name.toLowerCase() == "background"){
			addChild(new Image(itemNode, spritesheets.get(spritesheet)));
		}
		else{
			super.createImage(itemNode);
		}
	}
}