package grar.view.style;

import grar.view.style.Style;

import haxe.ds.StringMap;

typedef StyleSheetData = {
	
	name : String,
	styles : StringMap<StyleData>
}

class StyleSheet  {

	public function new(name : String, styles : StringMap<Style>) {

		this.name = name;
		this.styles = styles;
	}

	public var name (default, null) : String;
	public var styles (default, null) : StringMap<Style>;


	///
	// API
	//

	public function getStyle(? name : String) : Null<Style> {

		if (Lambda.count(styles) == 0) {

			throw "No style here. Have you parse a style file ?";
		}
		if (name == null) {

			return styles.get("text");
		}
		if (StringTools.endsWith(name, "-")) {

			return styles.get(name + "text");
		
		} else {

			return styles.get(name);
		}
	}
}