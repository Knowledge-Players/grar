package grar.model;

import grar.model.Grar;
import grar.model.Tracking;

import haxe.ds.StringMap;


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
	public var currentLocale (default,set) : Null<String> = null;

	public var bookmark (default,default) : Int = -1;

	public var checksum (default,default) : Int;

	//public var tmpState (default, null) : String;

	//private var completion : Map<String, Int>;
	//private var completionOrdered : Array<String>;
	//private var allItem : Array<Trackable>;

	/*********/

	public var currentStyleSheet (default, set) : Null<String> = null;

	public var locales (default, set) : Null<StringMap<Locale>> = null;

	public var localeStrings (default, set) : Null<StringMap<String>> = null;


	///
	// GETTER / SETTER
	//

	function set_currentStyleSheet( v : Null<String> ) : Null<String> {

		currentStyleSheet = v;

		onCurrentStyleSheetChanged();

		return currentStyleSheet;
	}

	function set_locales( v : Null<StringMap<Locale>> ) : Null<StringMap<Locale>> {

		locales = v;

		onLocalesAdded();

		return locales;
	}

	function set_localeStrings( v : Null<StringMap<String>> ) : Null<StringMap<String>> {

		localeStrings = v;

		onLocaleLoaded();

		return localeStrings;
	}

	function set_tracking( v : Tracking ) : Tracking {

		tracking = v;

		tracking.onLocationChanged = onTrackingLocationChanged;
		tracking.onStatusChanged = onTrackingStatusChanged;
		tracking.onSuccessStatusChanged = onTrackingSuccessStatusChanged;
		tracking.onSuspendDataChanged = onTrackingSuspendDataChanged;

		onTrackingChanged();

		return tracking;
	}

	function set_currentLocale( v : String ) : String {

		if (v == currentLocale) {
			return v;
		}
		currentLocale = v;

		onCurrentLocaleChanged();

		return currentLocale;
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

		module.onPartsChanged = onModulePartsChanged;

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

	public dynamic function onTrackingStatusChanged() : Void { }

	public dynamic function onTrackingSuccessStatusChanged() : Void { }

	public dynamic function onTrackingSuspendDataChanged() : Void { }

	public dynamic function onCurrentLocaleChanged() : Void { }

	public dynamic function onReadyStateChanged() : Void { }

	public dynamic function onModuleChanged() : Void { }

	public dynamic function onModuleStateChanged() : Void { }

	public dynamic function onModulePartsChanged() : Void { }

	public dynamic function onCurrentStyleSheetChanged() : Void { }

	public dynamic function onLocalesAdded() : Void { }

	public dynamic function onLocaleLoaded() : Void { }
}