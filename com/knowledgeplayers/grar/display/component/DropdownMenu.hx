package com.knowledgeplayers.grar.display.component;

import nme.geom.Point;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import haxe.ds.GenericStack;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;

/**
 * Drop down menu component
 */
class DropdownMenu extends WidgetContainer {

	public var items (default, default):GenericStack<String>;
	public var currentLabel (default, set_currentLabel):String;

	private var list:Sprite;
	private var labelSprite:Sprite;
	private var sprites:Map<String, Sprite>;
	private var blank:Bool;

	public function new(?xml: Fast, blankItem = false)
	{
		super(xml);
		blank = blankItem;
		buttonMode = true;
		items = new GenericStack<String>();
		sprites = new Map<String, Sprite>();
		list = new Sprite();
		labelSprite = new Sprite();
		list.visible = false;
		addEventListener(Event.ADDED_TO_STAGE, onAdd);
		addEventListener(MouseEvent.CLICK, onClick);
	}

	/**
     * Add an item at the top of the menu
     * @param	item : Item to add
     */

	public function addItem(item:String):Void
	{
		items.add(item);
	}

	// Private

	private function set_currentLabel(label:String):String
	{
		currentLabel = label;
		if(labelSprite.numChildren > 0)
			labelSprite.removeChildAt(0);
		labelSprite.addChild(KpTextDownParser.parse(label)[0].createSprite(maskWidth));
		dispatchEvent(new Event(Event.CHANGE));
		return label;
	}

	private function onAdd(e:Event):Void
	{

		var yOffset:Float = 0;
		// TODO remove useless index
		var index = 0;
		for(item in items){
			var sprite = KpTextDownParser.parse(item)[0].createSprite(maskWidth);
			sprite.buttonMode = true;
			sprite.y = yOffset;
			yOffset += sprite.height;
			sprite.addEventListener(MouseEvent.CLICK, onItemClick);
			list.addChild(sprite);
			sprites.set(item, sprite);
			index++;
		}
		if(localToGlobal(new Point(0, 0)).y+list.height > nme.Lib.stage.stageHeight)
			list.y = y - list.height;
		list.visible = false;

		if(!blank)
			set_currentLabel(items.first());
		else{
			labelSprite.graphics.beginFill(0x000000, 0.1);
			labelSprite.graphics.drawRect(0, 0, list.getChildAt(0).width, list.getChildAt(0).height);
			labelSprite.graphics.endFill();
		}
		addChild(labelSprite);

		addChild(list);
	}

	private function onItemClick(e:MouseEvent):Void
	{
		for(label in sprites.keys()){
			if(e.currentTarget == sprites.get(label))
				set_currentLabel(label);
		}
		list.visible = false;
		labelSprite.visible = true;
		e.stopImmediatePropagation();
		addEventListener(MouseEvent.CLICK, onClick);
	}

	private function onClick(e:MouseEvent):Void
	{
		labelSprite.visible = false;
		list.visible = true;
		removeEventListener(MouseEvent.CLICK, onClick);
	}
}