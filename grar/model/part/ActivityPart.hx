package grar.model.part;

//import com.knowledgeplayers.grar.display.GameManager; FIXME (see below)

import grar.model.part.Part;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

using StringTools;

typedef Group = {

	var id : String;
	var ref : String;
	var rules : Array<String>;
	@:optional var groups : Array<Dynamic>;
	@:optional var inputs : Array<Input>;
}

typedef Rule = {

	var id : String;
	var type : String;
	var value : String;
}

typedef Input = {

	var id : String;
	var ref : String;
	var content : StringMap<String>;
	var values : Array<String>;
	var selected : Bool;
	@:optional var group : Group;
}

class ActivityPart extends Part {

	public function new(pd : PartData, g : Array<Group>, r : StringMap<Rule>, gi : Int, nra : Int) {

		super(pd);

		this.groups = g;
		this.rules = r;
		this.groupIndex = gi;
		this.numRightAnswers = nra;

		// Ordering Inputs
		var orderingRules = getRulesByType("ordering");

		if (orderingRules.length > 1) {

			throw "[ActivityPart] Multiple ordering rules in activity '"+id+"'. Pick only one!";
		}
		if (orderingRules.length == 1) {

			if (orderingRules[0].value == "shuffle") {

				for (group in groups) {

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
	}

	/**
	 * Rules of this activity
	 **/
	public var rules (default, null): StringMap<Rule>;

	/**
	 * Groups of input in this activity
	 **/
	private var groups : Array<Group>;
	private var groupIndex : Int;
	private var numRightAnswers :Int;


	///
	// API
	//

	public inline function hasNextGroup() : Bool {

		return groupIndex < groups.length-1;
	}

	public inline function getNextGroup() : Group {

		return groups[++groupIndex];
	}

	public function getRulesByType( type : String, ? group : Group ) : Array<Rule> {

		var selectedRules : Array<Rule> = new Array();
		var rulesSet : StringMap<Rule> = new StringMap();
		
		if (group != null && group.rules != null) {

			for (id in group.rules) {

				if (rules.exists(id)) {

					rulesSet.set(id, rules.get(id));
				}
			}

		} else {

			rulesSet = rules;
		}
		for (rule in rulesSet) {

			if (rule.type == type.toLowerCase()) {

				selectedRules.push(rule);
			}
		}
		return selectedRules;
	}

	public function validate(input : Input, value : String) : Bool {

		var i = 0;
		
		while (i < input.values.length && input.values[i] != value) {

			i++;
		}
		var result = i != input.values.length;
		
		if (result) {

			numRightAnswers++;
		}
		input.selected = value == "true";
		
		return result;
	}

	/**
	 * End an activity
	 * @return the id of the next Part if there is a threshold. If there is none, return null
	 **/
	public function endActivity() : String {

		score = Math.round(numRightAnswers * 100 / groups[groupIndex].inputs.length);
		var contextuals = getRulesByType("contextual");
		
		for (rule in contextuals) {

			if (rule.value == "addtonotebook") {

				var currentGroup = groups[groupIndex];
				var inputs = currentGroup.inputs;
				
				if (currentGroup.groups != null) {

					for (group in currentGroup.groups) {

						inputs.concat(group.inputs);
					}
				}
				for (input in inputs) {

					if (input.selected) {

						// GameManager.instance.activateToken(input.id); FIXME
					}
				}
			}
		}

		// Reset inputs
		for (group in groups) {

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

	override public function restart() : Void {

		super.restart();
		groupIndex = -1;
	}

	override public function toString() : String {

		return 'ref: $ref, groups: $groups, rules: $rules';
	}

	override public function isActivity():Bool
	{
		return true;
	}
}