package grar.parser.style;

import grar.view.style.StyleSheet;
import grar.view.style.Style;

import grar.util.DisplayUtils;

import haxe.ds.StringMap;

import haxe.Json;

class JsonToStyleSheet {

    static public function parse( json : String ) : StyleSheetData {

		var jsonStylesheet = Json.parse(json);
		var styleSheet : StyleSheetData = { name: jsonStylesheet.name, styles: new StringMap() };
		var waitingList : Array<{style: StyleData, infos: Dynamic}> = new Array();

		for (key in Reflect.fields(jsonStylesheet.styles)) {

			var style : StyleData = cast { };
			style.name = key;

			var styleInfos = Reflect.field(jsonStylesheet.styles, key);

			if (Reflect.hasField(styleInfos, "inherit")) {

				if (styleSheet.styles.exists(styleInfos.inherit)) {

					XmlToStyleSheet.inherit( styleSheet.styles.get(styleInfos.inherit), style );
					
					parseRules(styleInfos, Reflect.fields(styleInfos), style);
					
					styleSheet.styles.set(style.name, style);
				
				} else {

					waitingList.push({style: style, infos: styleInfos});
				}

			} else {

				parseRules(styleInfos, Reflect.fields(styleInfos), style);
				
				styleSheet.styles.set(style.name, style);
			}
		}
		var i = 0;

		while (waitingList.length > 0) {

			var style = waitingList.shift();

			if (styleSheet.styles.exists(style.infos.inherit)) {

				XmlToStyleSheet.inherit(styleSheet.styles.get(style.infos.inherit), style.style);
				
				parseRules(style.infos, Reflect.fields(style.infos), style.style);
				
				styleSheet.styles.set(style.style.name, style.style);
			
			} else {

				waitingList.push(style);
			}
		}
		return styleSheet;
    }

	static function parseRules(styleInfos : Dynamic, fields : Iterable<Dynamic>, style : StyleData) : Void {

		for (field in fields) {

			if (field == "icon") {

				// Icon src
				if (Reflect.field(styleInfos, field).graphic.indexOf(".") < 0) {

					style.iconSrc = styleInfos.icon.graphic;
				}
				// Icon margin
				XmlToStyleSheet.setIconMargin(style, Reflect.hasField(styleInfos.icon, "margin") ? Reflect.field(styleInfos.icon, "margin") : "");

				// Icon position
				style.iconPosition = Reflect.field(styleInfos.icon, "position");
			
			} else if (field == "background") {

				style.backgroundSrc = Std.string(Reflect.field(styleInfos, field));

			} else if (field != "inherit") {

				style.values.set(field, Reflect.field(styleInfos, field));
			}
		}
	}
}