package grar.view.contextual;

import js.html.NodeList;
import Array;
import grar.model.contextual.MenuData;
import js.Browser;
import js.html.Element;

class MenuDisplay extends BaseDisplay {

	public var ref (default, set):String;

	var closeButtons: NodeList;

	public function new()
	{
		super();
	}

	///
	// Callbacks
	//

	dynamic public function onLevelClick(levelId):Void {}
	dynamic public function onCloseMenuRequest():Void {}

	///
	// Getter/Setter
	//

	public function set_ref(ref: String):String
	{
		root = Browser.document.querySelector("#"+ref);

		// Bind close button
		closeButtons = root.getElementsByClassName("close");
		for(b in closeButtons){
			cast(b, Element).onclick = function(_) onCloseMenuRequest();
		}

		return this.ref = ref;
	}

	///
	// API
	//

	public function setTitle(title:String, ?ref: String = "title"):Void
	{
		doSetText(ref, title);
	}

	public function initLevels(levels: Array<LevelData>):Void
	{
		// TODO get template system

		// Create unordered list
		var list = Browser.document.createUListElement();
		root.appendChild(list);

		var itemNum = 1;
		for(l in levels){
			var listItem = Browser.document.createLIElement();
			list.appendChild(listItem);
			// Set part name
			var name = "";
			for(elem in markupParser.parse(l.partName))
				name += elem.innerHTML;
			listItem.innerHTML = "<span class='decimal'>"+(itemNum < 10 ? '0'+ itemNum : Std.string(itemNum))+"</span>"+name;

			// Sub list
			if(l.items != null){
				var sublist = Browser.document.createUListElement();
				listItem.appendChild(sublist);

				for(i in l.items){
					var item = Browser.document.createLIElement();
					sublist.appendChild(item);

					// Set subpart name
					var name = "<a href='javascript:void(0)'>";
					for(elem in markupParser.parse(l.partName))
						name += elem.innerHTML;
					name += "</a>";
					item.innerHTML = name;
					item.onclick = function(_) onLevelClick(l.id);
				}
			}
			itemNum++;
		}
	}

	public function close():Void
	{
		root.classList.add("closed");
	}
}