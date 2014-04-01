package grar.model.part;

import grar.model.part.GroupItem;
import grar.model.part.Part;
import grar.model.part.Pattern;
import grar.model.part.item.Item;

enum PartElement {

	Part(p : Part);
	Item(i : Item);
	Pattern(p : Pattern);
	GroupItem(g: GroupItem);
}