package grar.parser;

import grar.model.StyleSheet;
import grar.model.Style;

import grar.util.DisplayUtils;

import haxe.ds.StringMap;
import haxe.Json;

import flash.display.Bitmap; // FIXME

import com.knowledgeplayers.utils.assets.AssetsStorage;

class JsonToStyleSheet {

    static public function parse( json : String, tilesheet : aze.display.TilesheetEx ) : StyleSheet {

		var jsonStylesheet = Json.parse(json);
		var styleSheet : StyleSheet = { name: jsonStylesheet.name, styles: new StringMap() };
		var waitingList : Array<{style: Style, infos: Dynamic}> = new Array();

		for (key in Reflect.fields(jsonStylesheet.styles)) {

			var style : Style = new Style();
			style.name = key;

			var styleInfos = Reflect.field(jsonStylesheet.styles, key);

			if (Reflect.hasField(styleInfos, "inherit")) {

				if (styleSheet.styles.exists(styleInfos.inherit)) {

					style.inherit(styleSheet.styles.get(styleInfos.inherit));
					parseRules(styleInfos, Reflect.fields(styleInfos), style, tilesheet);
					styleSheet.styles.set(style.name, style);
				
				} else {

					waitingList.push({style: style, infos: styleInfos});
				}

			} else {

				parseRules(styleInfos, Reflect.fields(styleInfos), style, tilesheet);
				styleSheet.styles.set(style.name, style);
			}
		}
		var i = 0;

		while (waitingList.length > 0) {

			var style = waitingList.shift();

			if (styleSheet.styles.exists(style.infos.inherit)) {

				style.style.inherit(styleSheet.styles.get(style.infos.inherit));
				parseRules(style.infos, Reflect.fields(style.infos), style.style, tilesheet);
				styleSheet.styles.set(style.style.name, style.style);
			
			} else {

				waitingList.push(style);
			}
		}
		return styleSheet;
    }

	static function parseRules(styleInfos : Dynamic, fields : Iterable<Dynamic>, style : Style, tilesheet : aze.display.TilesheetEx) : Void {

		for (field in fields) {

			if (field == "icon") {

				// Icon bmp
				if (Reflect.field(styleInfos, field).graphic.indexOf(".") < 0) {
#if (flash || openfl)
					style.icon = DisplayUtils.getBitmapDataFromLayer(tilesheet, styleInfos.icon.graphic);
#end
				} else {
#if (flash || openfl)
					style.icon = AssetsStorage.getBitmapData(styleInfos.icon.graphic);
#end
				}
				// Icon margin
				if (Reflect.hasField(styleInfos.icon, "margin")) {

					style.setIconMargin(Reflect.field(styleInfos.icon, "margin"));
				
				} else {

					style.setIconMargin("");
				}
				// Icon position
				style.iconPosition = Reflect.field(styleInfos.icon, "position");
			
			} else if (field == "background") {
#if !html
				if (Std.parseInt(Reflect.field(styleInfos, field)) != null) {
#if (flash || openfl)
					style.background = new Bitmap();
					style.background.opaqueBackground = Std.parseInt(Reflect.field(styleInfos, field));
#else
					style.background = Std.string(Reflect.field(styleInfos, field));
#end
				} else
#end
#if (flash || openfl)
				style.background = new Bitmap(AssetsStorage.getBitmapData(Reflect.field(styleInfos, field)));
#else
				style.background = Std.string(Reflect.field(styleInfos, field));
#end
			} else if (field != "inherit") {

				style.addRule(field, Reflect.field(styleInfos, field));
			}
		}
	}
}