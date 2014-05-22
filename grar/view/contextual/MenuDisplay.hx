package grar.view.contextual;

import js.html.Node;
import js.Browser;
import js.html.Element;

enum ItemStatus {
	TODO;
	STARTED;
	DONE;
}

class MenuDisplay extends BaseDisplay {

	public var ref (default, set):String;

	public function new()
	{
		super();
	}

	///
	// Callbacks
	//

	dynamic public function onLevelClick(levelId):Void {}
	dynamic public function onCloseMenuRequest():Void {}
	dynamic public function onOpenMenuRequest():Void {}

	///
	// Getter/Setter
	//

	public function set_ref(ref: String):String
	{
		root = Browser.document.querySelector("#"+ref);

		return this.ref = ref;
	}

	///
	// API
	//

	public function setTitle(title:String, ?ref: String = "title"):Void
	{
		doSetText(ref, title);
	}

	public function setCurrentItem(id:String):Void
	{
		var last = root.querySelector("#"+id);
		// Update progress bar
		if(last != null){
			for(pb in root.getElementsByClassName("progressbar")){
				var bar: Element = null;
				if(pb.nodeType == Node.ELEMENT_NODE)
					bar = cast pb;
				else
					continue;

				bar.style.width = last.style.left;
			}

			for(marker in root.getElementsByClassName("done")){
				var elem: Element = cast marker;
				if(Std.parseFloat(elem.style.left) > Std.parseFloat(last.style.left)){
					elem.classList.remove("done");
				}
			}
			for(marker in root.getElementsByClassName("started")){
				var elem: Element = cast marker;
				if(Std.parseFloat(elem.style.left) > Std.parseFloat(last.style.left)){
					elem.classList.remove("started");
				}
			}
		}
	}

	public function setGameOver():Void
	{
		for(pb in root.getElementsByClassName("progressbar")){
			var bar: Element = null;
			if(pb.nodeType == Node.ELEMENT_NODE)
				bar = cast pb;
			else
				continue;

			bar.style.width = "100%";
		}
	}

	public function setItemStatus(itemId: String, status: ItemStatus):Void
	{
		var item: Element = getChildById(itemId);
		if(item == null)
			return;

		// Remove previous state classes
		for(state in Type.getEnumConstructs(ItemStatus))
			item.classList.remove(state.toLowerCase());

		// Add current state class
		item.classList.add(Std.string(status).toLowerCase());
	}

	public function close():Void
	{
		root.classList.add("closed");
	}

	public function open():Void
	{
		root.classList.remove("closed");
	}
}