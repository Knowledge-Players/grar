package grar.parser.style;

import grar.model.style.TextDownElement;

/**
 * Parser for the MarkUp language
 */
class TextDownParser {

	///
	// API
	//

	/**
     * Parse the string for MarkUp
     * @param	text : text to parse
     * @return a sprite with well-formed text
     */
	static public function parse(text:String):Array<TextDownElement> {

		var array = new Array<TextDownElement>();

		if (text != null && text != "") {

			// Standardize line endings
			var lineEnding:EReg = ~/(\r)(\n)?|(&#13;)|(&#10;)|(<br\/>)/g;
			var uniformedText = lineEnding.replace(text, "\n");

			for (line in uniformedText.split("\n")) {

				var formattedLine = parseLine(line);
				array.push(formattedLine);
			}
		}

		return array;
	}


	///
	// INTERNALS
	//

	static private function parseLine(line : String) : TextDownElement {

		var styleName = "";
		var substring:String = line;
		var level = 1;
		var output:TextDownElement = {};

		while (substring.charAt(0) == " ") {

			level++;
			substring = substring.substr(1);
		}

		switch (substring.charAt(0)) {

			// Bigger Style
			case "+":

				styleName += "big-";
				substring = substring.substr(1);

			// Smaller Style
			case "-":

				styleName += "small-";
				substring = substring.substr(1);

			// Title style
			case "#":

				styleName += "title";
				substring = substring.substr(1);
				while(substring.charAt(0) == "#"){
					level++;
					substring = substring.substr(1);
				}
				styleName += Std.string(level);

			// Quote Style
			case ">":

				styleName += "quote";
				substring = substring.substr(1);

			// Lists Style
			case "*":

				if(substring.charAt(1) == " " || substring.substr(1).indexOf("*") == -1){
				styleName += "list" + level;
				substring = substring.substr(1);
			}

			// Default Style
			default: substring = line;
		}
		if (styleName == "" && substring.charAt(1) == ".") {

			styleName += "ordered" + level;
			output.bullerChar = substring.substr(0);
			substring = substring.substr(2);
		}

		// Custom Style on the whole line.
		var regexStyle:EReg = ~/^\[(.+)\](.+)\[\/(.+)\]$/;

		if (regexStyle.match(substring)) {

			styleName = regexStyle.matched(1);
			substring = regexStyle.replace(substring, "$2");
		}

		substring = StringTools.ltrim(substring);

		if (styleName != "") {

			output.style = styleName;
		}
		output.content = substring;

		return output;
	}
}