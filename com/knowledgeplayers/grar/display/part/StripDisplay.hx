package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.container.BoxDisplay;
import Lambda;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import aze.display.TileSprite;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.strip.pattern.BoxPattern;
import com.knowledgeplayers.grar.structure.part.strip.StripPart;
import com.knowledgeplayers.grar.structure.part.TextItem;
import haxe.xml.Fast;
import nme.display.DisplayObject;
import nme.display.Sprite;

/**
 * Display for the strip parts, like a comic
 */
class StripDisplay extends PartDisplay {

	private var boxes:Map<String, BoxDisplay>;
	private var currentBox:BoxPattern;
	private var currentItem:TextItem;
	private var boxIndex:Int = 0;

	public function new(part:StripPart)
	{
		super(part);

		boxes = new Map<String, BoxDisplay>();
	}

	override public function next(event:ButtonActionEvent):Void
	{
		startPattern(currentBox);
	}

	// Private

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
			currentItem = nextItem;
			setupTextItem(nextItem);
			GameManager.instance.playSound(nextItem.sound);
			if(nextItem.token != null){
				GameManager.instance.activateToken(nextItem.token);
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
		displayPart();
	}

	override private function setupTextItem(item:TextItem, ?isFirst:Bool = true):Void
	{
		if(isFirst)
			displayBackground(item.background);

		setSpeaker(item.author, item.transition);
		setText(item, isFirst);
	}

	override private function displayPart():Void
	{
		var box: BoxDisplay = boxes.get(currentBox.name);
		if(!box.textFields.exists(currentItem.ref))
			throw "[StripDisplay] There is no TextField with ref \""+currentItem.ref+"\"";
		else
			box.textFields.get(currentItem.ref).setContent(Localiser.instance.getItemContent(currentItem.content));
		var tfCount = 1;
		while(tfCount < Lambda.count(box.textFields)){
			var nextItem = currentBox.getNextItem();
			if(nextItem != null){
				currentItem = nextItem;
				box.textFields.get(currentItem.ref).setContent(Localiser.instance.getItemContent(currentItem.content));
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
		if(Lambda.count(currentBox.buttons) == 0 && currentBox.nextPattern != "")
			goToPattern(currentBox.nextPattern);
	}
}