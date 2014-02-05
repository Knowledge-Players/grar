package com.knowledgeplayers.grar.display.part;

import List;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.Image;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import com.knowledgeplayers.grar.factory.GuideFactory;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.structure.part.Item;
import haxe.ds.GenericStack;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.util.guide.Guide;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.structure.part.ActivityPart;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.display.part.PartDisplay;

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
	private var inputs: GenericStack<DefaultButton>;
	private var validationRef: String;
	private var validatedInputs: Map<DefaultButton, Bool>;
	private var minSelect: Int;
	private var maxSelect: Int;
	private var validationButton: DefaultButton;
	private var dragOrigin:Coordinates;
    private var dropped:Map<String,List<DefaultButton>>;

	public function new(model: Part)
	{
		super(model);
		autoCorrect = false;
		hasCorrection = true;
		groups = new Map<String, Fast>();
		buttonsToInputs = new Map<DefaultButton, Input>();
		inputs = new GenericStack<DefaultButton>();
		validatedInputs = new Map<DefaultButton, Bool>();
        dropped = new Map<String,List<DefaultButton>>();
	}

	override public function nextElement(startIndex:Int = -1):Void
	{
		// If startIndex == 0, it's called from startPart, no verification needed
		if(startIndex == 0 || cast(part, ActivityPart).hasNextGroup()){
			for(elem in part.elements){
				if(elem.isText()){
					setupItem(cast(elem, Item));
				}
			}
			displayInputs();
			displayPart();
		}
		else
			exitPart();
	}

	override public function startPart(startPosition:Int = -1):Void
	{
		//displayInputs();

		// Checking rules
		// Validation
		var validationRules = cast(part, ActivityPart).getRulesByType("correction");
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
		var activity = cast(part, ActivityPart);

		var currentGroup: Group = activity.getNextGroup();
		// Create inputs, place & display them
		if(currentGroup.inputs != null){
			var guide = createGroupGuide(currentGroup);
			for(input in currentGroup.inputs){
				createInput(input, guide);
			}
		}
		if(currentGroup.groups != null){
			for(group in currentGroup.groups){
				var guide = createGroupGuide(group);
				// Specify inputs because of an "Can't iterate on a Dynamic value" error
				var inputs: Array<Input> = group.inputs;
				for(input in inputs)
					createInput(input, guide);
			}
		}
		if(!inputs.isEmpty()){
			var lastTemplate: Fast = displayTemplates.get(inputs.first().ref).fast;
			if(lastTemplate.has.validation)
				validationRef = displayTemplates.get(inputs.first().ref).fast.att.validation;
		}
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
		button.zz = displayTemplates.get(input.ref).z;
		inputs.add(button);
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
			validationButton.buttonAction = endActivity;
			validationButton.toggleState = "end";
			disableInputs();
		}
		var debriefRules = cast(part, ActivityPart).getRulesByType("debrief");
		for(rule in debriefRules){
			switch(rule.value.toLowerCase()){
				case "onvalidate": cast(displays.get(rule.id), DefaultButton).toggle();
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
		}
		else
			exitPart();
	}

	override private function mustBeDisplayed(key:String):Bool
	{
		var object: Widget = displays.get(key);

		// Display all buttons/inputs
		if(Std.is(object, DefaultButton)){
			if(part.buttons.exists(key)){
				setButtonText(key, part.buttons.get(key));
				return true;
			}
			else
				return false;
		}

		return super.mustBeDisplayed(key);
	}

	override private function selectElements():Array<Widget>
	{
		var array = super.selectElements();
		for(input in inputs)
			array.push(input);
		return array;
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
					if(target.isPart())
						GameManager.instance.displayPart(cast(target, Part));
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

					while(drop != null && !(drop.is(DefaultButton) && (inputs.has(cast(drop, DefaultButton)) || cast(drop, Widget).ref == dropRef)))
						drop = drop.parent;

					if(drop != null && validate(e.target, (buttonsToInputs.exists(cast(drop, DefaultButton)) ? buttonsToInputs.get(cast(drop, DefaultButton)).id : drop.name))){
						copyCoordinates(e.target, cast(drop, DefaultButton));
                        cast(e.target,DefaultButton).toggle();



                        var folder:Input = null;
                        if(buttonsToInputs.exists(cast(drop, DefaultButton)))
                            folder = buttonsToInputs.get(cast(drop, DefaultButton));
                        else{
                            for(input in buttonsToInputs){
                                if(input.id == drop.name){
                                    folder =input;
                                }
                            }
                        }
                        if(!dropped.exists(folder.id))
                            dropped.set(folder.id,new List<DefaultButton>());
                        var listDrag:List<DefaultButton> = dropped.get(folder.id);
                        listDrag.add(e.target);

                        var bool:Bool = true;
                        var goodInputs:List<DefaultButton> = new List<DefaultButton>();
                        trace('listdrag : '+listDrag);

                        for(val in folder.values){

                             for(drag in buttonsToInputs.keys()){
                                if(buttonsToInputs.get(drag).id == val){
                                    goodInputs.add(drag);

                                }
                             }


                        }
                        for (input in goodInputs){
                            if(!listDrag.has(input)){
                                bool =false;

                            }else{

                            }
                        }
                        trace('boobool : '+bool);
                        if(bool){
                            for(drag in buttonsToInputs.keys()){
                                if(buttonsToInputs.get(drag).id == folder.id){

                                    drag.toggleState='true';
                                }
                            }

                        }
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

typedef Coordinates = {
	var x: Float;
	var y: Float;
}