package grar.view;

import js.html.Node;
import grar.view.style.TextDownParser;

import js.html.Element;

using Lambda;

class BaseDisplay{

	public var markupParser (default, default):TextDownParser;

	private var root:Element;

	private function new(){

	}

	private function doSetText(ref:String, content:String):Element
	{
		var text: Element = getChildById(ref);
		var html = "";

		// Clone child note list
		var children: Array<Node> = [];
		for(node in text.childNodes) children.push(node);
		// Clean text node in Textfield
		for(node in children){
			if(node.nodeType == Node.TEXT_NODE || (node.nodeType == Node.ELEMENT_NODE && node.nodeName.toLowerCase() != "div")){
				text.removeChild(node);
			}
		}

		// TODO Std.is inconsistency
		//if(Std.is(text, ParagraphElement)){
		var p: Bool = untyped __js__("text.align != null");
		if(p != null){
		///
			for(elem in markupParser.parse(content))
				html += elem.outerHTML;
			text.innerHTML += html;
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