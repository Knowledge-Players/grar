package grar.controller;

import grar.model.Config;
import grar.util.TextDownParser;

import grar.view.part.PartDisplay;
import grar.view.Application;

import grar.service.KalturaService;

import grar.model.part.Part;
import grar.model.part.PartElement;
import grar.model.part.PartElement;
import grar.model.part.ButtonData;
import grar.model.part.item.Item;
import grar.model.part.item.Pattern;
import grar.model.State;

import grar.Controller;

using Lambda;
using StringTools;

typedef InputCallback = {
	@:optional var click: String -> Void;
	@:optional var mouseDown: String -> Void;
	@:optional var mouseUp: String -> Void;
	@:optional var mouseOver: String -> Void;
	@:optional var mouseOut: String -> Void;
}

class PartController
{

	public function new(parent: Controller, state: State, config: Config, app: Application)
	{
		this.parent = parent;
		this.state = state;
		this.config = config;
		this.application = app;

		init();
	}

	var parent:Controller;
	var state: State;
	var application: Application;
	var display: PartDisplay;
	var config: Config;

	var part: Part;

	///
	// CALLBACKS
	///

	public dynamic function onRestoreLocaleRequest() : Void {}

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
    * @param    forward : Whether the part are progressing forward or backward. Default is true
    * @param    noReload: Don't reload the display on init. Default is false
    * @return true if the part can be displayed.
    */
	public function displayPart(part : Part, ?forward: Bool = true, ?noReload = false): Bool {
		this.part = part;

		// Reset activity state
		state.activityState = ActivityState.NONE;

		onLocaleDataPathRequest(part.file, function(){
			application.updateChapterInfos(getLocalizedContent("chapterName"), getLocalizedContent("activityName"));

			application.onPartLoaded = function(){
				// Activity Part
				if(part.activityData != null){
					state.activityState = ActivityState.QUESTION;
					startActivity(noReload);
				}
				// Standard Part
				else
					nextElement();
			}

			// Check if a HTML template is needed
			if(part.ref.indexOf("#") != -1){
				var ids = part.ref.split("#");
				application.initPart(ids[1], ids[0], forward, noReload);
			}
			else
				application.initPart(part.ref, forward, noReload);
		});

		return true;
	}

	public function unloadPart(partRef:String):Void
	{
		display.unloadPart(partRef);
	}

	public function startActivity(?resume: Bool = false):Void
	{
		display.onValidationRequest = function(inputId: String, ?value: String, ?dragging: Bool = false){
			if(value != null){
				var inputs: Inputs = part.getInputGroup(value);
				if(inputs == part.getInputGroup(inputId) && dragging){
					display.stopDrag(inputId, value, false);
					return;
				}
			}

			var isValid = validateInput(inputId, value);
			if(dragging){
				if(isValid){
					var drop: Input = part.getInput(value);
					if(drop.additionalValues == null)
						drop.additionalValues = new Array();
					drop.additionalValues.push(inputId);
					var isFull = drop.values.foreach(function(id: String){
						return drop.additionalValues.has(id);
					});
					if(isFull){
						validateActivity();
						display.setInputComplete(value);
					}
					part.activityData.numRightAnswers++;
					part.activityData.score++;

					// Selection limits
					var maxSelect = -1;
					var rules = part.getRulesByType("selectionLimits", part.getInputGroup(inputId));
					if(rules.length == 1)
						maxSelect = Std.parseInt(rules[0].value);
					else if(rules.length > 1 && rules[1].value != "*")
						maxSelect = Std.parseInt(rules[1].value);

					display.setText(drop.id+"_completion", part.activityData.numRightAnswers+"/"+maxSelect);

					var rules = part.getRulesByType("minScore");
					if(rules.length > 0 && part.activityData.score >= Std.parseInt(rules[0].value))
						display.enableNextButtons();
				}
				display.stopDrag(inputId, value, isValid);
			}
		}

		// If resuming activity, just show inputs
		if(resume){
			display.displayElements(Lambda.map(part.activityData.groups, function(group: Inputs) return group.ref));
			return;
		}

		// Clean previous inputs
		if(part.activityData.groupIndex > 0){
			var group = part.activityData.groups[part.activityData.groupIndex-1];
			if(group.ref != "")
				display.hideElements(group.ref);
			for (item in group.items) {
				unsetAuthor(item.author);
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
			nextElement();
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
			else{
				var rules = part.getRulesByType("minVisited");
				if(rules.length > 0)
					display.disableNextButtons();
			}
		}
	}

	public function onGameOver():Void
	{
		display.hideElementsByClass("next");
	}

	public function exitPart(?completed : Bool = true, ?fromMenu: Bool = false) : Void {

		part.isDone = completed;

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
				displayPart(p);

			case Item(i):
				setupItem(i);
				if (i.endScreen) {
					part.isDone = true;
					parent.gameOver();
				}

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
				displayPart(p);

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

		// Tear down current element
		switch (part.currentElement) {
			case Part(p):// TODO
			case Item(i):
				teardownItem(i);
			case Pattern(p):
				endPattern(p);

			case GroupItem(group):
				for(it in group.elements)
					teardownItem(it);
		}

		var elem : Null<PartElement> = null;
		for (e in part.elements) {
			switch (e) {
				case Pattern(p):
					if (p.id == target) {
						elem = e;
						nextElement(part.getElementIndex(elem)-1);
						break;
					}
				default: //nothing
			}
		}
		if (elem == null)
			throw "[PartDisplay] There is no pattern with ref \""+target+"\"";
	}

	public function onMasterVolumeChanged():Void
	{
		display.onMasterVolumeChanged(application.masterVolume);
	}

	///
	// INTERNALS
	//

	private function onVideoComplete():Void
	{
		if(application.isFullscreen)
			application.exitFullscreen();
		if(part.hasNextElement())
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
	        if(p.nextPattern != null)
	            goToPattern(p.nextPattern);
	        else{
		        endPattern(p);
		        nextElement();
	        }
        }

		for(b in part.buttons)
			initButtons(b);

		// Choices
		if(p.choicesData != null){
			var choicesList = Lambda.map(p.choicesData.choices, function(choice: Choice){
				var localizedContent = new Map<String, String>();
				for(key in choice.content.keys())
					localizedContent[key] = getLocalizedContent(choice.content[key]);

				return {ref: choice.ref, content: localizedContent, id: choice.id, icon: choice.icon, selected: choice.viewed, goto: choice.goTo};
			});
			display.createChoices(choicesList, p.choicesData.ref);
			display.onChangePatternRequest = function(patternId: String) goToPattern(patternId);
		}

		// Update counter if any
		if(p.counterRef != null){
			display.setText(p.counterRef, (p.patternContent.indexOf(p.currentItem)+1)+"/"+p.patternContent.length);
		}
	}

	private function endPattern(pattern:Pattern):Void
	{
		if(pattern.choicesData != null)
			for(choice in pattern.choicesData.choices)
				display.removeElement(choice.id);
		teardownItem(pattern.currentItem);
		display.hidePattern(pattern.ref);
		pattern.restart();
	}

	private function setupItem(item : Item) : Void {

		// Activate tokens in the part
 		for (token in item.tokens)
		    state.module.activateInventoryToken(token);

		// Set part background
		if (item.background != null)
			display.showBackground(item.background);

		for(b in item.button)
			initButtons(b);

		var introScreenOn = false;

		if(item.videoData != null) {
			if(parent.ks != null){
				var srv = new KalturaService();
				srv.getUrl(item.content, config.bitrate, parent.ks, function(url){
					var errCode = ~/code/;
					if(errCode.match(url))
						trace("Cannot retrieve video: "+url);
					else{
						var decodeUrl = url.replace("\\/", "/");
						display.setVideo(item.ref, decodeUrl, item.videoData, function(){}, function() onVideoComplete(), state.module.currentLocale);
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
			setAuthor(item.author);
			display.setText(item.ref, getLocalizedContent(item.content));

			// The intro screen automatically removes itself after its duration
			var intro = item.introScreen;

			for (field in intro.content.keys())
				display.setIntroText(field, getLocalizedContent(intro.content.get(field)));

			display.onIntroEnd = function() displayPart(part);

		}
		else {
			setAuthor(item.author);
			if(item.content != "")
				display.setText(item.ref, getLocalizedContent(item.content));
			else
				display.setText(item.ref, " ");
			display.hideVideoPlayer();
		}

		// Voice over
		if(item.voiceOverUrl != null){
			setVoiceOver(item.voiceOverUrl, item.ref);
		}

		for (image in item.images)
			display.setImage(image.ref,image.src);

		display.displayElements(createDisplayList(item));
	}

	private function teardownItem(item : Item):Void
	{
		// Unset part background
		if (item.background != null)
			display.hideBackground(item.background);

		if(item.videoData != null)
			display.hideVideoPlayer();
		else if(item.soundData != null){
			// TODO Stop sound
		}
		else {
			unsetAuthor(item.author);
			display.hideText(item.ref);
			display.hideVideoPlayer();
		}

		// Voice over
		if(item.voiceOverUrl != null)
			display.stopVoiceOver();

		for (image in item.images)
			display.unsetImage(image.ref);

		display.hideElements(createDisplayList(item));
	}

	private function setAuthor(author: String):Void
	{
		if (author != null) {
			display.showSpeaker(author);
			display.setSpeakerLabel(getLocalizedContent(author));
		}
	}

	private function unsetAuthor(author: String):Void
	{
		if(author != null)
			display.hideSpeaker(author);
	}

	private inline function getLocalizedContent(key: String):String {
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
				if(state.activityState != null && state.activityState != ActivityState.NONE)
					startActivity();
				else{
					// Tear down current element
					switch (part.currentElement) {
						case Part(p):// TODO
						case Item(i):
							teardownItem(i);
						case Pattern(p): display.stopVoiceOver();// Just stop voice over. Tear down handled by endPattern()
						case GroupItem(group):
							for(it in group.elements)
								teardownItem(it);
					}
					nextElement();
				}
			};
			case "prev": function(){
				display.stopVoiceOver();
				previousElement();
			};
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
				display.setText(key, getLocalizedContent(bd.content[key]));
			else
				display.setText(bd.ref, getLocalizedContent(bd.content[key]));
		}
	}

	private function validateActivity():Void
	{
		// No activity, ignore call
		if(state.activityState == ActivityState.NONE)
			return;

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

			// Debrief
			var lastId = null;
			var lastValue = null;
			var isTrue = false;
			for(rule in debriefRules){
				var intValue = Std.parseInt(rule.value);
				if(intValue == null){
					lastValue = rule.value;
					lastId = rule.id;
				}
				else if(part.getScore() >= intValue){
					lastValue = rule.id;
					isTrue = true;
				}
			}

			display.setDebrief(lastId, getLocalizedContent(group.id+"_"+lastValue));
			if(lastId != null)
				display.setInputState(lastId, Std.string(isTrue));

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

	private function validateInput(inputId: String, ?validation: Rule, ?value: String):Bool
	{
		// No activity, ignore call
		if(state.activityState == ActivityState.NONE)
			return false;

		// Correction
		var result = true;
		if(validation == null){
			result = part.validate(inputId, value);
			display.setInputState(inputId, result ? "true" : "false");
		}
		else
			switch(validation.value.toLowerCase()){
				case "showanswers":
					display.setInputState(inputId,part.getInput(inputId).values[0]);
					display.uncheckElement(inputId);
				default:
					result = part.validate(inputId, value);
					display.setInputState(inputId, result ? "true" : "false");
			}

		return result;
	}

    private function setInputSelected(input: Input,selected:Bool):Void{

        if(input.selected == selected) return;

        display.toggleElement(input.id,selected);

	    if(!input.selected)
		    input.visited = true;

        input.selected = selected;

	    var rules = part.getRulesByType("minVisited");
	    var inputs = part.getInputGroup(input.id).inputs;
	    if(rules.length > 0 && inputs.count(function(input: Input) return input.visited) >= Std.parseInt(rules[0].value))
		    display.enableNextButtons();

	    // TODO Don't use score variable; replace by numVisited?
        if(input.selected)
            part.activityData.score += input.points;
        else
            part.activityData.score -= input.points;

        var rules = part.getRulesByType("minScore");
        if(rules.length > 0 && part.activityData.score >= Std.parseInt(rules[0].value))
            display.enableNextButtons();

	    verifySelectionLimits(part.getInputGroup(input.id));
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
		minSelect = Std.parseInt(rules[0]);
		if(rules.length == 1)
			maxSelect = minSelect;
		else if(rules.length > 1 && rules[1] != "*")
			maxSelect = Std.parseInt(rules[1]);

		var numSelected = group.inputs.count(function(input: Input) return input.selected);

		if(maxSelect == numSelected){
			part.activityData.score = 1;
			part.activityData.inputsEnabled = false;
		}

		// Disable/Enable validation with minSelect
		display.toggleValidationButtons(minSelect > numSelected);

	}

	private function createInputs(group:Inputs) {
		var inputList = Lambda.map(group.inputs, function(input: Input){
			var localizedContent = new Map<String, String>();
			for(key in input.items.keys())
				localizedContent[key] = getLocalizedContent(input.items[key].content);

			return {ref: input.ref, id: input.id, content: localizedContent, icon: input.images, selected: input.selected};
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

		// Bind inputs
		var callbacks: InputCallback = {click: null, mouseDown: null, mouseUp: null, mouseOver: null, mouseOut: null};

		for(action in Reflect.fields(callbacks)){
			var actions = new Array<String -> Void>();
			var rules = part.getRulesByType(action, group);
			for(rule in rules)
				actions.push(getInputAction(rule));

			Reflect.setField(callbacks, action, function(inputId: String){
				for(a in actions)
					a(inputId);
			});
		}

		display.createInputs(inputList, group.ref, callbacks, autoValidation, group.position);
	}

	private function getInputAction(rule:Rule):String -> Void
	{
		return switch(rule.value.toLowerCase()){
			case "drag":
				function(inputId: String) display.startDrag(inputId);
			case "showmore":
				function(inputId: String) display.displayElements(inputId+"_more");
			case "showelement":
				function(inputId: String){
					var input: Input = part.getInput(inputId);
					if(input == null)
						throw "Can't find input with id '"+inputId+"'.";
					for (s in input.values)
						setInputSelected(part.getInput(s), true);
					//display.toggleElement(s, true);
				}
			case "setvisited" :
				function(inputId: String){
					var input: Input = part.getInput(inputId);
					if(input == null)
						throw "Can't find input with id '"+inputId+"'.";
					setInputSelected(input,true);
				}
			case "replacecontent" :
				function(inputId: String){
					var input: Input = part.getInput(inputId);
					if(input == null)
						throw "Can't find input with id '"+inputId+"'.";
					var output: Input = part.getInput(input.values[0]);
					var item: Item = input.items[input.values[0]];
					var loc = getLocalizedContent(item.content);
					display.setText(output.id,loc);
					display.setInputState(output.id, "more");
					if(item.voiceOverUrl != null)
						setVoiceOver(item.voiceOverUrl, output.id);
				}
			case "removecontent":
				function(inputId: String){
					var input: Input = part.getInput(inputId);
					if(input == null)
						throw "Can't find input with id '"+inputId+"'.";
					var output: Input = part.getInput(input.values[0]);
					display.setText(output.id,null);
					display.removeInputState(output.id, "more");
				}
			case "toggle" :
				function(inputId: String){
					var input: Input = part.getInput(inputId);
					if(input == null)
						throw "Can't find input with id '"+inputId+"'.";
					setInputSelected(input,!input.selected);
				}
			case "toggleother" :
				function(inputId: String){
					var input: Input = part.getInput(inputId);
					if(input == null)
						throw "Can't find input with id '"+inputId+"'.";
					var output: Input = part.getInput(input.values[0]);
					setInputSelected(output,!output.selected);
				}
			case "goto":
				function(inputId: String){
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
					display.hideElements(Lambda.map(part.activityData.groups, function(group: Inputs) return group.ref));
					displayPart(state.module.getPartById(id));
				}
			default: throw "Unknown rule '"+rule.value+"'.";
		}
	}

	private function setVoiceOver(voiceOverUrl: String, ?itemRef: String):Void
	{
		display.stopVoiceOver();
		var fullPath: Array<String> = voiceOverUrl.split("/");

		var path: String = null;
		if(fullPath.length == 1)
			path = state.module.currentLocale + "/" + fullPath[0];
		else{
			var localePath : StringBuf = new StringBuf();

			localePath.add(fullPath[0] + "/");
			localePath.add(state.module.currentLocale + "/");

			for (i in 1...fullPath.length-1) {

				localePath.add(fullPath[i] + "/");
			}
			localePath.add(fullPath[fullPath.length-1]);
			path = localePath.toString();
		}
		display.setVoiceOver(path, application.masterVolume, itemRef);
	}
}