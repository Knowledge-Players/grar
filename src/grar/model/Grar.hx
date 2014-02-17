package grar.model;

import haxe.ds.StringMap;

import aze.display.TilesheetEx;

typedef InitState = {

	var value : String;
	var tracking : String;
}

enum ReadyState {

	Loading(langs : String, layout : String, displayNode : haxe.xml.Fast, structureNode : haxe.xml.Fast);
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
		this.styles = new StringMap();
	}

	public var readyState (default, set) : ReadyState;

	public var mode (default, null) : TrackingMode;

	public var id (default, null) : String;

	public var state (default, null) : InitState;

	public var tilesheet (default, null) : TilesheetEx;


	private var styles : StringMap<StringMap<StyleSheet>>;


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
	// API
	//

	public function getStyleSheet(locale : String, sn : String) : Null<StyleSheet> {

		if (!styles.exists(locale)) {

			return null;
		}
		return styles.get(locale).get(sn);
	}

	public function setStyleSheet(locale : String, s : StyleSheet) : Void {

		if (!styles.exists(locale) ) {

			styles.set(locale, new StringMap());
		}
		styles.get(locale).set(s.name, s);
	}

	public function countStyleSheet(locale : String) : Int {

		if (!styles.exists(locale) ) {

			return 0;
		}
		return Lambda.count(styles.get(locale));
	}

	///
	// CALLBACKS
	//

	public dynamic function onReadyStateChanged() { }
}