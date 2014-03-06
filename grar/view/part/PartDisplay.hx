package grar.view.part;

import grar.view.Display;
import grar.view.component.container.SoundPlayer;
import grar.view.component.container.SimpleContainer;
import grar.view.component.container.VideoPlayer;
import grar.view.component.container.DefaultButton;
import grar.view.component.container.ScrollPanel;
import grar.view.component.Widget;
import grar.view.component.Image;
import grar.view.component.CharacterDisplay;
import grar.view.element.Timeline;

import grar.model.part.sound.SoundItem;
import grar.model.part.Item;
import grar.model.part.video.VideoItem;
import grar.model.part.Part;
import grar.model.part.PartElement;
import grar.model.part.Pattern;
import grar.model.part.TextItem;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

using StringTools;

/**
 * Display of a part
 */
class PartDisplay extends Display {

	/**
     * Constructor
     * @param	part : Part to display
     */
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, part : Part) {

		super(callbacks, applicationTilesheet);
		
		this.onActivateTokenRequest = function(tokenId : String){ callbacks.onActivateTokenRequest(tokenId); }

		this.part = part;
//		resizeD = ResizeManager.get_instance();
		currentItems = new GenericStack<Widget>();
	}

	/**
     * Part model to display
     */
	public var part : Part;

	public var introScreenOn (default, null) : Bool = false;

	private var currentElement : PartElement;
// 	private var resizeD : ResizeManager;
	private var currentSpeaker : CharacterDisplay;
	private var previousBackground : String;
	private var localeLoaded : Bool = false;
	private var displayLoaded : Bool = false;
	private var currentItems : GenericStack<Widget>;
	private var currentItem : Item;
	private var itemSound : Sound;
	private var itemSoundChannel : SoundChannel;
	private var numWidgetAdded : Int;
	private var numWidgetReady : Int;
	private var nextTimeline : String;


	///
	// CALLBACKS
	//

	public dynamic function onExit() : Void { }

	public dynamic function onEnterSubPart(sp : Part) : Void { }

	public dynamic function onPartLoaded() : Void { }

	public dynamic function onGameOver() : Void { }

	public dynamic function onActivateTokenRequest(token : String) : Void { }


	///
	// API
	//

	/**
     * Initialize the part display.
     **/
	public function init() : Void {

		if (part.file != null) {

//			Localiser.instance.layoutPath = part.file;
			onLocaleDataPathRequest(part.file);
		
		} else {

			localeLoaded = true; // useless ?
		}

 		if (part.display != null) {

 			//parseContent(AssetsStorage.getXml(part.display));
 			setContent(part.display);
 		
 		} else {

			displayLoaded = true; // <= useless ?
 		}

		localeLoaded = true; // useless ?
		checkPartLoaded();
	}

	public function exitPart(completed : Bool = true) : Void {

		part.isDone = completed;
		
		unLoad();

		if (part.file != null) {

			//Localiser.instance.popLocale();
			onRestoreLocaleRequest();
		}

// 		dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
		onExit();
	}

	/**
	* @param    startIndex :   element after this index
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/
	public function nextElement(startIndex : Int = -1) : Void {

		currentElement = part.getNextElement(startIndex);

		if (currentElement == null) {

			exitPart();
			return;
		}
		switch (currentElement) {

			case Part(p):

				if (p.endScreen) {

					part.isDone = true;
// 					dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
					onGameOver();
				}
				cleanDisplay();
// 				var event = new PartEvent(PartEvent.ENTER_SUB_PART);
// 				event.part = cast(currentElement, Part);
// 				dispatchEvent(event);
				onEnterSubPart(p);

			case Item(i):

				if (i.endScreen) {

					part.isDone = true;
// 					dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
					onGameOver();
				}
				crawlTextGroup(i);

			case Pattern(p):

				if (p.endScreen) {

					part.isDone = true;
// 					dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
					onGameOver();
				}
				startPattern(p);
		}
	}

	/**
    * Start the part
    * @param    startPosition : Start at this position
    **/

	public function startPart(startPosition:Int = -1):Void
	{
// 		TweenManager.applyTransition(this, transitionIn);
 		onTransitionRequest(this, transitionIn);

		nextElement(startPosition);
	}

	/**
	* Next Button action
	* @param target : Clicked button
	**/
	public function next(?target: DefaultButton):Void
	{
		nextElement();
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

	/**
     * Unload the display from the scene
     */

	private function unLoad():Void
	{
		while(numChildren > 0){
			var child = removeChildAt(numChildren - 1);
			child = null;
		}
		if(parent != null)
			parent.removeChild(this);
		currentElement = null;
		currentSpeaker = null;
		previousBackground = null;
		if(currentItems != null)
			for(item in currentItems)
				item = null;
		currentItems = null;
		currentItem = null;
		itemSound = null;
		itemSoundChannel = null;
	}

	private function crawlTextGroup(item : Item, ? pattern : Pattern) : Void {

		if (textGroups != null) {
//trace("crawlTextGroup "+item.ref);
			var groupKey : String = null;
			
			for (key in textGroups.keys()) {

				if (textGroups.get(key).exists(item.ref)) {

					groupKey = key;
					break;
				}
			}
//trace("FOUND GROUP "+groupKey);
			if (groupKey != null) {

				var textItem = null;
				var i = 0;
				
				while ( i < Lambda.count(textGroups.get(groupKey)) ) {

					if (i > 0) {

						if (pattern != null) {

							textItem = pattern.getNextItem();
						
						} else {

							//textItem = cast(part.getNextElement(), Item);
							switch (part.getNextElement()) {

								case Item(i):

									textItem = i;

								default: // nothing
							}
						}
					
					} else {

						textItem = item;
					}
					if (textItem != null && textItem.endScreen) {

						part.isDone = true;
// 						dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
						onGameOver();
					}
//trace("SETTING UP ITEM "+textItem.ref);
					setupItem(cast(textItem, Item), (i == 0));

					i++;
				}
			
			} else {

				setupItem(item);
			}
		}
	}

	//override private function createElement(elemNode:Fast):Widget
	override private function createElement(e : ElementData, r : String) : Widget {

		switch (e) {

			case IntroScreen(d):

				var intro = new IntroScreen(callbacks, applicationTilesheet, d);
//				intro.zz = zIndex;
				displays.push({ w: intro, ref: r });
				displaysRefs.set(r, intro);
//				zIndex++;
				return intro;

			default: 

				return super.createElement(e, r);
		}
	}

	override private function createDisplay(d : DisplayData) : Void {

		super.createDisplay(d);

		displayLoaded = true;
		checkPartLoaded();
	}

	private function checkPartLoaded():Void // TODO check if still useful
	{
		if (localeLoaded && displayLoaded) {
// 			var event = new PartEvent(PartEvent.PART_LOADED);
// 			event.part = part;
// 			dispatchEvent(event);
			onPartLoaded();
		}
	}

	private function startPattern(p : Pattern):Void
	{
		currentElement = Pattern(p);
	}

	override private function setButtonAction(button:DefaultButton, action:String):Bool
	{
//if(part.id == "intro") trace("setButtonAction "+action);
		if (super.setButtonAction(button, action)) {

			return true;
		
		} else {

			switch (action.toLowerCase()) {

				case "next":
				
					button.buttonAction = next;

					return true;
				
				case "goto":
				
					button.buttonAction = function(?target: DefaultButton){

							var goToTarget : PartElement = part.buttonTargets.get(button.ref);
trace("button actionned goto " + button.ref+ "  goToTarget= "+goToTarget);						
							if (goToTarget == null) {

								exitPart();
							
							} else {

								nextElement(part.getElementIndex(goToTarget) - 1);
							}
						};

					return true;
				
				case "exit":

					button.buttonAction = function(?target) {

							exitPart(false);

						};

					return true;
			}
		}
		return false;
	}


	private function setBackground(background:String):Void
	{
		if(background != null && background != ""){
			var sameBackground = true;
			// Clean previous background
			if(previousBackground != null && previousBackground != background){
				sameBackground = false;
				for(b in previousBackground.split(","))
					removeChild(displaysRefs.get(b));
			}
			else if(previousBackground == null)
				sameBackground = false;
			// Add new background if different from previous one
			if(!sameBackground){
				var bkgs = background.split(",");
				bkgs.reverse();
				for(b in bkgs){
					if(!displaysRefs.exists(b))
						throw '[PartDisplay] There is no background with ref "$b"';
				}
				previousBackground = background;
			}
		}
	}

	private function setSpeaker(author:String, ?transition:String):Void
	{
		if(author != null && displaysRefs.exists(author)){
			if(!displaysRefs.exists(author))
				throw "[PartDisplay] There is no Character with ref " + author;
			var char = cast(displaysRefs.get(author), CharacterDisplay);

			if(char != currentSpeaker){
				if(currentSpeaker != null && contains(currentSpeaker) && !Std.is(this, StripDisplay)){
					removeChild(currentSpeaker);
				}
				currentSpeaker = char;

				if(char.nameRef != null && displaysRefs.exists(char.nameRef))
					cast(displaysRefs.get(char.nameRef), grar.view.component.container.ScrollPanel).setContent(currentSpeaker.charRef);
				else if(char.nameRef != null)
					throw "[PartDisplay] There is no TextArea with ref " + char.nameRef;
			}
		}
		else if(currentSpeaker != null && contains(currentSpeaker)){
			removeChild(currentSpeaker);
			currentSpeaker = null;
		}
	}

	private function setupItem(item : Item, ? isFirst : Bool = true) : Void {

		if (item == null) {

			return;
		}
//trace("SETTING CURRENT ITEM TO "+item);
		currentItem = item;

 		for (token in item.tokens) {

// 			GameManager.instance.activateToken(token);
			onActivateTokenRequest(token);
 		}
		if (isFirst) {

			setBackground(item.background);
		}
		if (item.isText()) {

			var text = cast(item, TextItem);

			if (text.introScreen != null) {

				cleanDisplay();

				setSpeaker(text.author, text.transition);
				setText(text, isFirst);

				// The intro screen automatically removes itself after its duration
				var intro = text.introScreen;
				var introDisplay : grar.view.part.IntroScreen = cast displaysRefs.get(intro.ref);
 
				for (field in intro.content.keys()) {

					introDisplay.setText(onLocalizedContentRequest(intro.content.get(field)), field);
				}
				introDisplay.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event) {

						introScreenOn = false;

						displayPart();

					});

				introScreenOn = true;
				
				addChild(introDisplay);
			
			} else {

				setSpeaker(text.author, text.transition);
				setText(text, isFirst);
			}
		
		} else if (item.isVideo()) {

			if (!displaysRefs.exists(item.ref)) {

				throw "[PartDisplay] There is no VideoPlayer with ref '"+ item.ref+"'.";
			}
			var video = cast(item, VideoItem);

			cast(displaysRefs.get(item.ref), grar.view.component.container.VideoPlayer).setVideo(video.content, video.autoStart, video.loop, video.defaultVolume, video.capture,video.autoFullscreen,video.thumbnail);
			cast(displaysRefs.get(item.ref), grar.view.component.container.VideoPlayer).addEventListener(Event.COMPLETE, onVideoComplete);
		
		} else {

            if (!displaysRefs.exists(item.ref)) {

                throw "[PartDisplay] There is no SoundPlayer with ref '"+ item.ref+"'.";
            }
            var sound = cast(item, SoundItem);

            cast(displaysRefs.get(item.ref), grar.view.component.container.SoundPlayer).setSound(sound.content, sound.autoStart, sound.loop, sound.defaultVolume);
        }

		// Display Part
		if (!introScreenOn && isFirst) {

			displayPart();
		
		} else if (!introScreenOn) {

			var i = 0;
			var found = false;
			
			while (i < numChildren && !found) {

				//if (Std.is(getChildAt(i),Widget) && (cast(getChildAt(i),Widget).zz > displaysRefs.get(item.ref).zz)) {
				if (Std.is(getChildAt(i), Widget) && getZPosition(cast(getChildAt(i),Widget)) > getZPosition(displaysRefs.get(item.ref))) {
//trace("Add "+item.ref+" at "+i);
					addChildAt(displaysRefs.get(item.ref), i);

					found = true;
				}
				i++;
			}
		}
	}

	private function onVideoComplete(e:Event):Void
	{
		// Nothing. See subclass
	}

	private function setText(item:TextItem, isFirst:Bool = true):Void
	{

		var content = onLocalizedContentRequest(item.content);

		if (item.ref != null) {

			if (!displaysRefs.exists(item.ref)) {

				throw "[PartDisplay] There is no TextArea with ref " + item.ref;
			}
			cast(displaysRefs.get(item.ref), grar.view.component.container.ScrollPanel).setContent(content);
		}

		//GameManager.instance.loadSound(item.sound);
		onSoundToLoad(item.sound);
	}

	private function displayPart() : Void {

		// Clean-up buttons
		cleanDisplay();

		// Dynamic timeline
		var tl: Timeline = null;
		if(currentItem != null){
			nextTimeline = currentItem.timelineIn;
			tl = currentItem != null ? timelines.get(nextTimeline) : null;
		}

		if(tl != null){
			for(elem in tl.elements){
				if(elem.dynamicValue == null)
					continue;
				var bkgRegExp: EReg = ~/\$currentBackground/;
				if(elem.dynamicValue == "$currentSpeaker"){
					elem.widget = currentSpeaker;
				}
				else if(bkgRegExp.match(elem.dynamicValue)){
					var bkgs = previousBackground.split(",");
					var index = 0;
					if(Std.parseInt(bkgRegExp.matchedRight()) != null)
						index = Std.parseInt(bkgRegExp.matchedRight());
					elem.widget = displaysRefs.get(bkgs[index]);
				}
				else if(elem.dynamicValue.startsWith("$character") && currentItem.isText()){
					var index = Std.parseInt(elem.dynamicValue.replace("$character", ""));
					var i = 0;
					for(item in cast(currentItem, TextItem).images){
						var object: Widget = displaysRefs.get(item);
						if(Std.is(object, CharacterDisplay))
							i++;
						if(i == index){
							elem.widget = object;
							break;
						}
					}
				}
				else if(elem.dynamicValue == "$nameRef"){
					elem.widget = displaysRefs.get(currentSpeaker.nameRef);
				}
			}
		}
		if (tl != null && currentItem.isText()) {

			var listener: Event -> Void = null;
			var ref = currentItem.ref;
			
			tl.onCompleteTransition = function(er:String) {

					if (er == ref) {

						if (currentItem != null && Std.is(currentItem, TextItem)) {

//		 					GameManager.instance.playSound(cast(currentItem, TextItem).sound);
							onSoundToPlay(cast(currentItem, TextItem).sound);
						}

					} else {

						throw "problem ?";
					}
				}
		}

		displayPartElements();
	}

	private function displayPartElements() : Void {

		numWidgetReady = 0;
		numWidgetAdded = 0;

		for (obj in displays) {

			if (!mustBeDisplayed(obj.ref)) {

				continue;
			}
			obj.w.onComplete = onWidgetAdded;
			
			addChild(obj.w);

			numWidgetAdded++;
			/*
			if (obj.zz == 0) {

				addChildAt(obj, 0);
			
			} else {

				addChild(obj);
			}
			*/
		}
	}

	private function cleanDisplay():Void
	{
		var toRemove = new GenericStack<DisplayObject>();
		for(i in 0...numChildren){
			if(Std.is(getChildAt(i), grar.view.component.container.DefaultButton) || Std.is(getChildAt(i), grar.view.component.container.ScrollPanel))
				toRemove.add(getChildAt(i));
		}
		for(item in currentItems){
			toRemove.add(item);
		}
		for(obj in toRemove)
			if(contains(obj))
				removeChild(obj);
	}

	private inline function onWidgetAdded() : Void {

		numWidgetReady++;
		if(numWidgetAdded == numWidgetReady && timelines.exists(nextTimeline)){
			timelines.get(nextTimeline).play();
		}
	}

	private inline function setButtonText(buttonRef : String, buttonContent : Map<String, String>) : Void {

		if (buttonContent != null) {

			for (contentKey in buttonContent.keys()) {

				var targetedText: String = null;
				
				if (contentKey != " ") {

					targetedText = contentKey;
				}
				cast(displaysRefs.get(buttonRef), grar.view.component.container.DefaultButton).setText(onLocalizedContentRequest(buttonContent.get(contentKey)), targetedText);
			}
		}
	}

	private function mustBeDisplayed(key : String) : Bool {

		var object : Widget = displaysRefs.get(key);
#if flash
		if (Std.is(object, grar.view.component.container.VideoPlayer)) {

			return currentItem.ref == key;
		}
#end
		// If the object is already displayed
		if (contains(object)) {
trace("object already on scene: "+key);
			return false;
		}

		// Background
		if (key == previousBackground) {

			return true;
		}

		// Buttons
		if (Std.is(object, grar.view.component.container.DefaultButton)) {

			var button : StringMap<StringMap<String>> = null;

			switch (currentElement) {

				case Item(i):

					button = i.button;

				case Pattern(p):

					button = p.buttons;

				default: throw "unexpected current element type";
			}
			if (button.exists(key)) {

				setButtonText(key, button.get(key));
				
				if (timelines.get(currentItem.timelineOut) != null) {

					cast(displaysRefs.get(key), DefaultButton).timeline = timelines.get(currentItem.timelineOut);
				}
				return true;
			
			} else {
trace("unexisting button: "+key);
				return false;
			}
		}

		// If the character is present on the scene
		if (Std.is(object, CharacterDisplay)) {

			if (object == currentSpeaker) {

				return true;
			
			} else if ((currentItem != null && currentItem.isText() && 
							Lambda.has(cast(currentItem, TextItem).images, key))) {

				currentItems.add(object);

				return true;
			
			} else {
trace("CharacterDisplay ignored: "+key);
				return false;
			}
		}

		// Image displayed with text items
		if (currentItem != null && currentItem.isText()) {

			var text = cast(currentItem, TextItem);
			
			if (currentSpeaker != null && Std.is(object, grar.view.component.container.ScrollPanel) && key == currentSpeaker.nameRef) {

				return true;
			}
			if (Std.is(object, grar.view.component.container.ScrollPanel) && key != text.ref) {
trace("ScrollPanel ignored: "+key);
				return false;
			}
			if (Std.is(object, grar.view.component.Image) || Std.is(object, grar.view.component.container.SimpleContainer)) {

				if (Lambda.has(text.images, key)) {

					currentItems.add(object);

					return true;
				
				} else {
trace("Image or Container ignored: "+key);
					return false;
				}
			}
		
		} else {

			if (Std.is(object, grar.view.component.container.ScrollPanel)) {

				return false;
			}
		}
		// Exclude IntroScreen
		if (Std.is(object, grar.view.part.IntroScreen)) {
trace("IntroScreen ignored: "+key);
			return false;
		}
		return true;
	}
}
