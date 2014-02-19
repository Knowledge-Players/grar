package grar.model.part;

import com.knowledgeplayers.grar.structure.score.Perk;
import com.knowledgeplayers.grar.structure.score.ScoreChart;
import grar.model.part.Pattern;
import grar.model.part.TextItem;
import grar.util.ParseUtils;
//import com.knowledgeplayers.grar.event.PartEvent;
//import com.knowledgeplayers.grar.factory.ItemFactory;
//import com.knowledgeplayers.grar.factory.PartFactory;
import com.knowledgeplayers.grar.tracking.Trackable;
//import com.knowledgeplayers.utils.assets.AssetsStorage;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;
import haxe.xml.Fast;

#if (flash || openfl)
import flash.media.Sound;
import flash.media.SoundChannel;
#end

typedef PartData = {

	var name : String;
	var id : String;
	var file : String;
	var display : String;
	var parent : Null<Part>;
	var isDone : Bool;
	var isStarted : Bool;
	var tokens : GenericStack<String>;
#if (flash || openfl)
	var soundLoop : Sound;
	var soundLoopSrc : String;
#else
	var soundLoop : String;
#end
	var elements : Array<PartElement>;
	var buttons : StringMap<StringMap<String>>;
	var perks : StringMap<Int>;
	var score : Int;
	var ref : String;
	var requirements (default, null) : StringMap<Int>;
	var next (default, default) : String;
	var endScreen (default, null) : Bool = false;
	var buttonTargets (default, null) : StringMap<PartElement>;
	var nbSubPartLoaded : Int = 0;
	var nbSubPartTotal : Int = 0;
	var partIndex : Int = 0;
	var elemIndex : Int = 0;
	var soundLoopChannel : SoundChannel;
	var loaded : Bool = false;
	// partial data
	var partialSubParts : Array<grar.parser.XmlToPart.PartialPart> = [];
	var xml : Xml;
}

class Part /* implements Part */ {

	public function new(pd : PartData) {

		this.name = pd.name;
		this.id = pd.id;
		this.file = pd.file;
		this.display = pd.display;
		this.parent = pd.parent;
		this.isDone = pd.isDone;
		this.isStarted = pd.isStarted;
		this.tokens = pd.tokens;
		this.soundLoop = pd.soundLoop;
		this.elements = pd.elements;
		this.buttons = pd.buttons;
		this.perks = pd.perks;
		this.score = pd.score;
		this.ref = pd.ref;
		this.requirements = pd.requirements;
		this.next = pd.next;
		this.endScreen = pd.endScreen;
		this.buttonTargets = pd.buttonTargets;
		this.nbSubPartLoaded = pd.nbSubPartLoaded;
		this.nbSubPartTotal = pd.nbSubPartTotal;
		this.partIndex = pd.partIndex;
		this.elemIndex = pd.elemIndex;
		this.soundLoopChannel = pd.soundLoopChannel;
		this.loaded = pd.loaded;
	}

	/**
     * Name of the part
     */
	public var name (default, default) : String;

	/**
     * ID of the part
     */
	public var id (default, default) : String;

	/**
     * Path to the XML structure file
     */
	public var file (default, null) : String;

	/**
     * Path to the XML display file
     */
	public var display (default, default) : String;

	/**
	 * Parent of this part
	 **/
	public var parent (default, default) : Null<Part>;

	/**
     * True if the part is done
     */
	public var isDone (default, set) : Bool;

    /**
     * True if the part is started
     */
    public var isStarted (default, set) : Bool;

	/**
     * Tokens in this part
     */
	public var tokens (default, default) : GenericStack<String>;

	/**
     * Sound playing during the part
     */
#if (flash || openfl)
	public var soundLoop (default, default) : Sound;
#else
	public var soundLoop (default, default) : String;
#end

	/**
     * Elements of the part
	 **/
	public var elements (default, null) : Array<PartElement>;

	/**
     * Button of the part
     **/
	public var buttons (default, default) : StringMap<StringMap<String>>;

	/**
	 * Perks of this part
	 **/
	public var perks (default, null) : StringMap<Int>;

	/**
	 * Score of this part
	 **/
	public var score (default, default) : Int;

	/**
	 * @inheritDoc
	 **/
	public var ref (default, default) : String;

	/**
	 * Perks requirements to start the part
	 **/
	public var requirements (default, null) : StringMap<Int>;

	public var next (default, default) : String;

	public var endScreen (default, null) : Bool = false;

	public var buttonTargets (default, null) : StringMap<PartElement>;

	private var nbSubPartLoaded : Int = 0;
	private var nbSubPartTotal : Int = 0;
	private var partIndex : Int = 0;
	private var elemIndex : Int = 0;
	private var soundLoopChannel : SoundChannel;
	private var loaded : Bool = false;

	public var data (get, set) : PartData;


	///
	// GETTER / SETTER
	//

    public function set_isDone(completed: Bool = true):Bool
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

        return completed;
    }

    /**
	* Start the part
	**/
    public function set_isStarted(completed: Bool = true):Bool
    {
        isStarted = completed;
        return completed;
    }


    ///
    // API
    //

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

	public function startElement(elemId: String):Void
	{
		if(elemIndex == 0 || elemId != elements[elemIndex-1].id){
			var tmpIndex = 0;
			while(tmpIndex < elements.length && elements[tmpIndex].id != elemId)
				tmpIndex++;
			if(tmpIndex < elements.length)
				elemIndex = tmpIndex;
			if(elements[elemIndex].isPart() && (cast(elements[elemIndex], Part).next == null || cast(elements[elemIndex], Part).next == ""))
				elemIndex++;
		}
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
			return elements[elemIndex++];
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
		//if(elements.length > 0)
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


	///
	// INTERNALS
	//

	private function enterPart():Void
	{
		if(parent != null)
			parent.startElement(id);
		if(soundLoop != null)
			soundLoopChannel = soundLoop.play();
	}

	// private function onPartLoaded(event:PartEvent):Void
	// {
	// 	nbSubPartLoaded++;
	// 	if(nbSubPartLoaded == nbSubPartTotal && loaded){
	// 		fireLoaded();
	// 	}
	// }
}
