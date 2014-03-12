package grar.model.part;

import grar.model.score.Perk;
import grar.model.score.ScoreChart;
import grar.model.part.Pattern;
import grar.model.part.TextItem;
import grar.model.tracking.Trackable;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

#if (flash || openfl)
import flash.media.Sound;
import flash.media.SoundChannel;
#end

enum PartType {

	Part;
	Activity;
	Dialog;
	Strip;
}

typedef PartialPart = {

	var pd : PartData;
	var type : PartType;
}

typedef PartData = {

	var name : String;
	var id : String;
	var file : String;
	var displaySrc : String;
	var display : grar.view.Display.DisplayData;
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
	var requirements : StringMap<Int>;
	var next : Null<Array<String>>;
	var buttonTargets : StringMap<PartElement>;
	var nbSubPartTotal : Int;
	var soundLoopChannel : SoundChannel;
	// partial data
	var partialSubParts : Array<PartialPart>;
	var xml : Xml;
}

class Part /* implements Part */ {

	public function new(pd : PartData) {

		this.name = pd.name;
		this.id = pd.id;
		this.file = pd.file;
		this.display = pd.display;
		this.parent = pd.parent;
		if (display == null && parent != null) {

			display = parent.display;
		}
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
		this.buttonTargets = pd.buttonTargets;
		this.nbSubPartTotal = pd.nbSubPartTotal;
		this.soundLoopChannel = pd.soundLoopChannel;
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
	public var file (default, default) : String;

	/**
     * Display data for the part
     */
	public var display (default, default) : grar.view.Display.DisplayData;

	/**
	 * Parent of this part
	 **/
	public var parent (default, set) : Null<Part>;

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

	public var next (default, default) : Null<Array<String>>;

	public var endScreen (default, null) : Bool = false;

	public var buttonTargets (default, null) : StringMap<PartElement>;

	private var nbSubPartLoaded : Int = 0;
	private var nbSubPartTotal : Int = 0;
	private var partIndex : Int = 0;
	private var elemIndex : Int = 0;
	private var soundLoopChannel : SoundChannel;
	private var loaded : Bool = false;


	///
	// CALLBACKS
	//

	public dynamic function onActivateTokenRequest(tokenId : String) : Void { }


	///
	// GETTER / SETTER
	//

	public function set_parent(pt : Null<Part>) : Null<Part> {

		if (pt == parent) {

			return parent;
		}
		parent = pt;

		this.onActivateTokenRequest = function(itId : String){ parent.onActivateTokenRequest(itId); }

		//onParentChanged();

		return parent;
	}

    public function set_isDone(completed : Bool = true) : Bool {

        isDone = completed;
// Add bounty to the right perks
        if (isDone) {

            for (perk in perks.keys()) {

                //ScoreChart.instance.addScoreToPerk(perk, perks.get(perk)); // FIXME
            }
        }

// Stop sound loop
        if (soundLoopChannel != null) {

            soundLoopChannel.stop();
        }
        return completed;
    }

    public function set_isStarted(completed : Bool = true) : Bool {

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
//		if (elemIndex == 0 || elemId != elements[elemIndex-1].id) {
		if (elemIndex == 0 || elemId != switch(elements[elemIndex-1]){ case Part(p): p.id; case Pattern(p): p.id; case Item(i): i.id; }) {

			var tmpIndex = 0;
			
			//while (tmpIndex < elements.length && elements[tmpIndex].id != elemId) {
			while (tmpIndex < elements.length && elemId != switch(elements[tmpIndex]){ case Part(p): p.id; case Pattern(p): p.id; case Item(i): i.id; }) {

				tmpIndex++;
			}
			if (tmpIndex < elements.length) {

				elemIndex = tmpIndex;
			}
			switch (elements[elemIndex]) {

				case Part(p):

					//if (p.next == null || p.next == "") {
					if (p.next == null) {

						elemIndex++;
					}

				default: // nothing
			}
		}
	}

	/**
	* @param    startIndex : Next element after this position
    * @return the next element in the part or null if the part is over
    */
	public function getNextElement(startIndex : Int = -1) : Null<PartElement> {

		if (startIndex > -1) {

			elemIndex = startIndex;
		}
		if (elemIndex < elements.length) {

			return elements[elemIndex++];
		
		} else {

			return null;
		}
	}

	/**
	* Get the position in this element in the part
	* @param    element : Element to find
	* @return the position of this element
	**/
	public function getElementIndex(element : PartElement) : Int {

		var i = 0;

		while (i < elements.length && !Type.enumEq( elements[i], element )) {

			i++;
		}
		return i == elements.length ? - 1 : i + 1;
	}

	/**
     * Tell if this part has sub-part or not
     * @return true if it has sub-part
     */
	public function hasParts() : Bool {

		for (e in elements) {

			switch (e) {

				case Part(p):

					return true;

				default: // nothing
			}
		}
		return false;
	}

	/**
     * @return all the sub-part of this part
     */
	public function getAllParts() : Array<Part> {

		var a : Array<Part> = [];

		a.push(this);
		
		for (e in elements) {

			switch (e) {

				case Part(p):

					a = a.concat(p.getAllParts());

				default: // nothing
			}
		}
		return a;
	}

	/**
     * @return all the trackable items of this part
     **/
	public function getAllItems() : Array<Trackable> {

		var items : Array<Trackable> = [];

		for (elem in elements) {

			switch (elem) {

				case Part(p):

					if (!p.hasParts()) {

						items.push(Part(p));

					} else {

						items = items.concat( p.getAllItems() );
					}

				default: // nothing
			}
		}
		items.push(Part(this));

		return items;
	}

	public function canStart() : Bool {

		var can : Bool = true;

		for (perk in requirements.keys()) {

			// FIXME if (!ScoreChart.instance.perks.exists(perk)) {

			// FIXME 	ScoreChart.instance.perks.set(perk, new Perk(perk));
			// FIXME }
			// FIXME if (ScoreChart.instance.perks.get(perk).getScore() < requirements.get(perk)) {

			// FIXME 	can = false;
			// FIXME }
		}
		return can;
	}

	public function getElementById(id : String) : PartElement {

		for (e in elements) {

			switch (e) {

				case Part(p):

					if (p.id == id) {

						return e;
					}

				case Pattern(p):

					if (p.id == id) {

						return e;
					}

				case Item(i):

					if (i.id == id) {

						return e;
					}
			}
		}
		throw "[StructurePart] There is no Element with the id '"+id+"'.";
	}

	/**
     * @return a string-based representation of the part
     */
	public function toString() : String {

		return "Part " + name + " " + file + " : " + elements.toString();
	}

	public function restart() : Void {

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
     * Tell if this part is a activity
     * @return true if this part is a activity
     */
	public function isActivity():Bool
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
	public function getItemName(id : String) : Null<String> {

		if (this.id == id) {

			return this.name;
		}
		for (e in elements) {

			switch(e) {

				case Part(p):

					if (p.getItemName(id) != null) {

						return p.getItemName(id);
					}

				default: // nothing
			}
		}
		return null;
	}


	///
	// INTERNALS
	//

	private function enterPart():Void
	{
		if(parent != null)
			parent.startElement(id);
#if (flash || openfl)
		if(soundLoop != null)
			soundLoopChannel = soundLoop.play();
#else
		// TODO
#end
	}
}
