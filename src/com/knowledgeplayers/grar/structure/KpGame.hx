package com.knowledgeplayers.grar.structure;

import com.knowledgeplayers.grar.display.activity.ActivityManager;
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


class KpGame extends EventDispatcher, implements Game
{	
	public var mode (default, default): Mode;
	public var title (default, default): String;
	public var state (default, default): String;
	public var inventory (default, null): Array<String>;

	private var structureXml: Fast;
	private var languages: Hash<String>;
	private var stateInfos: StateInfos;
	private var flags: Hash<String>;
	private var parts: IntHash<Part>;
	private var connection: Connection;
	private var nbPartsLoaded: Int = 0;
	private var	partIndex: Int = 0;

	public function new()
	{
		super();
		languages = new Hash<String>();
		flags = new Hash<String>();
		parts = new IntHash<Part>();
		inventory = new Array<String>();
		Lib.current.stage.addEventListener(Event.DEACTIVATE, onExit);
	}

	public function init(xml: Xml) : Void
	{
		structureXml = new Fast(xml);

		var paramatersNode: Fast = structureXml.node.Grar.node.Parameters;
		mode = Type.createEnum(Mode, paramatersNode.node.Mode.innerData);
		title = paramatersNode.node.Title.innerData;
		state = paramatersNode.node.State.innerData;
		
		initTracking();
		
		var xml = XmlLoader.load(paramatersNode.node.Languages.att.File, onLanguagesComplete);
		#if !flash
			initLangs(xml);
		#end

		var displayNode: Fast = structureXml.node.Grar.node.Display;
		if (displayNode.hasNode.Ui)
			UiFactory.setSpriteSheet(displayNode.node.Ui.att.Display);
		for (activity in displayNode.nodes.Activity) {
			var activityXml = XmlLoader.load(activity.att.Display, onActivityComplete);
			#if !flash
				initActivities(activityXml);
			#end
		}
		
		var structureNode: Fast = structureXml.node.Grar.node.Structure;
		for (part in structureNode.nodes.Part) {
			addPartFromXml(Std.parseInt(part.att.Id), part);
		}
		
		checkIntegrity();
	}

	public function start(partId: Int = 0) : Null<Part>
	{
		if(partId == 0)
			return parts.get(0).next();
		else {
			for (part in getAllParts()) {
				if (part.id == partId)
					return part.start(true);
			}
			return null;
		}
	}
	
	public function next() : Null<Part>
	{
		if (partIndex == Lambda.count(parts)) {
			return null;
		}
		var nextPart: Part = parts.get(partIndex).next();
		if (nextPart == null) {
			partIndex++;
			return next();
		}
		else
			return nextPart;
	}
	
	public function addPart(partIndex: Int, part: Part) : Void
	{
		part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		part.addEventListener(PartEvent.EXIT_PART, onPartComplete);
		part.addEventListener(TokenEvent.ADD_GLOBAL, onGlobalTokenAdd);
		parts.set(partIndex, part);
	}

	private function addPartFromXml(partIndex: Int, partXml: Fast) : Void
	{
		var part: Part = PartFactory.createPartFromXml(partXml);
		addPart(partIndex, part);
		part.init(partXml);
	}

	public function addLanguage(value: String, path: String, flagIconPath: String) : Void
	{
		Localiser.getInstance().localisations.set(value, path);
		flags.set(value, flagIconPath);
	}

	override public function toString() : String
	{
		return title+" - "+mode+" - "+state+". Parts: \n\t"+parts.toString();
	}

	public function initTracking(?mode: Mode) : Void
	{
		connection = new Connection();
		if(mode != null)
			this.mode = mode;			
		connection.initConnection(this.mode);
		stateInfos = connection.revertTracking();
		if (stateInfos.isEmpty()) {
			stateInfos.loadStateInfos(state);
		}
	}
	
	private function checkIntegrity() : Void 
	{
		if(stateInfos.checksum != getAllParts().length){
			throw "Invalid checksum ("+getAllParts().length+" must be "+stateInfos.checksum+"). The structure file must be corrupt";
		}		
	}

	public function getLoadingCompletion() : Float
	{
		return nbPartsLoaded/Lambda.count(parts);
	}
	
	public function getAllParts() : Array<Part> 
	{
		var array = new Array<Part>();
		for (part in parts) {
			array = array.concat(part.getAllParts());
		}
		
		return array;
	}
	
	// Privates
	
	private function initLangs(xml: Xml) : Void 
	{
		var languagesXml: Fast = new Fast(xml);
		for(lang in languagesXml.node.Langs.nodes.Lang) {
			addLanguage(lang.att.Value, lang.att.Folder, lang.att.Pic);
		}
		Localiser.instance.setCurrentLocale(stateInfos.currentLanguage);
	}
	
	private function initActivities(xml: Xml):Void 
	{
		var activityNode: Fast = new Fast(xml.firstElement());
		ActivityManager.instance.getActivity(activityNode.name).setDisplay(activityNode);
	}

	// Handlers
	
	private function onActivityComplete(event: Event) : Void
	{
		var loader: URLLoader = cast(event.currentTarget, URLLoader);
		initActivities(Xml.parse(loader.data));
	}

	private function onLanguagesComplete(event: Event) : Void
	{
		var loader: URLLoader = cast(event.currentTarget, URLLoader);
		initLangs(Xml.parse(loader.data));
	}

	private function onPartLoaded(event: Event) : Void
	{
		nbPartsLoaded++;
		if (getLoadingCompletion() == 1) {
			for (part in getAllParts())
				part.isDone = stateInfos.activityCompletion[part.id];
			dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
		}
	}
	
	private function onPartComplete(event: PartEvent) : Void 
	{
		stateInfos.activityCompletion[cast(event.target, Part).id] = true;
	}
	
	private function onGlobalTokenAdd(e: TokenEvent) : Void 
	{
		inventory.push(e.tokenId);
	}
	
	/**
	 * Handler for minimization on mobile
	 * @param	e: Event	Desactivation event
	 */
	private function onExit(e: Event) : Void 
	{
		Lib.exit();
	}
}
