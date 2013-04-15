package com.knowledgeplayers.grar.display;

import nme.media.SoundChannel;
import nme.media.SoundTransform;
import nme.net.URLRequest;
import nme.media.Sound;
import nme.display.Bitmap;
import com.knowledgeplayers.grar.util.LoadData;
import nme.display.BitmapData;
import com.knowledgeplayers.grar.display.element.TokenNotification;
import nme.Lib;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.util.XmlLoader;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.structure.Token;
import haxe.FastList;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.layout.Layout;
import nme.events.EventDispatcher;
import nme.display.Sprite;
import com.knowledgeplayers.grar.util.KeyboardManager;
import com.knowledgeplayers.grar.display.LayoutManager;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.event.GameEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.DisplayFactory;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.events.Event;

/**
 * Display of a game
 */
class GameManager extends EventDispatcher {
	/**
    * Instance of the game manager
    **/
	public static var instance (getInstance, null):GameManager;

	/**
     * The game model
     */
	public var game (default, default):Game;

	/**
     * Queue of parts managed in the game
     */
	public var parts (default, null):FastList<PartDisplay>;

	/**
    * Inventory of the game
    **/
	public var inventory (default, null):Hash<Token>;

	/**
    * Notification display of a token
    **/
	public var tokenNotif:TokenNotification;

	/**
    * Tokens images
    **/
	public var tokensImages (default, null):Hash<BitmapData>;

	private var layout:Layout;
	private var activityDisplay:ActivityDisplay;
	private var navByMenu:Bool = false;
	private var nbVolume:Float = 1;

	private var controle:SoundTransform;
	private var itemSound:Sound;
	private var itemSoundChannel:SoundChannel;

	/**
    * @return the instance of the singleton
    **/

	public static function getInstance():GameManager
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
		displayPartById();
	}

	/**
    * Activate a token of the inventory
    * @param    tokenName : Name of the token to activate
    **/

	public function activateToken(tokenName:String):Void
	{
		inventory.get(tokenName).isActivated = true;
		var tokenEvent = new TokenEvent(TokenEvent.ADD);

		layout.zones.get(game.ref).addChild(tokenNotif);
		tokenNotif.showNotification(tokenName);

		tokenEvent.token = inventory.get(tokenName);
		dispatchEvent(tokenEvent);
	}

	/**
    * Load the tokens descriptor file
    * @param    path : Path to the file
    **/

	public function loadTokens(path:String):Void
	{
		XmlLoader.load(path, function(e:Event)
		{
			parseTokens(XmlLoader.getXml(e));
		}, parseTokens);
	}

	/**
    * Change the layout of the game
    **/

	public function changeLayout(layout:String):Void
	{
		if(this.layout != null)
			Lib.current.removeChild(this.layout.content);
		this.layout = LayoutManager.instance.getLayout(layout);
		Lib.current.addChild(this.layout.content);
	}

	/**
    * Change volume
    **/

	public function changeVolume(nb:Float = 0):Void
	{
		nbVolume = nb;
		if(itemSoundChannel != null){
			controle = itemSoundChannel.soundTransform;
			controle.volume = nbVolume;
			itemSoundChannel.soundTransform = controle;
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
    * @param part : The part to display
    **/

	public function displayPart(part:Part):Void
	{
		// Display the new part
		parts.add(DisplayFactory.createPartDisplay(part));
		if(parts.first() == null)
			dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
		else{
			parts.first().addEventListener(PartEvent.EXIT_PART, onExitPart);
			parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
			parts.first().addEventListener(PartEvent.ENTER_SUB_PART, onEnterSubPart);
			parts.first().init();
		}
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
		activityDisplay.addEventListener(Event.COMPLETE, onActivityReady);
		activityDisplay.model = activity;

	}

	/**
    * Display a graphic representation of the part with the given ID
    * @param id : The ID of the part to display
    **/

	public function displayPartById(?id:String):Void
	{
		displayPart(game.start(id));
	}

	public function getItemName(id:String):String
	{
		return game.getItemName(id) != null ? game.getItemName(id) : ActivityManager.instance.activities.get(id).name;
	}

	// Privates

	private function new()
	{
		super();
		parts = new FastList<PartDisplay>();
		inventory = new Hash<Token>();
		tokensImages = new Hash<BitmapData>();
		// Set Keyboard Manager
		KeyboardManager.instance.game = this;
	}

	private function parseTokens(tokens:Xml):Void
	{
		var tokenFast = new Fast(tokens.firstElement());
		XmlLoader.load(tokenFast.att.display, function(e:Event)
		{
			parseDisplayTokens(XmlLoader.getXml(e));
		}, parseDisplayTokens);
		for(token in tokenFast.nodes.Token){
			inventory.set(token.att.ref, new Token(token));
		}
	}

	private function parseDisplayTokens(display:Xml):Void
	{
		var fast = new Fast(display.firstElement());
		tokenNotif = new TokenNotification(fast.node.Hud);
		for(token in fast.nodes.Token){
			tokensImages.set(token.att.ref, cast(LoadData.instance.getElementDisplayInCache(token.att.src), Bitmap).bitmapData);
		}
	}

	// Handlers

	private function onExitPart(event:Event):Void
	{
		parts.first().unLoad();
		parts.pop();
		// Display next part
		displayPartById();
	}

	private function onPartLoaded(event:PartEvent):Void
	{
		var partDisplay = cast(event.target, PartDisplay);
		partDisplay.removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		partDisplay.startPart();
		layout.zones.get(game.ref).addChild(partDisplay);
	}

	private function onExitSubPart(event:PartEvent):Void
	{
		parts.first().unLoad();
		layout.zones.get(game.ref).removeChild(parts.pop());
		parts.first().visible = true;
		parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		parts.first().nextElement();
	}

	public function onEnterSubPart(event:PartEvent):Void
	{
		parts.first().visible = false;
		parts.first().removeEventListener(PartEvent.PART_LOADED, onPartLoaded);
		parts.add(DisplayFactory.createPartDisplay(event.part));
		parts.first().addEventListener(PartEvent.EXIT_PART, onExitSubPart);
		parts.first().addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		parts.first().init();
	}

	private function onActivityReady(e:Event):Void
	{
		activityDisplay.removeEventListener(Event.COMPLETE, onActivityReady);
		layout.zones.get(game.ref).addChild(activityDisplay);
		activityDisplay.startActivity();
	}

	private function onActivityEnd(e:PartEvent):Void
	{
		e.target.removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
		if(activityDisplay != null && layout.zones.get(game.ref).contains(activityDisplay))
			layout.zones.get(game.ref).removeChild(activityDisplay);
		cleanup();
		if(parts != null && !navByMenu){
			parts.first().nextElement();
		}
		else
			navByMenu = false;
	}

	private function cleanup():Void
	{
		if(activityDisplay != null){
			activityDisplay.model.removeEventListener(PartEvent.EXIT_PART, onActivityEnd);
			activityDisplay.endActivity();
			navByMenu = true;
			activityDisplay = null;
		}
	}
}
