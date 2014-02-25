package grar.model.part;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

typedef ItemData = {

	var id : String;
	var content : String;
	var background : Null<String>;
	var button : Null<StringMap<StringMap<String>>>;
	var ref : Null<String>;
	var tokens : GenericStack<String>;
	var images : GenericStack<String>;
	var endScreen : Bool;
	var timelineIn : Null<String>;
	var timelineOut : Null<String>;
}

class Item /* implements PartElement */ {

	/**
     * Never called directly (only in sub-classes)
     */
// private function new(?xml:Fast, content:String = "")
	private function new(o : ItemData) {

		this.id = o.id;
		this.content = o.content;
		this.background = o.background;
		this.button = o.button;
		this.ref = o.ref;
		this.tokens = o.tokens;
		this.images = o.images;
		this.endScreen = o.endScreen;
		this.timelineIn = o.timelineIn;
		this.timelineOut = o.timelineOut;
	}

	/**
	 * @inherits
	 **/
	public var id (default, null) : String;

	/**
     * Content of the item
     */
	public var content (default, default) : String;

	/**
     * Background when the item is displayed
     **/
	public var background (default, default) : String;

	/**
     * ID of the button that will appear with this item
     **/
	public var button (default, default) : Null<StringMap<StringMap<String>>>;

	/**
     * Unique ref that will match the display
     **/
	public var ref (default, default) : String;

	/**
     * Reference to the tokens in this item
     **/
	public var tokens (default, null) : GenericStack<String>;
	/**
     * Graphicals items associated with this item
     **/
	public var images (default, default) : GenericStack<String>;

	public var endScreen (default, null) : Bool = false;

	public var timelineIn (default, default) : String;

	public var timelineOut (default, default) : String;

	/**
     * @return true if the item starts a vertical flow
     */
	public function hasVerticalFlow():Bool
	{
		return false;
	}

	/**
     * @return true if the item starts an activity
     */
	public function hasActivity():Bool
	{
		return false;
	}

	/**
    * @return true
    **/
	public function isText():Bool
	{
		return false;
	}

	/**
    * @return false
    **/
	public function isActivity():Bool
	{
		return false;
	}

	/**
    * @return false
    **/
	public function isPattern():Bool
	{
		return false;
	}

	/**
    * @return false
    **/
	public function isPart():Bool
	{
		return false;
	}

	/**
    * @return false
    **/
	public function isVideo():Bool
	{
		return false;
	}

	/**
    * @return false
    **/
	public function isSound():Bool
	{
		return false;
	}
}
