package grar.controller;

import StringTools;
import grar.service.KalturaService;
import grar.model.part.PartElement;
import grar.model.part.ButtonData;
import haxe.ds.StringMap;
import grar.view.Application;
import grar.view.part.IntroScreen;
import grar.view.part.PartDisplay;

import grar.model.part.Part;
import grar.model.part.PartElement;
import grar.model.part.Pattern;
import grar.model.part.item.Item;
import grar.model.State;

import haxe.ds.GenericStack;

import grar.Controller;

class PartController
{

	public function new(parent: Controller, state: State, app: Application)
	{
		this.parent = parent;
		this.state = state;
		this.application = app;

		parts = new GenericStack<Part>();

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

		//application.onPartDisplayRequest = function(p : Part) {

			//displayPart(part);
		//}
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
			display.ref = part.ref;
			nextElement();
		});

		display.onExit = function(){ exitPart(part); }
		//display.onEnterSubPart = function(sp : Part) enterSubPart(sp);
		display.onGameOver = function() parent.gameOver();

		return true;
	}

	public function exitPart(part: Part, completed : Bool = true) : Void {

		part.isDone = completed;
		state.module.setPartFinished(part.id);

		display.reset();

		if (part.file != null) {

			//Localiser.instance.popLocale();
			onRestoreLocaleRequest();
		}

		// Go to next Part
		//nextElement();
	}

	/**
	* @param    startIndex :   element after this index
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/
	public function nextElement(?startIndex : Int = -1) : Void {

		display.reset();
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
		currentElement = Pattern(p);
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
						trace("Cannot retrieve video");
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

		// Display Part
		/*if (!introScreenOn)
			displayPart();*/

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

		} else if (currentSpeaker != null) {
			display.hideSpeaker(currentSpeaker);

			currentSpeaker = null;
		}
	}

	private function getLocalizedContent(key: String):String {
		return state.module.getLocalizedContent(key);
	}

	private function createDisplayList(item: Item): List<String> {

		var list = new List<String>();
		list = Lambda.concat(list, item.images);

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

	/*private function onInputEvents(inputRef: String, eventType: String):Void
	{
		var needValidation = false;
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
			enableInputs();
	}*/
}