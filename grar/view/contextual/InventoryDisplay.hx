package grar.view.contextual;

import grar.view.guide.Guide;
import grar.view.guide.Absolute;
import grar.util.Point;
import grar.view.guide.Grid;
import grar.model.InventoryToken;

import js.html.Node;
import js.html.Element;
import js.html.ImageElement;

using Lambda;

class InventoryDisplay{

	public function new(){

	}

	private var root:Element;
	private var templates: Map<String, TemplateElement>;
	private var templatesPosition: Map<Element, {refElement: Node, parent: Node}>;

	public function init(root: Element):Void
	{
		this.root = root;
		templates = new Map();
	}

	private function createInventorySlots(tokens:Array<InventoryToken>, ?ordered: Bool = false):Void
	{
		var firstUse = true;
		var guide: Guide = null;

		var list = ordered ? root.ownerDocument.createOListElement() : root.ownerDocument.createUListElement();
		for(token in tokens){
			var t: Element;
			if(templates.exists(token.ref)){
				t = templates[token.ref].element;
				if(firstUse){
					if(templates[token.ref].guide != null)
						templates[token.ref].guide.init(t);
					firstUse = false;
				}
			}
			else{
				t = root.ownerDocument.getElementById(token.ref);
				templatesPosition.set(t, {refElement: t.nextSibling, parent: t.parentNode});

				// Guide creation for this template
				if(root.hasAttribute("data-grid")){
					var data = root.getAttribute("data-grid").split(",");
					if(data.length > 1)
						guide = new Grid(root, Std.parseInt(data[0]), Std.parseInt(data[1]));
					else
						guide = new Grid(root, Std.parseInt(data[0]));
				} else if (root.hasAttribute("data-absolute")) {
					var data = root.getAttribute("data-absolute").split(",");

					var points = new Array<Point>();
					for (s in data) {
						var p:Point = new Point(Std.parseFloat(s.split(";")[0]),Std.parseFloat(s.split(";")[1]));
						points.push(p);
					}
					guide = new Absolute(root, points);
				}
				else
					guide = null;

				if(firstUse && guide != null){
					guide.init(t);
					firstUse = false;
				}

				templates[token.ref] = {element: t, guide: guide};
			}
			var li: Element = t.cloneNode(true).getElement();

			// State
			li.classList.add(token.isActivated ? "collected" : "uncollected");

			// Content
			if(token.content.count() == 1)
				li.innerHTML = token.content.iterator().next();
			else{
				for(key in token.content.keys()){
					var elem = root.ownerDocument.getElementById(key);
					if(elem != null)
						elem.innerHTML = token.content[key];
				}
			}

			// Images
			for(key in token.images.keys()){
				var elem = root.ownerDocument.getElementById(key);
				if(elem != null){
					if(elem.nodeName.toLowerCase() == "img"){
						var img: ImageElement = cast elem;
						img.src = token.images[key];
					}
				}
			}
		}
	}
}