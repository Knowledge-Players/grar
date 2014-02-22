package grar.parser;

import grar.view.Display;
import grar.view.component.Image;
import grar.view.component.TileImage;
import grar.view.component.CharacterDisplay;

import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToDisplay {

	///
	// API
	//

	/**
	 * You should call this method only from GameService as there is a two-step loading because of assets
	 */
	static public function parseDisplayData(xml : Xml, type : DisplayType) : DisplayData {

		var f : Fast = new Fast(xml.firstElement());


		// TODO switch on type, ...

		var dd : DisplayData = parseContent(f : Fast, type);

		return dd;
	}


	///
	// INTERNALS
	//

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

			var ret : { e : Null<ElementData>, r : Null<String> } = createElement(child, type, dd);
			
			if (ret.e != null && ret.r != null) {

				dd.displays.set(ret.r, ret.e);
			}
		}
		for (c in f.nodes.Timeline) {

			var t : { ref : String, elements : Array<{ ref : String, transition : String, delay : Float }> };

			t = {
					ref: c.att.ref,
					elements: [],
				};

			for (e in c.elements) {

				t.elements.push({   ref: e.att.ref,
									transition: e.att.transition,
									delay: e.has.delay ? Std.parseFloat(e.att.delay) : 0 });
			}

			timelines.set(t.ref, t);
		}
		for (elem in dd.displays) {

			// FIXME if (Std.is(elem, DefaultButton)) {

				// FIXME cast(elem,DefaultButton).initStates(timelines);
			// FIXME }
		}
	}

	//static function createElement(elemNode:Fast) : Widget {
	static function createElement(f : Fast, dd : DisplayData) : { e : Null<ElementData>, r : Null<String> } {

		var e : Null<ElementData> = null;
		var r : Null<String> = f.has.ref ? f.att.ref : null;

		switch (f.name.toLowerCase()) {

			case "textgroup":

				var numIndex : Int = 0;
				var hashTextGroup : StringMap<{ obj : ElementData, z : Int }> = new StringMap();

				for (c in f.elements) {

					var ret : { e : Null<ElementData>, r : Null<String> } = createElement(c, dd);

					if (ret.e != null) {

						hashTextGroup.set(c.att.ref, { obj: ret.e, z: numIndex });
						numIndex++;
					}
				}
				e = TextGroup({ data: hashTextGroup });

			case "background" | "image":

				if (f.has.src || f.has.filters || (f.has.extract && f.att.extract == "true")) {

					var id : ImageData = XmlToImage.parseImageData(f, f.has.spritesheet ? f.att.spritesheet : "ui");
					id.isBackground = f.name.toLowerCase() == "background";

					e = Image(id);
				
				} else {

					var tid : TileImageData = XmlToImage.parseTileImageData(f, f.has.spritesheet ? f.att.spritesheet : "ui");
					tid.id.isBackground = f.name.toLowerCase() == "background";

					e = TileImage(tid);
				}
			
			case "character":
		
				e = Character(XmlToCharacter.parseCharacterData(f));
			
			case "button":

				e = DefaultButton(XmlToWidgetContainer.parseWidgetContainerData(f, DefaultButton));
			
			case "text":

				e = ScrollPanel(XmlToWidgetContainer.parseWidgetContainerData(f, ScrollPanel));
			
			case "video":
#if flash
				e = VideoPlayer(XmlToWidgetContainer.parseWidgetContainerData(f, VideoPlayer));
#end
			case "sound":

				e = SoundPlayer(XmlToWidgetContainer.parseWidgetContainerData(f, SoundPlayer));

			case "scrollbar":

				e = ScrollBar({ width: Std.parseFloat(f.att.width),
								bgColor: f.has.bgColor ? f.att.bgColor : null,
								cursorColor: f.has.cursorColor ? f.att.cursorColor : null,
								bgTile: f.has.bgTile ? f.att.bgTile : null,
								tile: f.att.tile,
								tilesheet: f.has.spritesheet ? f.att.spritesheet : null,
								cursor9Grid: f.att.cursor9Grid.split(",").map(function(it:String):Float{ return Std.parseFloat(it); }),
								bg9Grid: f.has.bg9Grid ? f.att.bg9Grid.split(",").map(function(it:String):Float{ return Std.parseFloat(it); }) : null
							}));

			case "div":

				e = SimpleContainer(XmlToWidgetContainer.parseWidgetContainerData(f, SimpleContainer));
            
            case "timer":

	            e = ChronoCircle(XmlToWidgetContainer.parseWidgetContainerData(f, ChronoCircle));
			
			case "template": // use seen only in ActivityDisplay

				var ret = createElement(f);

				if (ret.e != null) {

					e = Template({ data: ret.e, validation: f.has.validation ? f.att.validation : null });
				}
			
			case "include" :
/** FIXME FIXME FIXME FIXME FIXME FIXME FIXME
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
*/
			default: // nothing
		}

		return {e: e, r: r};
	}
}