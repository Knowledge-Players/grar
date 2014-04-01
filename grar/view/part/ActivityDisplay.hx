package grar.view.part;

import js.html.Element;

import grar.view.part.PartDisplay;
import grar.view.guide.Guide;
import grar.view.guide.Curve;
import grar.view.guide.Line;
import grar.view.guide.Grid;

import grar.model.part.ActivityPart;

import grar.util.ParseUtils;

import haxe.ds.StringMap;
import haxe.ds.GenericStack;

using Lambda;
using Std;

typedef Coordinates = {

	var x : Float;
	var y : Float;
}

/**
 * Display of an activity
 */
class ActivityDisplay extends PartDisplay {

	public function new(callbacks : grar.view.DisplayCallbacks) {

		super(callbacks);

		autoCorrect = false;
		hasCorrection = true;
		groups = new StringMap();
		buttonsToInputs = new Map();
		inputs = new GenericStack<Element>();
		validatedInputs = new Map();
	}

	private static inline var dropRef: String = "dropZone";

	private var groups : StringMap<{ x : Float, y : Float, guide : GuideData }>;

	private var buttonsToInputs : Map<Element, Input>;
	private var autoCorrect : Bool;
	private var hasCorrection : Bool;
	private var inputs : GenericStack<Element>;
	private var validationRef : String;
	private var validatedInputs : Map<Element, Bool>;
	private var minSelect : Int;
	private var maxSelect : Int;
	private var validationButton : Element;
	private var dragOrigin : Coordinates;


	///
	// CALLBACKS
	//

	public dynamic function onValidate() : Void { }

	public dynamic function onInputEvents(inputRef: String, eventType: String) : Void { }

	/*override public function nextElement(startIndex : Int = -1) : Void {

		// If startIndex == 0, it's called from startPart, no verification needed
		if(startIndex == 0 || cast(part, ActivityPart).hasNextGroup()){
			for(elem in part.elements){

				switch(elem) {

					case Item(i):

						if (i.isText()) {

							setupItem(i);
						}
					default: // nothing
				}
			}
			displayInputs();
			displayPart();
		}
		else
			exitPart();
	}

	public function startPart(startPosition:Int = -1) : Void {

		//displayInputs();

		// Checking rules
		// Validation
		var validationRules = cast(part, ActivityPart).getRulesByType("correction");

		if (validationRules.length > 1) {

			throw "[ActivityDisplay] Multiple correction rules in activity '"+part.id+"'. Pick only one!";
		}
		if (validationRules.length == 1) {

			if (document.getElementById(validationRules[0].id) == null) {

				throw "[ActivityDisplay] You must have a button with ref '"+validationRules[0].id+"' (same as the id of your rule) in order to use the correction rule.";
			}
			validationButton = document.getElementById(validationRules[0].id);

			switch (validationRules[0].value) {

				case "auto":

					autoCorrect = true;

				case "onvalidate":

					validationButton.onclick = function(_) onValidate();

				case "off":

					hasCorrection = false;
					validationButton.onclick = function(_) endActivity();

				default:

					trace("Unknown value '"+validationRules[0].value+"' as a validation rule");
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
					maxSelect = -1; // Won't ever trigger limits, so unlimited selection
				else
					throw "[ActivityDisplay] Unknown character '"+limits[1]+"' for selection limits in activity '"+part.id+"'.";
			}
			else
				throw "[ActivityDisplay] There is more than 2 limits of selection in activity '"+part.id+"'. Just set a minimum and a maximum.";
			if(minSelect > 0 && validationButton != null){
				validationButton.classList.add("locked");
			}
		}

		//super.startPart(0);
	}

	public function checkInput(inputRef:String):Void
	{
		document.getElementById(inputRef).classList.add("checked");
	}

	// Private

	private function displayInputs() : Void {

		var activity = cast(part, ActivityPart);

		var currentGroup : Group = activity.getNextGroup();

		// Create inputs, place & display them
		if (currentGroup.inputs != null) {

			var guide = createGroupGuide(currentGroup);

			for (input in currentGroup.inputs) {

				createInput(input, guide);
			}
		}
		if (currentGroup.groups != null) {

			for (group in currentGroup.groups) {

				var guide = createGroupGuide(group);

				// Specify inputs because of an "Can't iterate on a Dynamic value" error
				var inputs : Array<Input> = group.inputs;

				for (input in inputs) {

					createInput(input, guide);
				}
			}
		}
		if (!inputs.isEmpty()) {

			var lastTemplate : Element = inputs.first();

			if (lastTemplate.hasAttribute('validation')) {

				validationRef = lastTemplate.getAttribute('validation');
			}
		}
	}

	private inline function createInput(input : Input, guide : Guide) : Void {

		var inputElement = document.getElementById(input.ref);
		if (inputElement == null) {

			throw "[ActivityDisplay] There is no template for input named "+input.ref+".";
		}

		var newInput: Element = cast inputElement.cloneNode(true);
		// Generate a unique ID for each input
		newInput.id += haxe.Timer.stamp();
		guide.add(newInput);
		buttonsToInputs.set(newInput, input);
		for (contentKey in input.content.keys()) {
			document.getElementById(contentKey).innerHTML = input.content.get(contentKey);
		}
		newInput.onmouseover = function(e) onInputEvents(newInput.id, e.type);
		newInput.onclick = function(e) onInputEvents(newInput.id, e.type);
		newInput.onmousedown = function(e) onInputEvents(newInput.id, e.type);
		inputs.add(newInput);
	}


	private inline function createGroupGuide(groupe : Group) : Guide {

		var groupTemplate : { x : Float, y : Float, guide : GuideData } = groups.get(groupe.ref);


		var guide : Guide;

		switch (groupTemplate.guide) {

			case Line(d):

				guide = new Line(d);

			case Grid(d):

				guide = new Grid(d);

			case Curve(d):

				guide = new Curve(d);
		}

		// Set guide to place inputs
		guide.x = groupTemplate.x;
		guide.y = groupTemplate.y;

		return guide;
	}

	/*private function validate(value: String):Bool
	{
		var result: Bool = true;
		if(autoCorrect){
			for(child in target.children){
				var correction = cast(part, ActivityPart).validate(buttonsToInputs.get(target), value);
				result = correction;
				if(child.ref == validationRef && Std.is(child, grar.view.component.container.DefaultButton))
					cast(child, grar.view.component.container.DefaultButton).toggleState = Std.string(correction);
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
				var input: Input = buttonsToInputs.get(button);
				var correction = cast(part, ActivityPart).validate(input, Std.string(input.selected));
				for(child in button.children)
					if(child.ref == validationRef && Std.is(child, grar.view.component.container.DefaultButton))
						cast(child, grar.view.component.container.DefaultButton).toggleState = Std.string(correction);
			}
			validationButton.buttonAction = endActivity;
			validationButton.toggleState = "end";
			disableInputs();
		}
		var debriefRules = cast(part, ActivityPart).getRulesByType("debrief");
		for(rule in debriefRules){
			switch(rule.value.toLowerCase()){
				case "onvalidate": cast(displaysRefs.get(rule.id), grar.view.component.container.DefaultButton).toggle();
			}
		}

		return result;
	}*/

	/*private function endActivity():Void
	{
		if(!hasCorrection){
			for(button in inputs){
				cast(part, ActivityPart).validate(buttonsToInputs.get(button), Std.string(button.classList.contains("checked")));
				button.classList.remove("checked");
				button.classList.remove("locked");
			}
		}
		var idNext = cast(part, ActivityPart).endActivity();
		var restartRules: Array<Rule> = cast(part, ActivityPart).getRulesByType("restart");
		var i = 0;
		while(i < restartRules.length && restartRules[i].value != idNext)
			i++;
		if(i != restartRules.length)
			part.restart();


		if (idNext != null) {

			var target = part.getElementById(idNext);

			switch (target) {

				case Part(p):

					onPartDisplayRequest(p);

				default: throw "[ActivityPart] Thresholds must point to Part.";
			}
		}
		else
			exitPart();
	}

	private inline function disableInputs():Void
	{
		for(input in inputs){
			if(input.classList.contains("checked"))
				input.classList.add("locked");
		}
	}

	private inline function enableInputs():Void
	{
		for(input in inputs){
			input.classList.remove("locked");
		}
	}*/

	// Handler

	/*private inline function onValidate():Void
	{
		onValidate(Std.string(target.toggleState == "active"));
	}

	private inline function copyCoordinates(object: Element, source: Element):Void
	{
		var position = source.getBoundingClientRect();
		object.style.position = "absolute";
		object.style.left = Std.string(position.left)+"px";
		object.style.top = Std.string(position.top)+"px";
	}*/
}