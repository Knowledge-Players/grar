package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.container.VideoPlayer;
import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.Image;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.structure.contextual.Notebook;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import aze.display.TileSprite;
import aze.display.TileLayer;
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
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.media.Sound;
import nme.media.SoundChannel;

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
	private var previousBackground:{ref:String, bmp:Image};
	private var localeLoaded:Bool = false;
	private var displayLoaded:Bool = false;
	private var currentItems:GenericStack<DisplayObject>;
	private var currentTextItem:TextItem;
	private var inventory:InventoryDisplay;
	private var itemSound:Sound;
	private var itemSoundChannel:SoundChannel;

	/**
     * Constructor
     * @param	part : Part to display
     */

	public function new(part:Part)
	{
		super();
		this.part = part;

		resizeD = ResizeManager.get_instance();
		currentItems = new GenericStack<DisplayObject>();
	}

	/**
    * Initialize the part display.
    **/

	public function init():Void
	{
		if(part.display != null)
			parseContent(AssetsStorage.getXml(part.display));
		else
			displayLoaded = true;

		if(part.file != null){
			Localiser.instance.pushLocale();
			Localiser.instance.set_layoutPath(part.file);
		}
		else
			localeLoaded = true;

		if(currentElement != null && currentElement.isPattern())
			startPattern(cast(currentElement, Pattern));
		else{

			localeLoaded = true;
			checkPartLoaded();
		}

		/*for(key in layers.keys()){
			if(key != "ui"){
				addChild(layers.get(key).view);
			}
		}
		if(layers.exists("ui"))
			addChild(layers.get("ui").view);*/
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
	* @param    startIndex : Next element after this index
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/

	public function nextElement(startIndex:Int = -1):Void
	{
		currentElement = part.getNextElement(startIndex);

		if(currentElement == null){
			exitPart();
			return;
		}
		if(currentElement.endScreen)
			dispatchEvent(new GameEvent(GameEvent.GAME_OVER));

		if(currentElement.isText()){
			var groupKey = "";
			if(textGroups != null){

				for(key in textGroups.keys()){

					if(textGroups.get(key).exists(cast(currentElement, TextItem).ref)){

						groupKey = key;
					}
				}

				if(groupKey != ""){

					var isFirst = true;
					var textItem = null;
					for(keyG in textGroups.get(groupKey).keys()){
						if(!isFirst){
							textItem = cast(part.getNextElement(), TextItem);

						}
						else{
							textItem = cast(currentElement, TextItem);
						}
						setupTextItem(cast(textItem, TextItem), isFirst);
						isFirst = false;
					}
				}
				else{
					setupTextItem(cast(currentElement, TextItem));
				}

				GameManager.instance.playSound(cast(currentElement, TextItem).sound);
			}
		}

		else if(currentElement.isActivity()){
			GameManager.instance.displayActivity(cast(currentElement, Activity));
		}

		else if(currentElement.isPattern()){

			startPattern(cast(currentElement, Pattern));
		}

		else if(currentElement.isPart()){
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

		cast(part.elements[i], Pattern).itemIndex = 0;
		startPattern(cast(part.elements[i], Pattern));
	}

	// Privates

	/**
     * Unload the display from the scene
     */

	private function unLoad():Void
	{
		while(numChildren > 0){
			var child = getChildAt(numChildren - 1);
			removeChild(child);
			child = null;
		}
		while(numChildren > 0){
			var child = getChildAt(numChildren - 1);
			removeChild(child);
			child = null;
		}
		if(parent != null)
			parent.removeChild(this);
		currentElement = null;
		currentSpeaker = null;
		previousBackground = null;
		for(item in currentItems)
			item = null;
		currentItems = null;
		currentTextItem = null;
		inventory = null;
		itemSound = null;
		itemSoundChannel = null;
	}

	override private function createElement(elemNode:Fast):Void
	{
		if(elemNode.name.toLowerCase() == "inventory"){
			inventory = new InventoryDisplay(elemNode);
			inventory.init(part.tokens);
		}
		else if(elemNode.name.toLowerCase() == "intro"){
			var intro = new IntroScreen(elemNode);
			intro.z = zIndex;
			displays.set(elemNode.att.ref, intro);
			zIndex++;
		}
		else
			super.createElement(elemNode);
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

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		if(action.toLowerCase() == ButtonActionEvent.NEXT){
			button.buttonAction = next;
		}
		else if(action.toLowerCase() == "open_notebook"){
			button.buttonAction = function(?target: DefaultButton){
				NotebookDisplay.instance.model = Notebook.instance;
				GameManager.instance.displayContextual(NotebookDisplay.instance, NotebookDisplay.instance.layout);
			};
		}
		else if(action.toLowerCase() == ButtonActionEvent.GOTO){
			button.buttonAction = function(?target: DefaultButton){
				if(part.buttonTargets.get(button.ref) == null)
					exitPart();
				else
					nextElement(part.getElementIndex(part.buttonTargets.get(button.ref))-1);
			};
		}
	}

	private function displayBackground(background:String):Void
	{
		if(background != null && background != ""){
			var sameBackground = true;
			// Clean previous background
			if(previousBackground != null && previousBackground.ref != background){
				sameBackground = false;
				if(previousBackground.bmp != null)
					removeChild(previousBackground.bmp);
			}
			else if(previousBackground == null)
				sameBackground = false;
			// Add new background if different from previous one
			if(!sameBackground){
				if(!displays.exists(background))
					throw '[PartDisplay] There is no background with ref "$background"';
				var bkg:Image = cast(displays.get(background), Image);
				if(bkg != null){
					addChildAt(bkg, 0);
				}

				previousBackground = {ref: background, bmp: cast(bkg, Image)};
			}
		}
	}

	private function setSpeaker(author:String, ?transition:String):Void
	{
		if(currentSpeaker != null)
			TweenManager.stop(currentSpeaker, null, false, true);
		if(author != null && displays.exists(author)){
			if(!displays.exists(author))
				throw "[PartDisplay] There is no Character with ref " + author;
			var char = cast(displays.get(author), CharacterDisplay);

			if(char != currentSpeaker){
				if(currentSpeaker != null && !Std.is(this, StripDisplay)){
					removeChild(currentSpeaker);
				}
				else{
					char.alpha = 1;
                    //TODO Ajout transtion au charactere par kévin
                    char.transitionIn=transition;
					char.set_visible(true);
				}
				currentSpeaker = char;
                //TODO  Ajout transtion au charactere par kévin
                currentSpeaker.transitionIn=transition;
				currentSpeaker.set_visible(true);
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

	private function setupTextItem(item:TextItem, ?isFirst:Bool = true):Void
	{
		if(item == null)
			return;

		currentTextItem = item;

		var toRemove = new GenericStack<DisplayObject>();

		if(isFirst){

			displayBackground(item.background);

			for(i in 0...numChildren){
				if(Std.is(getChildAt(i), ScrollPanel))
					toRemove.add(getChildAt(i));
			}
			for(item in currentItems){
				toRemove.add(item);
			}
			for(obj in toRemove){
				if(contains(obj))
					removeChild(obj);
			}
		}

		setSpeaker(item.author, item.transition);
		if(item.introScreen != null){

			for(i in 0...numChildren){
				if(Std.is(getChildAt(i), DefaultButton))
					toRemove.add(getChildAt(i));
			}
			if(inventory != null && contains(inventory))
				toRemove.add(inventory);
			for(obj in toRemove){
				if(contains(obj))
					removeChild(obj);
			}

			// The intro screen automatically removes itself after its duration
			var intro = item.introScreen;
			var introDisplay:IntroScreen = cast(displays.get(intro.ref), IntroScreen);
			introDisplay.set_text(Localiser.instance.getItemContent(intro.content));
			introDisplay.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
			{
				introScreenOn = false;
				setText(item, isFirst);
			});
			introScreenOn = true;
			addChild(introDisplay);
		}
		else
			setText(item, isFirst);
	}

	private function setText(item:TextItem, isFirst:Bool = true):Void
	{
		var content = Localiser.get_instance().getItemContent(item.content);
		if(item.ref != null){
			if(!displays.exists(item.ref))
				throw "[PartDisplay] There is no TextArea with ref " + item.ref;
			cast(displays.get(item.ref), ScrollPanel).setContent(content);
		}

		if(!isFirst)
			addChild(cast(displays.get(item.ref), ScrollPanel));

		displayPart();
	}

	private function displayPart():Void
	{
		// Clean-up buttons
		var toRemove = new GenericStack<DisplayObject>();
		for(i in 0...numChildren){
			if(Std.is(getChildAt(i), DefaultButton))
				toRemove.add(getChildAt(i));
		}
		if(inventory != null && contains(inventory))
			toRemove.add(inventory);
		for(button in toRemove){
			removeChild(button);
		}

		var array = new Array<Widget>();

		for(key in displays.keys()){
			if(mustBeDisplayed(key))
				array.push(displays.get(key));
		}

		array.sort(sortDisplayObjects);
		for(obj in array){
			addChild(obj);
		}

		if(inventory != null && currentSpeaker != null)
			addChild(inventory);
	}

	private function sortDisplayObjects(x:Widget, y:Widget):Int
	{
		if(x.z < y.z)
			return -1;
		else if(x.z > y.z)
			return 1;
		else
			return 0;
	}

	private function mustBeDisplayed(key:String):Bool
	{
		var object = displays.get(key);
		if(Std.is(object, VideoPlayer)){
			return true;
		}

		// If the object is already displayed
		if(!Std.is(object, Image) && contains(object)){
			return false;
		}
		if(Std.is(object, DefaultButton)){

			var button: Map<String, Map<String, String>> = null;
			if(currentElement.isText())
				button = cast(currentElement, TextItem).button;
			else if(currentElement.isActivity())
				button = cast(currentElement, Activity).button;
			if(currentElement.isPattern())
				button = cast(currentElement, Pattern).buttons;

			if(button.exists(key)){
				for(contentKey in button.get(key).keys()){
					var targetedText: String = null;
					if(contentKey != " ")
						targetedText = contentKey;
					cast(displays.get(key), DefaultButton).setText(Localiser.instance.getItemContent(button.get(key).get(contentKey)), targetedText);
				}
				return true;
			}
			else
				return false;
		}
		// If the character is not the current speaker
		if(Std.is(object, CharacterDisplay) && object != currentSpeaker)
			return false;
		else if(Std.is(object, CharacterDisplay))
			return true;

		if(currentTextItem != null){

			if(currentSpeaker != null && Std.is(object, ScrollPanel) && key == currentSpeaker.nameRef)
				return true;
			if(Std.is(object, ScrollPanel) && key != currentTextItem.ref)
				return false;
			if(Std.is(object, Image)){
				var exists = false;
				for(item in currentTextItem.images){
					if(key == item){
						exists = true;
						if(Std.is(object, TileImage)){
							currentItems.add(object);

							cast(object, TileImage).set_visible(true);
						}
						else
							currentItems.add(object);
						break;
					}
				}

				return exists;
			}
		}
		return true;
	}
}