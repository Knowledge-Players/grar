package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.event.ButtonActionEvent;
import haxe.ds.GenericStack;
import nme.events.Event;
import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import nme.filters.BitmapFilter;
import com.knowledgeplayers.grar.util.DisplayUtils;
import nme.Lib;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.component.CharacterDisplay;
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

	/**
	* Layout where to display this widget
	**/
	public var layout (default, default):String;

	public var renderLayers (default, null):Map<TileLayer, Bool>;

	private var displays:Map<String, Widget>;
	private var zIndex:Int = 0;
	private var layers:Map<String, TileLayer>;
	private var displayFast:Fast;
	private var totalSpriteSheets:Int = 0;
	private var textGroups:Map<String, Map<String, {obj:Fast, z:Int}>>;
	private var buttonGroups: Map<String, GenericStack<DefaultButton>>;

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
		if(displayFast.has.layout)
			layout = displayFast.att.layout;

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
			case "background" | "image": createImage(elemNode);
			case "character": createCharacter(elemNode);
			case "button": createButton(elemNode);
			case "text": createText(elemNode);
			case "textgroup":createTextGroup(elemNode);
		}

	}

	private function createImage(itemNode:Fast):Void
	{
		var spritesheet = itemNode.has.spritesheet?itemNode.att.spritesheet:"ui";
		if(itemNode.has.src || itemNode.has.filters){
			addElement(new Image(itemNode, spritesheets.get(spritesheet)), itemNode);
		}
		else{
			if(!layers.exists(spritesheet)){
				var layer = new TileLayer(UiFactory.tilesheet);
				layers.set(spritesheet, layer);
			}
			addElement(new TileImage(itemNode, layers.get(spritesheet), false), itemNode);
		}
	}

	private function createButton(buttonNode:Fast):Void
	{
		var button:DefaultButton = new DefaultButton(buttonNode);

		if(buttonNode.has.action)
			setButtonAction(button, buttonNode.att.action);
		if(buttonNode.has.group){
			if(buttonGroups.exists(buttonNode.att.group.toLowerCase()))
				buttonGroups.get(buttonNode.att.group.toLowerCase()).add(button);
			else{
				var stack = new GenericStack<DefaultButton>();
				stack.add(button);
				buttonGroups.set(buttonNode.att.group.toLowerCase(), stack);
			}
		}
		button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
		addElement(button, buttonNode);
	}

	private function createText(textNode:Fast):Void
	{
		addElement(new ScrollPanel(textNode), textNode);
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
		addElement(char, character);

	}

	private function addElement(elem:Widget, node:Fast):Void
	{
		elem.z = zIndex;
		if(node.has.id && !node.has.ref){
			displays.set(node.att.id, elem);
		}
		else if(!node.has.ref){
			displays.set(node.att.src, elem);
		}
		else{
			displays.set(node.att.ref, elem);
		}

		ResizeManager.instance.addDisplayObjects(elem, node);
		zIndex++;
	}

	private function setButtonAction(button:DefaultButton, action:String):Void
	{}

	private function onButtonToggle(e:ButtonActionEvent):Void
	{
		var button = cast(e.target, DefaultButton);
		if(button.toggle == "inactive"){
			for(b in buttonGroups.get(button.group)){
				if(b != button)
					b.setToggle(true);
			}
		}
	}

	private function checkRender(e:Event):Void
	{
		for(layer in renderLayers.keys()){
			if(renderLayers.get(layer)){
				layer.render();
				renderLayers.set(layer, false);
			}
		}
	}

	private function new()
	{
		super();
		displays = new Map<String, Widget>();
		spritesheets = new Map<String, TilesheetEx>();
		textGroups = new Map<String, Map<String, {obj:Fast, z:Int}>>();
		buttonGroups = new Map<String, GenericStack<DefaultButton>>();
		layers = new Map<String, TileLayer>();
		renderLayers = new Map<TileLayer, Bool>();

		addEventListener(Event.ENTER_FRAME, checkRender);
	}
}
