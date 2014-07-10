package grar.util;

using StringTools;

class ParseUtils {

	public static inline function parseHash(s : String) : Map<String, String> {

		var content= new Map<String, String>();

		if (s.indexOf("{") == 0) {

			var contentString : String = s.substr(1, s.length - 2);
			var contents = contentString.split(",");

			for (c in contents) {

				content.set(c.split(":")[0].trim(), c.split(":")[1].trim());
			}

		} else {

			content.set("_", s);
		}
		return content;
	}

	public static inline function parseListOfValues(list: String, separator: String = ","):Array<String>
	{
		var result = new Array<String>();
		for(elem in list.split(separator)){
			result.push(elem.trim());
		}
		return result;
	}

	public static inline function parseListOfIntValues(list: String, separator: String = ","):Array<Int>
	{
		var result = new Array<Int>();
		var list = parseListOfValues(list, separator);
		for(elem in list){
			result.push(Std.parseInt(elem));
		}
		return result;
	}

	public static inline function parseListOfFloatValues(list: String, separator: String = ","):Array<Float>
	{
		var result = new Array<Float>();
		var list = parseListOfValues(list, separator);
		for(elem in list){
			result.push(Std.parseFloat(elem));
		}
		return result;
	}
}
