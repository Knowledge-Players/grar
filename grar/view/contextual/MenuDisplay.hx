package grar.view.contextual;

import js.html.Document;
import grar.util.TextDownParser;

import js.html.Node;
import js.html.Element;

using StringTools;

enum ItemStatus {
	TODO;
	STARTED;
	DONE;
}

class MenuDisplay{

	public var ref (default, set):String;

	public var markupParser (default, default):TextDownParser;

	public var document (default, null): Document;

	public var root (default, null): Element;

	var application: Application;

	public function new(parent: Application, ?document: Document)
	{
		application = parent;
		this.document = document;
	}

	///
	// Getter/Setter
	//

	public function set_ref(ref: String):String
	{
		if(document != null)
			root = document.getElementById(ref);
		else
			root = application.getElementById(ref);

		return this.ref = ref;
	}

	///
	// API
	//

	public function setTitle(title:String, ?ref: String = "title"):Void
	{
		var text: Element = document != null ? document.getElementById(ref) : application.getElementById(ref);
		if(text == null)
			return null;
		var html = "";

		if(text.nodeName.toLowerCase() == "p" || text.nodeName.toLowerCase() == "span" || text.nodeName.toLowerCase() == "a" || text.nodeName.toLowerCase().charAt(0) == "h" || text.hasAttribute("forced")){
			var it: Iterator<Element> = markupParser.parse(title).iterator();
			while(it.hasNext()){
				var elem: Element = it.next();
				html += elem.innerHTML;
				if(it.hasNext())
					html+= "<br/>";
				for(c in elem.classList)
					text.classList.add(c);
			}
			text.innerHTML += html;
		}
		else
			for(elem in markupParser.parse(title))
				text.appendChild(elem);
	}

	public function setCurrentItem(id:String):Void
	{
		var last: Element = application.getElementById(ref+"_"+id);
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

			// Refresh done part
			var doneMarker = new Array<Element>();
			for(node in root.getElementsByClassName("done"))
				doneMarker.push(cast node);
			for(marker in doneMarker){
				var elem: Element = cast marker;
				if(Std.parseFloat(elem.style.left) > Std.parseFloat(last.style.left)){
					elem.classList.remove("done");
				}
			}

			// Refresh started part
			var startedMarker = new Array<Element>();
			for(node in root.getElementsByClassName("started"))
				startedMarker.push(cast node);
			for(marker in startedMarker){
				var elem: Element = cast marker;
				if(Std.parseFloat(elem.style.left) > Std.parseFloat(last.style.left)){
					elem.classList.remove("started");
				}
			}

			// Refresh 'to do' part
			var todoMarker = new Array<Element>();
			for(node in root.getElementsByClassName("todo"))
				todoMarker.push(cast node);
			for(marker in todoMarker){
				var elem: Element = cast marker;
				if(Std.parseFloat(elem.style.left) < Std.parseFloat(last.style.left)){
					elem.classList.remove("todo");
					elem.classList.add("done");
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
		var item: Element = application.getElementById(ref+"_"+itemId);
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