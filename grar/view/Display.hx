package grar.view;

import aze.display.TileLayer;
import aze.display.TilesheetEx;

import motion.actuators.GenericActuator.IGenericActuator;

import grar.view.DisplayCallbacks;
import grar.view.ElementData;
import grar.view.guide.Guide;
import grar.view.contextual.NotebookDisplay;
import grar.view.contextual.menu.MenuDisplay;
import grar.view.element.ChronoCircle;
import grar.view.element.Timeline;
import grar.view.component.container.SoundPlayer;
import grar.view.component.container.DefaultButton;
import grar.view.component.container.SimpleContainer;
import grar.view.component.ScrollBar;
#if flash
import grar.view.component.container.VideoPlayer;
#end
import grar.view.component.TileImage;
import grar.view.component.Widget;
import grar.view.component.Image;
import grar.view.component.container.DefaultButton;
import grar.view.component.container.ScrollPanel;
import grar.view.component.CharacterDisplay;
import grar.view.component.container.WidgetContainer;

import grar.util.DisplayUtils;

import flash.geom.Rectangle;
import flash.events.Event;
import flash.display.DisplayObject;
import flash.display.Sprite;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

using StringTools;

typedef Template = {

	var data : ElementData;
	var validation : Null<String>;
}

enum DisplayType {

	Display; // TODO remove ?
	Part;
	Strip;
	Activity(? groups : StringMap<{ x : Float, y : Float, guide : GuideData }>);
	Zone(? bgColor : Null<Int>, ? ref : Null<String>, ? rows : Null<String>, ? columns : Null<String>, ? zones : Null<Array<DisplayData>>);
	Menu(? bookmark : Null<WidgetContainerData>, ? orientation : String, ? levelDisplays : StringMap<MenuLevel>, ? xBase : Null<Float>, ? yBase : Null<Float>);
	Notebook(? chapterTemplates : Null<StringMap<{ offsetY : Float, e : ElementData }>>, ? tabTemplate : Null<{ x : Float, xOffset : Float, e : WidgetContainerData }>, ? bookmark : Null<ImageData>, ? guide : Null<GuideData>, ? step : Null<{ r : String, e : WidgetContainerData, transitionIn : Null<String> }>);
}

typedef DisplayData = {

	var type : DisplayType;
	@:optional var x : Null<Float>;
	@:optional var y : Null<Float>;
	@:optional var width : Null<Float>;
	@:optional var height : Null<Float>;
	@:optional var spritesheets : Null<StringMap<TilesheetEx>>; // set in a second step (service layer)
	@:optional var spritesheetsSrc : StringMap<String>;
	@:optional var transitionIn : Null<String>;
	@:optional var transitionOut : Null<String>;
	@:optional var layout : Null<String>;
	@:optional var filtersData : Null<Array<String>>;
#if (flash || openfl)
	@:optional var filters : Null<Array<flash.filters.BitmapFilter>>; // set in a second step
#end
	@:optional var timelines : StringMap<{ ref : String, elements : Array<{ ref : String, transition : String, delay : Float }> }>;
	var displays : Array<{ ed : ElementData, ref : String }>;
	@:optional var layers : Null<StringMap<TileLayer>>; // set in a second step
	@:optional var layersSrc : StringMap<String>;
}

class Display extends Sprite {

	/**
	 * Never instanciated directly (only in sub-classes)
	 */
	private function new(callbacks : DisplayCallbacks, applicationTilesheet : TilesheetEx) {

		super();
		
		this.displays = new Array();
		this.displaysRefs = new StringMap();
		this.spritesheets = new StringMap();
		this.textGroups = new StringMap();
		this.buttonGroups = new StringMap();
		this.layers = new StringMap();
		this.renderLayers = new Map();
		this.scrollBars = new StringMap();
        this.timelines = new StringMap();
		this.dynamicFields = new Array();
		this.displayTemplates = new StringMap();

		this.callbacks = callbacks;
		this.onContextualDisplayRequest = function(c : grar.view.Application.ContextualType, ? ho : Bool = true){ callbacks.onContextualDisplayRequest(c, ho); }
		this.onContextualHideRequest = function(c : grar.view.Application.ContextualType){ callbacks.onContextualHideRequest(c); }
		this.onQuitGameRequest = function(){ callbacks.onQuitGameRequest(); }
		this.onTransitionRequest = function(t : Dynamic, tt : String, ? de : Float = 0) { return callbacks.onTransitionRequest(t, tt, de); }
		this.onStopTransitionRequest = function(t : Dynamic, ? p : Null<Dynamic>, ? c : Bool = false, ? se : Bool = true){ callbacks.onStopTransitionRequest(t, p, c, se); }
		this.onRestoreLocaleRequest = function(){ callbacks.onRestoreLocaleRequest(); }
		this.onLocalizedContentRequest = function(k : String){ return callbacks.onLocalizedContentRequest(k); }
		this.onLocaleDataPathRequest = function(p : String){ callbacks.onLocaleDataPathRequest(p); }
		this.onStylesheetRequest = function(s : String){ return callbacks.onStylesheetRequest(s); }
		this.onPartDisplayRequest = function(p : grar.model.part.Part){ callbacks.onPartDisplayRequest(p); }
		this.onSoundToLoad = function(sndUri : String){ callbacks.onSoundToLoad(sndUri); }
		this.onSoundToPlay = function(sndUri : String){ callbacks.onSoundToPlay(sndUri); }
		this.onSoundToStop = function(){ callbacks.onSoundToStop(); }

		this.applicationTilesheet = applicationTilesheet;

		addEventListener(Event.ENTER_FRAME, checkRender);
	}

	var callbacks : DisplayCallbacks;

	// Should not be written. Can't be inlined because of inheritance
	private var groupMenu : String = "menu";
	private var groupNotebook : String = "notebook";
	/**
    * All the spritesheets used here
    **/
	public var spritesheets : StringMap<TilesheetEx>;

	var applicationTilesheet : TilesheetEx;

	/**
    * Transition to play at the beginning of the part
    **/
	public var transitionIn (default, default) : String;

	/**
    * Transition to play at the end of the part
    **/
	public var transitionOut (default, default) : String;

	/**
	* Layout where to display this widget
	**/
	public var layout (default, default) : String;

	/**
	* Fields with dynamic content that need to be update while loading a new part
	**/
	public var dynamicFields (default, null) : Array<{field: ScrollPanel, content: String}>;

	/**
	* Map for layer render needed
	**/
	public var renderLayers (default, null) : Map<TileLayer, Bool>;

	/**
	* Scroll bars
	**/
	public var scrollBars (default, null) : StringMap<ScrollBar>;

	/**
	 * An array to keep the original z order from XML
	 */
	private var displays : Array<{ w : Widget, ref : String }>;
	/**
	 * A StringMap to ease retreiving widgets by ref
	 */
	private var displaysRefs : StringMap<Widget>;

//	private var zIndex : Int = 0;
	private var layers : StringMap<TileLayer>;

	private var totalSpriteSheets : Int = 0;
//	private var textGroups:Map<String, Map<String, {obj:Fast, z:Int}>>;
	private var textGroups : StringMap<StringMap<{ obj : ElementData, z : Int }>>; // ??? don't understand the use of it
	private var buttonGroups : StringMap<GenericStack<DefaultButton>>;
	private var displayTemplates : StringMap<Template>;
	private var timelines : StringMap<Timeline>;

	var data : Null<DisplayData> = null;


	///
	// CALLBACKS
	//

	public dynamic function onContextualDisplayRequest(c : grar.view.Application.ContextualType, ? hideOther : Bool = true) : Void { }

	public dynamic function onContextualHideRequest(c : grar.view.Application.ContextualType) : Void { }

	public dynamic function onQuitGameRequest() : Void { }

	public dynamic function onTransitionRequest(target : Dynamic, transition : String, ? delay : Float = 0) : IGenericActuator { return null; }

	public dynamic function onStopTransitionRequest(target : Dynamic, ? properties : Null<Dynamic>, ? complete : Bool = false, ? sendEvent : Bool = true) : Void {  }

	public dynamic function onRestoreLocaleRequest() : Void { }

	public dynamic function onLocalizedContentRequest(k : String) : String { return null; }

	public dynamic function onLocaleDataPathRequest(uri : String) : Void { }

	public dynamic function onStylesheetRequest(s : Null<String>) : grar.view.style.StyleSheet { return null; }

	public dynamic function onPartDisplayRequest(p : grar.model.part.Part) : Void { }

	public dynamic function onUpdateDynamicFieldsRequest() : Void { }

	public dynamic function onSoundToLoad(sound : String) : Void { }

	public dynamic function onSoundToPlay(sound : String) : Void { }

	public dynamic function onSoundToStop() : Void { }


	///
	// API
	//

	//public function parseContent(content:Xml):Void
	public function setContent(d : DisplayData) : Void {
trace("setContent, display type is "+d.type);
		this.data = d;

		if (d.x != null) {

			x = d.x;
		}
		if (d.y != null) {

			y = d.y;
		}
		this.spritesheets = d.spritesheets;

		if (d.width != null && d.height != null) {

			DisplayUtils.initSprite(this, d.width, d.height, 0, 0.001);
		}
		if (d.spritesheets != null) {

			for (sk in d.spritesheets.keys()) {
//trace("add TileLayer " + sk);
				var layer = new TileLayer(spritesheets.get(sk));
				layers.set(sk, layer);

				addChild(layer.view);
			}
		}
		var uiLayer = new TileLayer(applicationTilesheet);
		layers.set("ui", uiLayer);
		addChild(uiLayer.view);// trace("add ui TileLayer ");

		createDisplay(d);

		if (d.transitionIn != null) {

			transitionIn = d.transitionIn;
//trace("TRANSITION IN");
			addEventListener(Event.ADDED_TO_STAGE, function(e){
//trace("display added to stage");
// 					TweenManager.applyTransition(this, transitionIn);
					onTransitionRequest(this, transitionIn);

				});
		}
		if (d.transitionOut != null) {

			transitionOut = d.transitionOut;
		}
		if (d.layout != null) {

			layout = d.layout;
		}
		if (d.filters != null) {

			filters = d.filters;
		}
// 		ResizeManager.instance.onResize();
	}

	public function getLayer(id : String) : TileLayer {

		return layers.get(id);
	}


	///
	// INTERNALS
	//

	private function createDisplay(d : DisplayData) : Void {

		for (c in d.displays) {

			createElement(c.ed, c.ref);
		}
		for (t in d.timelines) {

			var timeline = new Timeline(callbacks, t.ref);

			for (e in t.elements) {

				// Creating mock widget for dynamic timeline
				if (e.ref.startsWith("$")) {

					var mock = new Image(callbacks, applicationTilesheet);
					mock.ref = e.ref;


					timeline.addElement(mock, e.transition, e.delay);
				
				} else if(!displaysRefs.exists(e.ref)) {

					throw "[Display] Can't add unexisting widget '"+e.ref+"' in timeline '"+t.ref+"'.";
				
				} else {

					timeline.addElement(displaysRefs.get(e.ref), e.transition, e.delay);
				}
			}
			timelines.set(t.ref, timeline);
		}
		for (elem in displays) {

			if (Std.is(elem.w, grar.view.component.container.DefaultButton)) { // could be avoided / improved with a collection of enums

				cast(elem.w, grar.view.component.container.DefaultButton).initStates(timelines);
			}
		}
	}

	//private function createElement(elemNode:Fast):Widget
	private function createElement(e : ElementData, r : String) : Widget {

		switch (e) {

			case TextGroup(d):

				createTextGroup(r, d);
				return null;

			case Image(d):

				return createImage(r, d);

			case TileImage(d):

				return createTileImage(r, d);

			case Character(d):

				return createCharacter(r, d);

			case DefaultButton(d):

				return createButton(r, d);

			case ScrollPanel(d):

				return createText(r, d);

			case VideoPlayer(d):

				return createVideo(r, d);

			case SoundPlayer(d):

				return createSound(r, d);

			case ScrollBar(d):

				return createScrollBar(r, d);

			case SimpleContainer(d):

				var div = new SimpleContainer(callbacks, applicationTilesheet, d);
				
				addElement(div, r);
				
				return div;

			case ChronoCircle(d):

	            var timer = new ChronoCircle(callbacks, applicationTilesheet, d);

	            addElement(timer, r);

				return timer;

			case Template(d):

				displayTemplates.set(r, d);

				return null;

			default: // nothing
		}
		return null;
	}

	private function createScrollBar(r : String, d : { width : Float, bgColor : Null<String>, cursorColor : Null<String>, bgTile : Null<String>, tile : String, tilesheet : Null<String>, cursor9Grid : Array<Float>, bg9Grid : Null<Array<Float>> }) : Widget {

		var tilesheet = d.tilesheet != null ? spritesheets.get(d.tilesheet) : applicationTilesheet;

		var cursor9Grid : Rectangle = new Rectangle(d.cursor9Grid[0], d.cursor9Grid[1], d.cursor9Grid[2], d.cursor9Grid[3]);
		
		var bg9Grid : Rectangle;
		
		if (d.bg9Grid != null) {

			bg9Grid = new Rectangle(d.bg9Grid[0], d.bg9Grid[1], d.bg9Grid[2], d.bg9Grid[3]);
		
		} else {

			bg9Grid = cursor9Grid;
		}
		var scroll = new ScrollBar(callbacks, applicationTilesheet, d.width, tilesheet, d.tile, d.bgTile, cursor9Grid, bg9Grid, d.cursorColor, d.bgColor);

		scrollBars.set(r, scroll);

		return scroll;
	}

    private function createSound(r : String, d : WidgetContainerData) : Widget {

    	switch (d.type) {

    		case SoundPlayer:

				var sound = new SoundPlayer(callbacks, applicationTilesheet, d, d.spritesheetRef != null ? spritesheets.get(d.spritesheetRef) : null);
				addElement(sound, r);

				return sound;

    		default: throw "wrong WidgetContainerData type passed to createSound function: " + d.type;
    	}

		return null;
	}

	private function createVideo(r : String, d : WidgetContainerData) : Widget {
#if flash
		switch (d.type) {

			case VideoPlayer(controlsHidden, autoFullscreen):

				var video = new VideoPlayer(callbacks, applicationTilesheet, d, d.spritesheetRef != null ? spritesheets.get(d.spritesheetRef) : null);

				addElement(video, r);
				
				return video;

			default: throw "wrong WidgetContainerData type passed to createVideo function: " + d.type;
		}
#end
		return null;
	}

	private function createText(r : String, d : WidgetContainerData) : Widget {

		switch(d.type) {

			case ScrollPanel(styleSheet, style, content, trim):

				var panel = new ScrollPanel(callbacks, applicationTilesheet, d);

				addElement(panel, r);

				if (content != null && content.startsWith("$")) {

					dynamicFields.push({ field: panel, content: content.substr(1) });
				}
				return panel;

			default: throw "wrong WidgetContainerData type passed to createText function: " + d.type;
		}
		return null;
	}

	//private function createButton(buttonNode : Fast) : Widget {
	private function createButton(r : String, d : WidgetContainerData) : Widget {

		switch (d.type) {

			case DefaultButton(ds, ite, action, group, e, _, _):
				
				var btn : DefaultButton = new DefaultButton(callbacks, applicationTilesheet, d);

				if (action != null) {

					setButtonAction(btn, action);
				}
				if (group != null) {

					if (buttonGroups.exists(group)) {

						buttonGroups.get(group).add(btn);
					
					} else {

						var stack : GenericStack<DefaultButton> = new GenericStack<DefaultButton>();
						stack.add(btn);
						buttonGroups.set(group, stack);
					}
				}
				if (btn.group != null) {

// 					btn.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
					btn.onToggle = function(){ onButtonToggle(btn); };
				}

				addElement(btn, r);
				
				return btn;

			default: throw "wrong WidgetContainerData type passed to createButton function: "+d.type;
		}
		return null;
	}

	private function createCharacter(r : String, d : CharacterData) : Widget {
//new CharacterDisplay(character, layers.get(character.att.spritesheet), new Character(character.att.ref));
		var c : CharacterDisplay = new CharacterDisplay(callbacks, applicationTilesheet, d, layers.get(d.tid.tilesheetName));
		
		addElement(c, r);
		
		return c;
	}

	//private function createImage(itemNode:Fast):Widget
	private function createTileImage(r : String, d : TileImageData) : Widget {

		if (d.tilesheetName == null) {

			d.tilesheetName = "ui";
		}
		if (!layers.exists(d.tilesheetName)) {

			var layer = new TileLayer(applicationTilesheet);
			layers.set(d.tilesheetName, layer);
		}
		var img = new TileImage(callbacks, applicationTilesheet, d, layers.get(d.tilesheetName));
		
		addElement(img, r);
		
		return img;
	}
	private function createImage(r : String, d : ImageData) : Widget {

		var img =  new Image(callbacks, applicationTilesheet, d, spritesheets.get(d.tilesheetRef));

		addElement(img, r);
		
		return img;
	}

	//private function createTextGroup(textNode:Fast):Void
	private function createTextGroup(r : String, d : StringMap<{ obj : ElementData, z : Int }>) : Void {

		for (ek in d.keys()) {

			createElement(d.get(ek).obj, ek);
		}
		textGroups.set(r, d); //trace("Add TextGroup "+r);
	}

	//private function addElement(elem:Widget, node:Fast):Void
	private function addElement(elem : Widget, ref : String) : Void {

		displays.push({ ref: ref, w: elem });
		displaysRefs.set(ref, elem);
	}

	private function setButtonAction(button : DefaultButton, action : String) : Bool {

		var actionSet = true;
		
		if (action.toLowerCase() == "open_menu") { 

			button.buttonAction = function(? target) {

// 					GameManager.instance.displayContextual(MenuDisplay.instance, MenuDisplay.instance.layout);
					onContextualDisplayRequest(MENU);

				}

			if (!buttonGroups.exists(groupMenu)) {

				buttonGroups.set(groupMenu, new GenericStack<DefaultButton>());
			}
			buttonGroups.get(groupMenu).add(button);
		
		} else if(action.toLowerCase() == "open_inventory") {

			button.buttonAction = function(? target) {

// 					GameManager.instance.displayContextual(NotebookDisplay.instance, NotebookDisplay.instance.layout);
					onContextualDisplayRequest(NOTEBOOK);

				}
			
			if (!buttonGroups.exists(groupNotebook)) {

				buttonGroups.set(groupNotebook, new GenericStack<DefaultButton>());
			}
			buttonGroups.get(groupNotebook).add(button);
		
		} else if (action.toLowerCase() == "close_menu") {

			button.buttonAction = function(? target) {

// 				GameManager.instance.hideContextual(MenuDisplay.instance);
				onContextualHideRequest(MENU);

			}

		} else if (action.toLowerCase() == "quit") {

			button.buttonAction = quit;

		} else {

			actionSet = false;
		}

		return actionSet;
    }

	private function onButtonToggle(button : DefaultButton) : Void {

		for (b in buttonGroups.get(button.group)) {

			if (b != button) {

				b.toggle(button.toggleState != "active");
			}
		}
	}

	private function checkRender(e:Event):Void {

		for (layer in renderLayers.keys()) {

			if (renderLayers.get(layer)) {

				layer.render();

				renderLayers.set(layer, false);
			}
		}
	}

	private function getZPosition(x : Widget) : Int {

		for (ei in 0...displays.length) {

			if (displays[ei].w == x) {

				return ei;
			}
		}
		return -1;
	}

	private inline function quit(? target : DefaultButton) : Void {

// 		GameManager.instance.quitGame();
		onQuitGameRequest();
	}
}