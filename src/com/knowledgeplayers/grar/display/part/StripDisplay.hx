package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
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

	private var boxesref:Array<String>;
	private var currentBox:BoxPattern;
	private var currentItem:TextItem;
	private var boxIndex:Int = 0;

	public function new(part:StripPart)
	{
		super(part);
		boxesref = new Array<String>();
	}

	// Private

	override private function next(event:ButtonActionEvent):Void
	{
		startPattern(currentBox);
	}

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		if(elemNode.name.toLowerCase() == "box"){
			boxesref.push(elemNode.att.ref);
			displaysFast.set(elemNode.att.ref, elemNode);
		}
	}

	override private function startPattern(pattern:Pattern):Void
	{
		super.startPattern(pattern);

		currentBox = cast(pattern, BoxPattern);

		var nextItem = pattern.getNextItem();
		if(nextItem != null){
			currentItem = nextItem;
			displayArea = new Sprite();
			setText(nextItem);
		}
		else
			this.nextElement();
	}

	override private function displayPart():Void
	{
		var array = new Array<{obj:DisplayObject, z:Int}>();
		for(key in displays.keys()){
			if(key == currentItem.ref || currentBox.buttons.exists(key) || key == currentItem.author)
				array.push(displays.get(key));

			if(currentBox.buttons.exists(key)){
				for(contentKey in currentBox.buttons.get(key).keys()){
					cast(displays.get(key).obj, DefaultButton).setText(contentKey, Localiser.instance.getItemContent(currentBox.buttons.get(key).get(contentKey)));
				}
			}
		}

		for(obj in array){
			displayArea.addChildAt(obj.obj, cast(Math.min(obj.z, numChildren), Int));
		}

		var node = displaysFast.get(boxesref[boxIndex]);
		displayArea.x = Std.parseFloat(node.att.x);
		displayArea.y = Std.parseFloat(node.att.y);
		var mask = new Sprite();
		mask.graphics.beginFill(0);
		mask.graphics.drawRect(displayArea.x, displayArea.y, Std.parseFloat(node.att.width), Std.parseFloat(node.att.height));
		displayArea.mask = mask;

		boxIndex++;

		addChild(displayArea);
	}
}