package grar.model.part;

import grar.model.part.item.Item;

import haxe.ds.GenericStack;

typedef PatternData = {

	var id : String;
	var patternContent : Array<Item>;
	var ref : String;
	var nextPattern : String;
	var buttons : List<ButtonData>;
	var tokens : GenericStack<String>;
	var endScreen : Bool;
	var itemIndex : Int;
}

class Pattern {

	public function new(pd : PatternData) {

		this.id = pd.id;
		this.patternContent = pd.patternContent;
		this.ref = pd.ref;
		this.nextPattern = pd.nextPattern;
		this.buttons = pd.buttons;
		this.tokens = pd.tokens;
		this.endScreen = pd.endScreen;
		this.itemIndex = pd.itemIndex;
	}

	/**
	 * @inherits
	 **/
	public var id (default, null) : String;

	/**
     * Array of item composing the pattern
     */
	public var patternContent (default, default) : Array<Item>;

	/**
	 * @inheritDoc
	 **/
	public var ref (default, default) : String;

	/**
     * Id of the next pattern
	 **/
	public var nextPattern (default, default) : String;

	/**
     * Buttons for this pattern
	 **/
	public var buttons (default, null) : Null<List<ButtonData>>;

	public var tokens (default, null) : GenericStack<String>;

	public var endScreen (default, null) : Bool = false;

	/**
     * Current item index
	 **/
	public var itemIndex (default, set): Int = 0;

	///
	// GETTER/SETTER
	//

	public function set_itemIndex(index: Int):Int
	{
        if(index < 0)
			itemIndex = 0;
		else if(index > patternContent.length)
			itemIndex = patternContent.length -1;
		else
			itemIndex = index;
		return itemIndex;
	}

	///
	// API
	//

	/**
     * @return the next item in the pattern, or null if the pattern reachs its end
     */
	public function getNextItem() : Null<Item> {


		if (itemIndex < patternContent.length)
            return patternContent[itemIndex++];
		else {
			restart();
			return null;
		}

	}

	/**
     * @return the previous item in the pattern, or null if the pattern reachs its beginning
     */
	public function getPreviousItem() : Null<Item> {

		if (itemIndex > 2){
			itemIndex--;
			return patternContent[itemIndex-1];
		}
		else{
			restart();
			return null;
		}
	}

	/**
     * Restart a pattern
	 **/
	public inline function restart() : Void {

		itemIndex = 0;
	}

	/**
     * @return whether this pattern has choice or not
	 **/
	public function hasChoices() : Bool {

		return false;
	}
}