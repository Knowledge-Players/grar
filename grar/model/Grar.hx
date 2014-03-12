package grar.model;

import grar.model.InventoryToken;
import grar.model.contextual.Glossary;
import grar.model.contextual.Bibliography;
import grar.model.contextual.Notebook;
import grar.model.score.ScoreChart;
import grar.model.part.Part;
import grar.model.tracking.TrackingMode;
import grar.model.tracking.Trackable;
import grar.model.localization.Locale;
import grar.model.localization.LocaleData;

import haxe.ds.StringMap;
import haxe.ds.GenericStack;

typedef InitState = {

	var value : String;
	var tracking : String;
}

enum ReadyState {

	Loading(langs : String, layout : String, displayNode : haxe.xml.Fast, structureNode : haxe.xml.Fast);
	LoadingGame(layoutUri : String, displayXml : haxe.xml.Fast, structureXml : haxe.xml.Fast, templates : Null<StringMap<Xml>>);
	Ready;
}

/**
 * Represents a GRAR module / game.
 */
class Grar {

	public function new(m : TrackingMode, id : String, s : InitState, r : String, rs : ReadyState) {

		this.mode = m;
		this.id = id;
		this.state = s;
		this.ref = r;
		this.readyState = rs;
		this.inventory = new StringMap();
		this.scoreChart = new ScoreChart();
		this.completion = new StringMap();
		this.completionOrdered = new Array();
		this.stashedLocaleData = new GenericStack<LocaleData>();
	}

	public var readyState (default, set) : ReadyState;

	public var mode (default, null) : TrackingMode;

	public var id (default, null) : String;

	public var state (default, null) : InitState;

	public var ref (default, set) : String; // ref for the layout (?)

	public var notebook (default, set) : Notebook;

	public var inventory (null, default) : StringMap<InventoryToken>;

	public var glossary (default, set) : Null<Glossary> = null;

	public var bibliography (default, set) : Null<Bibliography> = null;

	public var parts (default, set) : Null<Array<Part>> = null;

	public var scoreChart (default, null) : ScoreChart;


	// Module localization related properties

	public var locales (default, set) : Null<StringMap<Locale>> = null;

	public var currentLocale (default, set) : String;

	public var currentLocaleDataPath (default, set) : Null<String> = null;

	public var interfaceLocaleDataPath (default, set) : Null<String> = null;

	public var localeData : Null<LocaleData> = null;

	private var stashedLocaleData : GenericStack<LocaleData>;

	private var sameLocale : Bool;


	// WIP

	// From StateInfos

	public var bookmark (default,default) : Int = -1;

	public var checksum (default,default) : Int;

	public var completion : StringMap<Int>;

	public var completionOrdered : Array<String>;

	//private var allItem : Array<Trackable>;

	var partIndex : Int = 0;


	///
	// CALLBACKS
	//

	public dynamic function onReadyStateChanged() { }

	public dynamic function onRefChanged() { }

	public dynamic function onNotebookChanged() { }

	public dynamic function onGlossaryChanged() { }

	public dynamic function onBibliographyChanged() { }

	public dynamic function onPartsChanged() { }

	public dynamic function onPartFinished(p : Part) { }

	public dynamic function onInventoryTokenActivated(it : InventoryToken) { }

	public dynamic function onCurrentLocalePathChanged() { }

	public dynamic function onCurrentLocaleChanged() { }

	public dynamic function onLocaleListChanged() { }


	///
	// GETTERS / SETTERS
	//

	public function set_currentLocale( v : String ) : String {
trace("set currentLocale to " + v);
		if (v == currentLocale) {
			return v;
		}
		currentLocale = v;

		onCurrentLocaleChanged();

		return currentLocale;
	}

	public function set_locales( v : Null<StringMap<Locale>> ) : Null<StringMap<Locale>> {

		locales = v;

		onLocaleListChanged();

		return locales;
	}

	public function set_interfaceLocaleDataPath(v : Null<String>) : Null<String> {

		if (interfaceLocaleDataPath == v) {

			return interfaceLocaleDataPath;
		}
		currentLocaleDataPath = interfaceLocaleDataPath = v;
//		onCurrentLocalePathChanged();

		return interfaceLocaleDataPath;
	}

	public function set_currentLocaleDataPath(v : Null<String>) : Null<String> {

		if (v != null) {

			if (currentLocaleDataPath != v) {

				stashedLocaleData.add(localeData);
				
				currentLocaleDataPath = v;

				sameLocale = false;

				onCurrentLocalePathChanged();
			
			} else {

				sameLocale = true;
			}
		
		} else {

			currentLocaleDataPath = v;

			onCurrentLocalePathChanged();
		}

		return currentLocaleDataPath;
	}

	public function set_parts(v : Null<Array<Part>>) : Null<Array<Part>> {

		if (parts == v) {

			return parts;
		}
		parts = v;

		for (p in parts) {

			p.onActivateTokenRequest = function(tid : String){ activateInventoryToken(tid); };
		}
		onPartsChanged();

		return parts;
	}

	public function set_bibliography(v : Null<Bibliography>) : Null<Bibliography> {

		if (bibliography == v) {
			return bibliography;
		}
		bibliography = v;
		onBibliographyChanged();

		return bibliography;
	}

	public function set_glossary(v : Null<Glossary>) : Null<Glossary> {

		if (glossary == v) {
			return glossary;
		}
		glossary = v;
		onGlossaryChanged();

		return glossary;
	}

	public function set_readyState(v : ReadyState) : ReadyState {

		if (readyState == v) {
			return readyState;
		}
		readyState = v;
		onReadyStateChanged();

		return readyState;
	}

	public function set_ref(v : String) : String {

		if (ref == v) {
			return ref;
		}
		ref = v;
		onRefChanged();

		return ref;
	}

	public function set_notebook(v : Notebook) : Notebook {

		if (notebook == v) {
			return notebook;
		}
		notebook = v;
		onNotebookChanged();

		return notebook;
	}


	///
	// API
	//

	/**
    * @return all trackable items of the game
    **/
    public function getAllItems() : Array<Trackable> {

        var trackable : Array<Trackable> = [];
        
        for (part in parts) {

            trackable = trackable.concat(part.getAllItems());
        }
        return trackable;
    }

	/**
    * Restore the previously stored locale
    **/
	public function restoreLocale() : Void {

		if (!sameLocale && !stashedLocaleData.isEmpty()) {

			localeData = stashedLocaleData.pop();
			
			currentLocaleDataPath = null; // shouldn't we restore it too ???
		}
	}

	public function getLocalizedContent(key : String) : Null<String> {

		if (localeData != null) {

			var content = localeData.getItem(key);
			
			if (content == null) {

				content = "unknown localized content key " + key;
			}

			return content;
		
		} else {

			trace("No locale data set. Returning null for key '"+key+"'.");

			return null;
		}
	}

	public function activateInventoryToken(tid : String) : Void {
trace("ON NEW TOKEN ACTIVATED "+tid);
		if (!inventory.exists(tid)) {

			throw 'unknown token "$tid". '+Lambda.array({ iterator: inventory.keys });
		}
		var it : InventoryToken = inventory.get(tid);

		it.isActivated = true;

		onInventoryTokenActivated(it);
	}


    public function setPartStarted(pid : String) : Void {

        completion.set(pid, 1);

        // onPartStarted(getPartById(pid));
    }

	public function setPartFinished(pid : String) : Void {

		completion.set(pid, 2);

		onPartFinished(getPartById(pid));
	}

    public function isPartStarted(pid : String) : Bool {

        return completion.get(pid) == 1;
    }

	public function isPartFinished(pid : String) : Bool {

		return completion.get(pid) == 2;
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
        return name;
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

                nextPart = parts[partIndex].start();
                partIndex++;
            
            } while (nextPart == null && partIndex < parts.length);
        
        } else if (partId != null) {

            var i : Int = 0;

            var allParts : Array<Part> = getAllParts();
            
            while (i < allParts.length && allParts[i].id != partId) {

                i++;
            }
	        if (i != allParts.length) {

                nextPart = allParts[i].start(true);
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