package grar.util;

#if (!js && !cocktail)
class HTMLTools{
	public static inline function getElement(node){}
}
#else

import js.html.Element;
import js.html.Node;

class HTMLTools{

	public static inline function getElement(node:Node):Element
	{
		if(node.nodeType == Node.ELEMENT_NODE)
			return cast node;
		return null;
	}

	public static function hasChild(elem:Element, child: Element):Bool
	{
		var isChild = false;
		var i = 0;
		while(i < elem.children.length && !isChild){
			var c: Element = cast elem.children[i];
			if(c == child)
				isChild = true;
			else if(c.hasChildNodes())
				isChild = hasChild(c, child);
			else
				isChild = false;
			i++;
		}

		return isChild;
	}
}
#end