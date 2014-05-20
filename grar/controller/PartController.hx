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

		parts = new GenericStack<Part>();

		dropList = new Map<String, List<String>>();

		init();
	}

	var parent:Controller;
	var state: State;
	var application: Application;
	var display: PartDisplay;
	var part: Part;
	var parts: GenericStack<Part>;
	var currentElement : PartElement;
	var currentSpeaker : String;
	var previousBackground : String;
    var currentPattern:Pattern;

	// Activity vars
	var isActivity: Bool = false;
	var inputs: List<Input>;
	var dropList: Map<String, List<String>>;
	var isEnabled: Bool = true;
	var maxSelect: Int;

	///
	// CALLBACKS
	///

	public dynamic function onRestoreLocaleRequest() : Void {}

	public dynamic function onLocaleDataPathRequest(uri: String, ?onSuccess: Void -> Void) : Void {}


	///
	// API
	//

	public function init():Void
	{
		display = application.partDisplay;

		// Offer to change parser?
		display.markupParser = new TextDownParser();
	}

	/**
    * Display a graphic representation of the given part
    * @param    part : The part to display
    * @param    interrupt : Stop current part to display the new one
    * @return true if the part can be displayed.
    */
	public function displayPart(part : Part, interrupt : Bool = false, startPosition : Int = -1) : Bool {
		this.part = part;
		if (interrupt) {

			var oldPart = parts.pop();

			if (oldPart != null) {
				exitPart(oldPart);
			}
		}
		/*if (!parts.isEmpty()) {

			parts.first().onPartLoaded = function(){ trace("CHECK THIS !!!!"); }
		}*/

		parts.add(part);

		//startIndex = startPosition;
		onLocaleDataPathRequest(part.file, function(){
			display.onPartLoaded = function(){
				// Activity Part
				if(part.activityData != null){
					display.onInputEvent = onInputEvent;
					startActivity();
				}
				// Standard Part
				else
					nextElement();
			}
			display.ref = part.ref;
		});

		display.onExit = function(){ exitPart(part); }
		//display.onEnterSubPart = function(sp : Part) enterSubPart(sp);
		display.onGameOver = function() parent.gameOver();

		return true;
	}

	public function startActivity():Void
	{
		inputs = new List<Input>();
            var group: Inputs = part.getNextGroup();
		if(group.groups != null){
			for(g in group.groups){
                createInputs(g);
			}
		} else if (group != null) {
            createInputs(group);
        }

        for (item in group.items) {
               display.setText(item.ref, getLocalizedContent(item.content));
        }

		// Selection limits
		var rules = part.getRulesByType("selectionLimits");
		if(rules.length == 1)
			maxSelect = Std.parseInt(rules[0].value);
		else if(rules.length > 1 && rules[1].value == "*")
			maxSelect = -1;
		else if(rules.length > 1)
			maxSelect = Std.parseInt(rules[1].value);

		for(b in part.buttons)
			initButtons(b);
	}

    private function createInputs(group:Inputs) {
        var inputList = Lambda.map(group.inputs, function(input: Input){
            var localizedContent = new Map<String, String>();
            for(key in input.content.keys()){
                localizedContent[key] = getLocalizedContent(input.content[key]);
            }
            return {ref: input.ref, id: input.id, content: localizedContent, icon: input.icon}
        });
        var sort = part.getRulesByType("sort", group);
        if(sort.length == 1){
            switch(sort[0].value.toLowerCase()){
                case "random":
                    var randomList = new List<{ref: String, id: String, content: Map<String, String>, icon: Map<String, String>}>();
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
        display.createInputs(inputList, group.ref);
        inputs = inputs.concat(group.inputs);
    }

	public function exitPart(part: Part, completed : Bool = true) : Void {

		part.isDone = completed;
		if(completed)
			state.module.setPartFinished(part.id);

		display.reset();

		if (part.file != null)
			onRestoreLocaleRequest();

		// Go to next Part
		//nextElement();
	}

	/**
	* @param    startIndex :   element after this index
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/
	public function nextElement(?startIndex : Int = -1) : Void {


		//display.reset();


        if(currentPattern !=null){
            startPattern(currentPattern);
        }
        else
        {

            currentElement = part.getNextElement(startIndex);



            if (currentElement == null) {
                exitPart(part);
                return;
            }

            switch (currentElement) {

                case Part(p):

                    if (p.endScreen) {

                        part.isDone = true;
                        parent.gameOver();
                    }
                    enterSubPart(p);

                case Item(i):
                    if (i.endScreen) {

                        part.isDone = true;
                        parent.gameOver();
                    }
                    setupItem(i);

                case Pattern(p):

                    startPattern(p);

                case GroupItem(group):
                    currentSpeaker = null;
                    for(it in group.elements){
                        setupItem(it);
                    }
            }
        }
	}

	public function previousElement():Void
	{
		//display.reset();
		currentElement = part.getPreviousElement();

		if (currentElement == null) {
			exitPart(part);
			return;
		}
		switch (currentElement) {

			case Part(p):
				enterSubPart(p);

			case Item(i):
				setupItem(i);

			case Pattern(p):
				startPattern(p);
				// Doesn't matter if it's too high, index setter take care of that
				p.itemIndex = p.patternContent.length;

			case GroupItem(group):
				for(it in group.elements){
					setupItem(it);
				}
		}
	}

	/**
    * Start the part
    * @param    startPosition : Start at this position
    **/

	public function startPart(?startPosition:Int = -1):Void
	{
		nextElement(startPosition);
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
						part.startElement(p.id);
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

	private function startPattern(p : Pattern):Void
	{

        currentPattern = p;

        for(b in part.buttons)
            initButtons(b);

        var nextItem = p.getNextItem();
        if(nextItem != null)
        {
            setupItem(nextItem);
        }
        else
        {

            currentPattern = null;

            nextElement();
        }



	}

	private function setupItem(item : Item) : Void {

		if (item == null) {

			return;
		}

		//currentItem = item;

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
						display.setVideo(item.ref, decodeUrl, item.videoData.autoStart, item.videoData.loop, item.videoData.defaultVolume, item.videoData.capture,item.videoData.fullscreen, function(){trace("playing");}, function() onVideoComplete());
					}
				});
			}
			else
				display.setVideo(item.ref, item.content, item.videoData.autoStart, item.videoData.loop, item.videoData.defaultVolume, item.videoData.capture,item.videoData.fullscreen, function(){}, function() onVideoComplete());


		}
		else if(item.soundData != null){
			display.setSound(item.ref, item.content, item.soundData.autoStart, item.soundData.loop, item.soundData.defaultVolume);
		}
		else if (item.introScreen != null) {

			introScreenOn = true;
			//display.cleanDisplay();

			setAuthor(item);

			display.setText(item.ref, getLocalizedContent(item.content));

			// TODO Sound
			//onSoundToLoad(item.sound);

			// The intro screen automatically removes itself after its duration
			var intro = item.introScreen;

			for (field in intro.content.keys()) {
				display.setIntroText(field, getLocalizedContent(intro.content.get(field)));
			}
			display.onIntroEnd = function() displayPart(part);

		} else {
			setAuthor(item);
			display.setText(item.ref, getLocalizedContent(item.content));

		}
		for (image in item.images){
			display.setImage(image.ref,image.src);
		}

		display.displayElements(createDisplayList(item));
	}

	private function setAuthor(item: Item):Void
	{
		if (item.author != null) {
			if (item.author != currentSpeaker) {
				display.hideSpeaker(currentSpeaker);
				currentSpeaker = item.author;
				display.showSpeaker(currentSpeaker);
				// TODO Manage nameRef
				/*if (char.nameRef != null) {

					cast(displaysRefs.get(char.nameRef), grar.view.component.container.ScrollPanel).setContent(currentSpeaker.getName());

				} else if (char.nameRef != null) {

					throw "[PartDisplay] There is no TextArea with ref " + char.nameRef;
				}*/
			}

		} else if (currentSpeaker == null) {
			display.hideSpeaker(currentSpeaker);
		}
	}

	private function getLocalizedContent(key: String):String {
		return state.module.getLocalizedContent(key);
	}

	private function createDisplayList(item: Item): List<String> {

		var list = new List<String>();
		//list = Lambda.concat(list, item.images);

		var button : List<ButtonData> = null;
		switch (currentElement) {
			case Item(i):
				button = i.button;
			case Pattern(p):
				button = p.buttons;
			default:
		}
		if(button != null){
			for(b in button){
				list.add(b.ref);
				for(key in b.content.keys())
					display.setText(key, b.content.get(key));
			}
		}

		return list;
	}

	private function initButtons(bd: ButtonData) : Void {

		var action = switch(bd.action.toLowerCase()) {
			case "next": function() nextElement();
			case "prev": function() previousElement();
			case "goto": function() {
						var goToTarget : PartElement = part.buttonTargets.get(bd.ref);
						if (goToTarget == null) {
							exitPart(part);
						} else {
							nextElement(part.getElementIndex(goToTarget) - 1);
						}
					};
			case "exit": function() exitPart(part, false);
			default: function() trace("Unsupported action "+bd.action);
		}
		display.setButtonAction(bd.ref, action);
	}

	private function onInputEvent(eventType: InputEvent, inputId: String, mousePoint: Point):Void
	{
		if(!isEnabled)
			return ;
		var targetId = null;
		var rules = switch(eventType){
			case MOUSE_DOWN(name): part.getRulesByType(name, part.getInputGroup(inputId));
			case MOUSE_UP(name, target): targetId = target;
				part.getRulesByType(name, part.getInputGroup(inputId));

			case CLICK(name): part.getRulesByType(name, part.getInputGroup(inputId));
		}
		for(rule in rules){
			switch(rule.value.toLowerCase()){
				case "drag": display.startDrag(inputId, mousePoint);
				case "drop":
					var input: Input = inputs.filter(function(i: Input)return i.id == inputId).first();
					var drop: Input = inputs.filter(function(i: Input)return i.id == targetId).first();
					var isValid = drop != null && (input.values.has(targetId) || drop.values.has(inputId));
					display.stopDrag(inputId, targetId, isValid, mousePoint);
					if(isValid){
						if(!dropList.exists(targetId))
							dropList[targetId] = new List();
						dropList[targetId].add(inputId);
						var isFull = drop.values.foreach(function(id: String){
							return dropList[targetId].has(id);
						});
						if(isFull)
							display.setInputComplete(targetId);
						part.activityData.numRightAnswers++;
						display.setText(drop.id+"_completion", part.activityData.numRightAnswers+"/"+maxSelect);
					}
				case "showmore":
					display.displayElements(Lambda.list([inputId+"_more"]));
                case "toggle" :
                    display.switchElementToVisited(inputId);
                case "replacecontent" :
                    var input: Input = inputs.filter(function(i: Input)return i.id == inputId).first();
                    var output: Input = inputs.filter(function(i: Input)return i.id == input.values[0]).first();
                    var loc = getLocalizedContent(input.content[input.values[0]]);
                    display.setText(output.id,loc);
			}
		}


		if(maxSelect == part.activityData.numRightAnswers)
			isEnabled = false;
		/*var needValidation = false;
		var input: Input = buttonsToInputs.get(target);
		var clickRules = cast(part, ActivityPart).getRulesByType(eventType, input.group);
		for(rule in clickRules){
			switch(rule.value.toLowerCase()){
				case "goto":
					var target = part.getElementById(buttonsToInputs.get(target).values[0]);

					switch (target) {

						case Part(p):

							onPartDisplayRequest(p);

						default: throw "target not a part"; // remove this throw if it happens normally
					}

					needValidation = true;

				case "toggle":
					target.classList.add("checked");
					var selected = buttonsToInputs.get(target).selected = e.target.toggleState == "active";
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
			onValidate(Std.string(e.target.toggleState == "active"));

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
			enableInputs();*/
	}
}