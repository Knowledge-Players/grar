package com.knowledgeplayers.grar.util;

import haxe.ds.GenericStack;
import haxe.xml.Fast;

class ParseUtils {

	public static inline function parseButtonContent(xml: Fast): Map<String, String>
	{
		var content = new Map<String, String>();
		if(xml.has.content){
			if(xml.att.content.indexOf("{") == 0){
				var contentString:String = xml.att.content.substr(1, xml.att.content.length - 2);
				var contents = contentString.split(",");
				for(c in contents)
					content.set(StringTools.trim(c.split(":")[0]), StringTools.trim(c.split(":")[1]));
			}
			else
				content.set(" ", xml.att.content);
		}

		return content;
	}

	public static inline function selectByAttribute(attr: String, value: String, xml: Xml): GenericStack<Xml>
	{
		var results = new GenericStack<Xml>();
		recursiveSelect(attr, value, xml, results);
		return results;
	}

	public static function updateIconsXml(value:String, xmls:GenericStack<Xml>):Void
	{
		for(elem in xmls){
			if (value != null){
				if(value.indexOf(".") < 0){
					elem.set("tile", value);
					if(elem.exists("src"))
						elem.remove("src");
				}
				else{
					elem.set("src", value);
					if(elem.exists("tile"))
						elem.remove("tile");
				}
			}
		}
	}

	// Private

	private static inline function recursiveSelect(attr: String, value: String, xml: Xml, res: GenericStack<Xml>):Void
	{
		if(xml.get(attr) == value)
			res.add(xml);
		else{
			for(elem in xml.elements()){
				recursiveSelect(attr, value, elem, res);
			}
		}
	}
}
