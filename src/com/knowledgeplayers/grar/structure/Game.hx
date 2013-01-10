package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.tracking.Connection;
import haxe.xml.Fast;
import nme.events.IEventDispatcher;


interface Game implements IEventDispatcher 
{
	public var mode (default, default): Mode;
	public var title (default, default): String;
	public var state (default, default): String;
	public var inventory (default, null): Array<String>;

	/**
	 * Start the game
	 * @param	partId : the ID of the part to start.
	 * @return 	the part with id partId or null if this part doesn't exist
	 */
	public function start(partId: Int = 0) : Null<Part>;
	
	/**
	 * Return the next part of the game
	 * @return the next part or null if the game is over
	 */
	public function next() : Null<Part>;

	/**
	 * Initialize the game with a xml structure
	 * @param	xml : the structure
	 */
	public function init(xml: Xml) : Void;

	/**
	 * Add a part to the game at partIndex
	 * @param	partIndex : position of the part in the game
	 * @param	part : the part to add
	 */
	public function addPart(partIndex: Int, part: Part) : Void;
	
	/**
	 * Return all the parts of the game
	 * @return an array of parts
	 */
	public function getAllParts() : Array<Part>;

	/**
	 * Add a language to the game
	 * @param	value : name of the language
	 * @param	path : path to the localisation folder
	 * @param	flagIconPath : path to the flag for this language
	 */
	public function addLanguage(value: String, path: String, flagIconPath: String) : Void;

	/**
	 * Start the tracking
	 * @param	mode : tracking mode (SCORM/AICC)
	 */
	public function initTracking(?mode: Mode) : Void;

	/**
	 * Get the state of loading of the game
	 * @return a float between 0 (nothing loaded) and 1 (everything's loaded)
	 */
	public function getLoadingCompletion() : Float;

	/**
	 * @return a string-based representation of the game
	 */
	public function toString() : String;
}
