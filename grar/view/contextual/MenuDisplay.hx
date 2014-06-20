package grar.view.contextual;

import grar.util.TextDownParser;

import js.html.ParagraphElement;
import js.html.AnchorElement;
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



	var root: Element;
	var application: Application;

	public function new(parent: Application)
	{
		application = parent;
	}

	///
	// Getter/Setter
	//

	public function set_ref(ref: String):String
	{
		root = application.getElementById(ref);

		return this.ref = ref;
	}

	///
	// API
	//

	public function setTitle(title:String, ?ref: String = "title"):Void
	{
		var text: Element = application.getElementById(ref);
		if(text == null)
			return null;
		var html = "";

		// Clone child note list
		var children: Array<Node> = [];
		for(node in text.childNodes) children.push(node);
		// Clean text node in Textfield
		for(node in children){
			if(node.nodeType == Node.TEXT_NODE || node.nodeName.toLowerCase() == "p" || node.nodeName.toLowerCase().startsWith("h")){
				text.removeChild(node);
			}
		}

		if(title != null){
			if(Std.instance(text, ParagraphElement) != null || Std.instance(text, AnchorElement) != null){
				for(elem in markupParser.parse(title))
					html += elem.outerHTML;
				text.innerHTML += html;
			}
			else
				for(elem in markupParser.parse(title))
					text.appendChild(elem);
		}
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