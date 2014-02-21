package grar.parser;

import grar.view.Display;
import grar.view.component.Image;
import grar.view.component.TileImage;
import grar.view.component.CharacterDisplay;

import haxe.ds.StringMap;

import haxe.xml.Fast;

enum DisplayType {

	Display; // TODO remove
	Zone;
	Menu;
	Notebook;
	Part;
	// TODO find others
}

class XmlToDisplay {


	///
	// API
	//

	/**
	 * You should call this method only from GameService as there is a two-step loading because of assets
	 */
	static public function parse(xml : Xml, type : DisplayType) : DisplayData {

		var f : Fast = new Fast(xml.firstElement());


		// TODO switch on type, ...

		var dd : DisplayData = parseContent(f : Fast, type);

		return dd;
	}


	///
	// INTERNALS
	//

	enum ElementData = {

		Image(i : ImageData);
		TileImage(ti : TileImageData);
		CharacterData(c : CharacterData);
	}

	typedef DisplayData = {

		var x : Null<Float> = null;
		var y : Null<Float> = null;
		var width : Null<Float> = null;
		var height : Null<Float> = null;
		var spritesheets : Null<StringMap<TilesheetEx>>; // set in second step
		var spritesheetsSrc : StringMap<String>;
		var transitionIn : Null<String>;
		var transitionOut : Null<String>;
		var layout : Null<String>;
		var filters : Null<String>;
		var timelines : StringMap<TimelineData>;
		var displays : StringMap<ElementData>;
		var layers : Null<StringMap<TileLayer>>; // set in second step
		var layersSrc : StringMap<String>;
	}

	static function parseContent(f : Fast, type : DisplayType) : DisplayData {

		// parseContent(content:Xml):Void
		//displayFast = new Fast(content.firstElement());

		var dd : DisplayData = { };

		dd.spritesheetsSrc = new StringMap();
		dd.timelines = new StringMap();
		dd.displays = new StringMap();
		dd.layersSrc = new StringMap();

		if (f.has.x) {

			dd.x = Std.parseFloat(f.att.x);
		}
		if (f.has.y) {

			dd.y = Std.parseFloat(f.att.y);
		}
		if (f.has.width && f.has.height) {

			dd.width = Std.parseFloat(f.att.width);
			dd.height = Std.parseFloat(f.att.height);
			// FIXME DisplayUtils.initSprite(this, Std.parseFloat(f.att.width), Std.parseFloat(f.att.height), 0, 0.001);
		}
		for (child in f.nodes.SpriteSheet) {

			//dd.spritesheets.set(child.att.id, AssetsStorage.getSpritesheet(child.att.src)); // FIXME
			dd.spritesheetsSrc.set(child.att.id, child.att.src);

			dd.layersSrc.set(child.att.id, child.att.src);

			// FIXME var layer = new TileLayer(AssetsStorage.getSpritesheet(child.att.src));
			// FIXME layers.set(child.att.id, layer);
			// FIXME addChild(layer.view);
		}
		dd.layersSrc.set("ui", "");
		// FIXME var uiLayer = new TileLayer(UiFactory.tilesheet);
		// FIXME layers.set("ui", uiLayer);
		// FIXME addChild(uiLayer.view);

		dd = createDisplay(f, type, dd);

		if (f.has.transitionIn) {

			dd.transitionIn = f.att.transitionIn;

			// FIXME addEventListener(Event.ADDED_TO_STAGE, function(e){
			// FIXME 	TweenManager.applyTransition(this, transitionIn);
			// FIXME });
		}
		if (f.has.transitionOut) {

			dd.transitionOut = f.att.transitionOut;
		}
		if (f.has.layout) {

			dd.layout = f.att.layout;
		}
		if (f.has.filters) {

			filters = f.att.filters;
			// FIXME filters = FilterManager.getFilter(f.att.filters);
		}
		// FIXME ResizeManager.instance.onResize();
	}

	static function createDisplay(f : Fast, type : DisplayType, dd : DisplayData) : DisplayData {

		for (child in f.elements) {

			dd = createElement(child, type, dd);
		}
		for (child in f.nodes.Timeline) {

			var t : TimelineData = XmlToTimeline.parseTimelineData(child);

			timelines.set(t.name, t);
		}
		for (elem in dd.displays) {

			// FIXME if (Std.is(elem, DefaultButton)) {

				// FIXME cast(elem,DefaultButton).initStates(timelines);
			// FIXME }
		}
	}

	//static function createElement(elemNode:Fast) : Widget {
	static function createElement(f : Fast, type : DisplayType, dd : DisplayData) : DisplayData {

		switch (f.name.toLowerCase()) {

// FIXME	case "textgroup": // useful for Parts only

// FIXME		createTextGroup(f, type, dd);

			case "background" | "image":

				dd = createImage(f, type, dd);
			
			case "character":

				dd = createCharacter(f, type, dd);
			
			case "button":

				dd = createButton(f, type, dd);
			
			case "text":

				createText(f);
			
			case "video":

				createVideo(f);
			
			case "sound":

				createSound(f);
			
			case "scrollbar":

				createScrollBar(f);
			
			case "div":

				var div = new SimpleContainer(f);
				addElement(div, f);
				div;
            
            case "timer":

	            var timer = new ChronoCircle(f);
	            addElement(timer, f);
				timer;
			
			case "template":

				displayTemplates.set(f.att.ref, {fast: f, z: zIndex++});
				null;
			
			case "include" :

				if (!DisplayUtils.templates.exists(f.att.ref)) {

					throw "[KpDisplay] There is no template '"+f.att.ref+"'.";
				}
				var tmpXml = Xml.parse(DisplayUtils.templates.get(f.att.ref).toString()).firstElement();
				
				for (att in f.x.attributes()) {

					if (att != "ref") {

						tmpXml.set(att, f.x.get(att));
					}
				}
				createElement(new Fast(tmpXml));
			
			default: // nothing
		}
	}

	enum ElementData {

		Image();
	}

/* FIXME useful for Parts only
	//static function createTextGroup(textNode : Fast) : Void {
	static function createTextGroup(f : Fast, type : DisplayType, dd : DisplayData) : Void {

		var numIndex = 0;
		var hashTextGroup : StringMap<{obj:Fast, z:Int}> = new StringMap();

		for (child in f.elements) {

			createElement(child, type, dd);
			hashTextGroup.set(child.att.ref, {obj:child, z:numIndex});
			numIndex++;
		}
		textGroups.set(textNode.att.ref, hashTextGroup);
	}
*/

	//static function createImage(itemNode:Fast):Widget
	static function createImage(f : Fast, type : DisplayType, dd : DisplayData) : DisplayData {

		var spritesheet = f.has.spritesheet ? f.att.spritesheet : "ui";

		var img : ElementData;

		if (f.has.src || f.has.filters || (f.has.extract && f.att.extract == "true")) {

			//img = new Image(f, dd.spritesheets.get(spritesheet));
			img = Image( XmlToImage.parseImageData(f, spritesheet );
		
		} else {

// FIXME			if (!layers.exists(spritesheet)) {

// FIXME				var layer = new TileLayer(UiFactory.tilesheet);
// FIXME				layers.set(spritesheet, layer);
// FIXME			}
			//img = new TileImage(f, layers.get(spritesheet), false);
			img = TileImage( XmlToImage.parseTileImageData(f, spritesheet );
		}
		// addElement(img, f);
		dd.displays.set(f.att.ref, img);
		
		return dd;
	}

	//static function createCharacter(character:Fast): Widget
	static function createCharacter(f : Fast, type : DisplayType, dd : DisplayData) : DisplayData {

		var c : CharacterData = XmlToCharacter.parseCharacterData(f);
		
		//addElement(char, character);
		dd.displays.set(Character(c));
		
		return dd;
	}

	//static function createButton(buttonNode:Fast):Widget
	static function createButton(f : Fast, type : DisplayType, dd : DisplayData) : DisplayData {

		var ref = f.att.ref;
		var button : DefaultButton = new DefaultButton(f);
		
		if (f.has.action) {

			setButtonAction(button, f.att.action);
		}
		if (f.has.group) {

			if (buttonGroups.exists(f.att.group.toLowerCase())) {

				buttonGroups.get(f.att.group.toLowerCase()).add(button);
			
			} else {

				var stack = new GenericStack<DefaultButton>();
				stack.add(button);
				buttonGroups.set(f.att.group.toLowerCase(), stack);
			}
		}
		if (button.group != null) {

			button.addEventListener(ButtonActionEvent.TOGGLE, onButtonToggle);
		}
		//addElement(button, f);
		dd.displays.set(Button(b));

		return dd;
	}



	static function createScrollBar(barNode : Fast) : Widget {

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

	static function createVideo(videoNode: Fast):Widget
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
    static function createSound(soundNode: Fast):Widget
	{

		var tilesheet = soundNode.has.spritesheet ? spritesheets.get(soundNode.att.spritesheet) : null;
		var sound = new SoundPlayer(soundNode, tilesheet);
		addElement(sound, soundNode);
		return sound;
	}

	static function createText(textNode:Fast):Widget
	{
		var panel = new ScrollPanel(textNode);
		addElement(panel, textNode);

		if(textNode.has.content && textNode.att.content.startsWith("$")){
			dynamicFields.push({field: panel, content: textNode.att.content.substr(1)});
		}
		return panel;
	}
}