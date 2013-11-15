package com.knowledgeplayers.grar.structure.part;

import haxe.ds.GenericStack;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.util.ParseUtils;
import haxe.xml.Fast;

using StringTools;

class ActivityPart extends StructurePart
{

	/**
	* Rules of this activity
	**/
	public var rules (default, null): Map<String, Rule>;

	/**
	* Inputs at the root of the activity (aka not in groups)
	**/
	public var inputs (default, null):Array<Input>;

	/**
	* Groups of input in this activity
	**/
	private var groups: Array<Group>;
	private var groupIndex: Int;

	public function new()
	{
		super();
		groups = new Array<Group>();
		rules = new Map<String, Rule>();
		inputs = new Array<Input>();
		groupIndex = -1;
	}

	public inline function getInputs():Array<Input>
	{
		return inputs.concat(groups[groupIndex].inputs);
	}

	public inline function hasNextGroup():Bool
	{
		return groupIndex < groups.length-1;
	}

	public inline function getNextGroup():Group
	{
		return groups[++groupIndex];
	}

	public function getRulesByType(type: String, ?group: Group):Array<Rule>
	{
		var selectedRules = new Array<Rule>();
		var rulesSet = new Map<String, Rule>();
		if(group != null){
			for(id in group.rules)
				rulesSet.set(id, rules.get(id));
		}
		else
			rulesSet = rules;
		for(rule in rulesSet){
			if(rule.type == type){
				selectedRules.push(rule);
			}
		}
		return selectedRules;
	}

	public function validate(input: Input, value: String): Bool
	{
		var i = 0;
		while(i < input.values.length && input.values[i] != value)
			i++;
		var result = i != input.values.length;
		if(result)
			score++;
		input.selected = value == "true";
		return result;
	}

	/**
	* End an activity
	* @return the id of the next Part if there is a threshold. If there is none, return null
	**/
	public function endActivity():String
	{
		var contextuals = getRulesByType("contextual");
		for(rule in contextuals){
			if(rule.value == "addtonotebook"){
				var inputs = getInputs();
				for(input in inputs){
					if(input.selected)
						GameManager.instance.activateToken(input.id);
				}
			}
		}

		var idNext: String = null;
		var thresholds = getRulesByType("threshold");
		if(thresholds.length == 0){
			end();
			getNextElement();
		}
		else{
			thresholds.sort(function(t1: Rule, t2: Rule){
				if(Std.parseInt(t1.value) > Std.parseInt(t2.value))
					return -1;
				else
					return 1;
			});
			var i = 0;
			// Search the highest threshold inferior or equal the score
			while(i < thresholds.length && score < Std.parseInt(thresholds[i].value))
				i++;
			if(i == thresholds.length)
				throw "[ActivityPart] You must have a threshold set to 0.";
			idNext = thresholds[i].id;
		}

		return idNext;
	}

	override public function restart():Void
	{
		super.restart();
		groupIndex = -1;
	}

	override public function toString():String
	{
		return 'ref: $ref, groups: $groups, rules: $rules, inputs: $inputs';
	}

	override public function isActivity():Bool
	{
		return true;
	}

	// Privates

	override private function parseContent(content:Xml):Void
	{
		var partFast:Fast = (content.nodeType == Xml.Element && content.nodeName == "Part") ? new Fast(content) : new Fast(content).node.Part;
		for(child in partFast.elements){
			switch(child.name.toLowerCase()){
				case "group":
					var rules: Array<String> = null;
					if(child.has.rules){
						rules = ParseUtils.parseListOfValues(child.att.rules);
					}
					var inputs = new Array<Input>();
					for(input in child.elements)
						inputs.push(createInput(input));
					var group: Group = {id: child.att.id, ref: child.att.ref, rules: rules, inputs: inputs};
					groups.push(group);

				case "rule":
					var rule: Rule = {id: child.att.id, type: child.att.type.toLowerCase(), value: child.att.value.toLowerCase()};
					rules.set(rule.id, rule);

				case "input": inputs.push(createInput(child));
			}
		}
		// If no rules has been set on a group, all applies
		for(group in groups){
			if(group.rules != null){
				for(rule in rules)
					group.rules.push(rule.id);
			}
		}

		super.parseContent(content);

		// Ordering Inputs
		var orderingRules = getRulesByType("ordering");
		if(orderingRules.length > 1)
			throw "[ActivityPart] Multiple ordering rules in activity '"+id+"'. Pick only one!";
		if(orderingRules.length == 1){
			if(orderingRules[0].value == "shuffle"){
				for(group in groups){
					var inputs: Array<Input> =  group.inputs;
					for(i in 0...inputs.length){
						var rand = Math.floor(Math.random()*inputs.length);
						var tmp = inputs[i];
						inputs[i] = inputs[rand];
						inputs[rand] = tmp;
					}
				}
			}
		}
	}

	private function createInput(xml:Fast):Input
	{
		var values;
		if(xml.has.values)
			values = ParseUtils.parseListOfValues(xml.att.values);
		else
			values = new Array<String>();
		return {id: xml.att.id, ref: xml.att.ref, content: ParseUtils.parseHash(xml.att.content), values: values, selected: false};
	}

	private function getAllInputs():Array<Input>
	{
		var inputsGroup = new Array<Input>();
		for(group in groups)
			inputsGroup = inputsGroup.concat(group.inputs);
		return inputs.concat(inputsGroup);
	}
}

typedef Group = {
	var id: String;
	var ref: String;
	var rules: Array<String>;
	var inputs: Array<Input>;
}

typedef Rule = {
	var id: String;
	var type: String;
	var value: String;
}

typedef Input = {
	var id: String;
	var ref: String;
	var content: Map<String, String>;
	var values: Array<String>;
	var selected: Bool;
}