package grar.model.part;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

typedef PatternData = {

	var id : String;
	var patternContent : Array<Item>;
	var ref : String;
	var nextPattern : String;
	var buttons : StringMap<StringMap<String>>;
	var tokens : GenericStack<String>;
	var endScreen : Bool;
	var itemIndex : Int;
}

class Pattern /* implements PartElement */ {

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
	public var buttons (default, null) : StringMap<StringMap<String>>;

	/**
     * Implements PartElement. FIXME should it be removed or is it still useful ?
     **/
	public var tokens (default, null) : GenericStack<String>;

	public var endScreen (default, null) : Bool = false;

	/**
     * Current item index
	 **/
	private var itemIndex : Int = 0;


	///
	// API
	//

	/**
     * @return the next item in the pattern, or null if the pattern reachs its end
     */
	public function getNextItem() : Null<Item> {

		if (itemIndex < patternContent.length) {

			itemIndex++;
			return patternContent[itemIndex - 1];
		
		} else {

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