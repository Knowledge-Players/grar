package com.knowledgeplayers.grar.display.component;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import haxe.FastList;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.Lib;

/**
 * Drop down menu component
 */

class DropdownMenu extends Sprite
{
	public var items (default, default): FastList<String>;
	public var currentLabel (default, setCurrentLabel): String;
	
	private var list: Sprite;
	private var labelSprite: Sprite;
	private var sprites: Hash<Sprite>;
	private var blank: Bool;

	public function new(blankItem = false) 
	{
		super();
		blank = blankItem;
		buttonMode = true;
		items = new FastList<String>();
		sprites = new Hash<Sprite>();
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
	public function addItem(item: String) : Void 
	{
		items.add(item);
	}
	
	// Private 
	
	private function setCurrentLabel(label: String) : String
	{
		currentLabel = label;
		if(labelSprite.numChildren > 0)
			labelSprite.removeChildAt(0);
		labelSprite.addChild(KpTextDownParser.parse(label));
		dispatchEvent(new Event(Event.CHANGE));
		return label;
	}
	
	private function onAdd(e:Event):Void 
	{
		
		var yOffset: Float = 0;
		var index = 0;
		for (item in items) {
			var sprite = KpTextDownParser.parse(item);
			sprite.buttonMode = true;
			sprite.y = yOffset;
			yOffset += sprite.height;
			sprite.addEventListener(MouseEvent.CLICK, onItemClick);
			list.addChild(sprite);
			sprites.set(item, sprite);
			index++;
		}
		list.visible = false;
		
		if(!blank)
			setCurrentLabel(items.first());
		else {
			labelSprite.graphics.beginFill(0x000000, 0.1);
			labelSprite.graphics.drawRect(0, 0, list.getChildAt(0).width, list.getChildAt(0).height);
			labelSprite.graphics.endFill();
		}
		addChild(labelSprite);
		
		addChild(list);
	}
	
	private function onItemClick(e: MouseEvent) : Void 
	{
		for (label in sprites.keys()) {
			Lib.trace(label);
			if (e.currentTarget == sprites.get(label))
				setCurrentLabel(label);
		}
		list.visible = false;
		labelSprite.visible = true;
		e.stopImmediatePropagation();
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e: MouseEvent) : Void 
	{
		labelSprite.visible = false;
		list.visible = true;
		removeEventListener(MouseEvent.CLICK, onClick);
	}
}