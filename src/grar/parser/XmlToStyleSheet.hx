package grar.parser;

import grar.model.StyleSheet;
import grar.model.Style;

import grar.util.DisplayUtils;

import haxe.ds.StringMap;
import haxe.xml.Fast;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import flash.display.Bitmap; // FIXME

class XmlToStyleSheet {

    static public function parse( xml : Xml, tilesheet : aze.display.TilesheetEx ) : StyleSheet {

		var xml : Fast = new Fast(xml).node.stylesheet;
		var stylesheet : StyleSheet = { name: xml.att.name, styles: new StringMap() };

		for (styleNode in xml.nodes.style) {

			var style : Style = parseStyle(styleNode, stylesheet.styles, tilesheet);
			
			stylesheet.styles.set(styleNode.att.name, style);
		}
		return stylesheet;
    }

    static function parseStyle( fxml : Fast, styles : StringMap<Style>, tilesheet : aze.display.TilesheetEx ) : Style {

    	var style : Style = new Style();
		style.name = fxml.att.name;
		
		if (fxml.has.inherit) {

			style.inherit(styles.get(fxml.att.inherit));
		}
		for (child in fxml.elements) {

			if (child.name.toLowerCase() == "icon") {

				if (child.att.value.indexOf(".") < 0) {
#if (flash || openfl)
					style.icon = DisplayUtils.getBitmapDataFromLayer(tilesheet, child.att.value); // FIXME
#else
					style.icon = child.att.value;
#end
				
				} else {
#if (flash || openfl)
					style.icon = AssetsStorage.getBitmapData(child.att.value); // FIXME
#else
					style.icon = child.att.value;
#end
				}
				style.iconPosition = child.att.position.toLowerCase();
				
				if (child.has.margin) {

					style.setIconMargin(child.att.margin);
				
				} else {

					style.setIconMargin("");
				}
			
			} else if (child.name.toLowerCase() == "background") {

				if (Std.parseInt(child.att.value) != null) {
#if (flash || openfl)
					style.background = new Bitmap();
	#if !html
					style.background.opaqueBackground = Std.parseInt(child.att.value);
	#end
#else
					style.background = child.att.value;
#end
				} else {
#if (flash || openfl)
					style.background = new Bitmap(AssetsStorage.getBitmapData(child.att.value));
#else
					style.background = child.att.value;
#end
				}

			} else {

				style.addRule(child.name, child.att.value);
			}
		}
		return style;
    }
}