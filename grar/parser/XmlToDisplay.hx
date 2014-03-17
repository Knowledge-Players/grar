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

import grar.util.ParseUtils;

import haxe.ds.StringMap;

import haxe.xml.Fast;

using StringTools;

class XmlToDisplay {

	///
	// API
	//

	/**
	 * You should call this method only from GameService as there is a two-step loading because of assets
	 */
	static public function parseDisplayData(xml : Xml, type : DisplayType, templates : StringMap<Xml>) : DisplayData {

		switch (type) {

			case Zone(_, _, _, _, _):

				return parseZoneContent(new Fast(xml), templates); // Zone parsing differs completely from other Displays

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

		var dd : DisplayData = parseContent(f, type, templates);

		return dd;
	}


	///
	// INTERNALS
	//

	static function parseContent(f : Fast, type : DisplayType, templates : StringMap<Xml>) : DisplayData {


		var dd : DisplayData = cast { };

		dd.spritesheetsSrc = new StringMap();
		dd.timelines = new StringMap();
		dd.displays = new Array();
		dd.layersSrc = new StringMap();
		dd.type = type;

		switch (dd.type) {

			case Notebook(_, _, _, _, _):

				var chapterTemplates : StringMap<{ offsetY : Float, e : ElementData }> = new StringMap();

				for (c in f.nodes.Chapter) {

					// clone Chapter node and parse it as a Button node
					var tempNode : Fast = new Fast(Xml.parse(c.x.toString().replace("<Chapter", "<Button").replace("</Chapter", "</Button")).firstElement());

					var tempE = parseElement(tempNode, dd, templates).e;

					chapterTemplates.set(c.att.ref, { offsetY: Std.parseFloat(c.att.offsetY), e: tempE });
				}

				var tabTemplate : { x : Float, xOffset : Float, e : WidgetContainerData } = { x: Std.parseFloat(f.node.Tab.att.x), xOffset: Std.parseFloat(f.node.Tab.att.xOffset), e: XmlToWidgetContainer.parseWidgetContainerData(f.node.Tab, DefaultButton(null, null, null, null, null, null, null), templates) };
				var bookmark : ImageData = XmlToImage.parseImageData(f.node.Bookmark);
				var guide : GuideData = XmlToGuide.parseGuideData(f.node.Bookmark.node.Guide);

				var step : { r : String, e : WidgetContainerData, transitionIn : Null<String> };
				step = {
						r: f.node.Bookmark.node.Step.att.ref,
						e: XmlToWidgetContainer.parseWidgetContainerData(f.node.Bookmark.node.Step, DefaultButton(null, null, null, null, null, null, null), templates),
						transitionIn: f.node.Bookmark.node.Step.att.transitionIn
					};

				dd.type = Notebook( chapterTemplates, tabTemplate, bookmark, guide, step );

			case Activity(_):

				var groups : StringMap<{ x : Float, y : Float, guide : GuideData }> = new StringMap();

				for (g in f.nodes.Group) {

					groups.set(g.att.ref, { x: Std.parseFloat(g.att.x), y: Std.parseFloat(g.att.y), guide: XmlToGuide.parseGuideData(g.node.Guide) });
				}

				dd.type = Activity( groups );

			case Menu(_, _, _, _, _):

				var bookmark : Null<WidgetContainerData> = null;

				if (f.hasNode.Bookmark) {

					bookmark = XmlToWidgetContainer.parseWidgetContainerData(f.node.Bookmark, BookmarkDisplay(null, null, null), templates);
				}
				var orientation : String = f.att.orientation;

				var levelDisplays : StringMap<MenuLevel> = new StringMap();

				var regEx = ~/h[0-9]+|hr|item/i;
				
				for (c in f.elements) {

					if (regEx.match(c.name)) {

						if (c.name == "hr") {

							if (c.elements.hasNext()) {

								levelDisplays.set(c.name, ContainerSeparator(XmlToWidgetContainer.parseWidgetContainerData(c, SimpleContainer(null), templates)));

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
							var button : Null<WidgetContainerData> = c.hasNode.Button ? XmlToWidgetContainer.parseWidgetContainerData(c.node.Button, DefaultButton(null, null, null, null, null, null, null), templates) : null;

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

			dd.spritesheetsSrc.set(child.att.id, child.att.src);

			dd.layersSrc.set(child.att.id, child.att.src);
		}

		dd = parseDisplay(f, type, dd, templates);

		dd.transitionIn = f.has.transitionIn ? f.att.transitionIn : null;
		dd.transitionOut = f.has.transitionOut ? f.att.transitionOut : null;
		dd.layout = f.has.layout ? f.att.layout : null;
		dd.filtersData = f.has.filters ? ParseUtils.parseListOfValues(f.att.filters) : null;

		return dd;
	}

	static function parseDisplay(f : Fast, type : DisplayType, dd : DisplayData, templates : StringMap<Xml>) : DisplayData {

		for (e in f.elements) {

			var ret : { e : Null<ElementData>, r : Null<String> } = parseElement(e, dd, templates);
			
			if (ret.e != null && ret.r != null) {

				dd.displays.push({ ref: ret.r, ed: ret.e });
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

		return dd;
	}

	//static function createElement(elemNode:Fast) : Widget {
	static public function parseElement(f : Fast, dd : DisplayData, templates : StringMap<Xml>) : { e : Null<ElementData>, r : Null<String> } {

		var e : Null<ElementData> = null;
		var r : Null<String> = f.has.ref ? f.att.ref : null;

		// parsing specific to some Display types
		switch (dd.type) {

			case Strip:

				switch (f.name.toLowerCase()) {

					case "box":

						var bdd : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, BoxDisplay, templates);

				        e = BoxDisplay(bdd);

					case "background": // in StripDisplay, "background" means Image (not TileImage)

						var id : ImageData = XmlToImage.parseImageData(f, f.has.spritesheet ? f.att.spritesheet : "ui");
						id.wd.isBackground = true;

						e = Image(id);

					default: // nothing
				}

			case Part:

				switch (f.name.toLowerCase()) {

					case "intro":

						var id : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, IntroScreen(null), templates);

				        e = IntroScreen(id);

					default: // nothing
				}

			case Zone(_, _, _, _, _):

				switch (f.name.toLowerCase()) {

// I think this is useless now...
//					case "menu":

//						e = Menu(parseDisplayData(f.x, Menu(null, null, null, null, null), templates));

					case "progressbar":

						e = ProgressBar(XmlToWidgetContainer.parseWidgetContainerData(f, ProgressBar(null, null, null), templates));
#if kpdebug
					case "fastnav":

						e = DropdownMenu(XmlToWidgetContainer.parseWidgetContainerData(f, DropdownMenu(null), templates));
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

						var ret : { e : Null<ElementData>, r : Null<String> } = parseElement(c, dd, templates);

						if (ret.e != null) {

							hashTextGroup.set(c.att.ref, { obj: ret.e, z: numIndex });
							numIndex++;
						}
					}
					e = TextGroup(hashTextGroup);

				case "background" | "image":

					if (f.has.src || f.has.filters || (f.has.extract && f.att.extract == "true")) {

						var id : ImageData = XmlToImage.parseImageData(f, f.has.spritesheet ? f.att.spritesheet : "ui");
						id.wd.isBackground = f.name.toLowerCase() == "background";

				        e = Image(id);
					
					} else {

						var tid : TileImageData = XmlToImage.parseTileImageData(f, f.has.spritesheet ? f.att.spritesheet : "ui");
						tid.id.wd.isBackground = f.name.toLowerCase() == "background";

				        e = TileImage(tid);
					}
				
				case "character":

					var cd : CharacterData = XmlToCharacter.parseCharacterData(f);

				    e = Character(cd);
				
				case "button":

					var dbd : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, DefaultButton(null, null, null, null, null, null, null), templates);

				    e = DefaultButton(dbd);
				
				case "text":

					var spd : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, ScrollPanel(null, null, null, null), templates);

				    e = ScrollPanel(spd);
				
				case "video":

					var vpd : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, VideoPlayer(null, null), templates);
#if flash
					e = VideoPlayer(vpd);
#end
				case "sound":

					var spd : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, SoundPlayer, templates);

				    e = SoundPlayer(spd);

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

					var scd : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, SimpleContainer(null), templates);

				    e = SimpleContainer(scd);
	            
	            case "timer":

		            var ccd : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, ChronoCircle(null, null, null, null, null), templates);

				    e = ChronoCircle(ccd);
				
				case "template": // use seen only in ActivityDisplay

					// At the moment, templates seem to be DefaultButton templates only
					var td : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(f, DefaultButton(null, null, null, null, null, null, null), templates);

				    e = Template({ data: DefaultButton(td), validation: f.has.validation ? f.att.validation : null });
				
				case "include" :

					if (!templates.exists(f.att.ref)) {

						throw "template '"+f.att.ref+"' nor found";
					}
					var tmpXml = Xml.parse(templates.get(f.att.ref).toString()).firstElement();
					
					for (att in f.x.attributes()) {

						if (att != "ref") { // useless ?

							tmpXml.set(att, f.x.get(att));
						}
					}
					var tr = parseElement(new Fast(tmpXml), dd, templates);

					e = tr.e;

				default: // nothing
			}
		}

		return {e: e, r: r};
	}

	static function parseZoneContent(f : Fast, templates : StringMap<Xml>) : DisplayData {

		var zones : Array<DisplayData> = [];

		var dd : DisplayData = {

				type: Zone(f.has.bgColor ? Std.parseInt(f.att.bgColor) : null, f.has.ref ? f.att.ref : null, f.has.rows ? f.att.rows : null, f.has.columns ? f.att.columns : null, zones),
				displays: new Array()
			};

		if (f.has.rows) {

			for (r in f.nodes.Row) {

				zones.push(parseZoneContent(r, templates));
			}

			return dd;

		} else if(f.has.columns) {

			for (c in f.nodes.Column) {

				zones.push(parseZoneContent(c, templates));
			}

			return dd;
		
		} else if (!f.has.ref) {

			trace("This zone is empty. Is your XML correct ?");
		}

		for (ce in f.elements) {

			var ret : { e : Null<ElementData>, r : Null<String> } = parseElement(ce, dd, templates);
			
			if (ret.e != null && ret.r != null) {

				dd.displays.push({ ref: ret.r, ed: ret.e });
			}
		}

		return dd;
	}
}