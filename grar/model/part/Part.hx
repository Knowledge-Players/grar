package grar.model.part;

import Array;
import grar.util.Point;

import grar.model.part.item.Item;
import grar.model.part.item.Pattern;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

using Lambda;

enum PartType {

	Part;
	Activity;
}

typedef PartialPart = {

	var pd : PartData;
	var type : PartType;
}

typedef ImageData ={
    var src:String;
    var ref:String;
}

typedef PartData = {

	var name : String;
	var id : String;
	var file : String;
	var parent : Null<Part>;
	var tokens : GenericStack<String>;
	var elements : Array<PartElement>;
	var buttons : List<ButtonData>;
    var images : List<ImageData>;
	var perks : Map<String, Int>;
	var score : Int;
	var ref : String;
	var requirements : Map<String, Int>;
	var next : Null<Array<String>>;
	var buttonTargets : Map<String, PartElement>;
	// partial data
	var partialSubParts : Array<PartialPart>;
	var xml : Xml;
}

typedef Inputs = {

	var id : String;
	var ref : String;
	var rules : Array<String>;
	@:optional var groups : Array<Inputs>;
	@:optional var inputs : Array<Input>;
    @:optional var items : Array<Item>;
	@:optional var position: Array<Point>;
}

typedef Rule = {

	var id : String;
	var type : String;
	var value : String;
/*

	var trigger : String;
	var injunctions : Array<InjunctionType>;
 */
}

typedef Input = {

	var id : String;
	var ref : String;
	var items : Map<String, Item>;
	var values : Array<String>;
	var selected : Bool;
	var visited: Bool;
	var images: Map<String, String>;
	var points: Int;
	var correct: Bool;
	@:optional var additionalValues: Array<String>;
}

typedef ActivityData = {
	/**
	* Rules for this activity
	**/
	var rules: Map<String, Rule>;
	/**
	* Groups of group of inputs
	**/
	var groups: Array<Inputs>;
	/**
	* Progression index
	**/
	var groupIndex: Int;
	/**
	* Number of right answer when auto correcting
	**/
	var numRightAnswers: Int;
	/**
	* Score for this activity
	**/
	var score: Int;
	/**
	* Enable inputs (i.e. clicks are active)
	**/
	var inputsEnabled: Bool;
}

enum PartState{
	STARTED;
	FINISHED;
}

/*
enum InjunctionType {
	SETTER(obj: Dynamic, value: Dynamic);
	GETTER(src: String, target: Map<String, String>);
	PUTTER(obj: String, target: Iterable<String>);
	VALIDATOR;
}

 */

class Part{

	public function new(pd : PartData) {
		this.name = pd.name;
		this.id = pd.id;
		this.file = pd.file;
		this.parent = pd.parent;
		this.perks = pd.perks;
		this.tokens = pd.tokens;
		this.elements = pd.elements;
		this.buttons = pd.buttons;
		this.images = pd.images;
		this.score = pd.score;
		this.ref = pd.ref;
		this.requirements = pd.requirements;
		this.next = pd.next;
		this.buttonTargets = pd.buttonTargets;

		// Initialize indexes
		restart();
	}

	/**
     * Name of the part
     */
	public var name (default, default) : String;

	/**
     * ID of the part
     */
	public var id (default, default) : String;

	/**
     * Path to the XML structure file
     */
	public var file (default, default) : String;

	/**
	 * Parent of this part
	 **/
	public var parent (default, set) : Null<Part>;

	/**
	* Completion state of this part
	**/
	public var state (default, set):PartState;

	/**
     * Tokens in this part
     */
	public var tokens (default, default) : GenericStack<String>;

	/**
     * Elements of the part
	 **/
	public var elements (default, null) : Array<PartElement>;

	/**
     * Button of the part
     **/
	public var buttons (default, default) : List<ButtonData>;

     /**
     * Images of the part
     **/
    public var images (default, default) : List<ImageData>;

	/**
	 * Perks of this part
	 **/
	public var perks (default, null) : Map<String, Int>;

	/**
	 * Score of this part
	 **/
	public var score (default, default) : Int;

	/**
	 * @inheritDoc
	 **/
	public var ref (default, default) : String;

	/**
	 * Perks requirements to start the part
	 **/
	public var requirements (default, null) : Map<String, Int>;

	public var next (default, default) : Null<Array<String>>;

	public var endScreen (default, null) : Bool = false;

	public var buttonTargets (default, null) : Map<String, PartElement>;

	public var activityData (default, set):ActivityData;

	public var currentElement (get, null):PartElement;

	private var elemIndex (default, set): Int;


	///
	// CALLBACKS
	//

	public dynamic function onActivateTokenRequest(tokenId : String) : Void { }

	public dynamic function onScoreToAdd(perk : String, score : Int) : Void { }

	public dynamic function onStateChanged(state: PartState): Void {}



	///
	// GETTER / SETTER
	//

	public function set_elemIndex(index:Int):Int
	{
		if(index < 0)
			elemIndex = 0;
		else if(index > elements.length)
			setIndexToEnd();
		else
			elemIndex = index;
		return elemIndex;
	}

	public function set_parent(pt : Null<Part>) : Null<Part> {

		// undefined == null for JS target, so parent is not initialized to null
		/*if (pt == parent) {

			return parent;
		}*/

		parent = pt;

		this.onActivateTokenRequest = function(itId : String){ parent.onActivateTokenRequest(itId); }

		this.onScoreToAdd = function(perk : String, score : Int){ parent.onScoreToAdd(perk, score); }

		return parent;
	}

	private function set_state(state:PartState):PartState
	{
		switch(state){
			case FINISHED:
				for (perk in perks.keys()) {
					//ScoreChart.instance.addScoreToPerk(perk, perks.get(perk));
					onScoreToAdd(perk, perks.get(perk));
				}
				// Reset inputs
				if(activityData != null)
					activityData.inputsEnabled = true;
			case STARTED: // nothing
		}

		onStateChanged(state);
		return this.state = state;
	}

    /*public function set_isDone(completed : Bool = true) : Bool {

        isDone = completed;
		// Add bounty to the right perks
        if (isDone) {
            for (perk in perks.keys()) {

                //ScoreChart.instance.addScoreToPerk(perk, perks.get(perk));
                onScoreToAdd(perk, perks.get(perk));
            }
        }

	    // Reset inputs
	    if(activityData != null)
		    activityData.inputsEnabled = true;

        return completed;
    }

    public function set_isStarted(completed : Bool = true) : Bool {

        isStarted = completed;

        return completed;
    }*/

	public function set_activityData(ad:ActivityData):ActivityData
	{
		activityData = ad;

		// Ordering Inputs
		var orderingRules = getRulesByType("ordering");

		if (orderingRules.length > 1) {

			throw "[ActivityPart] Multiple ordering rules in activity '"+id+"'. Pick only one!";
		}
		if (orderingRules.length == 1) {

			if (orderingRules[0].value == "shuffle") {

				for (group in activityData.groups) {

					var inputs : Array<Input> =  group.inputs;

					for (i in 0...inputs.length) {

						var rand = Math.floor( Math.random() * inputs.length );
						var tmp = inputs[i];
						inputs[i] = inputs[rand];
						inputs[rand] = tmp;
					}
				}
			}
		}
		return activityData;
	}

	public function get_currentElement():PartElement
	{
		if(elemIndex == elements.length)
			return elements[elemIndex-1];
		else
			return switch(elements[elemIndex]){
				case Pattern(p): elements[elemIndex];
				default: elements[elemIndex-1];
			}
	}

    ///
    // API
    //

	/**
	* Set the part index to the end of the part, so the call to getNextElement will return the last element of the part.
	**/
	public inline function setIndexToEnd():Void
	{
		elemIndex = elements.length - 1;
	}

	public inline function hasNextElement():Bool
	{
		return elemIndex < elements.length;
	}

	/**
	* @param    startIndex : Next element after this position
    * @return the next element in the part or null if the part is over
    */
	public function getNextElement(startIndex : Int = -1) : Null<PartElement> {

		if (startIndex > -1)
			elemIndex = startIndex;

		if (hasNextElement()){
			// If current element is a pattern, explore pattern first
			switch(elements[elemIndex]){
				case Pattern(p) if(p.hasNextItem() || p.nextPattern != null): return elements[elemIndex] ;
				case Part(p) if(p.state == FINISHED):
					elemIndex++;
					return getNextElement();
				default: return elements[elemIndex++];
			}
		}
		else{
			restart();
			return null;
		}
	}

	/**
    * @return previous element in the part or null if at the beginning of the part
    */
	public function getPreviousElement() : Null<PartElement> {

		if(elemIndex < elements.length){
			// If current element is a pattern, restart it
			switch((elements[elemIndex])){
				case Pattern(p): p.restart();
				default:
			}
		}

		if (elemIndex > 2){
			elemIndex--;
			// Need to step 2 back, because elemIndex is already pointing for next element
			return elements[elemIndex-1];
		}
		else{
			restart();
			return null;
		}
	}

	/**
	* Get the position in this element in the part
	* @param    element : Element to find
	* @return the position of this element
	**/
	public function getElementIndex(element : PartElement) : Int {

		var i = 0;
		while (i < elements.length && !Type.enumEq( elements[i], element ))
			i++;

		return i == elements.length ? - 1 : i + 1;
	}

	/**
     * Tell if this part has sub-part or not
     * @return true if it has sub-part
     */
	public function hasParts() : Bool {

		for (e in elements) {

			switch (e) {

				case Part(p):

					return true;

				default: // nothing
			}
		}
		return false;
	}

	/**
     * @return all the sub-part of this part
     */
	public function getAllParts() : Array<Part> {

		var a : Array<Part> = [];
		a.push(this);

		for (e in elements) {
			switch (e) {
				case Part(p): a = a.concat(p.getAllParts());
				default: // nothing
			}
		}

		return a;
	}

	public function getElementById(id : String) : PartElement {

		for (e in elements) {
			switch (e) {
				case Part(p):
					if (p.id == id) return e;
				case Pattern(p):
					if (p.id == id) return e;
				case Item(i):
					if (i.content == id) return e;
				default: // nothing
			}
		}
		throw "[StructurePart] There is no Element with the id '"+id+"'.";
	}

	/**
     * @return a string-based representation of the part
     */
	public function toString() : String {

		return "Part " + name + " " + file + " : " + elements.toString();
	}

	public function restart() : Void {

		elemIndex = 0;
		if(activityData != null){
			activityData.groupIndex = 0;
			activityData.score = 0;
		}
	}

	/**
     * @param    id : Id of the item
     * @return the name of the item
     **/
	public function getItemName(id : String) : Null<String> {

		if (this.id == id)
			return this.name;

		for (e in elements) {
			switch(e) {
				case Part(p) if (p.getItemName(id) != null):
						return p.getItemName(id);
				default: // nothing
			}
		}
		return null;
	}

	// Activity API

	public function getNextGroup() : Null<Inputs> {

		if(activityData == null)
			throw 'This part is not an activity';
		return activityData.groups[activityData.groupIndex++];
	}

	public function getInputGroup(inputId: String):Null<Inputs>
	{
		var i = 0;
		var result: Inputs = null;
		while(i < activityData.groups.length && result == null){
			var group = activityData.groups[i];
			result = searchGroup(group, inputId);
			i++;
		}
		return result;
	}

	/**
	* Get the number of visited inputs in a group
	* @param group: Group where to count
	*
	* @return the number of visited inputs
	**/
	public inline function getNumInputsVisited(group:Inputs):Int
	{
		return group.inputs.count(function(input: Input) return input.visited);
	}

	public function getInput(inputId:String):Null<Input>
	{
		if(activityData == null)
			throw 'This part is not an activity';

		var result: Input = null;
		var group: Inputs = null;
		var i = 0;
		while(i < activityData.groups.length && group == null){
			group = searchGroup(activityData.groups[i], inputId);
			i++;
		}

		if(group != null){
			var j = 0;
			while(j < group.inputs.length && group.inputs[j].id != inputId)
				j++;

			result = group.inputs[j];
		}

		return result;
	}

	private function searchGroup(group:Inputs, id: String):Inputs
	{
		var result: Inputs = null;
		if(group.groups != null){
			var j = 0;
			while(j < group.groups.length && result == null){
				result = searchGroup(group.groups[j], id);
				j++;
			}
		}
		if(group.inputs != null){
			var k = 0;
			while(k < group.inputs.length && group.inputs[k].id != id)
				k++;
			if(k < group.inputs.length)
				result = group;
		}

		return result;
	}

	public function getRulesByType( type : String, ? group : Inputs ) : Array<Rule> {

		if(activityData == null)
			throw 'This part is not an activity';
		var selectedRules : Array<Rule> = new Array();
		var rulesSet : StringMap<Rule> = new StringMap();

		if (group != null && group.rules != null) {

			for (id in group.rules) {

				if (activityData.rules.exists(id)) {

					rulesSet.set(id, activityData.rules.get(id));
				}
			}

		} else {

			rulesSet = activityData.rules;
		}
		for (rule in rulesSet) {

			if (rule.type == type.toLowerCase()) {
			//if (rule.trigger == type.toLowerCase()) {
				selectedRules.push(rule);
			}
		}
		return selectedRules;
	}

	public function validate(inputId : String, ?value: String) : Bool {

		if(activityData == null)
			throw 'This part is not an activity';

		var input: Input = getInput(inputId);

		var i = 0;
		while (i < input.values.length && input.values[i] != (value != null ? value : Std.string(input.selected)))
			i++;

		var result = i != input.values.length;
		input.correct = result;

		if (result)
			activityData.numRightAnswers++;

		//input.selected = value == "true";

		return result;
	}

	/**
	* @return score of the activity from 0 to 100
	**/
	public function getScore():Int
	{
		if(activityData == null)
			throw 'This part is not an activity';

		var numGroup = 0;
		for(group in activityData.groups)
			numGroup += group.inputs.length;

		return score = Std.int(activityData.numRightAnswers * 100 / numGroup);
	}
}
