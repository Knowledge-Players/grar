package grar.model.part.item;

import grar.model.part.ButtonData;
import grar.model.part.item.Item;

import haxe.ds.GenericStack;

typedef Choice = {

	var ref : String;
	var toolTip : String;
	var goTo : String;
	var viewed : Bool;
	var content: Map<String, String>;
	var id: String;
	var icon: Map<String, String>;

	/**
	* Hash of tokens that must or musn't be collected to activate the choice
	**/
	var requierdTokens: Map<String, Bool>;
}

/**
* Junction pattern with multiple choices for multiple direction
**/
typedef ChoicesData = {
	/**
     * Minimum choices that needs to be explored before leaving the pattern
     **/
	var minimumChoice: Int;

	/**
     * Number of choices currently explored
     **/
	var numChoices: Int;

	/**
     * All the choices for this pattern
     **/
	var choices: Map<String, Choice>;

	/**
     * Reference to the tooltip area
     **/
	var tooltipRef: String;

	/**
	* Reference to the container of the choices
	**/
	var ref: String;

	var question: Map<String, String>;
}

typedef PatternData = {

	var id : String;
	var patternContent : Array<Item>;
	var ref : String;
	var nextPattern : String;
	var buttons : List<ButtonData>;
	var tokens : GenericStack<String>;
	var endScreen : Bool;
	var itemIndex : Int;
	var choicesData: ChoicesData;
	@:optionnal var counterRef: String;
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
		this.choicesData = pd.choicesData;
		if(pd.counterRef != null)
			this.counterRef = pd.counterRef;
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
	public var nextPattern (default, default) : Null<String>;

	/**
     * Buttons for this pattern
	 **/
	public var buttons (default, null) : Null<List<ButtonData>>;

	public var tokens (default, null) : GenericStack<String>;

	public var endScreen (default, null) : Bool = false;

	/**
	* Reference to a counter of pattern avancement
	**/
	public var counterRef (default, null):Null<String>;

	/**
	* Current active item in the pattern
	**/
	public var currentItem (get, null):Item;

	/**
	* Naviguation choices
	**/
	public var choicesData (default, default):ChoicesData;

	/**
     * Current item index
	 **/
	private var itemIndex (default, set): Int = 0;

	///
	// GETTER/SETTER
	//

	private function set_itemIndex(index: Int):Int
	{
        if(index < 0)
			itemIndex = 0;
		else if(index > patternContent.length)
			itemIndex = patternContent.length -1;
		else
			itemIndex = index;
		return itemIndex;
	}

	private function get_currentItem():Item
	{
		return patternContent[itemIndex-1];
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
			//restart();
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
			//restart();
			return null;
		}
	}

	public inline function hasNextItem():Bool
	{
		return itemIndex < patternContent.length;
	}

	/**
     * Restart a pattern
	 **/
	public inline function restart() : Void {

		itemIndex = 0;
	}
}