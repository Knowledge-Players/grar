package grar.model;

import grar.model.Grar;
import grar.model.tracking.Tracking;
import grar.model.localization.Locale;

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

	/*********/

	public var currentStyleSheet (default, set) : Null<String> = null;


	///
	// GETTER / SETTER
	//

	function set_currentStyleSheet( v : Null<String> ) : Null<String> {

		currentStyleSheet = v;

		onCurrentStyleSheetChanged();

		return currentStyleSheet;
	}

	function set_tracking( v : Tracking ) : Tracking {

		tracking = v;

		tracking.onScoreChanged = onTrackingScoreChanged;
		tracking.onLocationChanged = onTrackingLocationChanged;
		tracking.onStatusChanged = onTrackingStatusChanged;
		tracking.onSuccessStatusChanged = onTrackingSuccessStatusChanged;
		tracking.onSuspendDataChanged = onTrackingSuspendDataChanged;

		onTrackingChanged();

		return tracking;
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

		module.onPartsChanged = function(){ onModulePartsChanged(); };
		module.onLocaleListChanged = function(){ onLocaleListChanged(); };
		module.onCurrentLocaleChanged = function(){ onCurrentLocaleChanged(); };
		module.onCurrentLocalePathChanged = function(){ onCurrentLocalePathChanged(); };
		module.onPartFinished = function(p:grar.model.part.Part){ onPartFinished(p); };
		module.onInventoryTokenActivated = function(it : grar.model.InventoryToken){ onInventoryTokenActivated(it); };

		onModuleChanged();

		module.onReadyStateChanged = function(){ onModuleStateChanged(); };
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

	public dynamic function onTrackingScoreChanged() : Void { }

	public dynamic function onTrackingSuspendDataChanged() : Void { }

	public dynamic function onReadyStateChanged() : Void { }

	public dynamic function onModuleChanged() : Void { }

	public dynamic function onModuleStateChanged() : Void { }

	public dynamic function onModulePartsChanged() : Void { }

	public dynamic function onCurrentStyleSheetChanged() : Void { }

	public dynamic function onLocaleListChanged() { }

	public dynamic function onCurrentLocaleChanged() : Void { }

	public dynamic function onCurrentLocalePathChanged() : Void { }

	public dynamic function onPartFinished(p : grar.model.part.Part) : Void { }

	public dynamic function onInventoryTokenActivated(it : grar.model.InventoryToken) : Void { }
}