package grar.service;

import haxe.Http;

import grar.model.contextual.MenuData;
import grar.model.Grar;
import grar.model.InventoryToken;
import grar.model.localization.Locale;
import grar.model.localization.LocaleData;
import grar.model.contextual.Glossary;
import grar.model.contextual.Bibliography;
import grar.model.contextual.Notebook;
import grar.model.part.Part;

import grar.parser.XmlToGrar;
import grar.parser.contextual.XmlToBibliography;
import grar.parser.contextual.XmlToGlossary;
import grar.parser.contextual.XmlToNotebook;
import grar.parser.contextual.XmlToMenu;
import grar.parser.part.XmlToPart;
import grar.parser.localization.XmlToLocale;

import haxe.ds.StringMap;

class GameService {

	public function new() { }

	public function fetchLocaleData(locale : String, path : String, onSuccess : LocaleData -> Void, onError : String -> Void) : Void {

		var ret : LocaleData;
		loadXml(path, function(xml: Xml){
			ret = XmlToLocale.parseData(locale, xml);
			onSuccess(ret);
		}, onError);
	}

	public function fetchModule(uri : String, onSuccess : Grar -> Void, onError : String -> Void) : Void {

		var m : Grar;
		loadXml(uri, function(xml: Xml){
				m =  XmlToGrar.parse(xml);
				onSuccess(m);
			}, onError);
	}

	public function fetchLangs(uri : String, onSuccess : StringMap<Locale> -> Void, onError : String -> Void) : Void {

		var l : StringMap<Locale>;
		loadXml(uri, function(xml: Xml){
				l = XmlToLocale.parseLangList(xml);
				onSuccess(l);
			}, onError);
	}

	/*public function fetchTemplates( path : String, onSuccess : StringMap<Xml> -> Void, onError : String -> Void ) : Void {

	    var tmpls : StringMap<Xml> = new StringMap();

		try {

			// at the moment, grar fetches its data from embedded assets only
	    	var templates = AssetsStorage.getFolderContent(path, "xml");

		    for (temp in templates) {

		    	var tXml : Xml = cast(temp, TextAsset).getXml().firstElement();

		    	tmpls.set( tXml.get("ref"), tXml );
		    }

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(tmpls);
	}*/

	public function fetchNotebook(uri : String, onSuccess : Notebook -> StringMap<InventoryToken> -> Void, onError : String -> Void) : Void {

		var m : { n: Notebook, i: StringMap<InventoryToken> };
		loadXml(uri, function(xml: Xml){
				m = XmlToNotebook.parseModel(uri, xml);
				onSuccess(m.n, m.i);
			}, onError);
	}

	public function fetchMenu(uri : Null<String>, onSuccess :Null<MenuData> -> Void, onError : String -> Void) : Void {

		var m : Null<MenuData> = null;

		if (uri != null) {
			loadXml(uri, function(xml: Xml){
				m = XmlToMenu.parse(xml);
				onSuccess(m);
			}, onError);
		}
		else
			onSuccess(m);
	}

	public function fetchGlossary(uri : String, onSuccess : Glossary -> Void, onError : String -> Void) : Void {

		var g : Glossary;
		loadXml(uri, function(xml: Xml){
				g = XmlToGlossary.parse(xml);
				onSuccess(g);
			}, onError);
	}

	public function fetchBibliography(uri : String, onSuccess : Bibliography -> Void, onError : String -> Void) : Void {

		var b : Bibliography;
		loadXml(uri, function(xml: Xml){
				b = XmlToBibliography.parse(xml);
				onSuccess(b);
			}, onError);
	}

	/*public function fetchStyles(localizedPathes : Array<{ p : String, e : String }>, onSuccess : Array<StyleSheetData> -> Void, onError : String -> Void) : Void {

		var s : Array<StyleSheetData> = [];

		try {

			for (l in localizedPathes) {

				var ssd : StyleSheetData;

				// at the moment, grar fetches its data from embedded assets only
				switch(l.e.toLowerCase()) {

					case "json":

						ssd = JsonToStyleSheet.parse(AssetsStorage.getText(l.p));

					case "xml":

						ssd = XmlToStyleSheet.parse(AssetsStorage.getXml(l.p));

					default:

						throw "unsupported style format " + l.e;
				}
#if (flash || openfl)
				for (st in ssd.styles) {

					if (st.values.get("font") != null) {

						st.font =  Assets.getFont(st.values.get("font"));
					}
					if (st.iconSrc != null && st.iconSrc.indexOf(".") > 0) {

						st.icon = AssetsStorage.getBitmapData(st.iconSrc);
					}
					if (st.backgroundSrc != null) {

						if (Std.parseInt(st.backgroundSrc) == null) {

							st.background = AssetsStorage.getBitmapData(st.backgroundSrc);
						}
					}
				}
#end
				s.push(ssd);
			}


		} catch (e:String) {

			onError(e);
			return;
		}

		onSuccess(s);
	}*/

	public function fetchParts(xml : Xml, onSuccess : Array<Part> -> Void, onError : String -> Void) : Void {

		try {

			var parts : Array<Part> = [];

			var f : haxe.xml.Fast = new haxe.xml.Fast(xml);

			var numPart : Int = f.nodes.Part.length;

			for (partXml in f.nodes.Part) {

				var pp : PartialPart = XmlToPart.parse(partXml.x);

				fetchPartContent(partXml.x, pp, function(p : Part) {

						parts.push(p);

						numPart--;

						if (numPart == 0) {

							onSuccess(parts);
						}

					}, onError );
			}

		} catch (e:String) {

			onError(e);
			return;
		}
	}


	///
	// INTERNALS
	//

	private function fetchPartContent(innerXml : Xml, pp : PartialPart, onInnerSuccess : Part -> Void, onInnerError : String -> Void) {

		var ret : { p : Part, pps : Array<PartialPart> } = null;
#if (flash)
		if (pp.pd.soundLoopSrc != null) {

			pp.pd.soundLoop = AssetsStorage.getSound(pp.pd.soundLoopSrc);
		}
#end

		if (pp.pd.file != null) {
			loadXml(pp.pd.file, function(xml: Xml){
				ret = XmlToPart.parseContent(pp, xml);
				fetchPartContentRecursive(ret, pp, onInnerSuccess, onInnerError);
			}, onInnerError);

		} else if (innerXml.elements().hasNext()) {
			ret = XmlToPart.parseContent(pp, innerXml);
			fetchPartContentRecursive(ret, pp, onInnerSuccess, onInnerError);
		}

	}

	private function fetchPartContentRecursive(ret : {p : Part, pps : Array<PartialPart>}, pp : PartialPart, onInnerSuccess : Part -> Void, onInnerError : String -> Void):Void
	{
		var cnt : Int = ret.pps.length;

		if (cnt == 0)
			onInnerSuccess( ret.p );
		else {

			for ( spp in ret.pps ) {

				fetchPartContent(spp.pd.xml, spp, function(sp : Part) {

					cnt--;

					ret.p.elements.push(Part(sp));
					sp.parent = ret.p;

					if (sp.file == null) {

						sp.file = ret.p.file; // probably useless now
					}
					if (cnt == 0) {

						onInnerSuccess(ret.p);
					}

				}, onInnerError);
			}
		}
	}

	private function loadXml(uri:String, onSuccess: Xml -> Void, onError: String -> Void):Void
	{
		if(uri != null && uri != ""){
			var http = new Http(uri);
			http.onData = function(data){
				onSuccess(Xml.parse(data));
			}

			http.onError = function(msg){
				onError(msg);
			}
			http.request();
		}
	}
}