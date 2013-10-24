package com.knowledgeplayers.grar.display;

import com.knowledgeplayers.grar.display.component.container.SoundPlayer;
import com.knowledgeplayers.grar.display.element.ChronoCircle;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.element.Timeline;
import com.knowledgeplayers.grar.display.component.container.SimpleContainer;
import flash.geom.Rectangle;
import com.knowledgeplayers.grar.display.component.ScrollBar;
#if flash
import com.knowledgeplayers.grar.display.component.container.VideoPlayer;
#end
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import haxe.ds.GenericStack;
import flash.events.Event;
import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.Image;
import flash.filters.BitmapFilter;
import com.knowledgeplayers.grar.util.DisplayUtils;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.component.CharacterDisplay;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.xml.Fast;
import flash.display.DisplayObject;
import flash.display.Sprite;

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
	public var scrollBars (default, null):Map<String, ScrollBar>;

	private var displays:Map<String, Widget>;
	private var zIndex:Int = 0;
	private var layers:Map<String, TileLayer>;
	private var displayFast:Fast;
	private var totalSpriteSheets:Int = 0;
	private var textGroups:Map<String, Map<String, {obj:Fast, z:Int}>>;
	private var buttonGroups: Map<String, GenericStack<DefaultButton>>;

	private var timelines: Map<String, Timeline>;


		/**
    * Parse the content of a display XML
    * @param    content : Content of the XML
    **/

	public function parseContent(content:Xml):Void
	{
		displayFast = new Fast(content.firstElement());

		if(displayFast.has.x)
			x = Std.parseFloat(displayFast.att.x);
		if(displayFast.has.y)
			y = Std.parseFloat(displayFast.att.y);
		if(displayFast.has.width && displayFast.has.height)
			DisplayUtils.initSprite(this, Std.parseFloat(displayFast.att.width), Std.parseFloat(displayFast.att.height), 0, 0.001);
		var i: Int = 0;
		for(child in displayFast.nodes.SpriteSheet){
			spritesheets.set(child.att.id, AssetsStorage.getSpritesheet(child.att.src));
			var layer = new TileLayer(AssetsStorage.getSpritesheet(child.att.src));
			layers.set(child.att.id, layer);
			addChild(layer.view);
			i++;
		}
		var uiLayer = new TileLayer(UiFactory.tilesheet);
		layers.set("ui", uiLayer);
		addChild(uiLayer.view);

		createDisplay();

		if(displayFast.has.transitionIn)
			transitionIn = displayFast.att.transitionIn;
		if(displayFast.has.transitionOut)
			transitionOut = displayFast.att.transitionOut;
		if(displayFast.has.layout)
			layout = displayFast.att.layout;
		if(displayFast.has.filters){
			var filtersArray = new Array<BitmapFilter>();
			for(filter in displayFast.att.filters.split(","))
				filtersArray.push(FilterManager.getFilter(filter));
			filters = filtersArray;
		}


		ResizeManager.instance.onResize();
	}

	public function getLayer(id:String):TileLayer
	{
		return layers.get(id);
	}

	// Privates

	private function createDisplay():Void
	{
		for(child in displayFast.elements){
			createElement(child);
		}

		for(child in displayFast.nodes.Timeline){
			var timeLine = new Timeline(child.att.ref);

			for (elem in child.elements){
				var delay = elem.has.delay?Std.parseFloat(elem.att.delay):0;
				timeLine.addElement(displays.get(elem.att.ref),elem.att.transition,delay);
			}

			timelines.set(child.att.ref,timeLine);
		}
		for (elem in displays){
			if(Std.is(elem, DefaultButton))
				cast(elem,DefaultButton).initStates(timelines);
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
			case "video": createVideo(elemNode);
            case "sound": createSound(elemNode);
			case "scrollbar": createScrollBar(elemNode);
			case "div": addElement(new SimpleContainer(elemNode), elemNode);
            case "timer":addElement(new ChronoCircle(elemNode),elemNode);

		}
	}

	private function createScrollBar(barNode:Fast):Void
	{
		var bgColor = barNode.has.bgColor ? barNode.att.bgColor : null;
		var cursorColor = barNode.has.cursorColor ? barNode.att.cursorColor : null;
		var bgTile = barNode.has.bgTile ? barNode.att.bgTile : null;
		var tilesheet = barNode.has.spritesheet?spritesheets.get(barNode.att.spritesheet):UiFactory.tilesheet;

		var grid = new Array<Float>();
		for(number in barNode.att.cursor9Grid.split(","))
			grid.push(Std.parseFloat(number));
		var cursor9Grid = new Rectangle(grid[0], grid[1], grid[2], grid[3]);
		var bg9Grid;
		if(barNode.has.bg9Grid){
			var bgGrid = new Array<Float>();
			for(number in barNode.att.bg9Grid.split(","))
				bgGrid.push(Std.parseFloat(number));
			bg9Grid = new Rectangle(bgGrid[0], bgGrid[1], bgGrid[2], bgGrid[3]);
		}
		else
			bg9Grid = cursor9Grid;
		var scroll = new ScrollBar(Std.parseFloat(barNode.att.width), tilesheet, barNode.att.tile, bgTile, cursor9Grid, bg9Grid, cursorColor, bgColor);
		scrollBars.set(barNode.att.ref, scroll);
	}

	private function createImage(itemNode:Fast):Void
	{
		var spritesheet = itemNode.has.spritesheet?itemNode.att.spritesheet:"ui";


		if(itemNode.has.src || itemNode.has.filters || (itemNode.has.extract && itemNode.att.extract == "true")){
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
		if(button.group != null)
			button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
		addElement(button, buttonNode);
	}

	private function createVideo(videoNode: Fast):Void
	{
		#if flash
		var tilesheet = videoNode.has.spritesheet ? spritesheets.get(videoNode.att.spritesheet) : null;
		var video = new VideoPlayer(videoNode, tilesheet);
		addElement(video, videoNode);
		#end
	}
    private function createSound(soundNode: Fast):Void
	{


		var tilesheet = soundNode.has.spritesheet ? spritesheets.get(soundNode.att.spritesheet) : null;
		var sound = new SoundPlayer(soundNode, tilesheet);
		addElement(sound, soundNode);

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
		#if flash
			if(textNode.hasNode.Video){
				createVideo(textNode.node.Video);
				hashTextGroup.set(textNode.node.Video.att.ref, {obj: textNode.node.Video, z: numIndex});
			}
		#end

        if(textNode.hasNode.Sound){
            createSound(textNode.node.Sound);
            hashTextGroup.set(textNode.node.Sound.att.ref, {obj: textNode.node.Sound, z: numIndex});
        }

		textGroups.set(textNode.att.ref, hashTextGroup);
	}

	private function createCharacter(character:Fast)
	{
		var char:CharacterDisplay = new CharacterDisplay(character, layers.get(character.att.spritesheet), new Character(character.att.ref));
		if(character.has.nameRef)
			char.nameRef = character.att.nameRef;
		addElement(char, character);

	}

	private function addElement(elem:Widget, node:Fast):Void
	{
		elem.zz = zIndex;
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
	{
		// override in subclass
    }

	private function onButtonToggle(e:ButtonActionEvent):Void
	{
		var button = cast(e.target, DefaultButton);
		if(button.toggleState == "inactive"){
			for(b in buttonGroups.get(button.group)){
				if(b != button)
					b.toggle(true);
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

	private inline function sortDisplayObjects(x:Widget, y:Widget):Int
	{
		if(x.zz < y.zz)
			return -1;
		else if(x.zz > y.zz)
			return 1;
		else
			return 0;
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
		scrollBars = new Map<String, ScrollBar>();
        timelines = new Map<String, Timeline>();

		addEventListener(Event.ENTER_FRAME, checkRender);
	}
}
