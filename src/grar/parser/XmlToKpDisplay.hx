package grar.parser;

import grar.view.KpDisplay;

import haxe.ds.StringMap;
import haxe.xml.Fast;

class XmlToKpDisplay {

	static public function parse(xml : Xml) : KpDisplayData {

		var x : Float;
		var y : Float;
		var width : Float;
		var height : Float;
		var spritesheets : StringMap<String> = new StringMap();
		var transitionIn : Null<String> = null;
		var transitionOut : Null<String> = null;
		var layout : Null<String> = null;
		var filters : Null<String> = null;

		var displayFast : Fast = new Fast(xml.firstElement());

		if (displayFast.has.x) {

			x = Std.parseFloat(displayFast.att.x);
		}
		if (displayFast.has.y) {

			y = Std.parseFloat(displayFast.att.y);
		}
		if (displayFast.has.width && displayFast.has.height) {

			width = Std.parseFloat(displayFast.att.width);
			height = Std.parseFloat(displayFast.att.height);
			// TODO DisplayUtils.initSprite(this, Std.parseFloat(displayFast.att.width), Std.parseFloat(displayFast.att.height), 0, 0.001);
		}
		for (child in displayFast.nodes.SpriteSheet) {

			spritesheets.set(child.att.id, child.att.src);
			// TODO
			//spritesheets.set(child.att.id, AssetsStorage.getSpritesheet(child.att.src));
			//var layer = new TileLayer(AssetsStorage.getSpritesheet(child.att.src));
			//layers.set(child.att.id, layer);
			//addChild(layer.view);
		}
		// TODO
		//var uiLayer = new TileLayer(UiFactory.tilesheet);
		//layers.set("ui", uiLayer);
		//addChild(uiLayer.view);

		//createDisplay();

		if (displayFast.has.transitionIn) {

			transitionIn = displayFast.att.transitionIn;

			/* TODO
			addEventListener(Event.ADDED_TO_STAGE, function(e){

					TweenManager.applyTransition(this, transitionIn);
				
				});
			*/
		}
		if (displayFast.has.transitionOut) {

			transitionOut = displayFast.att.transitionOut;
		}
		if (displayFast.has.layout) {

			layout = displayFast.att.layout;
		}
		if (displayFast.has.filters) {

			filters = displayFast.att.filters;
			// TODO filters = FilterManager.getFilter(displayFast.att.filters);
		}
		// TODO ResizeManager.instance.onResize();

		return { x: x, y: y, w: width, h: height, ss: spritesheets, ti: transitionIn, to: transitionOut, l: layout, f: filters };
	}
}