package grar.parser.component.container;

import grar.view.ElementData;
import grar.view.Color;
import grar.view.guide.Guide;
import grar.view.component.Widget;
import grar.view.component.Image;
import grar.view.component.TileImage;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.SimpleContainer;
import grar.view.component.container.VideoPlayer;

import grar.parser.component.XmlToWidget;

import grar.util.ParseUtils;

import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToWidgetContainer {

	static public function parseWidgetContainerData(? f : Null<Fast>, ? type : Null<WidgetContainerType>, templates : StringMap<Xml>  ) : Null<WidgetContainerData> {

		var wcd : WidgetContainerData = cast { };
		wcd.type = type == null ? WidgetContainer : type;
//trace("type= "+wcd.type);
		switch (wcd.type) {
			case SimpleBubble: return null;
			default: // nothing
		}

		wcd.wd = XmlToWidget.parseWidgetData(f);

		if (f != null) {

			wcd.spritesheetRef = f.has.spritesheet ? f.att.spritesheet : null;
			wcd.contentAlpha = f.has.contentAlpha ? Std.parseFloat(f.att.contentAlpha) : 1;
			wcd.scrollBarName = f.has.scrollBar ? f.att.scrollBar : null;
			wcd.transitionIn = f.has.transitionIn ? f.att.transitionIn : null;

			if (f.has.contentTransition) {

				wcd.contentTransition = f.att.contentTransition;
			}
			if (f.has.scrollable) {

				wcd.scrollable =  f.att.scrollable == "true";
			
			} else {

				wcd.scrollable = false;
			}
			if (f.has.grid) {

				var grid : Array<Float> = [];
				
				for (number in f.att.grid.split(",")) {

					grid.push(Std.parseFloat(number));
				}
				wcd.grid9 = { g0: grid[0], g1: grid[1], g2: grid[2], g3: grid[3] };
			}
// ???			for (child in f.elements) {

// ???				wcd = createElement(child, wcd);
// ???			}
			wcd.maskWidth = f.has.width ? Std.parseFloat(f.att.width) : null;
			wcd.maskHeight = f.has.height ? Std.parseFloat(f.att.height) : null;

			wcd.background = {

					background: f.has.background ? f.att.background:null,
					color: f.has.color ? Std.string(f.att.color).split(","):null,
					arrowX: f.has.arrowX ? Std.parseFloat(f.att.arrowX):0,
					arrowY: f.has.arrowY ? Std.parseFloat(f.att.arrowY):0,
					radius: f.has.radius ? ParseUtils.parseListOfFloatValues(f.att.radius):null,
					line: f.has.line ? Std.parseFloat(f.att.line):0,
					colorLine: f.has.colorLine ? Std.parseInt(f.att.colorLine):0xFFFFFF,
					bubbleWidth: f.has.bubbleWidth ? Std.parseInt(f.att.bubbleWidth):0,
					bubbleHeight: f.has.bubbleHeight ? Std.parseInt(f.att.bubbleHeight):0,
					shadow: f.has.shadow ? Std.parseFloat(f.att.shadow):0,
					gap: f.has.gap ? Std.parseFloat(f.att.gap):5,
					bubbleX: f.has.bubbleX ? Std.parseFloat(f.att.bubbleX):0,
					bubbleY: f.has.bubbleY ? Std.parseFloat(f.att.bubbleY):0,
					resize: f.has.resize ? f.att.resize == "true" : false
				};
		}

		// additional parsing specific to each WidgetContainer type
		switch (wcd.type) {

			case SimpleContainer(_):

				var nm : Null<String> = f.has.mask ? f.att.mask : null;

				wcd.type = SimpleContainer(nm);

			case DefaultButton(_, _, _, _, _, _, _):

				var defaultState : String = f.has.defaultState ? f.att.defaultState : "active";
				var isToggleEnabled : Bool = f.has.toggle ? (f.att.toggle == "true") : false;
				var action : Null<String> = f.has.action ? f.att.action : null;
				var group : Null<String> = f.has.group ? f.att.group.toLowerCase() : null;
				var enabled : Bool = f.has.action || f.name != "Button";
				var states : Array<{ name : String, timeline : Null<String>, enabled : Bool }> = [];
				var statesElts : StringMap<StringMap<ElementData>> = new StringMap();

				var createStates = function(e : Fast) : StringMap<ElementData>{
				
						// createStates
						var list = new StringMap();
		
						for (elem in e.elements) {
		
							var ed : { r : String, e : ElementData} = parseElement(elem, wcd, templates);
							list.set(ed.r, ed.e);
						}
						return list;
					}

				for (state in f.elements) {

					var stName : String = state.name;
					var stTimeline : Null<String> = state.has.timeline ? state.att.timeline : null;
					var stEnable : Bool = state.has.enable ? state.att.enable == "true" : true;

					states.push( { timeline: stTimeline, name: stName, enabled: stEnable } );

					for (elem in state.elements) {

						statesElts.set(state.name + "_" + elem.name, createStates(elem));
					}
				}
				// Simplified XML
				if (Lambda.count(statesElts) == 0) {

					statesElts.set(defaultState + "_out", createStates(f));
				}

				wcd.type = DefaultButton(defaultState, isToggleEnabled, action, group, enabled, states, statesElts);

			case DropdownMenu(_):

				var color : String = f.has.color ? f.att.color : "0x02000000";

				wcd.type = DropdownMenu(ParseUtils.parseColor(color));

			case ScrollPanel(_, _, _, _):

				var styleSheet : Null<String> = f.has.styleSheet ? f.att.styleSheet : null;
				var style : Null<String> = f.has.style ? f.att.style : null;
				var content : Null<String> = f.has.content ? f.att.content : null;
				var trim : Bool = f.has.trim ? f.att.trim == "true" : false;

				wcd.type = ScrollPanel(styleSheet, style, content, trim);

			case ChronoCircle(_, _, _, _, _):

				var colorCircle : Null<Color> = null;
				var minRadius : Null<Int> = null;
				var maxRadius : Null<Int> = null;
				var colorBackground : Null<Color> = null;
				var centerCircle : Null<Color> = null;

		        if (f.att.type == "circle") {

		            colorCircle = ParseUtils.parseColor(f.att.color);
		            minRadius = Std.parseInt(f.att.minRadius);
		            maxRadius = Std.parseInt(f.att.maxRadius);
					colorBackground = f.has.colorBackground ? ParseUtils.parseColor(f.att.colorBackground) : null;
					centerCircle = f.has.colorCenter ? ParseUtils.parseColor(f.att.colorCenter) : null;
		        }

		        wcd.type = ChronoCircle(colorCircle, minRadius, maxRadius, colorBackground, centerCircle);

		    case VideoPlayer(_, _):

		    	var controlsHidden : Bool = f.has.controlsHidden ? f.att.controlsHidden == "true" : false;
				var autoFullscreen : Null<Bool> = f.has.autoFullscreen ? f.att.autoFullscreen == "true" : null;

				wcd.type = VideoPlayer(controlsHidden, autoFullscreen);

		    case ProgressBar(_, _, _):

		    	var iconScale : Float = f.has.iconScale ? Std.parseFloat(f.att.iconScale) : 1;
				var progressColor : Int = Std.parseInt(f.att.progressColor);
				var icon : String = f.att.icon;

				wcd.type = ProgressBar(iconScale, progressColor, icon);

			case BookmarkDisplay(_, _, _):

				var animation : Null<String> = f.has.animation ? f.att.animation : null;
				var xOffset : Float = f.has.xOffset ? Std.parseFloat(f.att.xOffset) : 0;
				var yOffset : Float = f.has.yOffset ? Std.parseFloat(f.att.yOffset) : 0;

				wcd.type = BookmarkDisplay(animation, xOffset, yOffset);

			case IntroScreen(_):

				var duration : Int = Std.parseInt(f.att.duration);

				wcd.type = IntroScreen(duration);

			case TokenNotification(_):

				var duration : Int = Std.parseInt(f.att.duration);

				wcd.type = TokenNotification(duration);

			default: // nothing
		}

		wcd = parseElements(f, wcd, templates);

		return wcd;
	}

	static function parseElements(f : Fast, wcd : WidgetContainerData, templates : StringMap<Xml>) : WidgetContainerData {

		wcd.displays = new StringMap();

		switch(wcd.type) {

			default: // all cases

				for (e in f.elements) {

					var ret : { e: ElementData, r: String } = parseElement(e, wcd, templates);

					if (ret.e != null && ret.r != null) {

						wcd.displays.set(ret.r, ret.e);
//trace("elt "+ret.r+" created");
					} else {

						switch (e.name.toLowerCase()) {

							case "active", "inactive", "true": return wcd; // don't know if that's normal

							default:
							
								trace("XmlToWidgetContainer.parseElement return null with "+e+" "+wcd); throw e.x.toString();
						}

					}
				}
		}
		return wcd;
	}

	static function parseElement(e : Fast, wcd : WidgetContainerData, templates : StringMap<Xml>) : { e: ElementData, r: String } {

		var ref : String = null;
		var ed : ElementData = null;

		switch(wcd.type) {

			case WidgetContainer, SimpleContainer(_), BoxDisplay, DefaultButton(_, _, _, _, _, _, _), DropdownMenu(_), 
				ScrollPanel(_, _, _, _), SoundPlayer, ChronoCircle(_, _, _, _, _), ProgressBar(_, _, _), 
				BookmarkDisplay(_, _, _), IntroScreen(_), AnimationDisplay, TokenNotification(_):

				switch (e.name.toLowerCase()) {

					case "background" | "image":

						if (e.has.src) {

				            var id : ImageData = XmlToImage.parseImageData(e);

				            ref = id.wd.ref;
				            ed = Image(id);
				        
				        } else {

				            var tid : TileImageData = XmlToImage.parseTileImageData(e,null,true,true);
				            
				            ref = tid.id.wd.ref;
				            ed = TileImage(tid);
				        }

					case "button":

						var dbd : WidgetContainerData = parseWidgetContainerData(e, DefaultButton(null, null, null, null, null, null, null), templates);

						ref = dbd.wd.ref;
						ed = DefaultButton(dbd);

					case "text":

						var spd : WidgetContainerData = parseWidgetContainerData(e, ScrollPanel(null, null, null, null), templates);

						ref = spd.wd.ref;
						ed = ScrollPanel(spd);

				    case "timer":

						var ccd : WidgetContainerData = parseWidgetContainerData(e, ChronoCircle(null, null, null, null, null), templates);

						ref = ccd.wd.ref;
						ed = ChronoCircle(ccd);

					case "include" :

						var tmpXml : Xml = Xml.parse(templates.get(e.att.ref).toString()).firstElement();
						
						for (att in e.x.attributes()) {

							if (att != "ref") { // useless ?

								tmpXml.set(att, e.x.get(att));
							}
						}
						var pe = parseElement(new Fast(tmpXml), wcd, templates);

						ref = pe.r;
						ed = pe.e;

					case "div":

						var scd : WidgetContainerData = parseWidgetContainerData(e, SimpleContainer(null), templates);

						ref = scd.wd.ref;
						ed = SimpleContainer(scd);

					default:

						//throw "unexpected "+e.name+" tag";
				}


			case VideoPlayer(ch, af):

				wcd.type = WidgetContainer;

				var ret = parseElement(e, wcd, templates);

				ref = ret.r;
				ed = ret.e;

				wcd.type = VideoPlayer(ch, af);
					
				switch (e.name.toLowerCase()) {

					case "backgroundcontrols":

						var bd : VideoBackgroundData = {

								color: e.has.color ? Std.parseInt(e.att.color) : 0,
								alpha: e.has.alpha ? Std.parseFloat(e.att.alpha) : 1,
								x: e.has.x ? Std.parseFloat(e.att.x) : 0,
								y: e.has.y ? Std.parseFloat(e.att.y) : 0,
								w: e.has.width ? Std.parseFloat(e.att.width) : 0,
								h: e.has.height ? Std.parseFloat(e.att.height) : 0
							};

						ref = e.has.ref ? e.att.ref : "backgroundcontrols";  // no ref available here ?
						ed = VideoBackground(bd);


					case "progressbar":

						var m : TileImageData = null;
						var b : { color : Int, alpha : Float, x : Float, y : Float } = null;
						var csr : { tile : TileImageData, ref : String, x : Float } = null;

						for (c in e.elements) {

							if (c.name.toLowerCase() == "mask") {

								m = XmlToImage.parseTileImageData(c);
								if (c.has.width) m.id.width = Std.parseFloat(c.att.width);
							}
							if (c.name.toLowerCase() == "bar") {

								b = {
										color: c.has.color ? Std.parseInt(c.att.color) : 0,
										alpha: c.has.alpha ? Std.parseFloat(c.att.alpha) : 1,
										x: c.has.x ? Std.parseFloat(c.att.x) : 0,
										y: c.has.y ? Std.parseFloat(c.att.y) : 0
									};
							}
							if (c.name.toLowerCase() == "cursor") {

								csr = {
										tile: XmlToImage.parseTileImageData(c),
										ref: c.att.ref,
										x: c.has.x ? Std.parseFloat(c.att.x) : 0
									};
							}
						}

						var pbd : grar.view.component.container.VideoPlayer.ProgressBarData = {

								x: Std.parseFloat(e.att.x),
								y: Std.parseFloat(e.att.y),
								mask: m,
								bar: b,
								cursor: csr
							};

						ref = e.has.ref ? e.att.ref : "progressbar";  // no ref available here ?
						ed = VideoProgressBar(pbd);


					case "slider":

						var b : { tile : TileImageData, x : Float, y : Float } = null;
						var csr : { tile : TileImageData, ref : String, x : Float, y : Float, vol : Float } = null;

						for (c in e.elements) {

							if (c.name.toLowerCase() == "bar") {

								b = {
										tile: XmlToImage.parseTileImageData(c),
										x: c.has.x ? Std.parseFloat(c.att.x) : 0,
										y: c.has.y ? Std.parseFloat(c.att.y) : 0
									};
							}
							if (c.name.toLowerCase() == "cursor") {

								csr = {
										tile: XmlToImage.parseTileImageData(c),
										ref: c.att.ref,
										x: c.has.x ? Std.parseFloat(c.att.x) : 0,
										y: c.has.y ? Std.parseFloat(c.att.y) : 0,
										vol: c.has.vol ? Std.parseFloat(c.att.vol) / 100 : 1
									};
							}
						}

						var sd : grar.view.component.container.VideoPlayer.SliderData = {

								x: Std.parseFloat(e.att.x),
								y: Std.parseFloat(e.att.y),
								bar: b,
								cursor: csr
							};

						ref = e.has.ref ? e.att.ref : "slider";  // no ref available here ?
						ed = VideoSlider(sd);

					default: // nothing
				}

			default: // nothing
		}

		return { e: ed, r: ref };
	}
}