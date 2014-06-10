package grar.view.style;

import js.html.Element;
import js.Browser;
import js.html.ParagraphElement;

using StringTools;

/**
 * Parser for the MarkUp language
 */
// TODO move to util
class TextDownParser {

	public function new(){ }

	///
	// API
	//

	/**
     * Parse the string for MarkUp
     * @param	text : text to parse
     * @return a sprite with well-formed text
     */
	public function parse(text:String):List<Element>
	{
		var list = new List<Element>();
		// Standardize line endings
		var lineEnding:EReg = ~/(\r)(\n)?|(&#13;)|(&#10;)|(<br\/>)/g;
		var uniformedText = lineEnding.replace(text, "\n");

		for(line in uniformedText.split("\n")){
			var formattedLine = parseLine(line);
			list.add(formattedLine);
		}
		return list;
	}


	///
	// INTERNALS
	//

	private function parseLine(line : String) : Element {

		var styleName = "";
		var substring:String = line;
		var level = 1;
		var output: Element = null;

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

		// Remove all spaces before content
		substring = StringTools.ltrim(substring);

		// HTML output
		var html: String;

		// Ordered list
		var regexOrder = ~/^(.)\./;

		if (styleName == "" && regexOrder.match(substring)) {
			styleName += "ordered" + level;
			html = regexOrder.replace(substring, "<span class='numbering'>$1</span>");
			substring = substring.substr(2);
		}
		else
			html = substring;

		// Bold
		// infos: ? after a selector reduces the greediness making it match the less character possible
		var regexBold = ~/\*(.*?)\*/g;
		html = regexBold.replace(html, "<b>$1</b>");

		// Italic
		var regexIta = ~/_(.*?)_/g;
		html = regexIta.replace(html, "<i>$1</i>");

		// Custom Style on the whole line.
		var regexStyle:EReg = ~/\[(.*?)\](.*?)\[\/.*?\]/g;
		html = regexStyle.replace(html, "<span class='$1'>$2</span>");

		if(styleName.startsWith("title")){
			output = Browser.document.createElement("h"+level);
		}
		else
			output = Browser.document.createParagraphElement();

		if(styleName != "")
			output.classList.add(styleName);

		output.innerHTML = html;

		return output;
	}
}