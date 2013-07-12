package com.knowledgeplayers.grar.util;

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
}
