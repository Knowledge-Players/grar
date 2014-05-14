package grar.view;

import grar.view.style.TextDownParser;

import js.html.Element;

class BaseDisplay{

	public var markupParser (default, default):TextDownParser;

	private var root:Element;

	private function new(){

	}

	private function doSetText(ref:String, content:String):Element
	{
		var text: Element = getChildById(ref);
		var html = "";
		// TODO Std.is inconsistency
		//if(Std.is(text, ParagraphElement)){
		var p: Bool = untyped __js__("text.align != null");
		if(p != null){
			///
			for(elem in markupParser.parse(content))
				html += elem.innerHTML;
			text.innerHTML = html;
		}
		else
			for(elem in markupParser.parse(content))
				text.appendChild(elem);
		return text;
	}

	private function hide(elem: Element) {
		elem.classList.remove("visible");
		elem.classList.add("hidden");
	}

	private function show(elem: Element) {
		elem.classList.remove("hidden");
		elem.classList.add("visible");
	}

	private function getChildById(id:String, ?parent: Element):Null<Element>
	{
		var p: Element = parent == null ? root: parent;
		var child = p.querySelector('#'+id);
		if(child == null)
			trace("Unable to find a child of "+p.id+" with id '"+id+"'.");
		return child;
	}
}