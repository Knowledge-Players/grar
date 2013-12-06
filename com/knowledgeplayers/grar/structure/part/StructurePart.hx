package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.structure.score.Perk;
import com.knowledgeplayers.grar.structure.score.ScoreChart;
import StringTools;
import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.ItemFactory;
import com.knowledgeplayers.grar.factory.PartFactory;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.tracking.Trackable;
import com.knowledgeplayers.utils.assets.AssetsStorage;
import haxe.ds.GenericStack;
import haxe.xml.Fast;
import flash.events.EventDispatcher;
import flash.media.Sound;
import flash.media.SoundChannel;

class StructurePart extends EventDispatcher implements Part{
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
		* Parent of this part
		**/
	public var parent (default, default):Part;

		/**
	     * True if the part is done
	     */
	public var isDone (default, default):Bool;

		/**
	     * Tokens in this part
	     */
	public var tokens (default, default):GenericStack<String>;

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
	public var buttons (default, default):Map<String, Map<String, String>>;

	/**
	* Perks of this part
	**/
	public var perks (default, null): Map<String, Int>;

	/**
	* Score of this part
	**/
	public var score (default, default):Int;

	/**
	* @inheritDoc
	**/
	public var ref (default, default):String;

	/**
	* Perks requirements to start the part
	**/
	public var requirements (default, null): Map<String, Int>;

	public var next (default, default):String;

	public var endScreen (default, null):Bool = false;

	public var buttonTargets (default, null): Map<String, PartElement>;

	private var nbSubPartLoaded:Int = 0;
	private var nbSubPartTotal:Int = 0;
	private var partIndex:Int = 0;
	private var elemIndex:Int = 0;
	private var soundLoopChannel:SoundChannel;
	private var loaded:Bool = false;

	public function new()
	{
		super();
		tokens = new GenericStack<String>();
		elements = new Array<PartElement>();
		buttons = new Map<String, Map<String, String>>();
		buttonTargets = new Map<String, PartElement>();
		perks = new Map<String, Int>();
		requirements = new Map<String, Int>();
	}

		/**
	     * Initialise the part with an XML node
	     * @param	xml : fast node with structure infos
	     * @param	filePath : path to an XML structure file (set the file variable)
	     */

	public function init(xml:Fast, ?filePath:String):Void
	{
		file = filePath;

		if(xml != null){
			parseXml(xml);
		}

		if(display == null && parent != null)
			display = parent.display;

		if(file != null){
			parseContent(AssetsStorage.getXml(file));
		}
		else if(xml.elements.hasNext()){
			parseContent(xml.x);
			if(parent != null)
				file = parent.file;
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
		if(elemIndex == elements.length && !forced)
			return null;
		else{
			enterPart();
			return this;
		}
	}

		/**
		* End the part
		**/

	public function end(completed: Bool = true):Void
	{
		isDone = completed;
		// Add bounty to the right perks
		if(isDone){
			for(perk in perks.keys())
				ScoreChart.instance.addScoreToPerk(perk, perks.get(perk));
		}

		// Stop sound loop
		if(soundLoopChannel != null)
			soundLoopChannel.stop();

	}
	/**
		* @param    startIndex : Next element after this position
	    * @return the next element in the part or null if the part is over
	    */

	public function getNextElement(startIndex:Int = - 1):Null<PartElement>
	{
		if(startIndex > - 1)
			elemIndex = startIndex;
		if(elemIndex < elements.length){
			elemIndex++;
			return elements[elemIndex - 1];
		}
		else{
			return null;
		}
	}

	/**
		* Get the position in this element in the part
		* @param    element : Element to find
		* @return the position of this element
		**/

	public function getElementIndex(element:PartElement):Int
	{
		var i = 0;
		while(i < elements.length && elements[i] != element)
			i++;

		return i == elements.length ? - 1 : i + 1;
	}

		/**
	     * Tell if this part has sub-part or not
	     * @return true if it has sub-part
	     */

	public function hasParts():Bool
	{
		var i = 0;
		while(i < elements.length && !elements[i].isPart())
			i++;
		return i < elements.length;
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

	public function getAllItems():Array<Trackable>
	{
		var items = new Array<Trackable>();

		for(elem in elements){
			if(Std.is(elem, Trackable)){
				if(elem.isPart()){
					if(!cast(elem, Part).hasParts()){
						items.push(cast(elem, Trackable));
					}
					else
						items = items.concat(cast(elem, Part).getAllItems());
				}
			}
		}
		items.push(this);

		return items;
	}

	public function canStart():Bool
	{
		var can: Bool = true;
		for(perk in requirements.keys()){
			if(!ScoreChart.instance.perks.exists(perk))
				ScoreChart.instance.perks.set(perk, new Perk(perk));
			if(ScoreChart.instance.perks.get(perk).getScore() < requirements.get(perk))
				can = false;
		}

		return can;
	}

	public function getElementById(id:String):PartElement
	{
		var i = 0;
		while(i < elements.length && elements[i].id != id)
			i++;
		if(i == elements.length)
			throw "[StructurePart] There is no Element with the id '"+id+"'.";
		return elements[i];
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

	/**
     * Tell if this part is a video
     * @return true if this part is a video
     */
	public function isVideo():Bool
	{
		return false;
	}

		/**
     * Tell if this part is a sound
     * @return true if this part is a sound
     */
	public function isSound():Bool
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
		var i = 0;
		while(i < elements.length && name == null){
			if(elements[i].isPart())
				name = cast(elements[i], Part).getItemName(id);
			i++;
		}
		return name;
	}

	// Private

	private function parseContent(content:Xml):Void
	{
		var partFast:Fast = (content.nodeType == Xml.Element && content.nodeName == "Part") ? new Fast(content) : new Fast(content).node.Part;

		parseHeader(partFast);

		for(child in partFast.elements){
			parseElement(child);
		}
		for(elem in elements){
			if(elem.isText() || elem.isVideo()|| elem.isSound()){
				var text = cast(elem, Item);
				if(text.button == null || Lambda.empty(text.button))
					text.button = buttons;
			}
			if(elem.isPattern()){
				for(item in cast(elem, Pattern).patternContent){
					for(image in item.tokens)
						tokens.add(image);
				}
			}
			for(image in elem.tokens)
				tokens.add(image);
		}
		loaded = true;
		if(nbSubPartLoaded == nbSubPartTotal)
			fireLoaded();
	}

	private function parseElement(node:Fast):Void
	{
		switch(node.name.toLowerCase()){
			case "text":
				elements.push(ItemFactory.createItemFromXml(node));
			case "part":
				createPart(node);
			case "sound":
				soundLoop = AssetsStorage.getSound(node.att.content);
			case "button":
				var content = null;
				if(node.has.content)
					content = ParseUtils.parseHash(node.att.content);
				buttons.set(node.att.ref, content);
				if(node.has.goTo){
					if(node.att.goTo == "")
						buttonTargets.set(node.att.ref, null);
					else{
						var i = 0;
						while((!elements[i].isText() || cast(elements[i], TextItem).content != node.att.goTo) && i < elements.length){
							i++;
						}
						if(i != elements.length)
							buttonTargets.set(node.att.ref, elements[i]);
					}
				}
		}
	}

	/**
	* Common attributes between xml tag and part file
	**/
	private function parseHeader(xml: Fast): Void
	{
		if(xml.has.name) name = xml.att.name;
		if(xml.has.file) file = xml.att.file;
		if(xml.has.display) display = xml.att.display;
		if(xml.has.next) next = xml.att.next;
		if(xml.has.bounty) setPerks(xml.att.bounty);
		if(xml.has.requires) setPerks(xml.att.requires, requirements);
	}

	private function parseXml(xml:Fast):Void
	{
		id = xml.att.id;
		parseHeader(xml);


		if(xml.hasNode.Sound)
			soundLoop = AssetsStorage.getSound(xml.node.Sound.att.content);

		if(xml.hasNode.Part && file != null){
			for(partNode in xml.nodes.Part){
				createPart(partNode);
			}
		}
	}

	private function createPart(partNode:Fast):Void
	{
		nbSubPartTotal++;
		var part:Part = PartFactory.createPartFromXml(partNode);
		part.addEventListener(PartEvent.PART_LOADED, onPartLoaded);
		part.parent = this;
		part.init(partNode);
		elements.push(part);
	}

		// Handlers

	private function enterPart():Void
	{
		if(soundLoop != null)
			soundLoopChannel = soundLoop.play();
	}

	private function onPartLoaded(event:PartEvent):Void
	{
		nbSubPartLoaded++;
		if(nbSubPartLoaded == nbSubPartTotal && loaded){
			fireLoaded();
		}
	}

	private function fireLoaded():Void
	{
		var ev = new PartEvent(PartEvent.PART_LOADED);
		ev.part = this;
		dispatchEvent(ev);
	}

	private function setPerks(perks: String, ?hash: Map<String, Int>):Void
	{
		var map = ParseUtils.parseHash(perks);
		for(perk in map.keys()){
			if(hash == null)
				hash = this.perks;
			hash.set(perk, Std.parseInt(map.get(perk)));
		}
	}
}
