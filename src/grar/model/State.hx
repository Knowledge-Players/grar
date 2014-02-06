package grar.model;

import grar.model.Structure;

/**
 * Stores the current GRAR module state.
 */
class State {

	public function new() { }

	public var readyState(default,set) : Bool = false;

	public var module(default,set) : Null<Grar> = null;

	/** WIP **/

	// From StateInfos
	public var currentLanguage (default, default) : String;
	public var bookmark (default, default) : Int = -1;
	public var checksum (default, default) : Int;
	//public var tmpState (default, null) : String;

	//private var completion : Map<String, Int>;
	//private var completionOrdered : Array<String>;
	//private var allItem : Array<Trackable>;

	/*********/

	///
	// getter / setter
	//

	function set_readyState( v : Bool ) : Bool {

		if (v == readyState) {
			return v;
		}
		readyState = v;

		onReadyStateChanged();

		return readyState;
	}

	function set_module( s : Grar ) : Grar {

		module = s;

		onModuleChanged();

		module.onReadyStateChanged = onModuleStateChanged;
		onModuleStateChanged();

		return module;
	}

	///
	// CALLBACKS
	//

	public dynamic function onReadyStateChanged() : Void { }

	public dynamic function onModuleChanged() : Void { }

	public dynamic function onModuleStateChanged() : Void { }
}