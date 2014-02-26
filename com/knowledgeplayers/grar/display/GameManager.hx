package com.knowledgeplayers.grar.display;

#if flash
import flash.system.System;
import flash.external.ExternalInterface;
#end
import flash.net.URLRequest;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.contextual.BibliographyDisplay;
import com.knowledgeplayers.grar.display.contextual.GlossaryDisplay;
import com.knowledgeplayers.grar.display.contextual.GlossaryDisplay;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.display.contextual.menu.MenuDisplay;
import com.knowledgeplayers.grar.tracking.Trackable;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.contextual.ContextualDisplay;
import com.knowledgeplayers.grar.display.element.TokenNotification;
import com.knowledgeplayers.grar.display.layout.Layout;
import com.knowledgeplayers.grar.display.LayoutManager;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.DisplayFactory;
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
	// TODO Refactor inventory
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

	public var layout(default,null):Layout;
	private var previousLayout: String;

	private var nbVolume:Float = 1;
	private var itemSoundChannel:SoundChannel;

	private var startIndex:Int;
	private var lastContextual: KpDisplay;
	private var sounds:Map<String, Sound>;

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
		if(!inventory.exists(tokenName))
			throw '[GameManager] Unknown token "$tokenName".';
		inventory.get(tokenName).isActivated = true;
		var tokenEvent = new TokenEvent(TokenEvent.ADD);

		if(tokenNotification != null){
			layout.zones.get(game.ref).addChild(tokenNotification);
			tokenNotification.setToken(tokenName);
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
			if(this.layout == null)
				throw "[GameManager] There is no layout '"+layout+"'.";
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
			var soundControl = itemSoundChannel.soundTransform;
			soundControl.volume = nbVolume;
			itemSoundChannel.soundTransform = soundControl;
		}
	}

	/**
	* Pre load a sound. Then use playSound with the same url to play it
	* @param soundUrl : Path to the sound file
	**/
	public function loadSound(soundUrl:String):Void
	{
		if(soundUrl != null && soundUrl != ""){
			var sound = new Sound(new URLRequest(soundUrl));
			sounds.set(soundUrl, sound);
		}
	}

	/**
    * Play a sound. May cause error if the sound is not preloaded with loadSound()
    * @param soundUrl : Path to the sound file
    **/
	public function playSound(soundUrl: String):Void
	{
		if(soundUrl != null){
			stopSound();
			if(!sounds.exists(soundUrl))
				loadSound(soundUrl);
			itemSoundChannel = sounds.get(soundUrl).play();
		}
	}

	/**
	* Stop currently playing sound
	**/
	public function stopSound():Void
	{
		if(itemSoundChannel != null)
			itemSoundChannel.stop();
	}

	/**
    * Display a graphic representation of the given part
    * @param    part : The part to display
    * @param    interrupt : Stop current part to display the new one
    * @return true if the part can be displayed.
    **/
	public function displayPart(part:Part, interrupt:Bool = false, startPosition:Int = -1):Bool
	{
		#if !kpdebug
		// Part doesn't meet the requirements to start
		if(!part.canStart())
			return false;
		#end

		if(interrupt){
			var oldPart = parts.pop();
			if(oldPart != null){
				oldPart.removeEventListener(PartEvent.EXIT_PART, onExitPart);
				oldPart.exitPart();
			}
		}
		if(!parts.isEmpty())
			parts.first().removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		// Display the new part
		var newPart: PartDisplay = DisplayFactory.createPartDisplay(part);
		parts.add(newPart);
		startIndex = startPosition;
		newPart.addEventListener(PartEvent.EXIT_PART, onExitPart);
		newPart.addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
		newPart.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		var endListener: GameEvent -> Void = null;
		endListener = function(e:GameEvent)
		{
			game.connection.tracking.setStatus(true);
			game.connection.computeTracking(game.stateInfos);
			dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
		}
		newPart.addEventListener(GameEvent.GAME_OVER, endListener);
		newPart.init();
		return true;
	}

	/**
    * Display a graphic representation of the part with the given ID
    * @param id : The ID of the part to display
    * @return true if the part can be displayed.
    **/
	public function displayPartById(?id:String, interrupt:Bool = false):Bool
	{
		return displayPart(game.start(id), interrupt);
	}

	public function displayTrackable(item: Trackable):Bool
	{
		if(Std.is(item, Part))
			return displayPart(cast(item, Part), true);
		else
			return false;
	}

	public function displayContextual(contextual:ContextualDisplay, ?layout: String, hideOther: Bool = true):Void
	{
		// Remove previous one
		if(hideOther && lastContextual != null && this.layout.zones.get(game.ref).contains(lastContextual) && !parts.isEmpty())
			hideContextual(cast(lastContextual, ContextualDisplay));
		// Change to selected layout
		if(layout != null)
			changeLayout(layout);
		this.layout.zones.get(game.ref).addChild(cast(contextual, KpDisplay));
		lastContextual = cast(contextual, KpDisplay);
		this.layout.updateDynamicFields();
	}

	public function hideContextual(contextual:ContextualDisplay):Void
	{
		if(layout.name == contextual.layout){
			layout.zones.get(game.ref).removeChild(cast(contextual, KpDisplay));
			changeLayout(previousLayout);
		}
	}

	/**
	* Get the name link to this ID
	**/

	public function getItemName(id:String):String
	{
		var name = game.getItemName(id);
		if(name != null)
			return Localiser.instance.getItemContent(name);
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

	private function parseTokens(tokens:Xml):Void
	{
		var tokenFast = new Fast(tokens.firstElement());
		parseDisplayTokens(AssetsStorage.getXml(tokenFast.att.display));
		for(token in tokenFast.nodes.Token){
			inventory.set(token.att.id, new Token(token));
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

		if(finishedPart.part.next != null && finishedPart.part.next != ""){
			var nexts = ParseUtils.parseStringArray(finishedPart.part.next);
			var i = 0;
			for(next in nexts){
				var nextPart: Part = game.start(next);
				if(nextPart != null)
					displayPart(nextPart, nextPart.elemIndex);
				else{
					var contextual: ContextualType = Type.createEnum(ContextualType, next.toUpperCase());
					switch(contextual){
		case MENU : displayContextual(MenuDisplay.instance, MenuDisplay.instance.layout, (i == 0));
						case NOTEBOOK : displayContextual(NotebookDisplay.instance, NotebookDisplay.instance.layout, (i == 0));
						case GLOSSARY : displayContextual(GlossaryDisplay.instance, GlossaryDisplay.instance.layout, (i == 0));
						case BIBLIOGRAPHY : displayContextual(BibliographyDisplay.instance, BibliographyDisplay.instance.layout, (i == 0));
						// TODO à gérer
						case INVENTORY : null;
					}
				}
				i++;
			}
		}
		else if(!parts.isEmpty() && parts.first().part == finishedPart.part.parent){
			parts.first().visible = true;
			parts.first().nextElement();
			// if this part is not finished too
			if(parts.first() != null)
				changeLayout(parts.first().layout);
		}
		else
			dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
	}

	public inline function onEnterSubPart(e:PartEvent):Void
	{
		displayPartById(e.part.id);
	}

	private function onPartLoaded(e:PartEvent):Void
	{
		setBookmark(e.partId);
		var partDisplay = cast(e.target, PartDisplay);

		partDisplay.removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		partDisplay.startPart(startIndex);
		if(partDisplay.visible && partDisplay.layout != null)
			changeLayout(partDisplay.layout);
		layout.zones.get(game.ref).addChild(partDisplay);
		layout.updateDynamicFields();
		var event = new PartEvent(PartEvent.ENTER_PART);
		event.part = partDisplay.part;
		dispatchEvent(event);
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

	private function new()
	{
		super();
		parts = new GenericStack<PartDisplay>();
		inventory = new Map<String, Token>();
		tokensImages = new Map<String, {small:BitmapData, large:BitmapData}>();
		sounds = new Map<String, Sound>();
		KeyboardManager.init();
	}
}
