package grar.view.style;

typedef ParagraphElement = String;

/**
 * Parser for the MarkUp language
 */
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
	public function parse(text:String):List<ParagraphElement>
	{
		var list = new List<ParagraphElement>();
		return list;
	}


	///
	// INTERNALS
	//

	private function parseLine(line : String) : ParagraphElement {
		return null;
	}
}