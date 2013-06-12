package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import nme.filters.BitmapFilter;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.Lib;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.element.CharacterDisplay;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.geom.Point;

class KpDisplay extends Sprite {
	/**
    * All the spritesheets used here
    **/
	public var spritesheets:Map<String, TilesheetEx>;

	/**
    * Transition to play at the beginning of the part
    **/
	public var transitionIn (default, default):String;

	/**
    * Transition to play at the end of the part
    **/
	public var transitionOut (default, default):String;

	private var displays:Map<String, {obj:DisplayObject, z:Int}>;
	private var displaysFast:Map<String, Fast>;
	private var zIndex:Int = 0;
	private var textGroups:Map<String, Map<String, {obj:Fast, z:Int}>>;
	private var layers:Map<String, TileLayer>;
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

		if(displayFast.has.transitionIn)
			transitionIn = displayFast.att.transitionIn;
		if(displayFast.has.transitionOut)
			transitionOut = displayFast.att.transitionOut;

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
		if(itemNode.has.src || itemNode.has.filters || itemNode.has.tween){
			addElement(UiFactory.createImageFromXml(itemNode, layers, spritesheets, false), itemNode);
		}
		else{
			UiFactory.createImageFromXml(itemNode, layers, spritesheets, false);
			var spritesheet = itemNode.has.spritesheet?itemNode.att.spritesheet:"ui";
			if(!displays.exists(spritesheet))
				displays.set(spritesheet, {obj: layers.get(spritesheet).view, z: zIndex++});

			displaysFast.set(itemNode.att.id, itemNode);
		}
	}

	private function createButton(buttonNode:Fast):Void
	{
		var button:DefaultButton = UiFactory.createButtonFromXml(buttonNode);

		if(buttonNode.has.action)
			setButtonAction(button, buttonNode.att.action);
		addElement(button, buttonNode);
	}

	private function createText(textNode:Fast):Void
	{
		addElement(UiFactory.createTextFromXml(textNode, spritesheets), textNode);
	}

	private function createTextGroup(textNode:Fast):Void
	{
		var numIndex = 0;
		var hashTextGroup = new Map<String, {obj:Fast, z:Int}>();

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
		if(character.has.nameRef)
			char.nameRef = character.att.nameRef;
		if(character.has.scale)
			char.scale = Std.parseFloat(character.att.scale);
		char.origin = {pos: new Point(Std.parseFloat(character.att.x), Std.parseFloat(character.att.y)), scale: char.scale};
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

	private function setButtonAction(button:DefaultButton, action:String):Void
	{}

	private function new()
	{
		super();
		displays = new Map<String, {obj:DisplayObject, z:Int}>();
		displaysFast = new Map<String, Fast>();
		spritesheets = new Map<String, TilesheetEx>();
		textGroups = new Map<String, Map<String, {obj:Fast, z:Int}>>();
		layers = new Map<String, TileLayer>();
	}
}
