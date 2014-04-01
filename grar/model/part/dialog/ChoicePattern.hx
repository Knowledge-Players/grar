package grar.model.part.dialog;

import grar.model.part.Pattern;
import grar.model.part.item.Item;

import haxe.ds.StringMap;

typedef Choice = {

	var ref : String;
	var toolTip : String;
	var goTo : String;
	var viewed : Bool;
}

/**
* Junction pattern with multiple choices for multiple direction
**/
class ChoicePattern extends Pattern {

	public function new(pd : PatternData, tr : String, c : StringMap<Choice>, nc : Int, mc : Int, tt : String) {

		super(pd);

		this.tooltipRef = tr;
		this.choices = c;
		this.numChoices = nc;
		this.minimumChoice = mc;
		this.tooltipTransition = tt;
	}

	/**
     * Minimum choices that needs to be explored before leaving the pattern
     **/
	public var minimumChoice (default, default) : Int;

	/**
     * Number of choices currently explored
     **/
	public var numChoices (default, default) : Int;

	/**
     * All the choices for this pattern
     **/
	public var choices (default, default) : StringMap<Choice>;

	/**
     * Reference to the tooltip area
     **/
	public var tooltipRef (default, default) : String;

	/**
     * Reference to the tooltip transition
     **/
	public var tooltipTransition (default, default) : String;


	///
	// API
	//

	override public function getNextItem() : Null<Item> {

		return patternContent[0];
	}

	/**
     * @return true
     **/
	override public function hasChoices() : Bool {

		return true;
	}
}
