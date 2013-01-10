package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import haxe.xml.Fast;
import nme.events.IEventDispatcher;
import nme.media.Sound;



interface Part implements IEventDispatcher
{
	public var name (default, default): String;
	public var id (default, default): Int;
	public var file (default, null): String;
	public var display (default, default): String;
	public var isDone (default, default): Bool;

	public var options (default, null): Hash<String>;
	public var activities (default, null): IntHash<Activity>;
	public var parts (default, null): IntHash<Part>;
	public var items (default, null): Array<Item>;
	public var inventory (default, null): Array<String>;
	public var soundLoop (default, default): Sound;

	/**
	 * Initialize a part with a xml structure
	 * @param	xml : a Fast xml object with initialization data
	 * @param	filePath : the path to the part file structure
	 */
	public function init(xml: Fast, filePath: String = "") : Void;

	/**
	 * Start this part
	 * @param	forced : Force the part to start, even if it's already done
	 * @return 	this part
	 */
	public function start(forced: Bool = false) : Part;

	/**
	 * @return the part following this one or null if there is none
	 */
	public function next() : Null<Part>;

	/**
	 * @return the next item in the part or null if the part is over
	 */
	public function getNextItem() : Null<Item>;

	/**
	 * @return all the sub-part of this part
	 */
	public function getAllParts() : Array<Part>;

	/**
	 * Tell if this part has sub-part or not
	 * @return true if it has sub-part
	 */
	public function hasParts() : Bool;

	/**
	 * @return the number of sub-part
	 */
	public function partsCount() : Int;

	/**
	 * @return the number of activities in the part
	 */
	public function activitiesCount() : Int;

	/**
	 * @return a string-based representation of the part
	 */
	public function toString() : String;
	
	/**
	 * Tell if this part is a dialog
	 * @return true if this part is a dialog
	 */
	public function isDialog() : Bool;
}