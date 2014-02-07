package grar.model;

import grar.model.Grar;
import grar.model.Tracking;

/**
 * Stores the current GRAR module state.
 */
class State {

	public function new() { }

	public var readyState (default,set) : Bool = false;

	public var module (default,set) : Null<Grar> = null;

	/** WIP **/

	public var tracking (default,set) : Null<Tracking> = null;

	// From StateInfos
	public var currentLanguage (default,set) : Null<String> = null;
	public var bookmark (default,default) : Int = -1;
	public var checksum (default,default) : Int;
	//public var tmpState (default, null) : String;

	//private var completion : Map<String, Int>;
	//private var completionOrdered : Array<String>;
	//private var allItem : Array<Trackable>;

	/*********/

	///
	// getter / setter
	//

	function set_tracking( v : Tracking ) : Tracking {

		tracking = v;

		tracking.onLocationChanged = onTrackingLocationChanged;

		onTrackingChanged();

		return tracking;
	}

	function set_currentLanguage( v : String ) : String {

		if (v == currentLanguage) {
			return v;
		}
		currentLanguage = v;

		onCurrentLanguageChanged();

		return currentLanguage;
	}

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

	public dynamic function onTrackingChanged() : Void { }

	public dynamic function onTrackingLocationChanged() : Void { }

	public dynamic function onCurrentLanguageChanged() : Void { }

	public dynamic function onReadyStateChanged() : Void { }

	public dynamic function onModuleChanged() : Void { }

	public dynamic function onModuleStateChanged() : Void { }
}