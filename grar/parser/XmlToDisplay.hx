package grar.parser;

import grar.view.ElementData;
import grar.view.Display;
import grar.view.guide.Guide;
import grar.view.component.Image;
import grar.view.component.TileImage;
import grar.view.component.CharacterDisplay;
import grar.view.component.container.WidgetContainer;
import grar.view.contextual.menu.MenuDisplay;

import grar.parser.component.XmlToImage;
import grar.parser.component.XmlToCharacter;
import grar.parser.component.container.XmlToWidgetContainer;

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

		switch (type) {

			case Menu(_, _, _, _, _):

				var tempXml : Xml = xml;

				if (xml.nodeType != Xml.Document) {

		            tempXml = Xml.createDocument();
			        tempXml.addChild(xml);
		        
		        }
		        xml = tempXml;

			default: // nothing
		}

		var f : Fast = new Fast(xml.firstElement());

		var dd : DisplayData = parseContent(f, type);

		return dd;
	}


	///
	// INTERNALS
	//

	static function parseContent(f : Fast, type : DisplayType) : DisplayData {


		var dd : DisplayData = cast { };

		dd.spritesheetsSrc = new StringMap();
		dd.timelines = new StringMap();
		dd.displays = new StringMap();
		dd.layersSrc = new StringMap();
		dd.type = type;

		switch (dd.type) {

			case Notebook(_, _, _, _, _):

				var chapterTemplates : StringMap<{ offsetY : Float, e : ElementData }> = new StringMap();

				for (c in f.nodes.Chapter) {

					chapterTemplates.set(c.att.ref, { offsetY: Std.parseFloat(c.att.offsetY), e: parseElement(c, dd).e});
				}

				var tabTemplate : { x : Float, xOffset : Float, e : WidgetContainerData } = { x: Std.parseFloat(f.node.Tab.att.x), xOffset: Std.parseFloat(f.node.Tab.att.xOffset), e: XmlToWidgetContainer.parseWidgetContainerData(f.node.Tab, DefaultButton(null, null, null, null, null, null, null)) };
				var bookmark : ImageData = XmlToImage.parseImageData(f.node.Bookmark);
				var guide : GuideData = XmlToGuide.parseGuideData(f.node.Bookmark.node.Guide);

				var step : { r : String, e : WidgetContainerData, transitionIn : Null<String> };
				step = {
						r: f.node.Bookmark.node.Step.att.ref,
						e: XmlToWidgetContainer.parseWidgetContainerData(f.node.Bookmark.node.Step, DefaultButton(null, null, null, null, null, null, null)),
						transitionIn: f.node.Bookmark.node.Step.att.transitionIn
					};

				dd.type = Notebook( chapterTemplates, tabTemplate, bookmark, guide, step );

			case Activity(_):

				var groups : StringMap<{ x : Float, y : Float, guide : GuideData }> = new StringMap();

				for (g in f.nodes.Group) {
			
					groups.set(f.att.ref, { x: Std.parseFloat(g.att.x), y: Std.parseFloat(g.att.y), guide: XmlToGuide.parseGuideData(g) });
				}

				dd.type = Activity( groups );

			case Zone(_, _, _, _, _):

				return parseZoneContent(f); // Zone parsing differs completely from other Displays

			case Menu(_, _, _, _, _):

				var bookmark : Null<WidgetContainerData> = null;

				if (f.hasNode.Bookmark) {

					bookmark = XmlToWidgetContainer.parseWidgetContainerData(f, BookmarkDisplay(null, null, null));
				}
				var orientation : String = f.att.orientation;

				var levelDisplays : StringMap<MenuLevel> = new StringMap();

				var regEx = ~/h[0-9]+|hr|item/i;
				
				for (c in f.elements) {

					if (regEx.match(c.name)) {

						if (c.name == "hr") {

							if (c.elements.hasNext()) {

								levelDisplays.set(c.name, ContainerSeparator(XmlToWidgetContainer.parseWidgetContainerData(c, SimpleContainer(null))));

							} else {

								var thickness : Null<Float> = c.has.thickness ? Std.parseFloat(c.att.thickness) : null;
								var color : Null<Int> = c.has.color ? Std.parseInt(c.att.color) : null;
								var alpha : Null<Float> = c.has.alpha ? Std.parseFloat(c.att.alpha) : null;
								var origin : Null<Array<Float>> = c.has.origin ? c.att.origin.split(';').map(function(it:String):Float{ return Std.parseFloat(it); }) : null;
								var destination : Null<Array<Float>> = c.has.destination ? c.att.destination.split(";").map(function(it:String):Float{ return Std.parseFloat(it); }) : null;
								var x : Null<Float> = c.has.x ? Std.parseFloat(c.att.x) : null;
								var y : Null<Float> = c.has.y ? Std.parseFloat(c.att.y) : null;

								levelDisplays.set(c.name, ImageSeparator(thickness, color, alpha, origin, destination, x, y));
							}

						} else {

							var xOffset : Null<Float> = c.has.xOffset ? Std.parseFloat(c.att.xOffset) : null;
							var yOffset : Null<Float> = c.has.yOffset ? Std.parseFloat(c.att.yOffset) : null;
							var width : Null<Float> = c.has.width ? Std.parseFloat(c.att.width) : null;
							var button : Null<WidgetContainerData> = c.has.Button ? XmlToWidgetContainer.parseWidgetContainerData(c.node.Button, DefaultButton(null, null, null, null, null, null, null)) : null;

							levelDisplays.set(c.name, Button(xOffset, yOffset, width, button));
						}
					}
				}

				var xBase : Null<Float> = f.has.xBase ? Std.parseFloat(f.att.xBase) : null;
				var yBase : Null<Float> = f.has.yBase ? Std.parseFloat(f.att.yBase) : null;

				dd.type = Menu( bookmark, orientation, levelDisplays, xBase, yBase );

			default: // nothing
		}

		dd.x = f.has.x ? Std.parseFloat(f.att.x) : null;
		dd.y = f.has.y ? Std.parseFloat(f.att.y) : null;
		dd.width = f.has.width ? Std.parseFloat(f.att.width) : null;
		dd.height = f.has.height ? Std.parseFloat(f.att.height) : null;

		for (child in f.nodes.SpriteSheet) {

			//dd.spritesheets.set(child.att.id, AssetsStorage.getSpritesheet(child.att.src)); // FIXME
			dd.spritesheetsSrc.set(child.att.id, child.att.src);

			dd.layersSrc.set(child.att.id, child.att.src);
		}

		dd = parseDisplay(f, type, dd);

		dd.transitionIn = f.has.transitionIn ? f.att.transitionIn : null;
		dd.transitionOut = f.has.transitionOut ? f.att.transitionOut : null;
		dd.layout = f.has.layout ? f.att.layout : null;
		dd.filters = f.has.filters ? f.att.filters : null;

		return dd;
	}

	static function parseDisplay(f : Fast, type : DisplayType, dd : DisplayData) : DisplayData {

		for (child in f.elements) {

			var ret : { e : Null<ElementData>, r : Null<String> } = parseElement(child, dd);
			
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

			dd.timelines.set(t.ref, t);
		}
		for (elem in dd.displays) {

			// FIXME if (Std.is(elem, DefaultButton)) {

				// FIXME cast(elem,DefaultButton).initStates(timelines);
			// FIXME }
		}

		return dd;
	}

	//static function createElement(elemNode:Fast) : Widget {
	static function parseElement(f : Fast, dd : DisplayData) : { e : Null<ElementData>, r : Null<String> } {

		var e : Null<ElementData> = null;
		var r : Null<String> = f.has.ref ? f.att.ref : null;

		// parsing specific to some Display types
		switch (dd.type) {

			case Strip:

				switch (f.name.toLowerCase()) {

					case "box":

						e = BoxDisplay(XmlToWidgetContainer.parseWidgetContainerData(f, BoxDisplay));

					case "background": // in StripDisplay, "background" means Image (not TileImage)

						var id : ImageData = XmlToImage.parseImageData(f, f.has.spritesheet ? f.att.spritesheet : "ui");
						id.isBackground = true;

						e = Image(id);

					default: // nothing
				}

			case Part:

				switch (f.name.toLowerCase()) {

					case "inventory":

						e = InventoryDisplay(XmlToWidgetContainer.parseWidgetContainerData(f, InventoryDisplay(null, null, null)));

					case "intro":

						e = IntroScreen(XmlToWidgetContainer.parseWidgetContainerData(f, IntroScreen(null)));

					default: // nothing
				}

			case Zone(_, _, _, _, _):

				switch (f.name.toLowerCase()) {

					case "menu":

						e = Menu(parseDisplayData(f.x, Menu(null, null, null, null, null)));

					case "progressbar":

						e = ProgressBar(XmlToWidgetContainer.parseWidgetContainerData(f, ProgressBar(null, null, null)));
#if kpdebug
					case "fastnav":

						e = DropdownMenu(XmlToWidgetContainer.parseWidgetContainerData(f, DropdownMenu(null)));
#end
					default: // nothing
				}

			default: // nothing
		}

		// common parsing
		if (e == null) {

			switch (f.name.toLowerCase()) {

				case "textgroup":

					var numIndex : Int = 0;
					var hashTextGroup : StringMap<{ obj : ElementData, z : Int }> = new StringMap();

					for (c in f.elements) {

						var ret : { e : Null<ElementData>, r : Null<String> } = parseElement(c, dd);

						if (ret.e != null) {

							hashTextGroup.set(c.att.ref, { obj: ret.e, z: numIndex });
							numIndex++;
						}
					}
					e = TextGroup(hashTextGroup);

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

					e = DefaultButton(XmlToWidgetContainer.parseWidgetContainerData(f, DefaultButton(null, null, null, null, null, null, null)));
				
				case "text":

					e = ScrollPanel(XmlToWidgetContainer.parseWidgetContainerData(f, ScrollPanel(null, null, null, null)));
				
				case "video":
#if flash
					e = VideoPlayer(XmlToWidgetContainer.parseWidgetContainerData(f, VideoPlayer(null, null)));
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
								});

				case "div":

					e = SimpleContainer(XmlToWidgetContainer.parseWidgetContainerData(f, SimpleContainer(null)));
	            
	            case "timer":

		            e = ChronoCircle(XmlToWidgetContainer.parseWidgetContainerData(f, ChronoCircle(null, null, null, null, null)));
				
				case "template": // use seen only in ActivityDisplay

					var ret = parseElement(f, dd);

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
		}

		return {e: e, r: r};
	}

	static function parseZoneContent(f : Fast) : DisplayData {

		var zones : Array<DisplayData> = [];

		if (f.has.rows) {

			for (r in f.nodes.Row) {

				zones.push(parseZoneContent(r));
			}

		} else if(f.has.columns) {

			for (c in f.nodes.Column) {

				zones.push(parseZoneContent(c));
			}
		
		} else if (!f.has.ref) {

			trace("This zone is empty. Is your XML correct ?");
		}

		var dd : DisplayData = {

				type: Zone(f.has.bgColor ? Std.parseInt(f.att.bgColor) : null, f.has.ref ? f.att.ref : null, f.has.rows ? f.att.rows : null, f.has.columns ? f.att.columns : null, zones),
				displays: new StringMap()

			};

		for (child in f.elements) {

			var ret : { e : Null<ElementData>, r : Null<String> } = parseElement(child, dd);
			
			if (ret.e != null && ret.r != null) {

				dd.displays.set(ret.r, ret.e);
			}
		}

		return dd;
	}
}