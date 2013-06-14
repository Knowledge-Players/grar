package com.knowledgeplayers.grar.display.part;

import Lambda;
import com.knowledgeplayers.grar.util.DisplayUtils;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import aze.display.TileSprite;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
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

	private var boxes:Map<String, Fast>;
	private var currentBox:BoxPattern;
	private var currentItem:TextItem;
	private var boxIndex:Int = 0;

	public function new(part:StripPart)
	{
		super(part);

		boxes = new Map<String, Fast>();
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
			boxes.set(elemNode.att.ref, elemNode);
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
		var boxContainer = new Sprite();
		var box: Fast = boxes.get(currentBox.name);
		var layer = new TileLayer(spritesheets.get(box.att.spritesheet));
		var sprite = new TileSprite(layer, box.att.id);
		sprite.x = Std.parseFloat(box.att.x);
		sprite.y = Std.parseFloat(box.att.y);
		layer.addChild(sprite);
		layer.render();
		boxContainer.addChild(layer.view);
		if(box.hasNode.Text){
			var textNode: Fast = box.node.Text;
			createText(textNode);
			var text = cast(displays.get(textNode.att.ref).obj, ScrollPanel);
			text.setContent(Localiser.instance.getItemContent(currentItem.content));
			text.x += Std.parseFloat(box.att.x);
			text.y += Std.parseFloat(box.att.y);
			boxContainer.addChild(text);
		}

		displayArea.addChild(boxContainer);

		var x = Std.parseFloat(box.att.x) - Std.parseFloat(box.att.width)/2;
		var y = Std.parseFloat(box.att.y) - Std.parseFloat(box.att.height)/2;
		DisplayUtils.maskSprite(boxContainer, Std.parseFloat(box.att.width), Std.parseFloat(box.att.height), x, y);

		var actuator = null;
		if(box.has.transitionIn)
			actuator = TweenManager.applyTransition(boxContainer, box.att.transitionIn);
		if(Lambda.count(currentBox.buttons) == 0)
			actuator.onComplete(onBoxVisible);
		else{
			for(key in currentBox.buttons.keys()){
				displayArea.addChild(displays.get(key).obj);
			}
		}
	}

	private function onBoxVisible():Void
	{
		if(Lambda.count(currentBox.buttons) == 0 && currentBox.nextPattern != "")
			goToPattern(currentBox.nextPattern);
	}
}