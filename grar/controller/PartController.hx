package grar.controller;

import StringTools;

import grar.util.Point;

import grar.view.style.TextDownParser;
import grar.view.part.PartDisplay.InputEvent;
import grar.view.part.PartDisplay;
import grar.view.Application;

import grar.service.KalturaService;

import grar.model.part.Part;
import grar.model.part.PartElement;
import grar.model.part.Pattern;
import grar.model.part.item.Item;
import grar.model.part.PartElement;
import grar.model.part.ButtonData;
import grar.model.State;

import haxe.ds.GenericStack;

import grar.Controller;

using Lambda;

class PartController
{

	public function new(parent: Controller, state: State, app: Application)
	{
		this.parent = parent;
		this.state = state;
		this.application = app;

		init();
	}

	var parent:Controller;
	var state: State;
	var application: Application;
	var display: PartDisplay;

	// TODO put in state
	var part: Part;
	var previousBackground : String;
    var currentPattern:Pattern;

	///
	// CALLBACKS
	///

	public dynamic function onRestoreLocaleRequest() : Void {}

	public dynamic function onHeaderStateChangeRequest(state: String) : Void {}

	public dynamic function onPartFinished(part: Part, next:Bool):Void
	{}

	public dynamic function onLocaleDataPathRequest(uri: String, ?onSuccess: Void -> Void) : Void {}


	///
	// API
	//

	public function init():Void
	{
		display = application.partDisplay;

		// TODO Offer to change parser? (App params)
		display.markupParser = new TextDownParser();
	}

	/**
    * Display a graphic representation of the given part
    * @param    part : The part to display
    * @param    interrupt : Stop current part to display the new one
    * @return true if the part can be displayed.
    */
	public function displayPart(part : Part, ?next: Bool = true, ?noReload = false): Bool {
		this.part = part;

		// Reset activity state
		state.activityState = ActivityState.NONE;

		//startIndex = startPosition;
		display.onHeaderStateChangeRequest = function(state: String){
			onHeaderStateChangeRequest(state);
		}

		onLocaleDataPathRequest(part.file, function(){
			application.updateChapterInfos(state.module.getLocalizedContent("chapterName"), state.module.getLocalizedContent("activityName"));

			display.onPartLoaded = function(){
				// Activity Part
				if(part.activityData != null){
					state.activityState = ActivityState.QUESTION;
					display.onInputEvent = onInputEvent;
					startActivity(noReload);
				}
					// Standard Part
				else
					nextElement();
			}
			display.init(part.ref, next, noReload);
		});

		display.onExit = function() exitPart();
		//display.onEnterSubPart = function(sp : Part) enterSubPart(sp);

		return true;
	}

	public function unloadPart(partRef:String):Void
	{
		display.unloadPart(partRef);
	}

	public function startActivity(?resume: Bool = false):Void
	{
		display.onValidationRequest = function(inputId: String){
			validateInput(inputId);
		}

		// If resuming activity, don't do anything
		if(resume)
			return;

		// Clean previous inputs
		if(part.activityData.groupIndex > 0){
			var group = part.activityData.groups[part.activityData.groupIndex-1];
			if(group.ref != "")
				display.hideElements(Lambda.list([group.ref]));
			for (item in group.items) {
				unsetAuthor(item);
			}
			for(input in group.inputs)
				display.removeElement(input.id);
			for(debrief in part.getRulesByType("debrief", group))
				display.unsetDebrief(debrief.id);
		}

		var group: Inputs = part.getNextGroup();

		// End of the activity
		if(group == null){
			state.activityState = ActivityState.NONE;
			part.restart();
			exitPart();
			return;
		}

		// Show debrief zone (maybe?)
		var debriefRules = part.getRulesByType("debrief", group);
		for(zone in debriefRules)
			display.showDebriefZone(zone.id);

		// Print round number. Ex: 1/4
		display.setRoundNumber(part.activityData.groupIndex, part.activityData.groups.length);

		if(group.groups != null && group.groups.length != 0)
			for(g in group.groups)
				createInputs(g);
		else if (group != null)
			createInputs(group);

        for (item in group.items) {
           setupItem(item);
        }

		// Init part buttons
		for(b in part.buttons)
			initButtons(b);

		// Init validation buttons state
		verifySelectionLimits(group);

		for(img in part.images)
			display.setImage(img.ref,img.src);

		if(part.activityData != null){
			var rules = part.getRulesByType("minScore");
			if(rules.length > 0)
				display.disableNextButtons();
		}
	}

    private function createInputs(group:Inputs) {
        var inputList = Lambda.map(group.inputs, function(input: Input){
            var localizedContent = new Map<String, String>();
            for(key in input.content.keys())
                localizedContent[key] = getLocalizedContent(input.content[key]);

            return {ref: input.ref, id: input.id, content: localizedContent, icon: input.icon, selected: input.selected}
        });

	    // Set sorting rule
        var sort = part.getRulesByType("sort", group);
        if(sort.length == 1){
            switch(sort[0].value.toLowerCase()){
                case "random":
                    var randomList = new List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>, selected: Bool}>();
                    for(i in inputList){
                        var rand = Math.random();
                        if(rand < 0.5)
                            randomList.add(i);
                        else
                            randomList.push(i);
                    }
                    inputList = randomList;
            }
        }

	    // Set validation rule
	    var validationRules = part.getRulesByType("validation", group);
	    if(validationRules.length > 1)
		    throw "Multiple validation rules for group '"+group+"'. Please choose only one.";
	    var autoValidation: Bool = validationRules.length > 0 ? validationRules[0].value == "auto" : true;

        display.createInputs(inputList, group.ref, autoValidation);
    }

	public function onGameOver():Void
	{
		display.hideElementsByClass("next");
	}

	public function exitPart(?completed : Bool = true, ?fromMenu: Bool = false) : Void {

		part.isDone = completed;

		display.reset();

		if(completed)
			state.module.setPartFinished(part.id);
		else if(!fromMenu)
			onPartFinished(part, false);


		if (part.file != null)
			onRestoreLocaleRequest();
	}

	/**
	* @param    startIndex :   element after this index
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/
	public function nextElement(?startIndex : Int = -1) : Void {

		// Check conditions
		if(part.activityData != null){
			var rules = part.getRulesByType("minScore");
			if(rules.length > 0 && part.activityData.score < Std.parseInt(rules[0].value))
				return;
		}
        var currentElement = part.getNextElement(startIndex);

		if (currentElement == null) {
			exitPart();
			return;
		}

		switch (currentElement) {

			case Part(p):

				if (p.endScreen) {

					part.isDone = true;
					parent.gameOver();
				}
				//enterSubPart(p);
				displayPart(p);

			case Item(i):
				if (i.endScreen) {

					part.isDone = true;
					parent.gameOver();
				}
				setupItem(i);

			case Pattern(p):

				startPattern(p);

			case GroupItem(group):
				for(it in group.elements){
					setupItem(it);
				}
		}
	}

	public function previousElement():Void
	{
		var currentElement = part.getPreviousElement();

		if (currentElement == null) {
			exitPart(false);
			return;
		}
		switch (currentElement) {

			case Part(p):
				enterSubPart(p);

			case Item(i):
				setupItem(i);

			case Pattern(p):
				startPattern(p, false);
				// Doesn't matter if it's too high, index setter take care of that
				//p.itemIndex = p.patternContent.length;

			case GroupItem(group):
				for(it in group.elements){
					setupItem(it);
				}
		}
	}

	/**
	* Go to a specific pattern
	* @param    target : Name of the pattern to go
	**/
	public function goToPattern(target : String) : Void {

		var elem : Null<PartElement> = null;

		for (e in part.elements) {

			switch (e) {

				case Pattern(p):

					if (p.id == target) {

						elem = e;
						nextElement(part.getElementIndex(elem)-1);
						break;
					}

				default: // original code doesn't filter on PartElement type (apply this to all PartElements)
			}
		}
		if (elem == null) {

			throw "[PartDisplay] There is no pattern with ref \""+target+"\"";
		}
	}

	///
	// INTERNALS
	//

	private function enterSubPart(part:Part):Void
	{

	}

	private function onVideoComplete():Void
	{
		nextElement();
	}

	private function startPattern(p : Pattern, ? next: Bool = true):Void
	{
        display.showPattern(p.ref);

        var nextItem = next ? p.getNextItem() : p.getPreviousItem();
        if(nextItem != null){
	        setupItem(nextItem);
        }
        else{
            display.hidePattern(p.ref);
            nextElement();
        }

		for(b in part.buttons)
			initButtons(b);
	}

	private function setupItem(item : Item) : Void {

		// Activate tokens in the part
 		for (token in item.tokens)
		    state.module.activateInventoryToken(token);

		// Set part background
		if (item.background != null && previousBackground != item.background)
			display.showBackground(item.background);
		else if(item.background == null)
			display.hideBackground(previousBackground);

		for(b in item.button)
			initButtons(b);

		var introScreenOn = false;

		if(item.videoData != null) {
			if(parent.ks != null){
				var srv = new KalturaService();
				srv.getUrl(item.content, 400, parent.ks, function(url){
					var errCode = ~/code/;
					if(errCode.match(url))
						trace("Cannot retrieve video: "+url);
					else{
						var decodeUrl = StringTools.replace(url, "\\/", "/");
						display.setVideo(item.ref, decodeUrl, item.videoData, function(){trace("playing");}, function() onVideoComplete(), state.module.currentLocale);
					}
				});
			}
			else
				display.setVideo(item.ref, item.content, item.videoData, function(){}, function() onVideoComplete(), state.module.currentLocale);


		}
		else if(item.soundData != null){
			display.setSound(item.ref, item.content, item.soundData.autoStart, item.soundData.loop, item.soundData.defaultVolume);
		}
		else if (item.introScreen != null) {

			introScreenOn = true;
			setAuthor(item);
			display.setText(item.ref, getLocalizedContent(item.content));

			// TODO Sound
			//onSoundToLoad(item.sound);

			// The intro screen automatically removes itself after its duration
			var intro = item.introScreen;

			for (field in intro.content.keys())
				display.setIntroText(field, getLocalizedContent(intro.content.get(field)));

			display.onIntroEnd = function() displayPart(part);

		}
		else {
			setAuthor(item);
			display.setText(item.ref, getLocalizedContent(item.content));
		}

		for (image in item.images)
			display.setImage(image.ref,image.src);

		display.displayElements(createDisplayList(item));
	}

	private function setAuthor(item: Item):Void
	{
		if (item.author != null) {
				display.showSpeaker(item.author);
				// TODO Manage nameRef
				/*if (char.nameRef != null) {

					cast(displaysRefs.get(char.nameRef), grar.view.component.container.ScrollPanel).setContent(currentSpeaker.getName());

				} else if (char.nameRef != null) {

					throw "[PartDisplay] There is no TextArea with ref " + char.nameRef;
				}*/
		}
	}

	private function unsetAuthor(item: Item):Void
	{
		if(item.author != null)
			display.hideSpeaker(item.author);
	}

	private function getLocalizedContent(key: String):String {
		return state.module.getLocalizedContent(key);
	}

	private function createDisplayList(item: Item): List<String> {

		var list = new List<String>();

		for(b in item.button){
			list.add(b.ref);
			for(key in b.content.keys()){
				if(key == "_")
					display.setText(b.ref, b.content[key]);
				else
					display.setText(key, b.content[key]);
			}
		}

		return list;
	}

	private function initButtons(bd: ButtonData) : Void {

		var action = switch(bd.action.toLowerCase()) {
			case "next": function(){
				if(state.activityState == null || state.activityState == ActivityState.NONE)
					nextElement();
				else
					startActivity();
			};
			case "prev": function() previousElement();
			case "goto": function() {
						var goToTarget : PartElement = part.buttonTargets.get(bd.ref);
						if (goToTarget == null) {
							exitPart();
						} else {
							nextElement(part.getElementIndex(goToTarget) - 1);
						}
					};
			case "exit": function() exitPart(false);
			case "validate": function() {
				validateActivity();
			};
			default: function() trace("Unsupported action "+bd.action);
		}
		display.setButtonAction(bd.ref, bd.action, action);

		for(key in bd.content.keys()){
			if(key != "_")
				display.setText(key, state.module.getLocalizedContent(bd.content[key]));
			else
				display.setText(bd.ref, state.module.getLocalizedContent(bd.content[key]));
		}
	}

	private function validateActivity():Void
	{
		var valid = part.getRulesByType("validation");
		var validationRule: Rule = null;
		if(valid.length > 1)
			throw "too many validation rules";
		if(valid.length == 1)
			validationRule = valid[0];

		var group = part.activityData.groups[part.activityData.groupIndex-1];
		var debriefRules = part.getRulesByType("debrief", group);
		if(state.activityState == ActivityState.QUESTION){
			for(input in group.inputs)
				validateInput(input.id, validationRule);

			// Enabling or not progression
			var rules = part.getRulesByType("minScore");
			if(rules.length > 0 && part.activityData.score >= Std.parseInt(rules[0].value))
				display.enableNextButtons();

			// Debrief
			for(rule in debriefRules)
				display.setDebrief(rule.id, state.module.getLocalizedContent(group.id+"_"+rule.value));

			// Disabling further input
			part.activityData.inputsEnabled = false;

			state.activityState = ActivityState.DEBRIEF;
		}
		else{
			for(rule in debriefRules){
				display.unsetDebrief(rule.id);
			}
			state.activityState = ActivityState.QUESTION;
			startActivity();
		}
	}

	private function validateInput(inputId: String, ?validation: Rule, ?value: String):Void
	{
		// Correction
		if(validation == null){
			var result = part.validate(inputId, value);
			display.setInputState(inputId, result ? "true" : "false");
		}
		else
			switch(validation.value.toLowerCase()){
				case "showanswers":
					display.setInputState(inputId,part.getInput(inputId).values[0]);
					display.uncheckElement(inputId);
				default:
					var result = part.validate(inputId, value);
					display.setInputState(inputId, result ? "true" : "false");
			}

		// Scoring
		part.activityData.score += part.getInput(inputId).points;
	}

	private function onInputEvent(eventType: InputEvent, inputId: String, mousePoint: Point):Void
	{
		if(!part.activityData.inputsEnabled)
			return ;

		var targetId = null;
		var inputGroup = part.getInputGroup(inputId);
		// Input is not in this part. Discard event
		if(inputGroup == null)
			return;

		var rules = switch(eventType){
			case MOUSE_DOWN: part.getRulesByType(PartDisplay.MOUSE_DOWN, inputGroup);
			case MOUSE_UP(target): targetId = target;
				part.getRulesByType(PartDisplay.MOUSE_UP, inputGroup);

			case CLICK: part.getRulesByType(PartDisplay.CLICK, inputGroup);

            case MOUSE_OVER: part.getRulesByType(PartDisplay.MOUSE_OVER, inputGroup);

		}
		var input: Input = inputGroup.inputs.filter(function(i: Input)return i.id == inputId)[0];
		for(rule in rules){
			switch(rule.value.toLowerCase()){
				// TODO drag&drop dans la view
				case "drag": display.startDrag(inputId, mousePoint);
				case "drop":
					var drop: Input = part.getInput(targetId);
					// TODO validate with model
					var isValid = drop != null && (input.values.has(targetId) || drop.values.has(inputId));
					display.stopDrag(inputId, targetId, isValid, mousePoint);
					if(isValid){
						if(drop.additionalValues == null)
							drop.additionalValues = new Array();
						drop.additionalValues.push(inputId);
						var isFull = drop.values.foreach(function(id: String){
							return drop.additionalValues.has(id);
						});
						if(isFull)
							display.setInputComplete(targetId);
						part.activityData.numRightAnswers++;


						// Selection limits
						var maxSelect = -1;
						var rules = part.getRulesByType("selectionLimits", inputGroup);
						if(rules.length == 1)
							maxSelect = Std.parseInt(rules[0].value);
						else if(rules.length > 1 && rules[1].value != "*")
							maxSelect = Std.parseInt(rules[1].value);

						display.setText(drop.id+"_completion", part.activityData.numRightAnswers+"/"+maxSelect);
					}
				case "showmore":
					display.displayElements(inputId+"_more");
                case "showelement":
                    for (s in input.values)
                       display.toggleElement(s, true);
                case "setvisited" :
                    display.toggleElement(inputId, true);
	                input.selected = true;
                case "replacecontent" :
                    var output: Input = part.getInput(input.values[0]);
                    var loc = getLocalizedContent(input.content[input.values[0]]);
                    display.setText(output.id,loc);
					display.setInputState(output.id, "more");
                case "toggle" :
                    display.toggleElement(inputId);
	                input.selected = !input.selected;
				case "goto":
					var id: String;
					// Detect dynamic values
					var tokens: Array<String> = rule.id.split("$");
					if(tokens.length == 1)
						id = rule.id;
					else if(tokens[1].toLowerCase() == "id"){
						id = tokens[0]+inputId;
					}
					else
						throw "Unsupported dynamic value '"+tokens[1]+"'.";

					displayPart(state.module.getPartById(id));
			}
		}

		verifySelectionLimits(inputGroup);
	}

	private function verifySelectionLimits(group: Inputs):Void
	{
		// Selection limits
		var maxSelect = -1;
		var minSelect = -1;

		var selectionRules = part.getRulesByType("selectionLimits", group);
		if(selectionRules.length > 1)
			throw 'Too many selection rules. Please choose one';
		else if(selectionRules.length == 0)
			return;

		var rules = selectionRules[0].value.split(" ");
		if(rules.length == 1){
			minSelect = Std.parseInt(rules[0]);
			maxSelect = Std.parseInt(rules[0]);
		}
		else if(rules.length > 1 && rules[1] != "*"){
			minSelect = Std.parseInt(rules[0]);
			maxSelect = Std.parseInt(rules[1]);
		}

		var numSelected = group.inputs.count(function(input: Input) return input.selected);

		if(maxSelect == numSelected){
			part.activityData.score = 1;
			part.activityData.inputsEnabled = false;
		}

		// Disable/Enable validation with minSelect
		display.toggleValidationButtons(minSelect > numSelected);

	}
}