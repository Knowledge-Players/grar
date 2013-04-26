package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.utils.assets.AssetsStorage;
import aze.display.SparrowTilesheet;
import nme.Assets;
import nme.Lib;
import nme.events.Event;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import nme.display.DisplayObject;
import nme.geom.Point;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.display.element.CharacterDisplay;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import aze.display.TileSprite;
import nme.display.Bitmap;
import haxe.xml.Fast;
import nme.display.Sprite;

class KpDisplay extends Sprite {
	/**
    * All the spritesheets used here
    **/
	public var spritesheets:Hash<TilesheetEx>;

	private var displays:Hash<{obj:DisplayObject, z:Int}>;
	private var displaysFast:Hash<Fast>;
	private var zIndex:Int = 0;
	private var textGroups:Hash<Hash<{obj:Fast, z:Int}>>;
	private var layers:Hash<TileLayer>;
	private var displayFast:Fast;
	private var totalSpriteSheets:Int = 0;

	/**
    * Parse the content of a display XML
    * @param    content : Content of the XML
    **/

	public function parseContent(content:Xml):Void
	{
		displayFast = new Fast(content.firstElement());

		for(child in displayFast.nodes.SpriteSheet){
			spritesheets.set(child.att.id, AssetsStorage.getSpritesheet(child.att.src));
			var layer = new TileLayer(AssetsStorage.getSpritesheet(child.att.src));
			layers.set(child.att.id, layer);
		}
		createDisplay();

		ResizeManager.instance.onResize();
	}

	// Privates

	private function createDisplay():Void
	{
		for(child in displayFast.elements){
			createElement(child);
		}
	}

	private function createElement(elemNode:Fast):Void
	{

		switch(elemNode.name.toLowerCase()){
			case "background": createBackground(elemNode);
			case "item": createItem(elemNode);
			case "character": createCharacter(elemNode);
			case "button": createButton(elemNode);
			case "text": createText(elemNode);
			case "textgroup":createTextGroup(elemNode);
		}

	}

	private function createBackground(bkgNode:Fast):Void
	{
		displaysFast.set(bkgNode.att.ref, bkgNode);
		zIndex++;
	}

	private function createItem(itemNode:Fast):Void
	{
		if(itemNode.has.src){
			var itemBmp:Bitmap = new Bitmap();
			#if flash
             itemBmp = new Bitmap(AssetsStorage.getBitmapData(itemNode.att.src));
            #else
			itemBmp = new Bitmap(Assets.getBitmapData(itemNode.att.src));
			#end
			addElement(itemBmp, itemNode);

		}
		else{
			var spritesheet;
			var itemTile = new TileSprite(itemNode.att.id);
			if(itemNode.has.scale)
				itemTile.scale = Std.parseFloat(itemNode.att.scale);
			if(itemNode.has.mirror){
				itemTile.mirror = switch(itemNode.att.mirror.toLowerCase()){
					case "horizontal": 1;
					case "vertical": 2;
				}
			}
			if(itemNode.has.spritesheet){
				layers.get(itemNode.att.spritesheet).addChild(itemTile);
				spritesheet = itemNode.att.spritesheet;
			}
			else{
				spritesheet = "ui";
				if(layers.exists("ui"))
					layers.get("ui").addChild(itemTile);
				else{
					var layer = new TileLayer(UiFactory.tilesheet);
					layer.addChild(itemTile);
					layers.set("ui", layer);
				}
			}

			addElement(layers.get(spritesheet).view, itemNode);
		}

	}

	private function createButton(buttonNode:Fast):Void
	{
		var button:DefaultButton = UiFactory.createButtonFromXml(buttonNode);

		if(buttonNode.has.action)
			setButtonAction(cast(button, CustomEventButton), buttonNode.att.action);
		addElement(button, buttonNode);
	}

	private function createText(textNode:Fast):Void
	{
		var background:String = textNode.has.background ? textNode.att.background : null;
		var spritesheet = null;
		if(background != null && background.indexOf(".") < 0 && textNode.has.spritesheet)
			spritesheet = spritesheets.get(textNode.att.spritesheet);

		var scrollable = textNode.has.scrollable ? textNode.att.scrollable == "true" : true;
		var styleSheet = textNode.has.style ? textNode.att.style : null;

		var text = new ScrollPanel(Std.parseFloat(textNode.att.width), Std.parseFloat(textNode.att.height), scrollable, styleSheet);
		if(textNode.has.textTransition)
			text.textTransition = textNode.att.textTransition;
		if(background != null)
			text.setBackground(background, spritesheet, textNode.has.alpha ? Std.parseFloat(textNode.att.alpha) : 1);
		if(textNode.has.transitionIn)
			text.transitionIn = textNode.att.transitionIn;
		if(textNode.has.transitionOut)
			text.transitionOut = textNode.att.transitionOut;
		addElement(text, textNode);
	}

	private function createTextGroup(textNode:Fast):Void
	{
		var numIndex = 0;
		var hashTextGroup = new Hash<{obj:Fast, z:Int}>();

		for(child in textNode.nodes.Text){
			createText(child);
			hashTextGroup.set(child.att.ref, {obj:child, z:numIndex});
			numIndex++;
		}
		textGroups.set(textNode.att.ref, hashTextGroup);
	}

	private function createCharacter(character:Fast)
	{
		var mirror = character.has.mirror ? character.att.mirror : null;
		var char:CharacterDisplay = new CharacterDisplay(spritesheets.get(character.att.spritesheet), character.att.id, new Character(character.att.ref), mirror);
		char.visible = false;
		char.origin = {pos: new Point(Std.parseFloat(character.att.x), Std.parseFloat(character.att.y)), scale: Std.parseFloat(character.att.scale)};
		char.nameRef = character.att.nameRef;
		if(character.has.scale)
			char.scale = Std.parseFloat(character.att.scale);
		addElement(char, character);

	}

	private function addElement(elem:DisplayObject, node:Fast, initObject:Bool = true):Void
	{
		if(initObject)
			initDisplayObject(elem, node);
		if(node.has.id && !node.has.ref){
			displays.set(node.att.id, {obj: elem, z: zIndex});
			displaysFast.set(node.att.id, node);
		}
		else if(!node.has.ref){
			displays.set(node.att.src, {obj: elem, z: zIndex});
			displaysFast.set(node.att.src, node);
		}
		else{
			displays.set(node.att.ref, {obj: elem, z: zIndex});
			displaysFast.set(node.att.ref, node);
		}
		ResizeManager.instance.addDisplayObjects(elem, node);
		zIndex++;
	}

	private function initDisplayObject(display:DisplayObject, node:Fast, ?transition:String):Void
	{
		if(node.has.x)
			display.x = Std.parseFloat(node.att.x);
		if(node.has.y)
			display.y = Std.parseFloat(node.att.y);

		if(node.has.width)
			display.width = Std.parseFloat(node.att.width);
		else if(node.has.scaleX)
			display.scaleX = Std.parseFloat(node.att.scaleX);
		if(node.has.height)
			display.height = Std.parseFloat(node.att.height);
		else if(node.has.scaleY)
			display.scaleY = Std.parseFloat(node.att.scaleY);
	}

	private function setButtonAction(button:CustomEventButton, action:String):Void
	{}

	private function new()
	{
		super();
		displays = new Hash<{obj:DisplayObject, z:Int}>();
		displaysFast = new Hash<Fast>();
		spritesheets = new Hash<TilesheetEx>();
		textGroups = new Hash<Hash<{obj:Fast, z:Int}>>();
		layers = new Hash<TileLayer>();
	}
}
