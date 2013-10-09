package com.knowledgeplayers.grar.display;

#if flash
import flash.system.System;
import flash.external.ExternalInterface;
#end
import com.knowledgeplayers.grar.display.contextual.InventoryDisplay;
import com.knowledgeplayers.grar.display.contextual.BibliographyDisplay;
import com.knowledgeplayers.grar.display.contextual.GlossaryDisplay;
import com.knowledgeplayers.grar.display.contextual.GlossaryDisplay;
import com.knowledgeplayers.grar.structure.contextual.Glossary;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.display.contextual.menu.MenuDisplay;
import com.knowledgeplayers.grar.tracking.Trackable;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.contextual.ContextualDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.element.TokenNotification;
import com.knowledgeplayers.grar.display.layout.Layout;
import com.knowledgeplayers.grar.display.LayoutManager;
import com.knowledgeplayers.grar.display.part.DialogDisplay;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.DisplayFactory;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.Token;
import com.knowledgeplayers.grar.util.KeyboardManager;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.Lib;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;

/**
 * Display of a game
 */
class GameManager extends EventDispatcher {
	/**
    * Instance of the game manager
    **/
	public static var instance (get_instance, null):GameManager;

	/**
     * The game model
     */
	public var game (default, default):Game;

	/**
     * Queue of parts managed in the game
     */
	public var parts (default, null):GenericStack<PartDisplay>;

	/**
    * Inventory of the game
    **/
	public var inventory (default, null):Map<String, Token>;

	/**
    * Notification display of a token
    **/
	public var tokenNotification:TokenNotification;

	/**
    * Tokens images
    **/
	public var tokensImages (default, null):Map<String, {small:BitmapData, large:BitmapData}>;

	public var menuLoaded (default, set_menuLoaded):Bool = false;

	/**
	* Current activity display
	**/
	public var activityDisplay (default, null):ActivityDisplay;

	private var layout:Layout;
	private var nbVolume:Float = 1;

	private var soundControl:SoundTransform;
	private var itemSound:Sound;
	private var itemSoundChannel:SoundChannel;
	private var startIndex:Int;
	private var previousLayout: String;
	private var lastContextual: KpDisplay;

		/**
    * @return the instance of the singleton
    **/

	public static function get_instance():GameManager
	{
		if(instance == null)
			instance = new GameManager();
		return instance;
	}

	/**
    * Start the game
    * @param    game : The game to start
    * @param    layout : The layout to display
    **/

	public function startGame(game:Game, layout:String = "default"):Void
	{
		this.game = game;
		changeLayout(layout);
		if(!MenuDisplay.instance.exists || menuLoaded){
			launchGame();
		}
	}

	/**
    * Activate a token of the inventory
    * @param    tokenName : Name of the token to activate
    **/

	public function activateToken(tokenName:String):Void
	{
		inventory.get(tokenName).isActivated = true;
		var tokenEvent = new TokenEvent(TokenEvent.ADD);

		if(tokenNotification != null){
			layout.zones.get(game.ref).addChild(tokenNotification);
			tokenNotification.showNotification(tokenName);
		}

		tokenEvent.token = inventory.get(tokenName);
		dispatchEvent(tokenEvent);
	}

	/**
    * Load the tokens descriptor file
    * @param    path : Path to the file
    **/

	public function loadTokens(path:String):Void
	{
		parseTokens(AssetsStorage.getXml(path));
	}

	public function set_menuLoaded(loaded:Bool):Bool
	{
		launchGame();
		return menuLoaded = loaded;
	}

	/**
    * Change the layout of the game
    **/

	public function changeLayout(layout:String):Void
	{
		if(layout == null)
			layout = "default";
		if(this.layout == null || layout != this.layout.name){
			previousLayout = this.layout == null ? "default" : this.layout.name;
			if(this.layout != null)
				Lib.current.removeChild(this.layout.content);
			this.layout = LayoutManager.instance.getLayout(layout);
			Lib.current.addChild(this.layout.content);
		}
		else
			previousLayout = this.layout == null ? "default" : this.layout.name;
	}

	/**
    * Change volume
    **/

	public function changeVolume(nb:Float = 0):Void
	{
		nbVolume = nb;
		if(itemSoundChannel != null){
			soundControl = itemSoundChannel.soundTransform;
			soundControl.volume = nbVolume;
			itemSoundChannel.soundTransform = soundControl;
		}
	}

	/**
    * Play a sound
    **/

	public function playSound(soundRef):Void
	{

		if(itemSoundChannel != null){
			itemSoundChannel.stop();
		}
		if(soundRef != null){
			itemSound = new Sound(new URLRequest(soundRef));
			itemSoundChannel = itemSound.play();
			changeVolume(nbVolume);

		}

	}

	/**
    * Display a graphic representation of the given part
    * @param    part : The part to display
    * @param    interrupt : Stop current part to display the new one
    **/

	public function displayPart(part:Part, interrupt:Bool = false, startPosition:Int = -1):Void
	{
		// TODO better user feedback
		if(!part.canStart())
			trace("Et non !");

		if(interrupt){
			var oldPart = parts.pop();
			if(oldPart != null){
				oldPart.removeEventListener(PartEvent.EXIT_PART, onExitPart);
				oldPart.exitPart();
			}
		}
		// Display the new part
		parts.add(DisplayFactory.createPartDisplay(part));
		startIndex = startPosition;
		parts.first().addEventListener(PartEvent.EXIT_PART, onExitPart);
		parts.first().addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
		parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		parts.first().addEventListener(GameEvent.GAME_OVER, function(e:GameEvent)
		{
			game.connection.tracking.setStatus(true);
			game.connection.computeTracking(game.stateInfos);
			dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
		});
		parts.first().init();
	}

	/**
    * Displays an activity
    * @param    activity : Activity model to display
    **/

	public function displayActivity(activity:Activity):Void
	{
		cleanup();
		activity.addEventListener(PartEvent.EXIT_PART, onActivityEnd);
		var activityName:String = Type.getClassName(Type.getClass(activity));
		activityName = activityName.substr(activityName.lastIndexOf(".") + 1);
		activityDisplay = ActivityManager.instance.getActivity(activityName);
		activityDisplay.model = activity;

		layout.zones.get(game.ref).addChild(activityDisplay);
		activityDisplay.startActivity();

	}

	/**
    * Display a graphic representation of the part with the given ID
    * @param id : The ID of the part to display
    **/

	public function displayPartById(?id:String, interrupt:Bool = false):Void
	{
		displayPart(game.start(id), interrupt);
	}

	public function displayTrackable(item: Trackable):Void
	{
		if(Std.is(item, Activity))
			displayActivity(cast(item,Activity));
		else if(Std.is(item, Part))
			displayPart(cast(item, Part), true);
	}

	public function displayContextual(contextual:ContextualDisplay, ?layout: String):Void
	{
		// Remove previous one
		if(lastContextual != null && this.layout.zones.get(game.ref).contains(lastContextual))
			hideContextual(cast(lastContextual, ContextualDisplay));
		// Change to selected layout
		if(layout != null)
			changeLayout(layout);
		this.layout.zones.get(game.ref).addChild(cast(contextual, KpDisplay));
		lastContextual = cast(contextual, KpDisplay);
	}

	public function hideContextual(contextual:ContextualDisplay):Void
	{
		this.layout.zones.get(game.ref).removeChild(cast(contextual, KpDisplay));
		changeLayout(previousLayout);
	}

	/**
	* Get the name link to this ID
	**/

	public function getItemName(id:String):String
	{
		if(game.getItemName(id) != null)
			return Localiser.instance.getItemContent(game.getItemName(id));
		else if(ActivityManager.instance.activities.get(id) != null)
			return Localiser.instance.getItemContent(ActivityManager.instance.activities.get(id).name);
		else
			throw "[GameManager] Unable to find the name of item \"" + id + "\".";
	}

	/**
	* End a part. Update internal state accordingly
	**/

	public function finishPart(partId:String):Void
	{
		game.stateInfos.setPartFinished(partId);
		var event = new PartEvent(PartEvent.EXIT_PART);
		event.partId = partId;
		dispatchEvent(event);
	}

	/**
	* Exit the app
	**/
	public function quitGame():Void
	{
		if (GameManager.instance.game.connection.tracking.suivi != "")
			GameManager.instance.game.connection.tracking.exitAU();

		#if flash
		if (ExternalInterface.available)
		{
			ExternalInterface.call("quitModule");
		}else
		{
			System.exit(0);
		}
		#end
	}

	// Privates

	private function launchGame():Void
	{
		var startingPart:String = null;
		if(game.stateInfos.bookmark > 0)
			startingPart = game.getAllItems()[game.stateInfos.bookmark].id;

		displayPartById(startingPart);
	}

	private function new()
	{
		super();
		parts = new GenericStack<PartDisplay>();
		inventory = new Map<String, Token>();
		tokensImages = new Map<String, {small:BitmapData, large:BitmapData}>();
		KeyboardManager.init();
	}

	private function parseTokens(tokens:Xml):Void
	{
		var tokenFast = new Fast(tokens.firstElement());
		parseDisplayTokens(AssetsStorage.getXml(tokenFast.att.display));
		for(token in tokenFast.nodes.Token){
			inventory.set(token.att.ref, new Token(token));
		}
	}

	private function parseDisplayTokens(display:Xml):Void
	{
		var fast = new Fast(display.firstElement());
		tokenNotification = new TokenNotification(fast.node.Hud);
		for(token in fast.nodes.Token){
			tokensImages.set(token.att.ref, {small:AssetsStorage.getBitmapData(token.att.src.substr(0, token.att.src.indexOf(","))), large: AssetsStorage.getBitmapData(token.att.src.substr(token.att.src.indexOf(",") + 1))});
		}
	}

	// Handlers

	private function onExitPart(event:Event):Void
	{
		finishPart(cast(event.target.part, Part).id);
		var finishedPart = parts.pop();
		if(finishedPart.part.parent == null){
			if(finishedPart.part.next != null){
				var next = game.start(finishedPart.part.next);
				if(next != null)
					displayPart(next);
				else{
					var contextual: ContextualType = Type.createEnum(ContextualType, finishedPart.part.next.toUpperCase());
					switch(contextual){
						case MENU : displayContextual(MenuDisplay.instance, MenuDisplay.instance.layout);
						case NOTEBOOK : displayContextual(NotebookDisplay.instance, NotebookDisplay.instance.layout);
						case GLOSSARY : displayContextual(GlossaryDisplay.instance, GlossaryDisplay.instance.layout);
						case BIBLIOGRAPHY : displayContextual(BibliographyDisplay.instance, BibliographyDisplay.instance.layout);
						// TODO à gérer
						case INVENTORY : null;
					}
				}
			}
			else
				dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
		}
		else if(!parts.isEmpty() && parts.first().part == finishedPart.part.parent){
			parts.first().visible = true;
			parts.first().nextElement();
		}
		else{
			displayPart(finishedPart.part.parent, false, finishedPart.part.parent.getElementIndex(finishedPart.part));
		}
	}

	private function onPartLoaded(event:PartEvent):Void
	{
		setBookmark(event.partId);
		var partDisplay = cast(event.target, PartDisplay);

		partDisplay.removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		partDisplay.startPart(startIndex);
		if(partDisplay.visible)
			changeLayout(partDisplay.layout);
		layout.zones.get(game.ref).addChild(partDisplay);
		layout.updateDynamicFields();
		var event = new PartEvent(PartEvent.ENTER_PART);
		event.part = partDisplay.part;
		dispatchEvent(event);
	}

	public function onEnterSubPart(event:PartEvent):Void
	{
		parts.first().visible = false;
		parts.first().removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		displayPartById(event.part.id);
	}

	private function onActivityEnd(e:PartEvent):Void
	{
		var activity:Activity = e.target;
		activity.removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
		if(activityDisplay != null && layout.zones.get(game.ref).contains(activityDisplay))
			layout.zones.get(game.ref).removeChild(activityDisplay);
		cleanup();
		if(parts != null){
			if(activity.nextPattern == null)
				parts.first().nextElement();
			else if(Std.is(parts.first(), DialogDisplay))
				cast(parts.first(), DialogDisplay).goToPattern(activity.nextPattern);

		}
	}

	private function cleanup():Void
	{
		if(activityDisplay != null){
			activityDisplay.model.removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
			activityDisplay.endActivity();
			activityDisplay = null;
		}
	}

	private function setBookmark(partId:String):Void
	{
		var i = 0;
		while(i < game.getAllItems().length && game.getAllItems()[i].id != partId){
			i++;
		}
		if(i < game.getAllItems().length){
			game.stateInfos.bookmark = i;
			game.connection.computeTracking(game.stateInfos);
		}
	}
}
