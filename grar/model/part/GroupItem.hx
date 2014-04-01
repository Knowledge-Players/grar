package grar.model.part;

import grar.model.part.item.Item;

class GroupItem{

	public var elements (default, default):List<Item>;

	// TODO use it or not ?
	public var id (default, default):String;

	public function new(){
		elements = new List<Item>();
	}
}