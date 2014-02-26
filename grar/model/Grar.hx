package grar.model;

import grar.model.InventoryToken;
import grar.model.contextual.Glossary;
import grar.model.contextual.Bibliography;
import grar.model.contextual.Notebook;
import grar.model.score.ScoreChart;
import grar.model.part.Part;
import grar.model.tracking.TrackingMode;

import haxe.ds.StringMap;

typedef InitState = {

	var value : String;
	var tracking : String;
}

enum ReadyState {

	Loading(langs : String, layout : String, displayNode : haxe.xml.Fast, structureNode : haxe.xml.Fast);
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
	}

	public var readyState (default, set) : ReadyState;

	public var mode (default, null) : TrackingMode;

	public var id (default, null) : String;

	public var state (default, null) : InitState;

	public var ref (default, set) : String; // ref for the layout (?)

	public var notebook (default, set) : Notebook;

	public var inventory (default, null) : StringMap<InventoryToken>;

	public var glossary (default, set) : Null<Glossary> = null;

	public var bibliography (default, set) : Null<Bibliography> = null;

	public var parts (default, set) : Null<Array<Part>> = null;

	public var scoreChart (default, null) : ScoreChart;

	public var interfaceLocale (default, set) : Null<String> = null;

	public var currentLocalePath (default, set) : Null<String> = null;


	// WIP

	// From StateInfos

	public var bookmark (default,default) : Int = -1;

	public var checksum (default,default) : Int;

	//public var tmpState (default, null) : String;

	private var completion : StringMap<Int>;
	public var completionOrdered : Array<String>;
	//private var allItem : Array<Trackable>;


	var partIndex : Int = 0;

	///
	// GETTERS / SETTERS
	//

	public function set_interfaceLocale(v : Null<String>) : Null<String> {

		if (interfaceLocale == v) {

			return interfaceLocale;
		}
		interfaceLocale = currentLocalePath = v;
//		onCurrentLocalePathChanged();

		return interfaceLocale;
	}

	public function set_currentLocalePath(v : Null<String>) : Null<String> {

		if (currentLocalePath == v) {

			return currentLocalePath;
		}
		currentLocalePath = v;
		onCurrentLocalePathChanged();

		return currentLocalePath;
	}

	public function set_parts(v : Null<Array<Part>>) : Null<Array<Part>> {

		if (parts == v) {
			return parts;
		}
		parts = v;
		onPartsChanged();
trace("onPartsChanged");
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

	public function setPartFinished(pid : String) : Void {

		completion.set(pid, 2);

		onPartFinished(getPartById(pid));
	}

	public function addInventoryTokens(t : StringMap<InventoryToken>) : Void {

		for (k in t.keys()) {

			inventory.set(k, t.get(k));
		}
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


	///
	// CALLBACKS
	//

	public dynamic function onReadyStateChanged() { }

	public dynamic function onRefChanged() { }

	public dynamic function onNotebookChanged() { }

	public dynamic function onGlossaryChanged() { }

	public dynamic function onBibliographyChanged() { }

	public dynamic function onPartsChanged() { }

	public dynamic function onCurrentLocalePathChanged() { }

	public dynamic function onPartFinished(p : Part) { }
}