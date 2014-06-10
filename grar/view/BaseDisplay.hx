package grar.view;

import js.Browser;
import js.html.AnchorElement;
import js.html.Node;
import js.html.Element;
import js.html.ParagraphElement;

import grar.view.style.TextDownParser;

using Lambda;

class BaseDisplay{

	public var markupParser (default, default):TextDownParser;

	private var root:Element;

	private function new(){

	}

	private function doSetText(ref:String, content:String):Null<Element>
	{
		var text: Element = getChildById(ref);
		if(text == null)
			return null;
		var html = "";

		// Clone child note list
		var children: Array<Node> = [];
		for(node in text.childNodes) children.push(node);
		// Clean text node in Textfield
		for(node in children){
			if(node.nodeType == Node.TEXT_NODE || (node.nodeType == Node.ELEMENT_NODE && node.nodeName.toLowerCase() == "p")){
				text.removeChild(node);
			}
		}

		if(Std.instance(text, ParagraphElement) != null || Std.instance(text, AnchorElement) != null){
			for(elem in markupParser.parse(content))
				html += elem.textContent;
			text.textContent += html;
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
		/*var p: Element = parent == null ? root: parent;
		var child = p.querySelector('#'+id);
		if(child == null)
			trace("Unable to find a child of "+p.id+" with id '"+id+"'.");
		return child;*/
		return Browser.document.getElementById(id);
	}
}