package grar.model.part;

import grar.model.part.Part;
import grar.model.part.item.Pattern;
import grar.model.part.item.Item;
import grar.model.part.item.GroupItem;

enum PartElement {

	Part(p : Part);
	Item(i : Item);
	Pattern(p : Pattern);
	GroupItem(g: GroupItem);
}