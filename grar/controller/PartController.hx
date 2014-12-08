package grar.controller;

import grar.model.InventoryToken;
import grar.service.SubtitleService;
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

		subtitleSrv = new SubtitleService(config.rootUri);

		init();
	}

	var parent:Controller;
	var state: State;
	var application: Application;
	var display: PartDisplay;
	var config: Config;
	var subtitleSrv: SubtitleService;

	var part: Part;

	///
	// CALLBACKS
	///

	public dynamic function onRestoreLocaleRequest() : Void {}

	public dynamic function onPartFinished(part: Part, next:Bool):Void{}

	public dynamic function onLocaleDataPathRequest(uri: String, ?onSuccess: Void -> Void) : Void {}

	public dynamic function onTrackingUpdateRequest(): Void {}


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

		// Bind
		this.part.onStateChanged = function(state: PartState) onPartStateChanged(state);
		this.part.state = STARTED;
		display.onSubtitleRequest = function(uri, callback){
			subtitleSrv.fetchSubtitle(uri, callback, parent.onError);
		}

		display.onTokenActivation = function(tokenId: String){
			state.module.activateInventoryToken(tokenId);
		}

		onLocaleDataPathRequest(part.file, function(){
			application.onPartLoaded = function(){
				var key = state.module.isInLocale("activityName_"+part.id) ? "activityName_"+part.id : "activityName";
				application.updateChapterInfos(getLocalizedContent("chapterName"), getLocalizedContent(key));
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

	public function getCurrentPartInfos():PartInfos
	{
		return {id: part.id, state: Std.string(part.state), name: getLocalizedContent(part.name)};
	}

	public function startActivity(?resume: Bool = false):Void
	{
		display.onValidationRequest = function(inputId: String, ?value: String, ?dragging: Bool = false){
			if(value != null){
				var inputs: Inputs = part.getInputGroup(value);
				if(inputs == part.getInputGroup(inputId) && dragging){
					display.stopDrag(inputId, value, false, false);
					return;
				}
			}

			var isCorrect = validateInput(inputId, value, dragging);
			if(dragging){
				display.stopDrag(inputId, value, true, isCorrect);
			}
		}

		// If resuming activity, just show inputs
		if(resume){
			display.displayElements(Lambda.map(part.activityData.groups, function(group: Inputs) return group.ref));
			////
			/*for(group in part.activityData.groups){
				if(group.groups != null && group.groups.length > 0)
					for(subgroup in group.groups){
						if(subgroup.inputs.foreach(function(input: Input) return input.selected)){
							state.activityState = ActivityState.NONE;
							nextElement();
							return;
						}
					}
				else if(group.inputs.foreach(function(input: Input) return input.selected)){
					state.activityState = ActivityState.NONE;
					nextElement();
					return;
				}
			}*/
			////
			part.activityData.inputsEnabled = true;
			return;
		}

		// Clean previous inputs
		if(part.activityData.groupIndex > 0){
			var group = part.activityData.groups[part.activityData.groupIndex-1];
			if(group == null)
				part.restart();
			else{
//				if(group.ref != "")
//					display.hideElements(group.ref);
				for (item in group.items) {
					unsetAuthor(item.author);
				}
				for(input in group.inputs)
					display.removeElement(input.id);
				for(debrief in part.getRulesByType("debrief", group))
					display.unsetDebrief(debrief.id);
			}
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
			if(rules.length > 0 && part.activityData.score < Std.parseInt(rules[0].value))
				display.disableNextButtons();
			else{
				var rules = part.getRulesByType("minVisited");
				if(rules.length > 0){
					if(group.inputs.length > 0 && part.getNumInputsVisited(group) < Std.parseInt(rules[0].value))
						display.disableNextButtons();
					else{
						var i = 0;
						while(i < group.groups.length && part.getNumInputsVisited(group.groups[i]) < Std.parseInt(rules[0].value))
							i++;
						if(i == group.groups.length)
							display.disableNextButtons();
					}
				}
			}
		}

		application.sendReadyHook();
	}

	public function onGameOver():Void
	{
		display.hideElementsByClass("next");
	}

	public function exitPart(?completed : Bool = true, ?fromMenu: Bool = false) : Void {

		//unloadPart(part.ref);

		if(completed)
		part.state = FINISHED
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
				displayPart(p);

			case Item(i):
				setupItem(i);

			case Pattern(p):
				startPattern(p);

			case GroupItem(group):
				for(it in group.elements){
					setupItem(it);
				}
		}

		checkGameOver();

		application.sendReadyHook();
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
		trace("Going to "+target);
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
				case Pattern(p) if (p.id == target):
					elem = e;
					nextElement(part.getElementIndex(elem)-1);
					break;
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
		//if(part.hasNextElement())
			nextElement();
	}

	private function startPattern(p : Pattern, ? next: Bool = true):Void
	{
        display.showPattern(p.ref);

        var nextItem = next ? p.getNextItem() : p.getPreviousItem();
        if(nextItem != null)
	        setupItem(nextItem);
        else if(p.nextPattern != null && p.nextPattern == "end")
	        exitPart();
	    else if(p.nextPattern != null)
            goToPattern(p.nextPattern);
        else{
	        endPattern(p);
	        nextElement(part.getElementIndex(Pattern(p)));
        }

		for(b in part.buttons)
			initButtons(b);

		// Choices
		if(p.choicesData != null){
			var choicesList = Lambda.map(p.choicesData.choices, function(choice: Choice){
				var locked = false;
				for(req in choice.requierdTokens.keys()){
					var token: InventoryToken = state.module.getInventoryToken(req);
					if(token != null)
						locked = token.isActivated != choice.requierdTokens[req];
					else
						trace("Unknown required token '"+req+"' for choice '"+choice.id+"'.");
				}
				var localizedContent = new Map<String, String>();
				for(key in choice.content.keys())
					localizedContent[key] = getLocalizedContent(choice.content[key]);

				return {ref: choice.ref, content: localizedContent, id: choice.id, icon: choice.icon, selected: choice.viewed, goto: choice.goTo, locked: locked};
			});
			var unlockedChoices = Lambda.filter(choicesList, function(choice) return !choice.locked);
			if(unlockedChoices.length > 1){
				display.createChoices(choicesList, p.choicesData.ref);
				display.onChangePatternRequest = function(patternId: String) goToPattern(patternId);
			}
			else
				goToPattern(unlockedChoices.first().goto);
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
		checkGameOver();
	}

	private function setupItem(item : Item) : Void {

		// Set part background
		if (item.background != null)
			display.showBackground(item.background);

		for(b in item.button)
			initButtons(b);

		var introScreenOn = false;

		if(item.videoData != null) {
			if(parent.ks != null && item.content.indexOf(".") == -1){
				var srv = new KalturaService();
				srv.getUrl(item.content, config.bitrate, parent.ks, function(url){
					var errCode = ~/code/;
					if(errCode.match(url))
						trace("Cannot retrieve video: "+url);
					else{
						var decodeUrl = url.replace("\\/", "/");
						display.setVideo(item.ref, decodeUrl, item.videoData, item.tokens, function(){}, function() {
							onVideoComplete();
						}, state.module.currentLocale);
					}
				});
			}
			else
				display.setVideo(item.ref, item.content, item.videoData, item.tokens, function(){}, function() {
					onVideoComplete();
				}, state.module.currentLocale);


		}
		else if(item.soundData != null){
			display.setSound(item.ref, item.content, item.soundData.autoStart, item.soundData.loop, item.soundData.defaultVolume, function() {});//activateToken());
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
			//display.hideVideoPlayer();

			//state.module.activateInventoryToken(tokenId);
		}

		// Voice over
		if(item.voiceOverUrl != null){
			setVoiceOver(item.voiceOverUrl, item.ref);
		}

		for (image in item.images)
			display.setImage(image.ref,image.src, image.crop);

		display.displayElements(createDisplayList(item));
	}

	private function teardownItem(item : Item):Void
	{
		// Unset part background
		if (item.background != null)
			display.hideBackground(item.background);

		/*if(item.videoData != null)
			display.hideVideoPlayer();
		else if(item.soundData != null){
			// TODO Stop sound
		}
		else {*/
			unsetAuthor(item.author);
			//display.hideText(item.ref);
		//}

		// Voice over
		if(item.voiceOverUrl != null)
			display.stopVoiceOver();

//		for (image in item.images)
//			display.unsetImage(image.ref);
//
//		display.hideElements(createDisplayList(item));
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
			/*for(key in b.content.keys()){
				if(key == "_")
					display.setText(b.ref, b.content[key]);
				else
					display.setText(key, b.content[key]);
			}*/
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

            var resultsArray = new Array<Bool>();

			for(input in group.inputs){
                validateInput(input.id, validationRule);
                resultsArray.push(input.selected);
            }

			// Debrief
			var lastId = null;
			var lastValue = null;
			var isTrue = false;
            var arrayDebriefs = new Array<{id:String,values:Array<String>}>();

			for(rule in debriefRules){
				if(rule.value.indexOf('[')==0){
					var ruleValue =rule.value.substring(1,rule.value.length-1);
					var valueArray =ruleValue.split(',');
					var debriefObject={id:rule.id,values:valueArray};

					arrayDebriefs.push(debriefObject);
				}
				else{
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
			}

            if(arrayDebriefs.length>0){
                var combiQuestion = "";

                for ( i in 0...resultsArray.length)
                    if(resultsArray[i])
                        combiQuestion += (i+1);//123

                for(debrief in arrayDebriefs){
                    for(combi in debrief.values){
                        if(combi == combiQuestion ){
                            var idTextDebrief = debrief.id.split('_')[0];
                            display.setDebrief(idTextDebrief, getLocalizedContent(group.id+"_"+debrief.id));
                        }
                    }
                }
            }
            else{
                display.setDebrief(lastId, getLocalizedContent(group.id+"_"+lastValue));

                if(lastId != null)
                    display.setInputState(lastId, Std.string(isTrue));
            }

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

	public function validateInput(inputId: String, ?validation: Rule, ?value: String, ?dragging: Bool = false):Bool
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


		if(result && dragging){
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

			part.activityData.score++;

		}

		// Selection limits
		var maxSelect = -1;
		var rules = part.getRulesByType("selectionLimits", part.getInputGroup(inputId));
		if(rules.length == 1)
			maxSelect = Std.parseInt(rules[0].value);
		else if(rules.length > 1 && rules[1].value != "*")
			maxSelect = Std.parseInt(rules[1].value);

		var rules = part.getRulesByType("minScore");
		if(rules.length > 0 && part.activityData.score >= Std.parseInt(rules[0].value))
			display.enableNextButtons();

		if(result)
			display.setText(value+"_completion", part.activityData.numRightAnswers+"/"+maxSelect);

		return result;
	}

    private function setInputSelected(input: Input,selected:Bool):Void{

        // Optim ?
        //if(input.selected == selected) return;

	    /////
	    var group: Inputs = part.getInputGroup(input.id);
	    var selectionRules = part.getRulesByType("selectionLimits", group);
	    if(selectionRules.length > 1)
		    throw 'Too many selection rules. Please choose one';
	    else if(selectionRules.length == 0)
		    return;

	    var maxSelect = -1;
	    var minSelect = -1;
	    var rules = selectionRules[0].value.split(" ");
	    minSelect = Std.parseInt(rules[0]);
	    if(rules.length == 1)
		    maxSelect = minSelect;
	    else if(rules.length > 1 && rules[1] != "*")
		    maxSelect = Std.parseInt(rules[1]);

	    if(maxSelect == 1){
		    group.inputs.iter(function(i: Input){
		        if(i.selected){
			        i.selected = false;
			        display.toggleElement(i.id, false);
		        }
		    });
	    }
		////
        display.toggleElement(input.id,selected);

	    if(!input.selected)
		    input.visited = true;

        input.selected = selected;

	    var rules = part.getRulesByType("minVisited");
	    //var group = part.getInputGroup(input.id);
	    var inputs = group.inputs;
	    if(rules.length > 0 && part.getNumInputsVisited(group) >= Std.parseInt(rules[0].value))
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
			if(maxSelect > 1)
				part.activityData.inputsEnabled = false;
		}
		else{
            part.activityData.inputsEnabled = true;
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

			if(actions.length != 0)
				Reflect.setField(callbacks, action, function(inputId: String){
					for(a in actions)
						a(inputId);
				});
			/*
			if(actions.length > 0)
				Reflect.setField(callbacks, action, function(inputId: String){

					bindRule(inputId);
					if(part.activityData.inputsEnabled && part.getInput(inputId) != null)
						for(a in actions)
							a(inputId);
					else if(part.activityData.inputsEnabled)
						trace("Unable to find an input with id: "+inputId);
				});
			 */
		}

		display.createInputs(inputList, group.ref, callbacks, autoValidation, group.position);

		// Update state
		for(input in group.inputs){
			if(input.selected)
				setInputSelected(input, true);
		}
	}

	/*
	private function bindRule(inputId: String, rule: Rule):Void
	{
		var input: Input = part.getInput(inputId);
		for(injunction in rule.injunctions){
			switch(injunction){
				case SETTER(obj, value):
					setVariableValue(obj, value);
				case GETTER(src, target):
				case PUTTER(obj, target):
					case VALIDATOR:
			}
		}
	}

	// No parameters: GET
	// 1 parameter : SET
	private function variableValue():Void
	{

	}

	private function getVariableValue(input:Input, variable:String, ?value: Dynamic):Dynamic
	{
		var result;
		if(variable.startsWith("this")){
			switch(variable.substr(5)){
				case "selected":
					if(value != null)
						input.selected = value;
					else
						result = input.selected;

				case "dragged": // TODO
				case "enabled": // TODO
				case "content":
					var content = new Map<String, String>();
					for(item in input.items)
					content[item.ref] = item.content;
					content;
				case "position": // TODO
				case "origin": // TODO
				case "states": // TODO
				case "isCorrect":
					if(value != null)
						input.correct = value;
					else
						result = input.correct;
			}
		}
		else{
			switch(variable){
				case "next": // TODO
				case "numVisited":
					if(value != null)
						throw("[GScript] numVisited property is read-only");
					else
						part.getNumInputsVisited(part.getInputGroup(input.id));
				case "minSelected":
			}
		}

		return value;
	}
	 */

	private function getInputAction(rule:Rule):String -> Void
	{
		return switch(rule.value.toLowerCase()){
			case "drag":
				function(inputId: String) display.startDrag(inputId);
			case "showmore":
				function(inputId: String) display.displayElements(inputId+"_more");
			case "showelement":
				function(inputId: String){
					for (s in part.getInput(inputId).values)
						setInputSelected(part.getInput(s), true);
					//display.toggleElement(s, true);
				}
			case "setvisited" :
				function(inputId: String){
					setInputSelected(part.getInput(inputId),true);
				}
			case "replacecontent" :
				function(inputId: String){
					var input: Input = part.getInput(inputId);
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
					var output: Input = part.getInput(part.getInput(inputId).values[0]);
					display.setText(output.id,null);
					display.removeInputState(output.id, "more");
				}
			case "toggle" :
				function(inputId: String){
					var input: Input = part.getInput(inputId);
                    //TODO déplacer dans setInputSelected
                    if(!input.selected){
                        if(part.activityData.inputsEnabled )
                            setInputSelected(input,!input.selected);
                    }
                    else{
                        setInputSelected(input,!input.selected);
                    }
				}
			case "toggleother" :
				function(inputId: String){
					var input: Input = part.getInput(inputId);
					if(input != null){
						var output: Input = part.getInput(input.values[0]);
						setInputSelected(output,!output.selected);
					}
				}
			case "validate":
				function(inputId: String){
					var input: Input = part.getInput(inputId);
				}
			case "goto":
				function(inputId: String){
					var input = part.getInput(inputId);
					// Don't go anywhere if already selected
					//if(input.selected)
					//	return;

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
					setInputSelected(input, true);
					part.activityData.inputsEnabled = false;
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

	private inline function checkGameOver():Void
	{
		if(!part.hasNextElement() && !state.module.hasNextPart(part))
			part.state = FINISHED;
	}

	private function onPartStateChanged(partState:PartState):Void
	{
		switch(partState){
			case STARTED:
				this.state.module.setPartStarted(part.id);
			case FINISHED:
				this.state.module.setPartFinished(part.id);
		}
		onTrackingUpdateRequest();
	}
}