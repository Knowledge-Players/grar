package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.factory.PartFactory;
import haxe.xml.Fast;
import nme.Assets;
import nme.events.EventDispatcher;
import nme.Lib;
import nme.media.Sound;
import nme.media.SoundChannel;

import nme.events.Event;

import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.part.dialog.item.Item;
import com.knowledgeplayers.grar.factory.ActivityFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;

class StructurePart extends EventDispatcher, implements Part
{
	public var name (default, default): String;
	public var id (default, default): Int;
	public var file (default, null): String;
	public var display (default, default): String;
	public var isDone (default, default): Bool;

	public var options (default, null): Hash<String>;
	public var activities (default, null): IntHash<Activity>;
	public var parts (default, null): IntHash<Part>;
	public var items (default, null): Array<Item>;
	public var inventory (default, null): Array<String>;
	public var soundLoop (default, default): Sound;

	private var nbSubPartLoaded: Int = 0;
	private var nbSubPartTotal: Int = 0;
	private var itemIndex: Int = 0;
	private var partIndex: Int = 0;
	private var soundLoopChannel: SoundChannel;

	public function new()
	{
		super();
		parts = new IntHash<Part>();
		activities = new IntHash<Activity>();
		options = new Hash<String>();
		items = new Array<Item>();
		inventory = new Array<String>();
		addEventListener(TokenEvent.ADD, onAddToken);
	}

	public function init(xml: Fast, filePath: String = "") : Void
	{
		file = filePath;

		if(xml != null){
			parseXml(xml);
		}
		
		if(file != ""){
			var content = XmlLoader.load(file, onLoadComplete);
			#if !flash
				parseContent(content);
			#end
		}
		else
			fireLoaded();
	}

	public function start(forced: Bool = false) : Part
	{
		if(!isDone || forced){
			enterPart();
			return this;
		}
		else
			return null;
	}

	public function getNextItem() : Null<Item>
	{
		if(itemIndex < items.length){
			itemIndex++;
			return items[itemIndex-1];
		}
		else{
			exitPart();
			return null;
		}
	}

	public function next() : Null<Part>
	{
		var part: Part = null;
		if (hasParts()) {
			if (partIndex == Lambda.count(parts)) {
				exitPart();
				return null;
			}
			part =  parts.get(partIndex).next();
			if(part == null){
				partIndex++;
				part = next();
			}
		}
		if(part != null)
			return part.start();
		else
			return part;
	}

	public function hasParts() : Bool
	{
		return partsCount() != 0;
	}

	public function partsCount() : Int
	{
		return Lambda.count(parts);
	}

	public function activitiesCount() : Int
	{
		return Lambda.count(activities);
	}

	public function getAllParts() : Array<Part>
	{
		var array = new Array<Part>();
		if(hasParts()){
			for (part in parts) {
				array = array.concat(part.getAllParts());
			}
		}
		else
			array.push(this);
		return array;
	}
	// Private
	 
	private function parseContent(content: Xml) : Void
	{
		var partFast: Fast = new Fast(content).node.Part;
		for(item in partFast.nodes.Item) {
			items.push(new Item(item));
		}
		fireLoaded();
	}

	private function parseXml(xml: Fast) : Void
	{
		id = Std.parseInt(xml.att.Id);
		if(xml.has.Name) name = xml.att.Name;
		if(xml.has.File) file = xml.att.File;
		if (xml.has.Display) display = xml.att.Display;
		
		if (xml.hasNode.Sound)
			soundLoop = Assets.getSound(xml.node.Sound.att.Content);

		if(xml.hasNode.Part){
			for(partNode in xml.nodes.Part) {
				nbSubPartTotal++;
			}
			for(partNode in xml.nodes.Part) {
				var part: Part = PartFactory.createPartFromXml(partNode);
				part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
				part.addEventListener(TokenEvent.ADD, onAddToken);
				part.init(partNode);
				parts.set(Std.parseInt(partNode.att.Id), part);
			}
		}
		else if(xml.hasNode.Activity){
			for(activity in xml.nodes.Activity){
				activities.set(Std.parseInt(activity.att.Id), ActivityFactory.createActivityFromXml(activity));
			}
		}
		if(xml.has.Options){
			for(option in xml.att.Options.split(";")) {
				if(option != ""){
					var key: String = StringTools.trim(option.split(":")[0]);
					var value: String = StringTools.trim(option.split(":")[1]);
					options.set(key, value);
				}
			}
		}
	}

	override public function toString() : String
	{
		return "Part " + name + " " + file + " has " +
		(hasParts()?"parts: \n" + parts.toString():"no part") +
		" and " + (activitiesCount() != 0?"activities: " + activities.toString():"no activity") +
		(items.length==0 ? ". It has no items":". It's composed by "+items.toString());
	}
	
	public function isDialog() : Bool
	{
		return false;
	}

	// Handlers
	
	private function onLoadComplete(event: Event) : Void 
	{
		parseContent(XmlLoader.getXml(event));
	}
	
	private function enterPart() : Void
	{
		Localiser.getInstance().setLayoutFile(file);
		if(soundLoop != null)
			soundLoopChannel = soundLoop.play();
	}

	private function onPartLoaded(event: Event) : Void
	{
		nbSubPartLoaded++;
		if(nbSubPartLoaded == nbSubPartTotal){
			fireLoaded();
		}
	}

	private function fireLoaded() : Void
	{
		dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
	}
	
	private function onAddToken(e: TokenEvent) : Void 
	{
		if (e.tokenTarget == "activity") {
			e.stopImmediatePropagation();
			inventory.push(e.tokenId);
		}
		else {
			var globalEvent = new TokenEvent(TokenEvent.ADD_GLOBAL, e.tokenId, e.tokenType, e.tokenTarget);
			dispatchEvent(globalEvent);
		}
	}
	
	private function exitPart():Void 
	{
		isDone = true;
		if(soundLoopChannel != null)
			soundLoopChannel.stop();
		dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
	}
}
