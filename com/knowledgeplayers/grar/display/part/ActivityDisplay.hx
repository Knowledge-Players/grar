package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import com.knowledgeplayers.grar.factory.GuideFactory;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.structure.part.Item;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.util.guide.Guide;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.structure.part.ActivityPart;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.structure.part.Button;

using Lambda;
using Std;
using com.knowledgeplayers.grar.util.DisplayUtils;

/**
 * Display of an activity
 */
class ActivityDisplay extends PartDisplay {

	private static inline var dropRef: String = "dropZone";

	private var groups: Map<String, Fast>;
	private var buttonsToInputs: Map<DefaultButton, Input>;
	private var autoCorrect: Bool;
	private var hasCorrection: Bool;
	private var inputs: List<DefaultButton>;
	private var validationRef: String;
	// Maybe remove this one. Not very useful
	private var validatedInputs: Map<DefaultButton, Bool>;
	private var minSelect: Int;
	private var maxSelect: Int;
	private var validationButton: DefaultButton;
	private var debriefZone: DefaultButton;
	private var dragOrigin:Coordinates;
	private var currentGroup:Group;
    private var dropped:Map<String,List<DefaultButton>>;
    private var zButton:Int;
    private var goodReps:Int;
    private var nbDrops:Int;

	private var savedData:String;
	private var roundIndex:Int;

	public function new(model: Part)
	{
		super(model);
		autoCorrect = false;
		hasCorrection = true;
		groups = new Map<String, Fast>();
		buttonsToInputs = new Map<DefaultButton, Input>();
		inputs = new List<DefaultButton>();
        dropped = new Map<String,List<DefaultButton>>();
        zButton = 1;
        goodReps = 0;
        nbDrops = 0;
		roundIndex = -1;
		savedData = GameManager.instance.game.stateInfos.getActivityData(part.id);
	}

	override public function nextElement(startIndex:Int = -1):Void
	{
		if(validatedInputs != null){
			var selection = new List<Int>();
			for(input in validatedInputs.keys())
				if(validatedInputs.get(input))
					selection.add(inputs.indexOf(input));
			GameManager.instance.game.stateInfos.storeActivityData(part.id, selection.toString());
		}
		// If startIndex == 0, it's called from startPart, no verification needed
		if(startIndex == 0 || cast(part, ActivityPart).hasNextGroup()){
			for(elem in part.elements){
				if(elem.isText()){
					setupItem(cast(elem, Item));
				}
			}
			displayInputs();
		}
		else
			endActivity();
	}

	override public function startPart(startPosition:Int = -1):Void
	{

		super.startPart(0);
	}

	override public function parseContent(content:Xml):Void
	{
		super.parseContent(content);
		for(group in displayFast.nodes.Group){
			groups.set(group.att.ref, group);
		}
	}

	// Private

	private function displayInputs():Void
	{
		roundIndex++;
		var activity = cast(part, ActivityPart);
		var needDisplay = true;

		// Reset group and inputs
		if(debriefZone != null && currentGroup.buttons.exists(function(button: Button){return button.ref == debriefZone.ref;}))
			debriefZone.toggle();
		validatedInputs = new Map<DefaultButton, Bool>();

		currentGroup = activity.getNextGroup();
		inputs = new List<DefaultButton>();
		// Create inputs, place & display them
		if(currentGroup.inputs != null){
			var guide = createGroupGuide(currentGroup);
			for(input in currentGroup.inputs){
				createInput(input, guide);
			}
		}

		for(group in currentGroup.groups){
			var guide = createGroupGuide(group);
			// Specify inputs because of an "Can't iterate on a Dynamic value" error
			var inputs: Array<Input> = group.inputs;

			if(currentGroup.id=='dossier')
				nbDrops = inputs.length;

			for(input in inputs)
				createInput(input, guide);
		}
		var first = true;
		for(item in currentGroup.items){

			setupItem(item, first);
			first = false;
			needDisplay = false;
		}
		if(!inputs.isEmpty()){
			var lastTemplate: Fast = displayTemplates.get(inputs.first().ref).fast;
			if(lastTemplate.has.validation)
				validationRef = displayTemplates.get(inputs.first().ref).fast.att.validation;
		}

		// Checking rules
		var validationRules = cast(part, ActivityPart).getRulesByType("correction", currentGroup);
		if(validationRules.length > 1)
			throw "[ActivityDisplay] Multiple correction rules in activity '"+part.id+"'. Pick only one!";
		if(validationRules.length == 1){
			if(!displays.exists(validationRules[0].id))
				throw "[ActivityDisplay] You must have a button with ref '"+validationRules[0].id+"' (same as the id of your rule) in order to use the correction rule.";
			validationButton = cast(displays.get(validationRules[0].id), DefaultButton);
			switch(validationRules[0].value){
				case "auto": autoCorrect = true;
				case "onvalidate":
					validationButton.buttonAction = onValidate;
				case "off": hasCorrection = false;
					validationButton.buttonAction = function(?target: DefaultButton){
						nextElement();
					};
				default: trace("Unknown value '"+validationRules[0].value+"' as a validation rule");
			}
		}
		// Selection limits
		var selectLimits = cast(part, ActivityPart).getRulesByType("selectionlimits", currentGroup);
		if(selectLimits.length > 1)
			throw "[ActivityDisplay] Multiple selection limits rules in activity '"+part.id+"'. Pick only one!";
		if(selectLimits.length == 1){
			var limits = ParseUtils.parseStringArray(selectLimits[0].value);
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

		// Apply saved data
		if(savedData != null){
			var list = ParseUtils.parseIntList(savedData.split("-")[roundIndex]);
			var i = 0;
			for(input in inputs){
				if(list.has(i)){
					buttonsToInputs.get(input).selected = !buttonsToInputs.get(input).selected;
					toggleInput(input);
				}
				i++;
			}
		}

		if(needDisplay)
			displayPart();
	}

	override private function onVideoComplete(e:Event):Void
	{
		nextElement();
	}

	private inline function createInput(input:Input, guide: Guide):Void
	{
		if(!displayTemplates.exists(input.ref))
			throw "[ActivityDisplay] There is no template for input named "+input.ref+".";
		var button:DefaultButton = new DefaultButton(displayTemplates.get(input.ref).fast);
		guide.add(button);
		buttonsToInputs.set(button, input);
		for(contentKey in input.content.keys())
			button.setText(Localiser.instance.getItemContent(input.content.get(contentKey)), contentKey);
		button.setAllListeners(onInputEvents);
		button.zz = displayTemplates.get(input.ref).z + zButton;
        zButton++;
		inputs.add(button);
		if(input.selected)
			toggleInput(button);
	}

	private inline function createGroupGuide(groupe: Group):Guide
	{
		var groupTemplate: Fast = groups.get(groupe.ref);
		// Set guide to place inputs
		var guide: Guide = GuideFactory.createGuideFromXml(new Fast(groupTemplate.x.firstElement()));
		guide.x = Std.parseFloat(groupTemplate.att.x);
		guide.y = Std.parseFloat(groupTemplate.att.y);

		return guide;
	}

	private function validate(?target: DefaultButton, value: String):Bool
	{
		var result: Bool = true;
		if(autoCorrect){
			for(child in target.children){
				var correction = cast(part, ActivityPart).validate(buttonsToInputs.get(target), value);
				result = correction;
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
				var input: Input = buttonsToInputs.get(button);
				var correction = cast(part, ActivityPart).validate(input, Std.string(input.selected));
				for(child in button.children)
					if(child.ref == validationRef && Std.is(child, DefaultButton))
						cast(child, DefaultButton).toggleState = Std.string(correction);
			}
			validationButton.buttonAction = function(?target: DefaultButton){nextElement();};
			validationButton.toggleState = "end";
			disableInputs(true);
		}
		var debriefRules = cast(part, ActivityPart).getRulesByType("debrief");
		for(rule in debriefRules){
			switch(rule.value.toLowerCase()){
				case "onvalidate":
					debriefZone = cast displays.get(rule.id);
					if(currentGroup.buttons.exists(function(button: Button){return button.ref == debriefZone.ref;}))
						debriefZone.toggle();
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

		if(idNext != null){
			var target = part.getElementById(idNext);
			if(target.isPart())
				GameManager.instance.displayPart(cast(target, Part));
			else
				throw "[ActivityPart] Thresholds must point to Part.";
			unLoad();
		}
		else
			exitPart();
	}

	override private function mustBeDisplayed(key:String):Bool
	{
		var object: Widget = displays.get(key);

		// Display all buttons/inputs
		if(Std.is(object, DefaultButton)){
			if(inputs.has(cast object)){
				return true;
			}
			else if(part.buttons.exists(key)){
				setButtonText(key, part.buttons.get(key));
				return true;
			}
			else if(currentGroup.buttons.exists(function(button: Button){return button.ref == key;})){
				setButtonText(key, Lambda.filter(currentGroup.buttons, function(button: Button){return button.ref == key;}).first().content);
				return true;
			}
			else
				return false;
		}

		// Display global images
		if(cast(part, ActivityPart).globalImages.has(key))
			return true;

		return super.mustBeDisplayed(key);
	}

	override private function selectElements():Array<Widget>
	{
		var array = super.selectElements();
		for(input in inputs)
			array.push(input);
		return array;
	}

	private inline function disableInputs(all: Bool = false):Void
	{
		for(input in inputs){
			if(all || input.toggleState == "inactive")
				input.enabled = false;
		}
	}

	private inline function enableInputs():Void
	{
		for(input in inputs){
			input.enabled = true;
		}
	}

	private function toggleInput(input:DefaultButton):Void
	{
		input.toggle();
		var selected: Bool = buttonsToInputs.get(input).selected;
		validatedInputs.set(input, selected);
		if(autoCorrect)
			validate(input, Std.string(selected));
		updateValidationButton();
	}

	// Handler
	private function onInputEvents(e: MouseEvent):Void
	{
		var needValidation = false;
		var updateButton = false;
		var goNext = false;
		var input: Input = buttonsToInputs.get(e.target);
		var clickRules = cast(part, ActivityPart).getRulesByType(e.type, input.group);
		for(rule in clickRules){
			switch(rule.value.toLowerCase()){
				case "goto":
					var target = part.getElementById(buttonsToInputs.get(e.target).values[0]);
					if(target.isPart())
						GameManager.instance.displayPart(cast(target, Part));
					needValidation = true;
					updateButton = true;
				case "toggle":
					buttonsToInputs.get(e.currentTarget).selected = !buttonsToInputs.get(e.currentTarget).selected;
					toggleInput(e.currentTarget);
				case "drag":
					e.target.startDrag();
					e.target.parent.setChildIndex(e.target, e.target.parent.numChildren-1);
					dragOrigin = {x: e.target.x, y: e.target.y};
				case "drop":
					e.target.stopDrag();
					var drop: DisplayObject = cast(e.target.dropTarget, DisplayObject);

					while(drop != null && !(drop.is(DefaultButton) && (inputs.has(cast(drop, DefaultButton)) || cast(drop, Widget).ref == dropRef)))
						drop = drop.parent;

					if(drop != null && validate(e.target, (buttonsToInputs.exists(cast(drop, DefaultButton)) ? buttonsToInputs.get(cast(drop, DefaultButton)).id : drop.name))){
						copyCoordinates(e.target, cast(drop, DefaultButton));

                        cast(e.target,DefaultButton).toggle();
                        cast(drop, DefaultButton).toggleState = 'uncomplete';
                        var folder:Input = null;
                        if(buttonsToInputs.exists(cast(drop, DefaultButton)))
                            folder = buttonsToInputs.get(cast(drop, DefaultButton));
                        else
                            for(input in buttonsToInputs)
                                if(input.id == drop.name)
                                    folder = input;

                        if(!dropped.exists(folder.id))
                            dropped.set(folder.id,new List<DefaultButton>());
                        var listDrag:List<DefaultButton> = dropped.get(folder.id);
                        listDrag.add(e.target);

                        var bool:Bool = true;
                        var goodInputs:List<DefaultButton> = new List<DefaultButton>();
                        for(val in folder.values)
                             for(drag in buttonsToInputs.keys())
                                if(buttonsToInputs.get(drag).id == val)
                                    goodInputs.add(drag);

                        for (input in goodInputs)
                            if(!listDrag.has(input))
                                bool = false;

                        if(bool)
                            for(drag in buttonsToInputs.keys())
                                if(buttonsToInputs.get(drag).id == folder.id)
                                    drag.toggleState='true';

                        if(bool){
                            for(drag in buttonsToInputs.keys()){

                                if(buttonsToInputs.get(drag).id == folder.id){

                                    drag.toggleState='complete';
                                    goodReps ++;
                                }
                            }

                        }

                        if(goodReps==nbDrops){
                            cast(displays.get('button_continue_folder'), DefaultButton).toggleState ='continue';
                        };
						if(buttonsToInputs.exists(cast(drop, DefaultButton))){
							var dropZone = new DefaultButton();
							dropZone.enabled = false;
							dropZone.initSprite(drop.width, drop.height, 0.001);
							dropZone.ref = dropRef;
							dropZone.name = buttonsToInputs.get(cast(drop, DefaultButton)).id;
							copyCoordinates(dropZone, drop);
							drop.parent.addChild(dropZone);
						}
					}
					else{
						copyCoordinates(e.target, dragOrigin);
                        cast(e.target,DefaultButton).toggleState='false';

					}
					updateButton = true;
				case "next":
					needValidation = true;
					updateButton = true;
					goNext = true;
			}
		}
		if(needValidation && autoCorrect)
			validate(e.target, Std.string(e.target.toggleState == "active"));

		// Insert this into cases (like toggleInput)
		if(updateButton)
			updateValidationButton();

		if(goNext)
			nextElement();
	}

	private function updateValidationButton():Void
	{
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

typedef Coordinates = {
	var x: Float;
	var y: Float;
}