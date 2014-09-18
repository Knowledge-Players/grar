package grar.model;

import grar.model.part.Part.ImageData;
import grar.model.part.item.Item;

typedef TokenData = {
	var ref: String;
	var id : String;
	var isActivated : Bool;
	var content : Map<String, Item>;
	var images : Map<String, ImageData>;
	@:optional var timecode: Float;
}

typedef TokenTrigger = {
	var id: String;
	@:optional var timecode: Float;
}

/**
 * A token that can be earned during parts or activities and stored into the inventory.
 **/
class InventoryToken {

	public function new(td : TokenData) : Void
	{
		this.id = td.id;
		this.isActivated = td.isActivated;
		this.content = td.content;
		this.images = td.images;
		this.ref = td.ref;
		this.timecode = td.timecode;
	}

	/**
     * Unique identifier
     **/
	public var id (default, null) : String;

	/**
	* Reference to the view template
	**/
	public var ref (default, default):String;

	/**
     * State of activation
     **/
	public var isActivated (default, default) : Bool;

	/**
     * Content of this token
     **/
	public var content (default, default) : Map<String, Item>;

	/**
     * Image to display when it's fullscreen
     **/
	public var images (default, default) : Map<String, ImageData>;

	/**
	* For non-text item only.
	* Time-code when to activate the token
	**/
	public var timecode (default, default):Float;
}