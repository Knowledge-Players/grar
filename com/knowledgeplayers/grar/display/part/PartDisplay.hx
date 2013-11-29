package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.element.Timeline;
import com.knowledgeplayers.grar.display.component.container.SoundPlayer;
import com.knowledgeplayers.grar.structure.part.sound.item.SoundItem;
import com.knowledgeplayers.grar.display.component.container.SimpleContainer;
import com.knowledgeplayers.grar.structure.part.Item;
import com.knowledgeplayers.grar.structure.part.video.item.VideoItem;
import com.knowledgeplayers.grar.display.component.container.VideoPlayer;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.contextual.InventoryDisplay;
import com.knowledgeplayers.grar.display.component.CharacterDisplay;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.ResizeManager;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

using StringTools;

/**
 * Display of a part
 */
class PartDisplay extends KpDisplay {
	/**
     * Part model to display
     */
	public var part:Part;

	public var introScreenOn (default, null):Bool = false;

	private var currentElement:PartElement;
	private var resizeD:ResizeManager;
	private var currentSpeaker:CharacterDisplay;
	private var previousBackground:String;
	private var localeLoaded:Bool = false;
	private var displayLoaded:Bool = false;
	private var currentItems:GenericStack<Widget>;
	private var currentItem:Item;
	private var inventory:InventoryDisplay;
	private var itemSound:Sound;
	private var itemSoundChannel:SoundChannel;
	private var numWidgetAdded: Int;
	private var numWidgetReady: Int;
	private var nextTimeline: String;

	/**
     * Constructor
     * @param	part : Part to display
     */

	public function new(part:Part)
	{
		super();
		this.part = part;
		resizeD = ResizeManager.get_instance();
		currentItems = new GenericStack<Widget>();
	}

	/**
    * Initialize the part display.
    **/

	public function init():Void
	{
		if(part.file != null){
			Localiser.instance.pushLocale();
			Localiser.instance.set_layoutPath(part.file);
		}
		else
			localeLoaded = true;

		if(part.display != null)
			parseContent(AssetsStorage.getXml(part.display));
		else
			displayLoaded = true;

		localeLoaded = true;
		checkPartLoaded();
	}

	public function exitPart():Void
	{
		part.end();
		unLoad();
		if(part.file != null)
			Localiser.instance.popLocale();
		dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
	}

	/**
	* @param    startIndex :   element after this index
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/

	public function nextElement(startIndex:Int = -1):Void
	{
		currentElement = part.getNextElement(startIndex);

		if(currentElement == null){
			exitPart();
			return;
		}
		if(currentElement.endScreen){
			part.isDone = true;
			dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
		}

		if(Std.is(currentElement, Item)){
			var groupKey = "";
			if(textGroups != null){

				for(key in textGroups.keys()){

					if(textGroups.get(key).exists(cast(currentElement, Item).ref)){

						groupKey = key;
					}
				}

				if(groupKey != ""){
					var textItem = null;
					var i = 0;
					while(i < Lambda.count(textGroups.get(groupKey))){
						if(i > 0){
							textItem = cast(part.getNextElement(), Item);
						}
						else{
							textItem = cast(currentElement, Item);
						}
						setupItem(cast(textItem, Item), (i == 0));
						i++;
					}
				}
				else{
					setupItem(cast(currentElement, Item));
				}

				if(Std.is(currentElement, TextItem))
					GameManager.instance.playSound(cast(currentElement, TextItem).sound);
			}
		}

		else if(currentElement.isPattern()){

			startPattern(cast(currentElement, Pattern));
		}

		else if(currentElement.isPart()){
			cleanDisplay();
			var event = new PartEvent(PartEvent.ENTER_SUB_PART);
			event.part = cast(currentElement, Part);
			dispatchEvent(event);
		}
	}

	/**
    * Start the part
    * @param    startPosition : Start at this position
    **/

	public function startPart(startPosition:Int = -1):Void
	{
		TweenManager.applyTransition(this, transitionIn);

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

	public function goToPattern(target:String):Void
	{
		var i = 0;
		while(i < part.elements.length && !(part.elements[i].isPattern() && cast(part.elements[i], Pattern).name == target)){
			i++;
		}
		if(i == part.elements.length)
			throw "[PartDisplay] There is no pattern with ref \""+target+"\"";

		cast(part.elements[i], Pattern).restart();
		startPattern(cast(part.elements[i], Pattern));
	}

	// Privates

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
		inventory = null;
		itemSound = null;
		itemSoundChannel = null;
	}

	override private function createElement(elemNode:Fast):Widget
	{
		if(elemNode.name.toLowerCase() == "inventory"){
			inventory = new InventoryDisplay(elemNode);
			inventory.init(part.tokens);
			return null;
		}
		else if(elemNode.name.toLowerCase() == "intro"){
			var intro = new IntroScreen(elemNode);
			intro.zz = zIndex;
			displays.set(elemNode.att.ref, intro);
			zIndex++;
			return intro;
		}
		else
			return super.createElement(elemNode);
	}

	override private function createDisplay():Void
	{
		super.createDisplay();
		displayLoaded = true;
		checkPartLoaded();
	}

	private function checkPartLoaded():Void
	{
		if(localeLoaded && displayLoaded){
			var event = new PartEvent(PartEvent.PART_LOADED);
			event.part = part;
			dispatchEvent(event);
		}
	}

	private function startPattern(pattern:Pattern):Void
	{
		currentElement = pattern;
	}

	override private function setButtonAction(button:DefaultButton, action:String):Bool
	{
		if(super.setButtonAction(button, action))
			return true;
		else if(action.toLowerCase() == ButtonActionEvent.NEXT){
			button.buttonAction = next;
			return true;
		}
		else if(action.toLowerCase() == ButtonActionEvent.GOTO){
			button.buttonAction = function(?target: DefaultButton){
				var goToTarget: PartElement = part.buttonTargets.get(button.ref);
				if(goToTarget == null)
					exitPart();
				else {
					nextElement(part.getElementIndex(goToTarget)-1);

                }
			};
			return true;
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
					removeChild(displays.get(b));
			}
			else if(previousBackground == null)
				sameBackground = false;
			// Add new background if different from previous one
			if(!sameBackground){
				var bkgs = background.split(",");
				bkgs.reverse();
				for(b in bkgs){
					if(!displays.exists(b))
						throw '[PartDisplay] There is no background with ref "$b"';
					var bkg:Image = cast(displays.get(b), Image);
					if(bkg != null){
						addChildAt(bkg, 0);
					}
				}
				previousBackground = background;
			}
		}
	}

	private function setSpeaker(author:String, ?transition:String):Void
	{
		if(author != null && displays.exists(author)){
			if(!displays.exists(author))
				throw "[PartDisplay] There is no Character with ref " + author;
			var char = cast(displays.get(author), CharacterDisplay);

			if(char != currentSpeaker){
				if(currentSpeaker != null && !Std.is(this, StripDisplay)){
					removeChild(currentSpeaker);
				}
				currentSpeaker = char;

				if(char.nameRef != null && displays.exists(char.nameRef))
					cast(displays.get(char.nameRef), ScrollPanel).setContent(currentSpeaker.model.getName());
				else if(char.nameRef != null)
					throw "[PartDisplay] There is no TextArea with ref " + char.nameRef;
			}
		}
		else if(currentSpeaker != null && contains(currentSpeaker)){
			removeChild(currentSpeaker);
			currentSpeaker = null;
		}
	}

	private function setupItem(item:Item, ?isFirst:Bool = true):Void
	{
		if(item == null)
			return;

		currentItem = item;

		if(item.token != null && item.token != ""){
			for(token in item.token.split(","))
				GameManager.instance.activateToken(token);
		}

		if(isFirst)
			setBackground(item.background);

		if(item.isText()){
			var text = cast(item, TextItem);
			GameManager.instance.playSound(cast(item, TextItem).sound);

			if(text.introScreen != null){
				cleanDisplay();

				// The intro screen automatically removes itself after its duration
				var intro = text.introScreen;
				var introDisplay:IntroScreen = cast(displays.get(intro.ref), IntroScreen);
				for(field in intro.content.keys())
					introDisplay.setText(Localiser.instance.getItemContent(intro.content.get(field)), field);
				introDisplay.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
				{
					introScreenOn = false;
					setSpeaker(text.author, text.transition);
					setText(text, isFirst);
					displayPart();
				});
				introScreenOn = true;
				addChild(introDisplay);
			}
			else{
				setSpeaker(text.author, text.transition);
				setText(text, isFirst);
			}
		}
		else if(item.isVideo()){
			if(!displays.exists(item.ref))
				throw "[PartDisplay] There is no VideoPlayer with ref '"+ item.ref+"'.";
			var video = cast(item, VideoItem);

			cast(displays.get(item.ref), VideoPlayer).setVideo(video.content, video.autoStart, video.loop, video.defaultVolume, video.capture,video.autoFullscreen,video.thumbnail);
			cast(displays.get(item.ref), VideoPlayer).addEventListener(Event.COMPLETE, onVideoComplete);
		}
		else {
            if(!displays.exists(item.ref))
                throw "[PartDisplay] There is no SoundPlayer with ref '"+ item.ref+"'.";
            var sound = cast(item, SoundItem);
            cast(displays.get(item.ref), SoundPlayer).setSound(sound.content, sound.autoStart, sound.loop, sound.defaultVolume);
        }

		// Display Part
		if(!introScreenOn && (isFirst || !item.isText()))
			displayPart();
	}

	private function onVideoComplete(e:Event):Void
	{
		// Nothing. See subclass
	}

	private function setText(item:TextItem, isFirst:Bool = true):Void
	{
		var content = Localiser.get_instance().getItemContent(item.content);
		if(item.ref != null){
			if(!displays.exists(item.ref))
				throw "[PartDisplay] There is no TextArea with ref " + item.ref;
			cast(displays.get(item.ref), ScrollPanel).setContent(content);
		}

		if(!isFirst){
			var i = 0;
			var found = false;
			while(i < numChildren && !found){
				if(Std.is(getChildAt(i),Widget) && (cast(getChildAt(i),Widget).zz > displays.get(item.ref).zz)){
					addChildAt(cast(displays.get(item.ref), ScrollPanel),i);
					found = true;
				}
				i++;
			}
		}
	}

	private function displayPart():Void
	{
		// Clean-up buttons
		cleanDisplay();

		var array = new Array<Widget>();

		for(key in displays.keys()){
			if(mustBeDisplayed(key))
				array.push(displays.get(key));
		}

		// Dynamic timeline
		var tl: Timeline = timelines.get(currentItem.timelineIn);
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
					elem.widget = displays.get(bkgs[index]);
				}
				else if(elem.dynamicValue.startsWith("$character") && currentItem.isText()){
					var index = Std.parseInt(elem.dynamicValue.replace("$character", ""));
					var i = 0;
					for(item in cast(currentItem, TextItem).images){
						var object: Widget = displays.get(item);
						if(Std.is(object, CharacterDisplay))
							i++;
						if(i == index){
							elem.widget = object;
							break;
						}
					}
				}
				else if(elem.dynamicValue == "$nameRef"){
					elem.widget = displays.get(currentSpeaker.nameRef);
				}
			}
		}

		array.sort(sortDisplayObjects);
		numWidgetReady = 0;
		numWidgetAdded = array.length;
		nextTimeline = currentItem.timelineIn;
		for(obj in array){
			obj.onComplete = onWidgetAdded;
			if(obj.zz == 0)
				addChildAt(obj, 0);
			else
				addChild(obj);
		}

		if(inventory != null && currentSpeaker != null)
			addChild(inventory);
	}

	private function cleanDisplay():Void
	{
		var toRemove = new GenericStack<DisplayObject>();
		for(i in 0...numChildren){
			if(Std.is(getChildAt(i), DefaultButton) || Std.is(getChildAt(i), ScrollPanel)#if flash || Std.is(getChildAt(i), VideoPlayer)#end)
				toRemove.add(getChildAt(i));
		}
		for(item in currentItems){
			toRemove.add(item);
		}
		if(inventory != null && contains(inventory))
			toRemove.add(inventory);
		for(obj in toRemove)
			if(contains(obj))
				removeChild(obj);
	}

	private inline function onWidgetAdded():Void
	{
		numWidgetReady++;
		if(numWidgetAdded == numWidgetReady && timelines.exists(nextTimeline)){
			timelines.get(nextTimeline).play();
		}
	}

	private function setButtonText(buttonRef: String, buttonContent: Map<String, String>):Void
	{
		for(contentKey in buttonContent.keys()){
			var targetedText: String = null;
			if(contentKey != " ")
				targetedText = contentKey;
			cast(displays.get(buttonRef), DefaultButton).setText(Localiser.instance.getItemContent(buttonContent.get(contentKey)), targetedText);
		}
	}

	private function mustBeDisplayed(key:String):Bool
	{
		var object: Widget = displays.get(key);
		#if flash
		if(Std.is(object, VideoPlayer)){
			return currentItem.ref == key;
		}
		#end

		// If the object is already displayed
		if(contains(object)){
			return false;
		}

		// Buttons
		if(Std.is(object, DefaultButton)){

			var button: Map<String, Map<String, String>> = null;
			if(currentElement.isText() || currentElement.isVideo())
				button = cast(currentElement, Item).button;
			else if(currentElement.isPattern())
				button = cast(currentElement, Pattern).buttons;

			if(button.exists(key)){
				setButtonText(key, button.get(key));
				if(timelines.get(currentItem.timelineOut) != null)
					cast(displays.get(key), DefaultButton).timeline = timelines.get(currentItem.timelineOut);
				return true;
			}
			else
				return false;
		}

		// If the character is present on the scene
		if(Std.is(object, CharacterDisplay)){
			if(object == currentSpeaker)
				return true;
			else if((currentItem != null && currentItem.isText() && Lambda.has(cast(currentItem, TextItem).images, key))){
				currentItems.add(object);
				return true;
			}
			else
				return false;
		}

		// Image displayed with text items
		if(currentItem != null && currentItem.isText()){
			var text = cast(currentItem, TextItem);
			if(currentSpeaker != null && Std.is(object, ScrollPanel) && key == currentSpeaker.nameRef)
				return true;
			if(Std.is(object, ScrollPanel) && key != text.ref)
				return false;
			if(Std.is(object, Image) || Std.is(object,SimpleContainer)){
				if(Lambda.has(text.images, key)){
					currentItems.add(object);
					return true;
				}
				else
					return false;
			}
		}
		else{
			if(Std.is(object, ScrollPanel))
				return false;
		}

		// Exclude IntroScreen
		if(Std.is(object, IntroScreen))
			return false;

		return true;
	}
}