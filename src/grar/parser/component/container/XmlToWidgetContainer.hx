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

			case SimpleContainer(s, m):

				var ns : Null<String> = f.has.spritesheet ? f.att.spritesheet : null;
				var nm : Null<String> = f.has.mask ? f.att.mask : null;

				wcd.type = SimpleContainer(ns, nm);

			case DefaultButton(ds, ite, a, g) :

				var defaultState : String = f.has.defaultState ? f.att.defaultState : "active";
				var isToggleEnabled : Bool = f.has.toggle ? (xml.att.toggle == "true") : false;
				var action : Null<String> = xml.has.action ? xml.att.action : null;
				var group : Null<String> = xml.has.group ? xml.att.group.toLowerCase() : null;

				wcd.type = DefaultButton(defaultState, isToggleEnabled, action, group);

			case DropdownMenu(c):

				var color : String = xml.has.color ? xml.att.color : "0x02000000";

				wcd.type = DropdownMenu(color);

			case ScrollPanel(ss, s, c, t):

				var styleSheet : Null<String> = xml.has.styleSheet ? xml.att.styleSheet : null;
				var style : Null<String> = xml.has.style ? xml.att.style : null;
				var content : Null<String> = xml.has.content ? xml.att.content : null;
				var trim : Bool = xml.has.trim ? xml.att.trim == "true" : false;

				wcd.type = ScrollPanel(styleSheet, style, content, trim);

			case ChronoCircle(cc, minR, maxR, cb, ctc):

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

		    case VideoPlayer(ch, af):

		    	var controlsHidden : Bool = f.has.controlsHidden ? f.att.controlsHidden == "true" : false;
				var autoFullscreen : Null<Bool> = f.has.autoFullscreen ? f.att.autoFullscreen == "true" : null;

				wcd.type = VideoPlayer(controlsHidden, autoFullscreen);

		    case ProgressBar(is, pc, i):

		    	var iconScale : Float = f.has.iconScale ? Std.parseFloat(f.att.iconScale) : 1;
				var progressColor : Int = Std.parseInt(f.att.progressColor);
				var icon : String = f.att.icon;

				wcd.type = ProgressBar(iconScale, progressColor, icon);

			case BookmarkDisplay(a, xo, yo):

				var animation : Null<String> = f.has.animation ? f.att.animation : null;
				var xOffset : Float = f.has.xOffset ? Std.parseFloat(f.att.xOffset) : 0;
				var yOffset : Float = f.has.yOffset ? Std.parseFloat(f.att.yOffset) : 0;

				wcd.type = BookmarkDisplay(animation, xOffset, yOffset);

			case IntroScreen(d):

				var duration : Int = Std.parseInt(f.att.duration);

				wcd.type = IntroScreen(duration);

			case TokenNotification(d):

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

			case WidgetContainer:

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

						throw "unexpected "+e.name+" tag";
				}


			case VideoPlayer(ch, af):

				wcd.type = WidgetContainer;

				try {

					wcd = parseElement(e, wcd);
					
				} catch(e:String) {

					switch (e.name.toLowerCase()) {

						case "backgroundcontrols":

							var bd : grar.view.component.container.VideoPlayer.BackgroundData = {

									color: f.has.color ? Std.parseInt(f.att.color) : 0,
									alpha: f.has.alpha ? Std.parseFloat(f.att.alpha) : 1,
									x: f.has.x ? Std.parseFloat(f.att.x) : 0,
									y: f.has.y ? Std.parseFloat(f.att.y) : 0,
									w: f.has.width ? Std.parseFloat(f.att.width) : 0,
									h: f.has.height ? Std.parseFloat(f.att.height) : 0
								};

							// wcd.displays.set(scd.wd.ref, SimpleContainer(scd));


						case "progressbar":


			progressBar = new Image();
			//progressBar.ref = f.att.ref;
			progressBar.x = Std.parseFloat(f.att.x);
			progressBar.y = Std.parseFloat(f.att.y);
			addElement(progressBar);
			var mask: Sprite = null;
			for(child in f.elements){
				if(child.name.toLowerCase() == "mask"){
					var tile = new TileImage(child, layer);
					tile.x = (progressBar.x + tile.width/2);
					tile.y = (progressBar.y + tile.height/2);
					mask = tile.getMask();
					mask.width = child.has.width ? Std.parseFloat(child.att.width) : tile.width;
				}
				if(child.name.toLowerCase() == "bar"){
					var bar = new Sprite();
					var color = child.has.color ? Std.parseInt(child.att.color) : 0;
					var alpha = child.has.alpha ? Std.parseFloat(child.att.alpha) : 1;
					var x = child.has.x ? Std.parseFloat(child.att.x) : 0;
					var y = child.has.y ? Std.parseFloat(child.att.y) : 0;
					DisplayUtils.initSprite(bar, mask.width, mask.height, color, alpha, x, y);
					bar.scaleX = 0;
					progressBar.addChild(bar);
				}
				if(child.name.toLowerCase() == "cursor"){
					var tile = new TileImage(child, new TileLayer(layer.tilesheet));
					cursor = new Widget();
					cursor.ref = child.att.ref;
					cursor.addChild(new Bitmap(DisplayUtils.getBitmapDataFromLayer(tile.tileSprite.layer.tilesheet, tile.tileSprite.tile)));
					cursor.x = (child.has.x ? Std.parseFloat(child.att.x) : 0) + progressBar.x-cursor.width/2;
					cursor.y = progressBar.y-cursor.height/3;
					addElement(cursor);
				}
			}
			progressBar.mask = mask;
			progressBar.mouseChildren = false;
			mask.mouseEnabled = false;
			content.addChild(mask);

			controls.add(progressBar);

						case "slider":


						default: 
					}
				}
				wcd.type = VideoPlayer(ch, af);

/*
			SimpleContainer(spritesheet : Null<String>, mask : Null<String>);
			BoxDisplay;
			DefaultButton(defaultState : String, isToggleEnabled : Bool, group : Null<String>);
			DropdownMenu(color : String);
			ScrollPanel(styleSheet : Null<String>, style : Null<String>, content : Null<String>, trim : Bool);
			// SimpleBubble(width : Null<Float>, height : Null<Float>, colors : Null<Array<Int>>, ? arrowX : Float = 0, ? arrowY : Float = 0, ? radius : Null<Array<Float>>, ? line : Float = 0, ? colorLine : Int = 0xFFFFFF, ? shadow : Float = 0, ? gap : Float = 5, ? alphas : Null<Array<Float>>, ? bubbleX : Float = 0, ? bubbleY : Float = 0);
			SoundPlayer;
			ChronoCircle(colorCircle : Null<Color>, minRadius : Null<Int>, maxRadius : Null<Int>, colorBackground : Null<Color>, centerCircle : Null<Color>);
			VideoPlayer(controlsHidden : Bool, autoFullscreen : Null<Bool>);
			ProgressBar(iconScale : Float, progressColor : Int, icon : String);
			InventoryDisplay;
			BookmarkDisplay(animation : Null<String>, xOffset : Float, yOffset : Float);
			IntroScreen(duration : Int);
			AnimationDisplay;
			TokenNotification(duration : Int);
*/

			default: // nothing
		}
		return wcd;
	}
}