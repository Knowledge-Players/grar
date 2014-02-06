package grar.model;

import haxe.ds.StringMap;

import aze.display.TilesheetEx;

typedef State = {

	var value : String;
	var tracking : String;
}

enum ReadyState {

	Loading(langs : String, layout : String, displayNode : Fast, structureNode : Fast);
}

/**
 * Represents a GRAR module/game.
 */
class Grar {

	public function new(m : TrackingMode, id : String, s : State, rs : ReadyState) {

		this.mode = m;
		this.id = id;
		this.state = s;
		this.readyState = rs;
	}

	public var readyState (default, set) : ReadyState;

	public var mode (default, null) : TrackingMode;

	public var id (default, null) : String;

	public var state (default, null) : State;

	public var tilesheet (default, null) : TilesheetEx;


	///
	// GETTERS / SETTERS
	//

	public function set_readyState(v : ReadyState) : ReadyState {

		if (readyState == v) {
			return readyState;
		}
		readyState = v;
		onReadyStateChanged();

		return readyState;
	}


	///
	// CALLBACKS / API
	//

	public dynamic function onReadyStateChanged() { }
}