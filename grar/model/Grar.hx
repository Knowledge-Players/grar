package grar.model;

import grar.model.InventoryToken;
import grar.model.contextual.Glossary;
import grar.model.contextual.Bibliography;
import grar.model.contextual.Notebook;
import grar.model.score.ScoreChart;
import grar.model.score.Perk;
import grar.model.part.Part;
import grar.model.tracking.TrackingMode;
import grar.model.localization.Locale;
import grar.model.localization.LocaleData;

import haxe.ds.GenericStack;

typedef InitState = {

	var value : String;
	var tracking : String;
}

typedef KalturaSettings = {
	var partnerId: Int;
	var secret: String;
	@:optional var serviceUrl: String;
}

enum ReadyState {

	Loading(langs : String, structureNode : haxe.xml.Fast);
	LoadingGame(structureXml : haxe.xml.Fast);
	Ready;
}

/**
 * Represents a GRAR module / game.
 */
class Grar {

	public function new(mode : TrackingMode, id : String, ks: KalturaSettings, s : InitState, rs : ReadyState) {
		this.mode = mode;
		this.id = id;
		this.state = s;
		this.kSettings = ks;
		this.readyState = rs;
		this.inventory = new Map();
		this.scoreChart = new ScoreChart();
		this.completion = new Map();
		this.completionOrdered = new Array();
		this.stashedLocaleData = new GenericStack<LocaleData>();
	}

	public var readyState (default, set) : ReadyState;

	public var mode (default, null) : TrackingMode;

	public var id (default, null) : String;

	public var state (default, null) : InitState;

	public var kSettings (default, default):KalturaSettings;

	public var notebook (default, set) : Notebook;

	public var inventory (null, default) : Map<String, InventoryToken>;

	public var glossary (default, set) : Null<Glossary> = null;

	public var bibliography (default, set) : Null<Bibliography> = null;

	public var parts (default, set) : Null<Array<Part>> = null;

	public var scoreChart (default, null) : ScoreChart;

	public var theme (default, default):Null<String>;


	// Module localization related properties

	public var locales (default, set) : Null<Map<String, Locale>> = null;

	public var currentLocale (default, set) : String;

	public var currentLocaleDataPath (default, set) : Null<String> = null;

	public var interfaceLocaleDataPath (default, set) : Null<String> = null;

	public var localeData : Null<LocaleData> = null;

	private var stashedLocaleData : GenericStack<LocaleData>;

	private var changeLocale : Bool;

	// From StateInfos

	public var bookmark (default, set) : Int = -1;

	public var checksum (default, default) : Int;

	public var completion : Map<String, Int>;

	public var completionOrdered : Array<String>;

	var partIndex : Int = 0;


	///
	// CALLBACKS
	//

	public dynamic function onReadyStateChanged() { }

	public dynamic function onNotebookChanged() { }

	public dynamic function onGlossaryChanged() { }

	public dynamic function onBibliographyChanged() { }

	public dynamic function onPartsChanged() { }

	public dynamic function onPartFinished(p : Part) { }

	public dynamic function onInventoryTokenActivated(it : InventoryToken) { }

	public dynamic function onCurrentLocalePathChanged() { }

	public dynamic function onCurrentLocaleChanged() { }

	public dynamic function onLocaleListChanged() { }

	public dynamic function onBookmarkChanged(): Void {}


	///
	// GETTERS / SETTERS
	//

	private function set_currentLocale( v : String ) : String {

		if (v == currentLocale)
			return v;
		currentLocale = v;
		onCurrentLocaleChanged();

		return currentLocale;
	}

	private function set_locales( v : Null<Map<String, Locale>> ) : Null<Map<String, Locale>>
	{

		locales = v;
		onLocaleListChanged();
		return locales;
	}

	private function set_interfaceLocaleDataPath(v : Null<String>) : Null<String>
	{

		if (interfaceLocaleDataPath == v)
			return interfaceLocaleDataPath;
		currentLocaleDataPath = interfaceLocaleDataPath = v;

		return interfaceLocaleDataPath;
	}

	private function set_currentLocaleDataPath(v : Null<String>) : Null<String>
	{
		if (v != null) {
			if (currentLocaleDataPath != v) {
				stashedLocaleData.add(localeData);
				currentLocaleDataPath = v;
				changeLocale = true;
				onCurrentLocalePathChanged();
			} else
				changeLocale = false;
		} else {
			currentLocaleDataPath = v;
			onCurrentLocalePathChanged();
		}

		return currentLocaleDataPath;
	}

	private function set_parts(v : Null<Array<Part>>) : Null<Array<Part>> {

		if (parts == v)
			return parts;
		parts = v;

		for (p in parts) {
			p.onActivateTokenRequest = function(tid : String){ activateInventoryToken(tid); };
			p.onScoreToAdd = function(perk : String, score : Int){ scoreChart.addScoreToPerk(perk, score); }
		}
		onPartsChanged();

		return parts;
	}

	private function set_bibliography(v : Null<Bibliography>) : Null<Bibliography> {

		if (bibliography == v) {
			return bibliography;
		}
		bibliography = v;
		onBibliographyChanged();

		return bibliography;
	}

	private function set_glossary(v : Null<Glossary>) : Null<Glossary> {

		if (glossary == v) {
			return glossary;
		}
		glossary = v;
		onGlossaryChanged();

		return glossary;
	}

	private function set_readyState(v : ReadyState) : ReadyState {

		if (readyState == v) {
			return readyState;
		}
		readyState = v;
		onReadyStateChanged();

		return readyState;
	}

	private function set_notebook(v : Notebook) : Notebook {

		if (notebook == v) {
			return notebook;
		}
		notebook = v;
		onNotebookChanged();

		return notebook;
	}

	private function set_bookmark(bookmark:Int):Int
	{
		this.bookmark = bookmark;
		onBookmarkChanged();
		return this.bookmark;
	}


	///
	// API
	//

	public function canStart(p : Part) : Bool {

		var can : Bool = true;

		if(p.requirements != null){
			for (perk in p.requirements.keys()) {

				if (!scoreChart.perks.exists(perk)) {

					scoreChart.perks.set(perk, new Perk(perk));
				}
				if (scoreChart.perks.get(perk).getScore() < p.requirements.get(perk)) {

					can = false;
				}
			}
		}
		return can;
	}

	/**
	* @return true if the last currentLocaleDataPath set was the same as the one already in place
	**/
	public function hasLocaleChanged():Bool
	{
		return changeLocale;
	}

	/**
    * Restore the previously stored locale
    **/
	public function restoreLocale() : Void
	{
		if (changeLocale && !stashedLocaleData.isEmpty()) {
			localeData = stashedLocaleData.pop();
			currentLocaleDataPath = null;
		}
	}

	public function getLocalizedContent(key : String) : Null<String> {

		if (localeData != null) {
			var content = localeData.getItem(key);
			if (content == null)
				content = "Unknown localized content key '"+key+"'.";

			return content;
		} else {
			trace("No locale data set. Returning null for key '"+key+"'.");
			return null;
		}
	}

	public function activateInventoryToken(tid : String) : Void {

		if (!inventory.exists(tid)) {

			throw 'Unknown token "$tid". ';
		}
		var it : InventoryToken = inventory.get(tid);

		it.isActivated = true;

		onInventoryTokenActivated(it);
	}


    public function setPartStarted(pid : String) : Void {
		// Can't go from finished to started
	    if(completion[pid] < 1)
            completion[pid] =  1;
	    bookmark = getAllParts().indexOf(getPartById(pid));
    }

	public function setPartFinished(pid : String) : Void {

		completion[pid] =  2;

		onPartFinished(getPartById(pid));
	}

    public function isPartStarted(pid : String) : Bool {

        return completion[pid] == 1;
    }

	public function isPartFinished(pid : String) : Bool {

		return completion[pid] == 2;
	}

	/**
    * @param    id : Id of the item
    * @return the name of the item
    **/
    public function getItemName(id:String):Null<String>
    {
        var i = 0;
        var name:String = null;
        while(i < parts.length && name == null){
            name = parts[i].getItemName(id);
            i++;
        }
        return getLocalizedContent(name);
    }

	/**
	* @param part: starting point
	* @return the part after the starting point
	**/
	public function getNextPart(p:Part):Null<Part>
	{
		var i = 0;
		var allParts = getAllParts();
		while(i < allParts.length && allParts[i] != p)
			i++;
		// Can't return a child of p. Children are return by p.getNextElement()
		while(i < allParts.length-1 && allParts[i+1].parent == p)
			i++;

		return i < allParts.length-1 ? allParts[i+1] : null;
	}

	/**
	* @param part: Starting point
	* @return wheter the part has a following part
	**/
	public function hasNextPart(p:Part):Bool
	{
		return getNextPart(p) != null;
	}

	/**
	* @param part: starting point
	* @return the part before the starting point
	**/
	public function getPreviousPart(p:Part):Null<Part>
	{
		var allParts = getAllParts();
		var i = allParts.length;
		while(i >= 0 && allParts[i] != p)
			i--;
		// Doesn't return subparts. For now?
		while(i >= 0 && allParts[i-1].parent != null)
			i--;

		return i < allParts.length ? allParts[i-1] : null;
	}

	/**
     * Start the game
     * @param	partId : the ID of the part to start.
     * @return 	the part with id partId or null if this part doesn't exist
     */
    public function start(? partId : Null<String>) : Null<Part> {

        var nextPart : Null<Part> = null;

        if (partId == null) {

            do {

                nextPart = parts[partIndex];
                partIndex++;

            } while (nextPart == null && partIndex < parts.length);

        } else if (partId != null) {

            var i : Int = 0;

            var allParts : Array<Part> = getAllParts();

            while (i < allParts.length && allParts[i].id != partId) {

                i++;
            }
	        if (i != allParts.length) {

                nextPart = allParts[i];
	            var j = 0;
	            var k = 0;

	            while (j <= i) {

	                if (allParts[j] == parts[k] && j > 0) {

	                    k++;
	                }
	                j++;
	            }
	            partIndex = k + 1;
	        }
        }
	    //setPartStarted(nextPart.id);
        return nextPart;
    }

    public function getPartById(pid : String) : Null<Part> {

    	var allParts : Array<Part> = getAllParts();

    	for (p in allParts) {

    		if (p.id == pid) {

    			return p;
    		}
    	}
    	return null;
    }

    public function getAllParts() : Array<Part> {

        var array = new Array<Part>();

        for (part in parts){

            array = array.concat(part.getAllParts());
        }
        return array;
    }
}