package com.knowledgeplayers.grar.display;

#if flash
import com.knowledgeplayers.grar.display.component.container.VideoPlayer;
#end
import com.knowledgeplayers.grar.util.guide.Guide;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.display.contextual.menu.MenuDisplay;
import com.knowledgeplayers.grar.display.component.container.SoundPlayer;
import com.knowledgeplayers.grar.display.element.ChronoCircle;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.element.Timeline;
import com.knowledgeplayers.grar.display.component.container.SimpleContainer;
import flash.geom.Rectangle;
import com.knowledgeplayers.grar.display.component.ScrollBar;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import haxe.ds.GenericStack;
import flash.events.Event;
import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.Image;
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

using StringTools;

class KpDisplay extends Sprite {

	// Should not be written. Can't be inlined because of inheritance
	private var groupMenu: String = "menu";
	private var groupNotebook: String = "notebook";
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

	/**
	* Fields with dynamic content that need to be update while loading a new part
	**/
	public var dynamicFields (default, null): Array<{field: ScrollPanel, content: String}>;

	/**
	* Map for layer render needed
	**/
	public var renderLayers (default, null):Map<TileLayer, Bool>;

	/**
	* Scroll bars
	**/
	public var scrollBars (default, null):Map<String, ScrollBar>;

	private var displays:Map<String, Widget>;
	private var zIndex:Int = 0;
	private var layers:Map<String, TileLayer>;
	private var displayFast:Fast;
	private var totalSpriteSheets:Int = 0;
	private var textGroups:Map<String, Map<String, {obj:Fast, z:Int}>>;
	private var buttonGroups: Map<String, GenericStack<DefaultButton>>;
	private var displayTemplates: Map<String, Template>;
	private var timelines: Map<String, Timeline>;
	private var guides:Map<String, Guide>;


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

		if(displayFast.has.transitionIn){
			transitionIn = displayFast.att.transitionIn;
			addEventListener(Event.ADDED_TO_STAGE, function(e){
				TweenManager.applyTransition(this, transitionIn);
			});
		}
		if(displayFast.has.transitionOut)
			transitionOut = displayFast.att.transitionOut;
		if(displayFast.has.layout)
			layout = displayFast.att.layout;
		if(displayFast.has.filters){
			filters = FilterManager.getFilter(displayFast.att.filters);
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
			var timeline = new Timeline(child.att.ref);

			for (elem in child.elements){
				var delay = elem.has.delay?Std.parseFloat(elem.att.delay):0;
				// Creating mock widget for dynamic timeline
				if(elem.att.ref.startsWith("$")){
					var mock = new Image();
					mock.ref = elem.att.ref;
					timeline.addElement(mock, elem.att.transition, delay);
				}
				else if(!displays.exists(elem.att.ref)){
					if(guides.exists(elem.att.ref))
						for(obj in guides.get(elem.att.ref).getAllObjects()){
							if(Std.is(obj, Widget))
								timeline.addElement(cast obj, elem.att.transition, delay);
						}
					else
						trace("[KpDisplay] Can't add unexistant widget '"+elem.att.ref+"' in timeline '"+child.att.ref+"'.");
				}
				else
					timeline.addElement(displays.get(elem.att.ref),elem.att.transition,delay);
			}

			timelines.set(child.att.ref,timeline);
		}
		for (elem in displays){
			if(Std.is(elem, DefaultButton))
				cast(elem,DefaultButton).initStates(timelines);
		}
	}

	private function createElement(elemNode:Fast):Widget
	{
		if(elemNode.name.toLowerCase() == "textgroup"){
			createTextGroup(elemNode);
			return null;
		}
		else{
			return switch(elemNode.name.toLowerCase()){
				case "background" | "image": createImage(elemNode);
				case "character": createCharacter(elemNode);
				case "button": createButton(elemNode);
				case "text": createText(elemNode);
				case "video": createVideo(elemNode);
				case "sound": createSound(elemNode);
				case "scrollbar": createScrollBar(elemNode);
				case "div":
					var div = new SimpleContainer(elemNode);
					addElement(div, elemNode);
					div;
	            case "timer":
		            var timer = new ChronoCircle(elemNode);
		            addElement(timer, elemNode);
					timer;
				case "template":
					displayTemplates.set(elemNode.att.ref, {fast: elemNode, z: zIndex++});
					null;
				case "include" :
					if(!DisplayUtils.templates.exists(elemNode.att.ref))
						throw "[KpDisplay] There is no template '"+elemNode.att.ref+"'.";
					var tmpXml = Xml.parse(DisplayUtils.templates.get(elemNode.att.ref).toString()).firstElement();
					for(att in elemNode.x.attributes()){
						if(att != "ref")
							tmpXml.set(att, elemNode.x.get(att));
					}
					createElement(new Fast(tmpXml));
				default: null;
			}
		}
	}

	private function createScrollBar(barNode:Fast):Widget
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
		return scroll;
	}

	private function createImage(itemNode:Fast):Widget
	{
		var spritesheet = itemNode.has.spritesheet?itemNode.att.spritesheet:"ui";
		var img = null;

		if(itemNode.has.src || itemNode.has.filters || (itemNode.has.extract && itemNode.att.extract == "true")){
			img = new Image(itemNode, spritesheets.get(spritesheet));
		}
		else{
			if(!layers.exists(spritesheet)){
				var layer = new TileLayer(UiFactory.tilesheet);
				layers.set(spritesheet, layer);

			}

			img = new TileImage(itemNode, layers.get(spritesheet), false);
		}
		addElement(img, itemNode);
		return img;
	}

	private function createButton(buttonNode:Fast):Widget
	{
		var ref = buttonNode.att.ref;
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
		return button;
	}

	private function createVideo(videoNode: Fast):Widget
	{
		#if flash
		var tilesheet = videoNode.has.spritesheet ? spritesheets.get(videoNode.att.spritesheet) : null;
		var video = new VideoPlayer(videoNode, tilesheet);
		addElement(video, videoNode);
		return video;
		#else
		return null;
		#end
	}
    private function createSound(soundNode: Fast):Widget
	{

		var tilesheet = soundNode.has.spritesheet ? spritesheets.get(soundNode.att.spritesheet) : null;
		var sound = new SoundPlayer(soundNode, tilesheet);
		addElement(sound, soundNode);
		return sound;
	}

	private function createText(textNode:Fast):Widget
	{
		var panel = new ScrollPanel(textNode);
		addElement(panel, textNode);

		if(textNode.has.content && textNode.att.content.startsWith("$")){
			dynamicFields.push({field: panel, content: textNode.att.content.substr(1)});
		}
		return panel;
	}

	private function createTextGroup(textNode:Fast):Void
	{
		var numIndex = 0;
		var hashTextGroup = new Map<String, {obj:Fast, z:Int}>();

		for(child in textNode.elements){
			createElement(child);
			hashTextGroup.set(child.att.ref, {obj:child, z:numIndex});
			numIndex++;
		}

		textGroups.set(textNode.att.ref, hashTextGroup);
	}

	private function createCharacter(character:Fast): Widget
	{
		var char:CharacterDisplay = new CharacterDisplay(character, layers.get(character.att.spritesheet), new Character(character.att.ref));
		if(character.has.nameRef)
			char.nameRef = character.att.nameRef;
		addElement(char, character);
		return char;
	}

	private function addElement(elem:Widget, node:Fast):Void
	{
		if(node.name.toLowerCase() == "background")
			elem.zz = 0;
		else
			elem.zz = zIndex;

		displays.set(node.att.ref, elem);

		ResizeManager.instance.addDisplayObjects(elem, node);
		zIndex++;
	}

	private function setButtonAction(button:DefaultButton, action:String):Bool
	{
		var actionSet = true;
		if(action.toLowerCase() == "open_menu"){
			button.buttonAction = function(?target){
				GameManager.instance.displayContextual(MenuDisplay.instance, MenuDisplay.instance.layout);
			}
			if(!buttonGroups.exists(groupMenu))
				buttonGroups.set(groupMenu, new GenericStack<DefaultButton>());
			buttonGroups.get(groupMenu).add(button);
		}
		else if(action.toLowerCase() == "open_inventory"){
			button.buttonAction = function(?target){
				GameManager.instance.displayContextual(NotebookDisplay.instance, NotebookDisplay.instance.layout);
			}
			if(!buttonGroups.exists(groupNotebook))
				buttonGroups.set(groupNotebook, new GenericStack<DefaultButton>());
			buttonGroups.get(groupNotebook).add(button);
		}
		else if(action.toLowerCase() == "close_menu")
			button.buttonAction = function(?target){
				GameManager.instance.hideContextual(MenuDisplay.instance);
			}
		else if(action.toLowerCase() == ButtonActionEvent.QUIT)
			button.buttonAction = quit;
		else
			actionSet = false;

		return actionSet;
    }

	private function onButtonToggle(e:ButtonActionEvent):Void
	{
		var button = cast(e.target, DefaultButton);
		for(b in buttonGroups.get(button.group)){
			if(b != button)
				b.toggle(button.toggleState != "active");
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

	private inline function quit(?target: DefaultButton):Void
	{
		GameManager.instance.quitGame();
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
		dynamicFields = new Array<{field: ScrollPanel, content: String}>();
		displayTemplates = new Map<String, {fast: Fast, z: Int}>();
		guides = new Map<String, Guide>();

		addEventListener(Event.ENTER_FRAME, checkRender);
	}
}

typedef Template = {
	var fast: Fast;
	var z: Int;
}
