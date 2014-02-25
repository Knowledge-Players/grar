package grar.view.style;

import grar.view.style.Style;

import haxe.ds.StringMap;

typedef StyleSheetData = {
	
	name : String,
	styles : StringMap<StyleData>
}

typedef StyleSheet = {

	name : String,
	styles : StringMap<Style>
}