package grar.model.part;

import grar.model.part.Part;

import haxe.ds.StringMap;

using StringTools;

/*typedef Inputs = {

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
	@:optional var group : Inputs;
}*/

class ActivityPart extends Part {

	public function new(pd : PartData, g : Array<Inputs>, r : StringMap<Rule>, gi : Int, nra : Int) {

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
	private var groups : Array<Inputs>;
	private var groupIndex : Int;
	private var numRightAnswers :Int;


	///
	// API
	//



	override public function nextElement():Void
	{

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