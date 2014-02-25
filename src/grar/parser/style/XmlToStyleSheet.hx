package grar.parser.style;

import grar.view.style.StyleSheet;
import grar.view.style.Style;

import grar.util.ParseUtils;

import haxe.ds.StringMap;
import haxe.xml.Fast;

class XmlToStyleSheet {

    static public function parse( xml : Xml ) : StyleSheetData {

		var f : Fast = new Fast(xml).node.stylesheet;
		var stylesheet : StyleSheetData = { name: f.att.name, styles: new StringMap() };

		for (c in f.nodes.style) {

			var style : StyleData = parseStyleData(c, stylesheet.styles);
			
			stylesheet.styles.set(c.att.name, style);
		}
		return stylesheet;
    }

    static function parseStyleData( f : Fast, styles : StringMap<StyleData> ) : StyleData {

    	var style : StyleData = cast { };
		style.name = f.att.name;
		style.values = new StringMap();
		
		if (f.has.inherit) {

			inherit(styles.get(f.att.inherit), style);
		}
		for (c in f.elements) {

			if (c.name.toLowerCase() == "icon") {

				if (c.att.value.indexOf(".") < 0) {

					style.iconSrc = c.att.value;
				
				} else {

					style.iconSrc = c.att.value;
				}
				style.iconPosition = c.att.position.toLowerCase();
				
				if (c.has.margin) {

					setIconMargin(style, c.att.margin);
				
				} else {

					setIconMargin(style, "");
				}
			
			} else if (c.name.toLowerCase() == "background") {

				style.backgroundSrc = c.att.value;

			} else {

				style.values.set(c.name, c.att.value);
			}
		}
		return style;
    }

	static public function setIconMargin(s : StyleData, v : String) : Void {

		var im : Array<Float> = [];

		if (v != null && v != "") {

			for (margin in v.split(" ")) {

				im.push(Std.parseFloat(margin));
			}
			ParseUtils.formatToFour(im);
		
		} else {

			im = [0, 0, 0, 0];
		}

		s.iconMargin = im;
	}

	static public function inherit(parent : StyleData, child : StyleData) : Void {

		if (parent == null) {

			throw "Can't inherit style for " + child.name + ", the parent doesn't exist.";
		}
		for (v in parent.values.keys()) {

			child.values.set(v, parent.values.get(v));
		}
	}
}