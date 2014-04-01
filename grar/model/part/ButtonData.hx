package grar.model.part;

import haxe.ds.StringMap;

typedef ButtonData = {
	var ref: String;
	var content: StringMap<String>;
	var action: String;
}