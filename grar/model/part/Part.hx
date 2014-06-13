package grar.model.part;

import grar.model.part.item.Item;
import grar.model.part.Pattern;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

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
	var isDone : Bool;
	var isStarted : Bool;
	var tokens : GenericStack<String>;
	//var soundLoopSrc : String;
	var soundLoop : String;
	var elements : Array<PartElement>;
	var buttons : List<ButtonData>;
    var images : List<ImageData>;
	var perks : Map<String, Int>;
	var score : Int;
	var ref : String;
	var requirements : Map<String, Int>;
	var next : Null<Array<String>>;
	var buttonTargets : Map<String, PartElement>;
	var nbSubPartTotal : Int;
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
}

typedef Rule = {

	var id : String;
	var type : String;
	var value : String;
}

typedef Input = {

	var id : String;
	var ref : String;
	var content : Map<String, String>;
	var values : Array<String>;
	var selected : Bool;
	var icon: Map<String, String>;
	var points: Int;
	@:optional var additionalValues: Array<String>;
}

typedef ActivityData = {
	var rules: Map<String, Rule>;
	var groups : Array<Inputs>;
	var groupIndex : Int;
	var numRightAnswers :Int;
	var score: Int;
	var inputsEnabled: Bool;
}

class Part{

	public function new(pd : PartData) {
		this.name = pd.name;
		this.id = pd.id;
		this.file = pd.file;
		this.parent = pd.parent;
		this.perks = pd.perks;
		this.tokens = pd.tokens;
		this.soundLoop = pd.soundLoop;
		this.elements = pd.elements;
		this.buttons = pd.buttons;
		this.images = pd.images;
		this.score = pd.score;
		this.ref = pd.ref;
		this.requirements = pd.requirements;
		this.next = pd.next;
		this.buttonTargets = pd.buttonTargets;
		this.nbSubPartTotal = pd.nbSubPartTotal;
		this.isDone = pd.isDone;
		this.isStarted = pd.isStarted;

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
     * True if the part is done
     */
	public var isDone (default, set) : Bool;

    /**
     * True if the part is started
     */
    public var isStarted (default, set) : Bool;

	/**
     * Tokens in this part
     */
	public var tokens (default, default) : GenericStack<String>;

	/**
     * Sound playing during the part
     */
	public var soundLoop (default, default) : String;

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

	public var elemIndex (default, set): Int;

	// TODO remove
	private var nbSubPartTotal : Int = 0;


	///
	// CALLBACKS
	//

	public dynamic function onActivateTokenRequest(tokenId : String) : Void { }

	public dynamic function onScoreToAdd(perk : String, score : Int) : Void { }


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

		if (pt == parent) {

			return parent;
		}
		parent = pt;

		this.onActivateTokenRequest = function(itId : String){ parent.onActivateTokenRequest(itId); }

		this.onScoreToAdd = function(perk : String, score : Int){ parent.onScoreToAdd(perk, score); }

		return parent;
	}

    public function set_isDone(completed : Bool = true) : Bool {

        isDone = completed;
		// Add bounty to the right perks
        if (isDone) {
            for (perk in perks.keys()) {

                //ScoreChart.instance.addScoreToPerk(perk, perks.get(perk));
                onScoreToAdd(perk, perks.get(perk));
            }
        }
        return completed;
    }

    public function set_isStarted(completed : Bool = true) : Bool {

        isStarted = completed;

        return completed;
    }

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
				case Pattern(p) if(p.itemIndex < p.patternContent.length): return elements[elemIndex] ;
				//case Part(p) if(activityData != null): return null;
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
					if (i.id == id) return e;
				case GroupItem(g):
					if (g.id == id) return e;
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

	public function hasNextGroup() : Bool {
		if(activityData == null)
			throw 'This part is not an activity';
		return activityData.groupIndex < activityData.groups.length;
	}

	public function getNextGroup() : Null<Inputs> {

		if(activityData == null)
			throw 'This part is not an activity';
		return activityData.groups[activityData.groupIndex++];
	}

	public function getInputGroup(inputId: String):Inputs
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

				selectedRules.push(rule);
			}
		}
		return selectedRules;
	}

	public function validate(inputId : String, ?value: String) : Bool {

		var input: Input = getInput(inputId);
		if(activityData == null)
			throw 'This part is not an activity';

		var i = 0;
		while (i < input.values.length && input.values[i] != (value != null ? value : Std.string(input.selected)))
			i++;

		var result = i != input.values.length;

		if (result)
			activityData.numRightAnswers++;

		//input.selected = value == "true";

		return result;
	}

	/**
	 * End an activity
	 * @return the id of the next Part if there is a threshold. If there is none, return null
	 **/
	// TODO use it or trash it!
	public function endActivity() : String {

		if(activityData == null)
			throw 'This part is not an activity';
		score = Math.round(activityData.numRightAnswers * 100 / activityData.groups[activityData.groupIndex].inputs.length);
		var contextuals = getRulesByType("contextual");

		for (rule in contextuals) {

			if (rule.value == "addtonotebook") {

				var currentGroup = activityData.groups[activityData.groupIndex];
				var inputs = currentGroup.inputs;

				if (currentGroup.groups != null) {

					for (group in currentGroup.groups) {

						inputs.concat(group.inputs);
					}
				}
				for (input in inputs) {

					if (input.selected) {

						// GameManager.instance.activateToken(input.id);
						onActivateTokenRequest(input.id);
					}
				}
			}
		}

		// Reset inputs
		for (group in activityData.groups) {

			for (input in group.inputs) {

				input.selected = false;
			}
		}

		var idNext : String = null;
		var thresholds = getRulesByType("threshold");

		if (thresholds.length == 0) {

			isDone = true;
			getNextElement();

		} else {

			thresholds.sort(function(t1: Rule, t2: Rule){

				if (Std.parseInt(t1.value) > Std.parseInt(t2.value)) {

					return -1;

				} else {

					return 1;
				}
			});

			var i = 0;
			// Search the highest threshold inferior or equal the score
			while (i < thresholds.length && score < Std.parseInt(thresholds[i].value)) {

				i++;
			}
			if (i == thresholds.length) {

				throw "[ActivityPart] You must have a threshold set to 0.";
			}
			idNext = thresholds[i].id;
		}
		return idNext;
	}
}
