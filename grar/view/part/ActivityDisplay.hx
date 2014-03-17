package grar.view.part;

import grar.view.component.Image;
import grar.view.component.Widget;
import grar.view.component.container.DefaultButton;
import grar.view.part.PartDisplay;
import grar.view.guide.Guide;
import grar.view.guide.Curve;
import grar.view.guide.Line;
import grar.view.guide.Grid;
import grar.view.Display;

import grar.model.part.Item;
import grar.model.part.ActivityPart;
import grar.model.part.Part;

import grar.util.ParseUtils;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import haxe.ds.StringMap;
import haxe.ds.GenericStack;

using Lambda;
using Std;
using grar.util.DisplayUtils;

typedef Coordinates = {

	var x : Float;
	var y : Float;
}

/**
 * Display of an activity
 */
class ActivityDisplay extends PartDisplay {

	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, 
							transitions : StringMap<TransitionTemplate>, model : Part) {

		super(callbacks, applicationTilesheet, transitions, model);

		autoCorrect = false;
		hasCorrection = true;
		groups = new StringMap();
		buttonsToInputs = new Map();
		inputs = new GenericStack<DefaultButton>();
		validatedInputs = new Map();
	}

	private static inline var dropRef: String = "dropZone";

	private var groups : StringMap<{ x : Float, y : Float, guide : GuideData }>;

	private var buttonsToInputs : Map<DefaultButton, Input>;
	private var autoCorrect : Bool;
	private var hasCorrection : Bool;
	private var inputs : GenericStack<DefaultButton>;
	private var validationRef : String;
	private var validatedInputs : Map<DefaultButton, Bool>;
	private var minSelect : Int;
	private var maxSelect : Int;
	private var validationButton : DefaultButton;
	private var dragOrigin : Coordinates;

	override public function nextElement(startIndex : Int = -1) : Void {

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

	override public function startPart(startPosition:Int = -1) : Void {

		//displayInputs();

		// Checking rules
		// Validation
		var validationRules = cast(part, ActivityPart).getRulesByType("correction");
		
		if (validationRules.length > 1) {

			throw "[ActivityDisplay] Multiple correction rules in activity '"+part.id+"'. Pick only one!";
		}
		if (validationRules.length == 1) {

			if (!displaysRefs.exists(validationRules[0].id)) {

				throw "[ActivityDisplay] You must have a button with ref '"+validationRules[0].id+"' (same as the id of your rule) in order to use the correction rule.";
			}
			validationButton = cast(displaysRefs.get(validationRules[0].id), grar.view.component.container.DefaultButton);
			
			switch (validationRules[0].value) {

				case "auto":

					autoCorrect = true;
				
				case "onvalidate":

					validationButton.buttonAction = onValidate;
				
				case "off":

					hasCorrection = false;
					validationButton.buttonAction = endActivity;
				
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
				validationButton.toggle(false);
			}
		}

		super.startPart(0);
	}

	//override public function parseContent(content:Xml):Void
	override public function setContent(d : DisplayData) : Void {

		super.setContent(d);

		switch (d.type) {

			case Activity(g):

				this.groups = g;

			default: throw "wrong DisplayData type passed to ActivityDisplay.setContent()";
		}
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

			var lastTemplate : Template = displayTemplates.get(inputs.first().ref);
			
			if (lastTemplate.validation != null) {

				validationRef = lastTemplate.validation;
			}
		}
	}

	private inline function createInput(input : Input, guide : Guide) : Void {

		if (!displayTemplates.exists(input.ref)) {

			throw "[ActivityDisplay] There is no template for input named "+input.ref+".";
		}
		var button : DefaultButton;

		switch (displayTemplates.get(input.ref).data) {

			case DefaultButton(d):

				button = new DefaultButton(callbacks, applicationTilesheet, transitions, d);

				guide.add(button);

				buttonsToInputs.set(button, input);

				for (contentKey in input.content.keys()) {

		//			button.setText(Localiser.instance.getItemContent(input.content.get(contentKey)), contentKey);
					button.setText(onLocalizedContentRequest(input.content.get(contentKey)), contentKey);

				}
				button.setAllListeners(onInputEvents);
// 				button.zz = displayTemplates.get(input.ref).z; // TODO check if still useful
				inputs.add(button);

			default : throw "unexpected ElementData type";
		}
	}


	private inline function createGroupGuide(groupe : Group) : Guide {

		var groupTemplate : { x : Float, y : Float, guide : GuideData } = groups.get(groupe.ref);


		var guide : Guide;

		switch (groupTemplate.guide) {

			case Line(d):

				guide = new Line(transitions, d);

			case Grid(d):

				guide = new Grid(transitions, d);

			case Curve(d):

				guide = new Curve(transitions, d);
		}

		// Set guide to place inputs
		guide.x = groupTemplate.x;
		guide.y = groupTemplate.y;

		return guide;
	}

	private function validate(?target: DefaultButton, value: String):Bool
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
	}

	private function endActivity(?target:DefaultButton):Void
	{
		if(!hasCorrection){
			for(button in inputs){
				cast(part, ActivityPart).validate(buttonsToInputs.get(button), Std.string(button.toggleState == "active"));
				button.resetToggle();
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

	override private function mustBeDisplayed(key:String):Bool
	{
		var object: Widget = displaysRefs.get(key);

		// Display all buttons/inputs
		if(Std.is(object, grar.view.component.container.DefaultButton)){
			if(part.buttons.exists(key)){
				setButtonText(key, part.buttons.get(key));
				return true;
			}
			else
				return false;
		}

		return super.mustBeDisplayed(key);
	}

	override private function displayPartElements() : Void {

		super.displayPartElements();

		for (input in inputs) {

			input.onComplete = onWidgetAdded;

			addChild(input);

			numWidgetAdded++;
		}
	}

	override private function cleanDisplay():Void
	{
	}

	private inline function disableInputs():Void
	{
		for(input in inputs){
			if(input.toggleState == "inactive")
				input.enabled = false;
		}
	}

	private inline function enableInputs():Void
	{
		for(input in inputs){
			input.enabled = true;
		}
	}

	// Handler
	private function onInputEvents(e: MouseEvent):Void
	{
		var needValidation = false;
		var input: Input = buttonsToInputs.get(e.target);
		var clickRules = cast(part, ActivityPart).getRulesByType(e.type, input.group);
		for(rule in clickRules){
			switch(rule.value.toLowerCase()){
				case "goto":
					var target = part.getElementById(buttonsToInputs.get(e.target).values[0]);

					switch (target) {

						case Part(p):

							onPartDisplayRequest(p);

						default: throw "target not a part"; // remove this throw if it happens normally
					}

					needValidation = true;

				case "toggle":
					e.target.toggle();
					var selected = buttonsToInputs.get(e.target).selected = e.target.toggleState == "active";
					validatedInputs.set(e.target, selected);
					needValidation = true;
				case "drag":
					e.target.startDrag();
					e.target.parent.setChildIndex(e.target, e.target.parent.numChildren-1);
					dragOrigin = {x: e.target.x, y: e.target.y};
				case "drop":
					e.target.stopDrag();
					var drop: DisplayObject = cast(e.target.dropTarget, DisplayObject);
					while(drop != null && !(drop.is(grar.view.component.container.DefaultButton) && (inputs.has(cast(drop, grar.view.component.container.DefaultButton)) || cast(drop, Widget).ref == dropRef)))
						drop = drop.parent;
					if(drop != null && validate(e.target, (buttonsToInputs.exists(cast(drop, grar.view.component.container.DefaultButton)) ? buttonsToInputs.get(cast(drop, grar.view.component.container.DefaultButton)).id : drop.name))){
						copyCoordinates(e.target, drop);
						if(buttonsToInputs.exists(cast(drop, grar.view.component.container.DefaultButton))){
							var dropZone = new DefaultButton(callbacks, applicationTilesheet, transitions);
							dropZone.enabled = false;
							dropZone.initSprite(drop.width, drop.height, 0.001);
							dropZone.ref = dropRef;
							dropZone.name = buttonsToInputs.get(cast(drop, grar.view.component.container.DefaultButton)).id;
							copyCoordinates(dropZone, drop);
							drop.parent.addChild(dropZone);
						}
					}
					else{
						copyCoordinates(e.target, dragOrigin);
					}
			}
		}
		if(needValidation && autoCorrect)
			validate(e.target, Std.string(e.target.toggleState == "active"));

		// Selection limits
		var validated = Lambda.count(validatedInputs, function(input){
			return input;
		});

		// Activate validation button
		if(validationButton != null)
			validationButton.toggle(validated >= minSelect);
		// Toggle inputs
		if(validated == maxSelect)
			disableInputs();
		else
			enableInputs();
	}

	private inline function onValidate(?target:DefaultButton):Void
	{
		validate(target, Std.string(target.toggleState == "active"));
	}

	private inline function copyCoordinates(object: DisplayObject, src: Dynamic):Void
	{
		object.x = src.x;
		object.y = src.y;
	}
}