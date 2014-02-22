package grar.parser.component.container;

import grar.view.component.Widget;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.SimpleContainer;

import grar.parser.component.XmlToWidget;

import grar.util.ParseUtils;

import haxe.xml.Fast;

class XmlToWidgetContainer {

	static public function parseWidgetContainerData( ? f : Fast, ? type : WidgetContainerType = WidgetContainer /*, ? tilesheet : TilesheetEx */ ) : WidgetContainerData {

		var wcd : WidgetContainerData = { };

		wcd.wd = XmlToWidget.parseWidgetData(f);
		wcd.type = type;

		if (f != null) {

			// Default tilesheet
// FIXME			if (tilesheet != null) { // TODO at instanciation

// FIXME				this.tilesheet = tilesheet;
			
// FIXME			} else {
				
// FIXME				this.tilesheet = UiFactory.tilesheet;
// FIXME			}

			wcd.contentAlpha = f.has.contentAlpha ? Std.parseFloat(f.att.contentAlpha) : 1;
			wcd.scrollBarName = f.has.scrollBar ? f.att.scrollBar : null;

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
				wcd.grid9 = { 0: grid[0], 1: grid[1], 2: grid[2], 3: grid[3] };
			}
			for (child in f.elements) {

				wcd = createElement(child, wcd);
			}
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

			case SimpleContainer:

				var ns : Null<String> = f.has.spritesheet ? f.att.spritesheet : null;
				var nm : Null<String> = f.has.mask ? f.att.mask : null;

				wcd.type = SimpleContainer(ns, nm);

			case DefaultButton:

				var defaultState : String = f.has.defaultState ? f.att.defaultState : "active";
				var isToggleEnabled : Bool = f.has.toggle ? (f.att.toggle == "true") : false;
				var action : Null<String> = f.has.action ? f.att.action : null;
				var group : Null<String> = f.has.group ? f.att.group.toLowerCase() : null;
				var enabled : Bool = f.has.action || f.name != "Button";

				wcd.type = DefaultButton(defaultState, isToggleEnabled, action, group, enabled);

			case DropdownMenu:

				var color : String = f.has.color ? f.att.color : "0x02000000";

				wcd.type = DropdownMenu(color);

			case ScrollPanel:

				var styleSheet : Null<String> = f.has.styleSheet ? f.att.styleSheet : null;
				var style : Null<String> = f.has.style ? f.att.style : null;
				var content : Null<String> = f.has.content ? f.att.content : null;
				var trim : Bool = f.has.trim ? f.att.trim == "true" : false;

				wcd.type = ScrollPanel(styleSheet, style, content, trim);

			case ChronoCircle:

				var colorCircle : Null<Color> = null;
				var minRadius : Null<Int> = null;
				var maxRadius : Null<Int> = null;
				var colorBackground : Null<Color> = null;
				var centerCircle : Null<Color> = null;

		        if (f.att.type == "circle") {

		            colorCircle = ParseUtils.parseColor(f.att.color);
		            minRadius = Std.parseInt(f.att.minRadius);
		            maxRadius = Std.parseInt(f.att.maxRadius);
					f.has.colorBackground ? colorBackground = ParseUtils.parseColor(f.att.colorBackground);
					f.has.colorCenter ? centerCircle = ParseUtils.parseColor(f.att.colorCenter);
		        }

		        wcd.type = ChronoCircle(colorCircle, minRadius, maxRadius, colorBackground, centerCircle);

		    case VideoPlayer:

		    	var controlsHidden : Bool = f.has.controlsHidden ? f.att.controlsHidden == "true" : false;
				var autoFullscreen : Null<Bool> = f.has.autoFullscreen ? f.att.autoFullscreen == "true" : null;

				wcd.type = VideoPlayer(controlsHidden, autoFullscreen);

		    case ProgressBar:

		    	var iconScale : Float = f.has.iconScale ? Std.parseFloat(f.att.iconScale) : 1;
				var progressColor : Int = Std.parseInt(f.att.progressColor);
				var icon : String = f.att.icon;

				wcd.type = ProgressBar(iconScale, progressColor, icon);

			case BookmarkDisplay:

				var animation : Null<String> = f.has.animation ? f.att.animation : null;
				var xOffset : Float = f.has.xOffset ? Std.parseFloat(f.att.xOffset) : 0;
				var yOffset : Float = f.has.yOffset ? Std.parseFloat(f.att.yOffset) : 0;

				wcd.type = BookmarkDisplay(animation, xOffset, yOffset);

			case IntroScreen:

				var duration : Int = Std.parseInt(f.att.duration);

				wcd.type = IntroScreen(duration);

			case TokenNotification:

				var duration : Int = Std.parseInt(f.att.duration);;

				wcd.type = TokenNotification(duration);

			default: // nothing
		}

		wcd = parseElements(f : Fast, type : WidgetContainerType, wcd : WidgetContainerData);

		return wcd;
	}

	static function parseElements(f : Fast, wcd : WidgetContainerData) : WidgetContainerData {

		switch(wcd.type) {

			default: // all cases

				for (e in f.elements) {

					wcd = parseElement(e, wcd);
				}
		}
		return wcd;
	}

	static function parseElement(e : Fast, wcd : WidgetContainerData) : WidgetContainerData {

		switch(wcd.type) {

			case WidgetContainer, SimpleContainer, BoxDisplay, DefaultButton, DropdownMenu, ScrollPanel, 
					SoundPlayer, ChronoCircle, ProgressBar, InventoryDisplay, BookmarkDisplay, IntroScreen, 
					AnimationDisplay, TokenNotification:

				switch (e.name.toLowerCase()) {

					case "background" | "image":

						if (e.has.src) {

				            var id : ImageData = XmlToImage.parseImageData(e);
				            
				            wcd.displays.set(id.wd.ref, Image(id));
				        
				        } else {

				            var tid : TileImageData = XmlToImage.parseTileImageData(e,null,true,true);
				            
				            wcd.displays.set(tid.id.wd.ref, TileImage(tid));
				        }

					case "button":

						var dbd : WidgetContainerData = parseWidgetContainerData(e, DefaultButton("", false, null, null));

						wcd.displays.set(dbd.wd.ref, DefaultButton(dbd));

					case "text":

						var spd : WidgetContainerData = parseWidgetContainerData(e, ScrollPanel(null, null, null, false));

						wcd.displays.set(spd.wd.ref, ScrollPanel(sbd));

				    case "timer":

						var ccd : WidgetContainerData = parseWidgetContainerData(e, ChronoCircle(null, null, null, null, null));

						wcd.displays.set(ccd.wd.ref, ChronoCircle(ccd));

					case "include" :
/*** FIXME
						var tmpXml = Xml.parse(DisplayUtils.templates.get(e.att.ref).toString()).firstElement();
						for(att in e.x.attributes()){
							if(att != "ref")
								tmpXml.set(att, e.x.get(att));
						}
						createElement(new Fast(tmpXml));
*/
					case "div":

						var scd : WidgetContainerData = parseWidgetContainerData(e, SimpleContainer(null, null));

						wcd.displays.set(scd.wd.ref, SimpleContainer(scd));

					default:

						//throw "unexpected "+e.name+" tag";
				}


			case VideoPlayer:

				wcd.type = WidgetContainer;

				wcd = parseElement(e, wcd);

				wcd.type = VideoPlayer(ch, af);
					
				switch (e.name.toLowerCase()) {

					case "backgroundcontrols":

						var bd : grar.view.component.container.VideoPlayer.BackgroundData = {

								color: e.has.color ? Std.parseInt(e.att.color) : 0,
								alpha: e.has.alpha ? Std.parseFloat(e.att.alpha) : 1,
								x: e.has.x ? Std.parseFloat(e.att.x) : 0,
								y: e.has.y ? Std.parseFloat(e.att.y) : 0,
								w: e.has.width ? Std.parseFloat(e.att.width) : 0,
								h: e.has.height ? Std.parseFloat(e.att.height) : 0
							};

						wcd.displays.set(e.has.ref ? e.att.ref : "backgroundcontrols", VideoBackground(bd)); // no ref available here ?


					case "progressbar":

						var m : TileImageData;
						var b : { color : Int, alpha : Float, x : Float, y : Float };
						var csr : { tile : TileImageData, ref : String, x : Float };

						for (c in f.elements) {

							if (c.name.toLowerCase() == "mask") {

								m = XmlToImage.parseTileImageData(c);
								m.id.width = c.has.width ? Std.parseFloat(c.att.width);
							}
							if (c.name.toLowerCase() == "bar") {

								b = {
										color: c.has.color ? Std.parseInt(c.att.color) : 0;
										alpha: c.has.alpha ? Std.parseFloat(c.att.alpha) : 1;
										x: c.has.x ? Std.parseFloat(c.att.x) : 0;
										y: c.has.y ? Std.parseFloat(c.att.y) : 0;
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

						wcd.displays.set(e.has.ref ? e.att.ref : "progressbar", VideoProgressBar(pbd)); // no ref available here ?


					case "slider":

						var b : { tile : TileImageData, x : Float, y : Float };
						var csr : { tile : TileImageData, ref : String, x : Float : 0, y : Float };

						for (child in elemNode.elements) {

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

						wcd.displays.set(e.has.ref ? e.att.ref : "slider", VideoSlider(pbd)); // no ref available here ?

					default: // nothing
				}

			default: // nothing
		}
		return wcd;
	}
}