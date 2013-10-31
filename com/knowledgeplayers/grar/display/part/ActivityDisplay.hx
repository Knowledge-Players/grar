package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.structure.part.Item;
import haxe.ds.GenericStack;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.GameManager;
import flash.geom.Point;
import com.knowledgeplayers.grar.util.guide.Curve;
import com.knowledgeplayers.grar.util.guide.Grid;
import com.knowledgeplayers.grar.util.guide.Guide;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.structure.part.ActivityPart;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.display.part.PartDisplay;

/**
 * Display of an activity
 */
class ActivityDisplay extends PartDisplay {

	private var groups: Map<String, Fast>;
	private var buttonsToInputs: Map<DefaultButton, Input>;
	private var autoCorrect: Bool;
	private var hasCorrection: Bool;
	private var inputs: GenericStack<DefaultButton>;
	private var validationRef: String;
	private var validatedInputs: Map<DefaultButton, Bool>;
	private var minSelect: Int;
	private var maxSelect: Int;
	private var validationButton: DefaultButton;

	public function new(model: Part)
	{
		super(model);
		autoCorrect = false;
		hasCorrection = true;
		groups = new Map<String, Fast>();
		buttonsToInputs = new Map<DefaultButton, Input>();
		inputs = new GenericStack<DefaultButton>();
		validatedInputs = new Map<DefaultButton, Bool>();
	}

	override public function nextElement(startIndex:Int = -1):Void
	{
		for(elem in part.elements){
			if(elem.isText()){
				setupItem(cast(elem, Item));
			}
		}
		displayPart();
	}

	override public function startPart(startPosition:Int = -1):Void
	{
		var activity = cast(part, ActivityPart);
		var currentGroup: Fast = groups.get(activity.currentGroup.ref);
		// Set guide to place inputs
		var guideNode = new Fast(currentGroup.x.firstElement());
		var guide: Guide = switch(guideNode.name.toLowerCase()){
			case "grid":
				var grid = new Grid(Std.parseInt(guideNode.att.numRow), Std.parseInt(guideNode.att.numCol));
				if(guideNode.has.width)
					grid.cellSize = {width: Std.parseFloat(guideNode.att.width), height: Std.parseFloat(guideNode.att.height)};
				if(guideNode.has.gapCol)
					grid.gapCol = Std.parseFloat(guideNode.att.gapCol);
				if(guideNode.has.gapRow)
					grid.gapRow = Std.parseFloat(guideNode.att.gapRow);
				if(guideNode.has.alignment)
					grid.setAlignment(guideNode.att.alignment);
				grid.x = Std.parseFloat(currentGroup.att.x);
				grid.y = Std.parseFloat(currentGroup.att.y);
				grid;
			case "curve":
				var curve = new Curve(new Point(Std.parseFloat(currentGroup.att.x), Std.parseFloat(currentGroup.att.y)));
				if(guideNode.has.radius)
					curve.radius = Std.parseFloat(guideNode.att.radius);
				if(guideNode.has.minAngle)
					curve.minAngle = Std.parseFloat(guideNode.att.minAngle);
				if(guideNode.has.maxAngle)
					curve.maxAngle = Std.parseFloat(guideNode.att.maxAngle);
				if(guideNode.has.centerObject)
					curve.centerObject = guideNode.att.centerObject == "true";
				curve;
			default:
				throw "[ActivityDisplay] Unsupported guide '"+guideNode.name+"'.";
		}
		// Create inputs, place & display them
		for(input in activity.getInputs()){
			var button:DefaultButton = new DefaultButton(displayTemplates.get(input.ref));
			guide.add(button);
			buttonsToInputs.set(button, input);
			for(contentKey in input.content.keys())
				button.setText(Localiser.instance.getItemContent(input.content.get(contentKey)), contentKey);
			button.buttonAction = onInputClick;
			button.mouseChildren = false;
			addChild(button);
			inputs.add(button);
		}
		var lastTemplate = displayTemplates.get(inputs.first().ref);
		if(lastTemplate.has.validation)
			validationRef = displayTemplates.get(inputs.first().ref).att.validation;

		// Checking rules
		// Validation
		var validationRules = cast(part, ActivityPart).getRulesByType("correction");
		if(validationRules.length > 1)
			throw "[ActivityDisplay] Multiple correction rules in activity '"+part.id+"'. Pick only one!";
		if(validationRules.length == 1){
			if(!displays.exists("validate"))
				throw "[ActivityDisplay] You must have a button with ref 'validate' in order to use the validation rule.";
			validationButton = cast(displays.get("validate"), DefaultButton);
			switch(validationRules[0].value){
				case "auto": autoCorrect = true;
				case "onvalidate":
					validationButton.buttonAction = validate;
				case "off": hasCorrection = false;
					validationButton.buttonAction = endActivity;
				default: trace("Unknown value '"+validationRules[0].value+"' as a validation rule");
			}
		}
		// Selection limits
		var selectLimits = cast(part, ActivityPart).getRulesByType("selectionlimits");
		if(selectLimits.length > 1)
			throw "[ActivityDisplay] Multiple selection limits rules in activity '"+part.id+"'. Pick only one!";
		if(selectLimits.length == 1){
			var limits = ParseUtils.parseListOfValues(selectLimits[0].value);
			if(limits.length == 1)
				maxSelect = minSelect = Std.parseInt(limits[0]);
			else if(limits.length == 2){
				minSelect = Std.parseInt(limits[0]);
				if(Std.parseInt(limits[1]) != null)
					maxSelect = Std.parseInt(limits[1]);
				else if(limits[1] == "*")
					maxSelect = 0; // Won't ever trigger limits, so unlimited selection
				else
					throw "[ActivityDisplay] Unknown character '"+limits[1]+"' for selection limits in activity '"+part.id+"'.";
			}
			else
				throw "[ActivityDisplay] There is more than 2 limits of selection in activity '"+part.id+"'. Just set a minimum and a maximum.";
			if(minSelect > 0)
				validationButton.enabled = false;
		}


		super.startPart(startPosition);
	}

	override public function parseContent(content:Xml):Void
	{
		super.parseContent(content);
		for(group in displayFast.nodes.Group){
			groups.set(group.att.ref, group);
		}
	}

	// Private

	private function validate(?target: DefaultButton):Void
	{
		if(autoCorrect){
			for(child in target.children){
				var correction = cast(part, ActivityPart).validate(buttonsToInputs.get(target), Std.string(target.toggleState == "inactive"));
				if(child.ref == validationRef && Std.is(child, DefaultButton))
					cast(child, DefaultButton).toggleState = Std.string(correction);
			}
			var allValidated = true;
			for(input in inputs){
				if(!validatedInputs.exists(input) || !validatedInputs.get(input))
					allValidated = false;
			}
			// Every inputs have been validated. What to do next?
			if(allValidated)
				trace("Fini");
		}
		else if(hasCorrection){
			for(button in inputs){
				var correction = cast(part, ActivityPart).validate(buttonsToInputs.get(button), Std.string(button.toggleState == "inactive"));
				for(child in button.children)
					if(child.ref == validationRef && Std.is(child, DefaultButton))
						cast(child, DefaultButton).toggleState = Std.string(correction);
			}
			validationButton.buttonAction = endActivity;
			disableInputs();
		}
	}

	private function endActivity(?target:DefaultButton):Void
	{
		var idNext = cast(part, ActivityPart).endActivity();

		if(idNext != null){
			var target = part.getElementById(idNext);
			if(target.isPart())
				GameManager.instance.displayPart(cast(target, Part));
			else
				throw "[ActivityPart] Thresholds must point to Part.";
		}
		else
			exitPart();
	}

	override private function mustBeDisplayed(key:String):Bool
	{
		var object = displays.get(key);

		if(Std.is(object, DefaultButton))
			return part.buttons.exists(key);
		else{
			for(elem in part.elements)
				if(elem.ref == key)
					return true;
		}

		return false;
	}

	override private function cleanDisplay():Void
	{
	}

	private inline function disableInputs():Void
	{
		for(input in inputs){
			input.enabled = false;
		}
	}

	// Handler

	private function onInputClick(?target: DefaultButton):Void
	{
		var clickRules = cast(part, ActivityPart).getRulesByType("onclick");
		for(rule in clickRules){
			switch(rule.value){
				case "goto":
					var target = part.getElementById(buttonsToInputs.get(target).values[0]);
					if(target.isPart())
						GameManager.instance.displayPart(cast(target, Part));
				case "toggle":
					target.toggle();
					validatedInputs.set(target, true);
			}
		}
		if(autoCorrect)
			validate(target);

		// Selection limits
		var validated = Lambda.count(validatedInputs);
		if(validated >= minSelect)
			validationButton.enabled = true;
		if(validated == maxSelect)
			disableInputs();
	}
}