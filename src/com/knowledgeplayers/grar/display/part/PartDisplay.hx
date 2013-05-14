package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.contextual.InventoryDisplay;
import com.knowledgeplayers.grar.display.element.CharacterDisplay;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.ResizeManager;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.util.XmlLoader;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.FastList;
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

	/**
    * Transition to play at the beginning of the part
    **/
	public var transitionIn (default, default):String;

	/**
    * Transition to play at the end of the part
    **/
	public var transitionOut (default, default):String;

	private var currentElement:PartElement;
	private var resizeD:ResizeManager;
	private var currentSpeaker:CharacterDisplay;
	private var previousBackground:{ref:String, bmp:Bitmap};
	private var displayArea:Sprite;
	private var localeLoaded:Bool = false;
	private var displayLoaded:Bool = false;
	private var currentItems:FastList<DisplayObject>;
	private var currentTextItem:TextItem;
	private var inventory:InventoryDisplay;
	private var itemSound:Sound;
	private var itemSoundChannel:SoundChannel;
	private var transitions:Array<{obj:DisplayObject, tween:String}>;

	/**
     * Constructor
     * @param	part : Part to display
     */

	public function new(part:Part)
	{
		super();
		this.part = part;

		resizeD = ResizeManager.getInstance();
		currentItems = new FastList<DisplayObject>();
		transitions = new Array<{obj:DisplayObject, tween:String}>();
		displayArea = this;
	}

	/**
    * Initialize the part display. Dispatch a PartEvent.PART_LOADED
    * when ready.
    **/

	public function init():Void
	{

		XmlLoader.load(part.display, onLoadComplete, parseContent);
		Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleLoaded);
		Localiser.instance.pushLocale();
		Localiser.instance.setLayoutFile(part.file);
	}

	public function exitPart():Void
	{
		part.end();
		unLoad();
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
			if(Localiser.instance.layoutPath != part.file){
				Localiser.instance.addEventListener(LocaleEvent.LOCALE_LOADED, onLocaleLoaded);
				Localiser.instance.setLayoutFile(part.file);
			}
			else
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
		//GameManager.instance.game.start(part.id);
		TweenManager.applyTransition(this, transitionIn);
		nextElement(startPosition);
	}

	override public function parseContent(content:Xml):Void
	{
		super.parseContent(content);

		if(displayFast.has.transitionIn)
			transitionIn = displayFast.att.transitionIn;
		if(displayFast.has.transitionOut)
			transitionOut = displayFast.att.transitionOut;

	}

	// Privates

	/**
     * Unload the display from the scene
     */

	private function unLoad():Void
	{
		while(displayArea.numChildren > 0){
			var child = getChildAt(displayArea.numChildren - 1);
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
		for(transition in transitions)
			transition = null;
		transitions = null;
	}

	override private function createElement(elemNode:Fast):Void
	{
		if(elemNode.name.toLowerCase() == "inventory"){
			inventory = new InventoryDisplay(elemNode);
			inventory.init(part.tokens);
		}
		else if(elemNode.name.toLowerCase() == "intro"){
			displays.set(elemNode.att.ref, {obj: new IntroScreen(elemNode), z: zIndex});
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

	private function next(event:ButtonActionEvent):Void
	{
		nextElement();
	}

	private function startPattern(pattern:Pattern):Void
	{
		currentElement = pattern;
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		if(action.toLowerCase() == ButtonActionEvent.NEXT){
			button.addEventListener(ButtonActionEvent.NEXT, next);
		}
	}

	private function displayBackground(background:String):Void
	{
		var sameBackground = true;
		// Clean previous background
		if(previousBackground != null && previousBackground.ref != background){
			sameBackground = false;
			if(previousBackground.bmp != null)
				displayArea.removeChild(previousBackground.bmp);
		}
		else if(previousBackground == null)
			sameBackground = false;
		// Add new background if different from previous one
		if(!sameBackground && background != null){
			if(!displaysFast.exists(background))
				throw "[PartDisplay] There is no background with ref " + background;
			var fastBkg = displaysFast.get(background);
			var bkg:DisplayObject = new Bitmap(AssetsStorage.getBitmapData(fastBkg.att.src));

			initDisplayObject(bkg, displaysFast.get(background));
			if(bkg != null){
				displayArea.addChildAt(bkg, 0);
				resizeD.addDisplayObjects(bkg, displaysFast.get(background));
			}

			if(fastBkg.has.tween)
				transitions.push({obj: bkg, tween: fastBkg.att.tween});

			previousBackground = {ref: background, bmp: cast(bkg, Bitmap)};
		}
	}

	private function setSpeaker(author:String, ?transition:String):Void
	{
		if(currentSpeaker != null)
			TweenManager.stop(currentSpeaker, null, false, true);
		if(author != null && displays.exists(author)){
			if(!displays.exists(author))
				throw "[PartDisplay] There is no Character with ref " + author;
			var char = cast(displays.get(author).obj, CharacterDisplay);

			if(char != currentSpeaker){
				if(currentSpeaker != null && !Std.is(this, StripDisplay)){
					displayArea.removeChild(currentSpeaker);
				}
				else{
					char.alpha = 1;
					char.visible = true;
				}
				currentSpeaker = char;

				currentSpeaker.visible = true;
				if(!displays.exists(char.nameRef))
					throw "[PartDisplay] There is no TextArea with ref " + char.nameRef;
				cast(displays.get(char.nameRef).obj, ScrollPanel).setContent(currentSpeaker.model.getName());
			}
			else
				currentSpeaker.reset();

			transitions.push({obj: currentSpeaker, tween: transition});
		}
		else if(currentSpeaker != null && displayArea.contains(currentSpeaker)){
			displayArea.removeChild(currentSpeaker);
			currentSpeaker = null;
		}
	}

	private function setupTextItem(item:TextItem, ?isFirst:Bool = true):Void
	{
		currentTextItem = item;

		var toRemove = new FastList<DisplayObject>();

		if(isFirst){

			displayBackground(item.background);

			for(i in 0...numChildren){
				if(Std.is(getChildAt(i), ScrollPanel))
					toRemove.add(getChildAt(i));
			}
			for(item in currentItems)
				toRemove.add(item);
			for(obj in toRemove){
				if(displayArea.contains(obj))
					displayArea.removeChild(obj);
			}

		}

		setSpeaker(item.author, item.transition);

		if(item.introScreen != null){

			for(i in 0...numChildren){
				if(Std.is(getChildAt(i), DefaultButton))
					toRemove.add(getChildAt(i));
			}
			if(inventory != null && displayArea.contains(inventory))
				toRemove.add(inventory);
			for(obj in toRemove){
				if(displayArea.contains(obj))
					displayArea.removeChild(obj);
			}

			// The intro screen automatically removes itself after its duration
			var intro = item.introScreen;
			var introDisplay:IntroScreen = cast(displays.get(intro.ref).obj, IntroScreen);
			introDisplay.setText(Localiser.instance.getItemContent(intro.content));
			introDisplay.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
			{
				setText(item, isFirst);
			});

			displayArea.addChild(introDisplay);
		}
		else
			setText(item, isFirst);
	}

	private function setText(item:TextItem, ?isFirst:Bool = true):Void
	{
		var content = Localiser.getInstance().getItemContent(item.content);
		if(item.ref != null){
			if(!displays.exists(item.ref))
				throw "[PartDisplay] There is no TextArea with ref " + item.ref;
			cast(displays.get(item.ref).obj, ScrollPanel).setContent(content);// + " " + item.content);
		}

		if(!isFirst)
			displayArea.addChild(cast(displays.get(item.ref).obj, ScrollPanel));

		displayPart();
	}

	private function displayPart():Void
	{
		// Clean-up buttons
		var toRemove = new FastList<DisplayObject>();
		for(i in 0...numChildren){
			if(Std.is(getChildAt(i), DefaultButton))
				toRemove.add(getChildAt(i));
		}
		if(inventory != null && displayArea.contains(inventory))
			toRemove.add(inventory);
		for(button in toRemove){
			displayArea.removeChild(button);
		}

		var array = new Array<{obj:DisplayObject, z:Int}>();

		for(key in displays.keys()){
			if(mustBeDisplayed(key))
				array.push(displays.get(key));
		}

		array.sort(sortDisplayObjects);
		for(obj in array){
			displayArea.addChild(obj.obj);
		}

		for(layer in layers){
			layer.render();
		}

		for(tween in transitions){
			TweenManager.applyTransition(tween.obj, tween.tween);
			tween = null;
		}
		transitions = new Array<{obj:DisplayObject, tween:String}>();

		if(inventory != null && currentSpeaker != null)
			displayArea.addChild(inventory);
	}

	private function sortDisplayObjects(x:{obj:DisplayObject, z:Int}, y:{obj:DisplayObject, z:Int}):Int
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

		// If the object is already displayed
		if(contains(object.obj))
			return false;

		if(Std.is(object.obj, DefaultButton)){
			if(currentElement.isPattern()){
				var pattern = cast(currentElement, Pattern);
				if(pattern.buttons.exists(key)){
					for(contentKey in pattern.buttons.get(key).keys()){
						cast(displays.get(key).obj, DefaultButton).setText(Localiser.instance.getItemContent(pattern.buttons.get(key).get(contentKey)), contentKey);
					}
					return true;
				}
				else
					return false;
			}
			else{
				var button = null;
				if(currentElement.isText())
					button = cast(currentElement, TextItem).button;
				else if(currentElement.isActivity())
					button = cast(currentElement, Activity).button;

				if(button.ref == key){
					for(contentKey in button.content.keys()){
						cast(displays.get(key).obj, DefaultButton).setText(Localiser.instance.getItemContent(button.content.get(contentKey)), contentKey);
					}

					return true;
				}
				else if(button.ref == key)
					return true;
				else
					return false;
			}
		}
		// If the character is not the current speaker
		if(Std.is(object.obj, CharacterDisplay) && object.obj != currentSpeaker)
			return false;

		// If the text area is not referenced by the current text item
		if(currentTextItem != null){
			if(currentSpeaker != null && Std.is(object.obj, ScrollPanel) && key == currentSpeaker.nameRef)
				return true;
			if(Std.is(object.obj, ScrollPanel) && key != currentTextItem.ref)
				return false;
			if(!Std.is(object.obj, ScrollPanel) && !Std.is(object.obj, CharacterDisplay)){
				var exists = false;
				for(item in currentTextItem.items){
					if(key == item){
						exists = true;

						if(displaysFast.get(item).has.tween){
							cast(displays.get(item).obj, Sprite).x = Std.parseFloat(displaysFast.get(item).att.x);
							cast(displays.get(item).obj, Sprite).y = Std.parseFloat(displaysFast.get(item).att.y);

							transitions.push({obj: displays.get(item).obj, tween: displaysFast.get(item).att.tween});
						}

						currentItems.add(object.obj);
					}
				}
				return exists;
			}
		}

		return true;
	}

	// Handlers

	private function onLoadComplete(event:Event):Void
	{
		parseContent(XmlLoader.getXml(event));
	}

	private function onLocaleLoaded(ev:LocaleEvent):Void
	{
		Localiser.instance.removeEventListener(LocaleEvent.LOCALE_LOADED, onLocaleLoaded);
		if(currentElement != null && currentElement.isPattern())
			startPattern(cast(currentElement, Pattern));
		else{
			localeLoaded = true;
			checkPartLoaded();
		}
	}
}