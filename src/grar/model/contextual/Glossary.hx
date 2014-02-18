package grar.model.contextual;

import haxe.ds.StringMap;

/**
 * Glossary will be accessible in all your game to provide word definition
 */
class Glossary {

	public function new(d : StringMap<String>) {

		this.definitions = d;
	}

	/**
     * Array of all the words in the glossary, alphabetically sorted
     */
	public var words (get, never) : Array<String>;

	private var definitions : StringMap<String>;

	/**
     * Return the definition of a given word
     * @param	word : Word to define
     * @return the definition
     */
	public function getDefinition(word : String) : String {

		return definitions.get(word);
	}

	/**
     * Add an entry to the glossary
     * @param	word : Word to define
     * @param	definition : Definition of the word
     */
	public function addEntry(word : String, definition : String) : Void {

		definitions.set(word, definition);
	}

	/**
     * @return all the words in the glossary
     */
	public function get_words() : Array<String> {

		return Lambda.array(definitions.keys()).sort(sortWords);
	}

	/**
     * @return a string-based representation of the glossary
     */
	public function toString() : String {

		var strbuf : StringBuf = new StringBuf();
		
		for (key in definitions.keys()) {

			strbuf.add(key + ";");
		}
		return strbuf.toString();
	}


	///
	// Internals
	//

	private function sortWords(x : String, y : String) : Int {

		x = x.toLowerCase();
		y = y.toLowerCase();
		
		if (x < y) {

			return -1;
		}
		if (x > y) {

			return 1;
		}	
		return 0;
	}
}