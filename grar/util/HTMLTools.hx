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
}
#end