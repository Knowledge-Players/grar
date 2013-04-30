package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.utils.assets.AssetsStorage;
import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.FastList;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import com.knowledgeplayers.grar.factory.ItemFactory;
import com.knowledgeplayers.grar.structure.part.Pattern;
import haxe.unit.TestCase;
import com.knowledgeplayers.grar.structure.part.dialog.Character;
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
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.factory.ActivityFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.XmlLoader;
import com.knowledgeplayers.grar.factory.PatternFactory;

class StructurePart extends EventDispatcher, implements Part, implements Trackable {
	/**
     * Name of the part
     */
	public var name (default, default):String;

	/**
     * ID of the part
     */
	public var id (default, default):String;

	/**
     * Path to the XML structure file
     */
	public var file (default, null):String;

	/**
     * Path to the XML display file
     */
	public var display (default, default):String;

	/**
     * True if the part is done
     */
	public var isDone (default, default):Bool;

	/**
     * Tokens in this part
     * @todo Do something with the options
     */
	public var tokens (default, default):FastList<String>;

	/**
     * Implements PartElement. Always null
     */
	public var token (default, default):String;

	/**
     * Sound playing during the part
     */
	public var soundLoop (default, default):Sound;

	/**
    * Elements of the part
**/
	public var elements (default, null):Array<PartElement>;

	/**
    * Button of the part
    **/
	public var button (default, default):{ref:String, content:Hash<String>};

	private var nbSubPartLoaded:Int = 0;
	private var nbSubPartTotal:Int = 0;
	private var partIndex:Int = 0;
	private var elemIndex:Int = 0;
	private var soundLoopChannel:SoundChannel;

	public function new()
	{
		super();
		tokens = new FastList<String>();
		elements = new Array<PartElement>();
	}

	/**
     * Initialise the part with an XML node
     * @param	xml : fast node with structure infos
     * @param	filePath : path to an XML structure file (set the file variable)
     */

	public function init(xml:Fast, filePath:String = ""):Void
	{

		file = filePath;

		if(xml != null){
			parseXml(xml);
		}

		if(file != ""){
			XmlLoader.load(file, onLoadComplete, parseContent);
		}
		else
			fireLoaded();
	}

	/**
     * Start the part if it hasn't been done
     * @param	forced : true to start the part even if it has already been done
     * @return this part, or null if it can't be start
     */

	public function start(forced:Bool = false):Null<Part>
	{
		if(!isDone || forced){
			enterPart();
			return this;
		}
		else
			return null;
	}

	/**
     * @return the next element in the part or null if the part is over
     */

	public function getNextElement():Null<PartElement>
	{
		if(elemIndex < elements.length){
			elemIndex++;
			return elements[elemIndex - 1];
		}
		else{
			exitPart();
			return null;
		}
	}

	/**
     * Tell if this part has sub-part or not
     * @return true if it has sub-part
     */

	public function hasParts():Bool
	{
		for(elem in elements){
			if(elem.isPart())
				return true;
		}
		return false;
	}

	/**
     * @return all the sub-part of this part
     */

	public function getAllParts():Array<Part>
	{
		var array = new Array<Part>();
		if(elements.length > 0)
			array.push(this);
		if(hasParts()){
			for(elem in elements){
				if(elem.isPart())
					array = array.concat(cast(elem, Part).getAllParts());
			}
		}
		return array;
	}

	/**
    * @return all the trackable items of this part
    **/

	public function getAllItems():Array<PartElement>
	{
		var items = new Array<PartElement>();

		for(elem in elements){
			if(elem.isPart()){
				if(!cast(elem, Part).hasParts())
					items.push(elem);
				else
					items = items.concat(cast(elem, Part).getAllItems());
			}
			if(elem.isActivity())
				items.push(cast(elem, Activity));
		}
		return items;
	}

	/**
     * @return a string-based representation of the part
     */

	override public function toString():String
	{
		return "Part " + name + " " + file + " : " + elements.toString();
	}

	public function restart():Void
	{
		elemIndex = 0;
	}

	/**
     * Tell if this part is a dialog
     * @return true if this part is a dialog
     */

	public function isDialog():Bool
	{
		return false;
	}

	/**
     * Tell if this part is a strip
     * @return true if this part is a strip
     */

	public function isStrip():Bool
	{
		return false;
	}

	// Implements PartElement

	/**
    * @return false
**/

	public function isActivity():Bool
	{
		return false;
	}

	/**
    * @return false
**/

	public function isText():Bool
	{
		return false;
	}

	/**
    * @return false
**/

	public function isPattern():Bool
	{
		return false;
	}

	/**
    * @return true
**/

	public function isPart():Bool
	{
		return true;
	}

	/**
    * @param    id : Id of the item
    * @return the name of the item
    **/

	public function getItemName(id:String):Null<String>
	{
		if(this.id == id)
			return this.name;
		var name = null;
		for(elem in elements){
			if(elem.isPart()){
				name = cast(elem, Part).getItemName(id);
			}
		}
		return name;
	}

	// Private

	private function parseContent(content:Xml):Void
	{
		var partFast:Fast = new Fast(content).node.Part;

		for(child in partFast.elements){
			switch(child.name.toLowerCase()){
				case "text":
					elements.push(ItemFactory.createItemFromXml(child));
				case "activity":
					elements.push(ActivityFactory.createActivityFromXml(child, this));
				case "part":
					nbSubPartTotal++;
					createPart(child);
				case "button":
					var content = new Hash<String>();
					if(child.has.content){
						var contentString:String = child.att.content.substr(1, child.att.content.length - 2);
						var contents = contentString.split(",");
						for(c in contents)
							content.set(c.split(":")[0], c.split(":")[1]);
					}
					button = {ref: child.att.ref, content: content};
			}
		}
		for(elem in elements){
			if(elem.isText()){
				var text = cast(elem, TextItem);
				if(text.button == null)
					text.button = button;
			}
			if(elem.isPattern()){
				for(item in cast(elem, Pattern).patternContent){
					if(item.token != null){
						tokens.add(item.token);
					}
				}
			}
			if(elem.token != null)
				tokens.add(elem.token);
		}
		if(nbSubPartLoaded == nbSubPartTotal)
			fireLoaded();
	}

	private function parseXml(xml:Fast):Void
	{
		id = xml.att.id;
		if(xml.has.name) name = xml.att.name;
		if(xml.has.file) file = xml.att.file;
		if(xml.has.display) display = xml.att.display;

		if(xml.hasNode.Sound)
			soundLoop = AssetsStorage.getSound(xml.node.Sound.att.content);

		if(xml.hasNode.Part){
			for(partNode in xml.nodes.Part){
				nbSubPartTotal++;
			}
			for(partNode in xml.nodes.Part){
				createPart(partNode);
			}
		}
	}

	private function createPart(partNode:Fast):Void
	{
		var part:Part = PartFactory.createPartFromXml(partNode);
		part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		part.init(partNode);
		elements.push(part);
	}

	// Handlers

	private function onLoadComplete(event:Event):Void
	{
		parseContent(XmlLoader.getXml(event));
	}

	private function enterPart():Void
	{
		if(soundLoop != null)
			soundLoopChannel = soundLoop.play();
	}

	private function onPartLoaded(event:PartEvent):Void
	{
		nbSubPartLoaded++;
		if(nbSubPartLoaded == nbSubPartTotal){
			fireLoaded();
		}
	}

	private function fireLoaded():Void
	{
		var ev = new PartEvent(PartEvent.PART_LOADED);
		ev.part = this;
		dispatchEvent(ev);
	}

	private function exitPart():Void
	{
		isDone = true;
		if(soundLoopChannel != null)
			soundLoopChannel.stop();
		dispatchEvent(new PartEvent(PartEvent.EXIT_PART));
	}
}
