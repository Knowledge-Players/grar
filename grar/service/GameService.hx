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

	private var prefix:String;

	public function new(prefix: String) {
		this.prefix = prefix;
	}

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

	public function fetchParts(xml : Xml, onSuccess : Array<Part> -> Void, onError : String -> Void) : Void {

		try {

			var parts : Array<Part> = [];

			var f = new haxe.xml.Fast(xml);

			var numPart : Int = f.nodes.Part.length + f.nodes.Activity.length;
			var partsOrder = new Map<String, Int>();
			var i = 0;

			for (partXml in f.elements) {
				if(partXml.name.toLowerCase() == "part" || partXml.name.toLowerCase() == "activity"){
					var pp : PartialPart = XmlToPart.parse(partXml.x);
					// Preserve XML order
					partsOrder[pp.pd.id] = i++;

					fetchPartContent(partXml.x, pp, function(p : Part) {
							parts.insert(partsOrder[p.id], p);

							numPart--;

							if (numPart == 0) {
								onSuccess(parts);
							}

						}, onError );
				}
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
			var http = new Http(prefix != "" ? prefix+"/"+uri : uri);
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