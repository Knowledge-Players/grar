package com.knowledgeplayers.grar.display.part;

import nme.media.SoundChannel;
import nme.net.URLRequest;
import nme.media.Sound;
import com.knowledgeplayers.grar.display.contextual.InventoryDisplay;
import com.knowledgeplayers.grar.display.GameManager;
import aze.display.TileSprite;
import aze.display.TileLayer;
import aze.display.SparrowTilesheet;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.element.CharacterDisplay;
import com.knowledgeplayers.grar.display.ResizeManager;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.LocaleEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.util.LoadData;
import com.knowledgeplayers.grar.util.XmlLoader;
import com.knowledgeplayers.grar.display.TweenManager;
import haxe.FastList;
import haxe.xml.Fast;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Point;
import nme.Lib;

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

	private var resizeD:ResizeManager;
	private var currentSpeaker:CharacterDisplay;
	private var previousBackground:{ref:String, bmp:Bitmap};
	private var displayArea:Sprite;
	private var currentElement:PartElement;
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
		Localiser.instance.setLayoutFile(part.file);
	}

	/**
     * Unload the display from the scene
     */

	public function unLoad():Void
	{
		while(numChildren > 0)
			removeChildAt(numChildren - 1);
	}

	/**
    * @return the TextItem in the part or null if there is an activity or the part is over
    **/

	public function nextElement():Void
	{
		currentElement = part.getNextElement();
		if(currentElement == null){
			dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
			return;
		}

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
    **/

	public function startPart():Void
	{
		TweenManager.applyTransition(this, transitionIn);
		nextElement();
	}

	override public function parseContent(content:Xml):Void
	{
		super.parseContent(content);

		if(displayFast.has.transitionIn)
			transitionIn = displayFast.att.transitionIn;
		if(displayFast.has.transitionOut)
			transitionOut = displayFast.att.transitionOut;

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
		if(localeLoaded && displayLoaded)
			dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
	}

	private function next(event:ButtonActionEvent):Void
	{
		nextElement();
	}

	private function startPattern(pattern:Pattern):Void
	{
		currentElement = pattern;
	}

	override private function setButtonAction(button:CustomEventButton, action:String):Void
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
			var bkg = new Bitmap(cast(LoadData.getInstance().getElementDisplayInCache(fastBkg.att.src), Bitmap).bitmapData);

			initDisplayObject(bkg, displaysFast.get(background));
			if(bkg != null){
				displayArea.addChildAt(bkg, 0);
				resizeD.addDisplayObjects(bkg, displaysFast.get(background));
			}

			if(fastBkg.has.tween)
				transitions.push({obj: bkg, tween: fastBkg.att.tween});

			previousBackground = {ref: background, bmp: bkg};
		}
	}

	private function setSpeaker(author:String, ?transition:String):Void
	{
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
				transitions.push({obj: currentSpeaker, tween: transition});

				currentSpeaker.visible = true;
				if(!displays.exists(char.nameRef))
					throw "[PartDisplay] There is no TextArea with ref " + char.nameRef;
				cast(displays.get(char.nameRef).obj, ScrollPanel).setContent(currentSpeaker.model.getName());
			}
		}
	}

	private function setupTextItem(item:TextItem, ?isFirst:Bool = true):Void
	{
		currentTextItem = item;
		displayBackground(item.background);

		var toRemove = new FastList<DisplayObject>();

		if(isFirst){
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
			cast(displays.get(item.ref).obj, ScrollPanel).setContent(content + " " + item.content);
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
		}
		transitions = new Array<{obj:DisplayObject, tween:String}>();

		if(inventory != null)
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
				if(Std.is(displays.get(key).obj, TextButton)){
					if(pattern.buttons.exists(key)){
						cast(displays.get(key).obj, TextButton).setText(Localiser.instance.getItemContent(pattern.buttons.get(key)));
						return true;
					}
					else
						return false;
				}
			}
			else{
				var button = null;
				if(currentElement.isText())
					button = cast(currentElement, TextItem).button;
				else if(currentElement.isActivity())
					button = cast(currentElement, Activity).button;

				if(button.ref == key && Std.is(object.obj, TextButton)){
					cast(displays.get(key).obj, TextButton).setText(Localiser.instance.getItemContent(button.content));
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
					if(key == item.ref){
						exists = true;
						if(item.transition != null)
							TweenManager.applyTransition(displays.get(item.ref).obj, item.transition);
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