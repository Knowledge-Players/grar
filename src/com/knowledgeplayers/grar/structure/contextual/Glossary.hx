package com.knowledgeplayers.grar.structure.contextual;

import haxe.xml.Fast;
import nme.events.Event;

/**
 * Glossary will be accessible in all your game to provide word definition
 */
class Glossary {
	/**
     * Instance
     */
	public static var instance (getInstance, null):Glossary;

	/**
     * Array of all the words in the glossary, alphabetically sorted
     */
	public var words (getWords, null):Array<String>;

	private var definitions:Hash<String>;

	/**
     * @return the instance
     */

	static public function getInstance():Glossary
	{
		if(instance == null)
			instance = new Glossary();
		return instance;
	}

	/**
     * Fill the glossary using an XMl file
     * @param	filePath : Path to the XML
     */

	public function fillWithXml(filePath:String):Void
	{
		parseContent(filePath);
	}

	/**
     * Return the definition of a given word
     * @param	word : Word to define
     * @return the definition
     */

	public function getDefinition(word:String):String
	{
		return definitions.get(word);
	}

	/**
     * Add an entry to the glossary
     * @param	word : Word to define
     * @param	definition : Definition of the word
     */

	public function addEntry(word:String, definition:String):Void
	{
		definitions.set(word, definition);
		words.push(word);
	}

	/**
     * @return all the words in the glossary
     */

	public function getWords():Array<String>
	{
		words.sort(sortWords);
		return words;
	}

	/**
     * @return a string-based representation of the glossary
     */

	public function toString():String
	{
		var strbuf:StringBuf = new StringBuf();
		for(key in definitions.keys()){
			strbuf.add(key + ";");
		}
		return strbuf.toString();
	}

	// Private

	private function parseContent(content:Xml):Void
	{
		var fast:Fast = new Fast(content).node.Glossary;
		for(def in fast.nodes.Definition){
			addEntry(def.att.word, def.innerData);
		}
	}

	private function sortWords(x:String, y:String):Int
	{
		x = x.toLowerCase();
		y = y.toLowerCase();
		if(x < y) return -1;
		if(x > y) return 1;
		return 0;
	}

	private function new()
	{
		definitions = new Hash<String>();
		words = new Array<String>();
	}

}