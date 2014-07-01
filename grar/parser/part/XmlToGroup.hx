package grar.parser.part;

import haxe.xml.Fast;
import grar.model.part.item.GroupItem;

class XmlToGroup{

	///
	// API
	//

	static public function parse(xml : Xml) : Null<GroupItem> {
		var f : Fast = new Fast(xml);
		var creation = new GroupItem();

		for(item in f.elements)
			creation.elements.add(XmlToItem.parse(item.x));

		return creation;
	}
}