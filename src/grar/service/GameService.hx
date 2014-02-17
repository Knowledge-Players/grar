package grar.service;

import grar.model.Grar;
import grar.model.TransitionTemplate;
import grar.model.FilterType;
import grar.model.StyleSheet;
import grar.model.Locale;

import grar.parser.XmlToGrar;
import grar.parser.XmlToTransition;
import grar.parser.XmlToFilter;
import grar.parser.XmlToStyleSheet;
import grar.parser.JsonToStyleSheet;

import aze.display.TilesheetEx;

import com.knowledgeplayers.utils.assets.AssetsStorage;

import haxe.ds.StringMap;

class GameService {

	public function new() { }

	public function fetchModule( uri : String, onSuccess : Grar -> Void, onError : String -> Void ) : Void {

		var m : Grar;

		try {

			// at the moment, grar fetches its data from embedded assets only
			m =  XmlToGrar.parse(AssetsStorage.getXml(uri));

		} catch(e:String) {

			onError(e);
			return;
		}
		onSuccess(m);
	}

	public function fetchTransitions(uri : String, onSuccess : StringMap<TransitionTemplate> -> Void, onError : String -> Void) : Void {

		var t : StringMap<TransitionTemplate>;

		try {

			// at the moment, grar fetches its data from embedded assets only
			t =  XmlToTransition.parse(AssetsStorage.getXml(uri));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(t);
	}

	public function fetchFilters(uri : String, onSuccess : StringMap<FilterType> -> Void, onError : String -> Void) : Void {

		var f : StringMap<FilterType>;

		try {

			// at the moment, grar fetches its data from embedded assets only
			f =  XmlToFilter.parse(AssetsStorage.getXml(uri));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(f);
	}

	public function fetchSpriteSheet(uri : String, onSuccess : TilesheetEx -> Void, onError : String -> Void) : Void {

		var t : TilesheetEx;

		try {

			// at the moment, grar fetches its data from embedded assets only
			t =  AssetsStorage.getSpritesheet(uri);

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(t);
	}

	public function fetchLangs(uri : String, onSuccess : StringMap<Locale> -> Void, onError : String -> Void) : Void {

		var l : StringMap<Locale>;

		try {

			// at the moment, grar fetches its data from embedded assets only
			l = XmlToLangs(AssetsStorage.getXml(uri));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(l);
	}

	public function loadLang(path : String, onSuccess : -> Void, onError : String -> Void) : Void {


	}

	public function fetchStyle(path : String, ext : String, tilesheet : aze.display.TilesheetEx, 
		onSuccess : StyleSheet -> Void, onError : String -> Void) : Void {

		var s : StyleSheet;

		try {
			// at the moment, grar fetches its data from embedded assets only
			switch(ext.toLowerCase()) {

				case "json":
					s = JsonToStyleSheet(AssetsStorage.getText(path), tilesheet);

				case "xml":
					s = XmlToStyleSheet(AssetsStorage.getXml(path), tilesheet);

				default:
					throw "unsupported style format "+ext;
			}

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(s);
	}
}