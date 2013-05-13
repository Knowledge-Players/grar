package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.structure.part.PartElement;
import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.FastList;
import com.knowledgeplayers.grar.display.GameManager;
import com.eclecticdesignstudio.motion.Actuate;
import nme.events.TimerEvent;
import nme.utils.Timer;
import nme.Assets;
import com.knowledgeplayers.grar.display.LayoutManager;
import nme.Assets;
import com.knowledgeplayers.grar.display.style.StyleParser;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.display.activity.ActivityManager;
import com.knowledgeplayers.grar.display.TweenManager;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.PartFactory;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.tracking.Connection;
import com.knowledgeplayers.grar.tracking.StateInfos;
import com.knowledgeplayers.grar.util.XmlLoader;
import haxe.xml.Fast;
import nme.events.Event;
import nme.events.EventDispatcher;
import nme.Lib;
import nme.net.URLLoader;

/**
 * KP inmplentation of a game
 */
class KpGame extends EventDispatcher, implements Game {
	/**
     * Connection mode
     */
	public var mode (default, default):Mode;

	/**
     * Game title
     */
	public var title (default, default):String;

	/**
     * State of the game
     */
	public var state (default, default):String;

	/**
     * Global inventory
     */
	public var inventory (default, null):Array<Token>;

	/**
    * Reference for the layout
    **/
	public var ref (default, default):String;

	/**
    * Xml describing the menu
    **/
	public var menu (default, default):Xml;

	/**
	* Tracking infos
	**/
	public var stateInfos (default, null):StateInfos;

	/**
	* Connection with the LMS
	**/
	public var connection (default, null):Connection;

	/**
    * Index of the current part
    **/
	private var partIndex:Int = 0;
	private var structureXml:Fast;
	private var languages:Hash<String>;
	private var flags:Hash<String>;
	private var parts:Array<Part>;
	private var nbPartsLoaded:Int = 0;
	private var layoutLoaded:Bool = false;
	private var numStyleSheet:Int = 0;
	private var numStyleSheetLoaded:Int = 0;
	private var activitiesWaiting:FastList<Xml>;

	/**
    * Constructor.
    * Register the game to the GameManager
    **/

	public function new()
	{
		super();
		languages = new Hash<String>();
		flags = new Hash<String>();
		parts = new Array<Part>();
		inventory = new Array<Token>();
		activitiesWaiting = new FastList<Xml>();

		GameManager.instance.game = this;

		Lib.current.stage.addEventListener(Event.DEACTIVATE, onExit);
		LayoutManager.instance.addEventListener(PartEvent.PART_LOADED, onPartLoaded);

	}

	/**
     * Initialize the game with a xml structure
     * @param	xml : the structure
     */

	public function init(xml:Xml):Void
	{
		structureXml = new Fast(xml);

		var displayNode:Fast = structureXml.node.Grar.node.Display;
		var parametersNode:Fast = structureXml.node.Grar.node.Parameters;
		var displayNode:Fast = structureXml.node.Grar.node.Display;

		mode = Type.createEnum(Mode, parametersNode.node.Mode.innerData);
		title = parametersNode.node.Title.innerData;
		state = parametersNode.node.State.innerData;

		// Load styles
		for(stylesheet in displayNode.nodes.Style){
			numStyleSheet++;
			XmlLoader.load(stylesheet.att.file, function(e:Event)
			{
				onStyleLoaded(XmlLoader.getXml(e));
			}, onStyleLoaded);
		}

		// Load Languages
		XmlLoader.load(parametersNode.node.Languages.att.file, onLanguagesComplete, initLangs);

		// Load UI
		UiFactory.setSpriteSheet(displayNode.node.Ui.att.display);

		// Load Transition
		if(displayNode.hasNode.Transitions)
			TweenManager.loadTemplate(displayNode.node.Transitions.att.display);

		// Load Activities displays
		for(activity in displayNode.nodes.Activity){
			var activityXml = XmlLoader.load(activity.att.display, onActivityComplete, initActivities);
		}

		// Load Parts
		var structureNode:Fast = structureXml.node.Grar.node.Structure;
		GameManager.instance.loadTokens(structureNode.att.inventory);
		if(structureNode.has.menu){
			XmlLoader.load(structureNode.att.menu, function(e:Event)
			{
				menu = XmlLoader.getXml(e);
			}, function(xml:Xml)
			{
				menu = xml;
			});
		}
		ref = structureNode.att.ref;
		for(part in structureNode.nodes.Part){
			addPartFromXml(part.att.id, part);
		}
	}

	/**
     * Start the game
     * @param	partId : the ID of the part to start.
     * @return 	the part with id partId or null if this part doesn't exist
     */

	public function start(?partId:String):Null<Part>
	{
		var nextPart:Part = null;
		if(partId == null && partIndex < getAllParts().length){
			do{
				nextPart = getAllParts()[partIndex].start();
				partIndex++;
			}
			while(nextPart.isDone);
		}
		else if(partId != null){
			var i:Int = 0;
			for(part in getAllParts()){
				if(part.id == partId){
					partIndex = i + 1;
					nextPart = part.start();
				}
				i++;
			}
		}
		return nextPart;
	}

	/**
     * Add a part to the game at partIndex
     * @param	partId : ID of the part
     * @param	part : the part to add
     */

	public function addPart(partId:String, part:Part):Void
	{
		part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		parts.push(part);
	}

	/**
     * Add a language to the game
     * @param	value : name of the language
     * @param	path : path to the localisation folder
     * @param	flagIconPath : path to the flag for this language
     */

	public function addLanguage(value:String, path:String, flagIconPath:String):Void
	{
		Localiser.getInstance().localisations.set(value, path);
		flags.set(value, flagIconPath);
	}

	/**
     * @return a string-based representation of the game
     */

	override public function toString():String
	{
		return title + " - " + mode + " - " + state + ". Parts: \n\t" + parts.toString();
	}

	/**
     * Start the tracking
     * @param	mode : tracking mode (SCORM/AICC)
     */

	public function initTracking(?mode:Mode):Void
	{
		connection = new Connection();
		if(mode != null)
			this.mode = mode;
		connection.initConnection(this.mode);
		stateInfos = connection.revertTracking();
		if(stateInfos.isEmpty()){
			stateInfos.loadStateInfos(state);
		}
		Localiser.instance.setCurrentLocale(stateInfos.currentLanguage);
	}

	/**
     * Get the state of loading of the game
     * @return a float between 0 (nothing loaded) and 1 (everything's loaded)
     */

	public function getLoadingCompletion():Float
	{
		// TODO crawl XML to know how many parts there is
		//return nbPartsLoaded / getAllParts().length;
		//return nbPartsLoaded / stateInfos.checksum;
		return nbPartsLoaded / parts.length;
	}

	/**
     * @return all the parts of the game
     */

	public function getAllParts():Array<Part>
	{
		var array = new Array<Part>();
		for(part in parts){
			array = array.concat(part.getAllParts());
		}

		return array;
	}

	/**
    * @return all trackable items of the game
    **/

	public function getAllItems():Array<Trackable>
	{
		var activities = new Array<Trackable>();
		for(part in parts){
			activities = activities.concat(part.getAllItems());
		}

		return activities;
	}

	/**
    * @param    id : Id of the item
    * @return the name of the item
    **/

	public function getItemName(id:String):Null<String>
	{
		for(part in parts){
			var name = part.getItemName(id);
			if(name != null)
				return name;
		}
		return null;
	}

	// Privates

	private function checkIntegrity():Void
	{
		if(stateInfos.checksum != getAllParts().length){
			throw "Invalid checksum (" + getAllParts().length + " part(s) found instead of " + stateInfos.checksum + "). The structure file must be corrupt";
		}
	}

	private function addPartFromXml(partIndex:String, partXml:Fast):Void
	{
		var part:Part = PartFactory.createPartFromXml(partXml);
		addPart(partIndex, part);
		part.init(partXml);
	}

	private function initLangs(xml:Xml):Void
	{
		var languagesXml:Fast = new Fast(xml);
		for(lang in languagesXml.node.Langs.nodes.Lang){
			addLanguage(lang.att.value, lang.att.folder, lang.att.pic);
		}
	}

	private function initActivities(xml:Xml):Void
	{
		if(numStyleSheetLoaded != numStyleSheet)
			activitiesWaiting.add(xml);
		else
			ActivityManager.instance.getActivity(xml.firstElement().nodeName).parseContent(xml);
	}

	// Handlers

	private function createMenuXml(xml:Xml, part:Part, level:Int = 1):Void
	{
		var child = Xml.createElement("h" + level);
		child.set("id", part.id);
		xml.addChild(child);
		for(elem in part.elements){
			if(elem.isPart() && cast(elem, Part).hasParts()){
				createMenuXml(child, cast(elem, Part), level++);
			}
			else if(Std.is(elem, Trackable)){
				var item = Xml.createElement("item");
				item.set("id", cast(elem, Trackable).id);
				child.addChild(item);
			}
		}
	}

	private function onStyleLoaded(styleSheet:Xml):Void
	{
		StyleParser.parse(styleSheet);
		numStyleSheetLoaded++;
		if(numStyleSheet == numStyleSheetLoaded){
			while(!activitiesWaiting.isEmpty())
				initActivities(activitiesWaiting.pop());
		}
		checkLoading();
	}

	private function onActivityComplete(event:Event):Void
	{
		var loader:URLLoader = cast(event.currentTarget, URLLoader);
		initActivities(Xml.parse(loader.data));
	}

	private function onLanguagesComplete(event:Event):Void
	{
		var loader:URLLoader = cast(event.currentTarget, URLLoader);
		initLangs(Xml.parse(loader.data));
	}

	private function onPartLoaded(event:PartEvent):Void
	{
		if(event.target == LayoutManager.instance)
			layoutLoaded = true;
		else{
			nbPartsLoaded++;
		}
		checkLoading();
	}

	private function checkLoading():Void
	{
		if(getLoadingCompletion() == 1 && (numStyleSheet == numStyleSheetLoaded)){
			//checkIntegrity();
			// Menu hasn't been set, creating the default
			if(menu == null){
				var menuXml = Xml.createElement("menu");
				for(part in parts){
					createMenuXml(menuXml, part);
				}
				menu = menuXml;
			}
			if(!layoutLoaded){
				// Start Tracking
				initTracking();
				for(part in getAllParts())
					part.isDone = stateInfos.isPartFinished(part.id);
				// Load Layout
				LayoutManager.instance.parseXml(Xml.parse(Assets.getText(structureXml.node.Grar.node.Parameters.node.Layout.att.file)));
			}
			else{
				dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
			}
		}
	}

	private function onExit(e:Event):Void
	{
		Lib.exit();
	}
}
