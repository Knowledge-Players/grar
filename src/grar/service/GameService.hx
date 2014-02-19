package grar.service;

import grar.model.Grar;
import grar.model.TransitionTemplate;
import grar.model.FilterType;
import grar.model.StyleSheet;
import grar.model.Locale;
import grar.model.InventoryToken;

import grar.view.TokenNotification;

import grar.parser.XmlToGrar;
import grar.parser.XmlToTransition;
import grar.parser.XmlToFilter;
import grar.parser.XmlToStyleSheet;
import grar.parser.JsonToStyleSheet;
import grar.parser.XmlToInventory;
import grar.parser.XmlToPart;

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

	public function fetchTemplates( path : String, onSuccess : StringMap<Xml> -> Void, onError : String -> Void ) : Void {		

	    var tmpls : StringMap<Xml> = new StringMap();

		try {

			// at the moment, grar fetches its data from embedded assets only
	    	var templates = AssetsStorage.getFolderContent(path, "xml");

		    for (temp in templates) {

		    	tmpls.set( temp.firstElement().get("ref"), cast(temp, TextAsset).getXml() );
		    }

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(tmpls);
	}

	public function fetchNotebook(mPath : String, vPath : String, onSuccess : Notebook -> StringMap<InventoryToken> -> NotebookDisplay -> Void, onError : String -> Void) : Void {

		var m : { n: Notebook, i: StringMap<InventoryToken> };
		var v : NotebookDisplay;

		try {

			// at the moment, grar fetches its data from embedded assets only
			m = XmlToNotebook.parseModel(AssetsStorage.getXml(mPath));

			v = XmlToNotebook.parseView(AssetsStorage.getXml(vPath));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(m.n, m.i, v);
	}

	public function fetchMenu(vPath : String, mPath : Null<String>, onSuccess : grar.view.contextual.menu.MenuDisplay -> Null<Xml> -> Void, onError : String -> Void) : Void {

		var v : MenuDisplay;
		var m : Null<Xml> = null;

		try {

			// at the moment, grar fetches its data from embedded assets only
			v = XmlToMenu.parseView(AssetsStorage.getXml(vPath));

			if (mPath != null) {

				m = AssetsStorage.getXml(mPath);
			}

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(v, m);
	}

	public function fetchGlossary(path : String, onSuccess : grar.model.contextual.Glossary -> Void, onError : String -> Void) : Void {

		var g : grar.model.contextual.Glossary;

		try {

			// at the moment, grar fetches its data from embedded assets only
			g = grar.parser.XmlToGlossary.parse(AssetsStorage.getXml(path));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(g);
	}

	public function fetchBibliography(path : String, onSuccess : grar.model.contextual.Bibliography -> Void, onError : String -> Void) : Void {

		var b : grar.model.contextual.Bibliography;

		try {

			// at the moment, grar fetches its data from embedded assets only
			b = grar.parser.XmlToBibliography.parse(AssetsStorage.getXml(path));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(b);
	}

#if (flash || openfl)
	public function fetchInventory(path : String, onSuccess : StringMap<InventoryToken> -> TokenNotification -> StringMap<{ small : flash.display.BitmapData, large : flash.display.BitmapData }> -> Void, onError : String -> Void) : Void {
#else
	public function fetchInventory(path : String, onSuccess : StringMap<InventoryToken> -> TokenNotification -> StringMap<{ small : String, large : String }> -> Void, onError : String -> Void) : Void {
#end
		var i : { m : StringMap<InventoryToken>, d : String };
		var id : { tn : TokenNotification, ti : StringMap<{ small : String, large : String }> };
#if (flash || openfl)
		var ti : StringMap<{ small : String, large : String }> = new StringMap();
#end
		try {

			var tXml : Xml = AssetsStorage.getXml(path);

			i = XmlToInventory.parse(tXml);

			var dtXml : Xml = AssetsStorage.getXml(i.d);

			id = XmlToInventory.parseDisplayToken(dtXml);
#if (flash || openfl)
			for (k in id.ti.keys()) {

				ti.set(k, { small: AssetsStorage.getBitmapData(id.ti.get(k.small)), large: AssetsStorage.getBitmapData(id.ti.get(k.large)) });
			}
#end
		} catch (e:String) {

			onError(e);
			return;
		}
#if (flash || openfl)
		onSuccess(i.m, id.tn, ti);
#else
		onSuccess(i.m, id.tn, id.ti);
#end
	}

	public function loadLang(path : String, onSuccess : -> Void, onError : String -> Void) : Void {

		// TODO
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

	public function fetchPart(xml : Xml, onSuccess : Part -> Void, onError : String -> Void) : Void {

		var fetchPartContent = function(innerXml : Xml, pp : PartialPart, onInnerSuccess : Part -> Void, onInnerError : String -> Void) {

				var ret : { p : Part, pps : Array<PartialPart> };
#if (flash || openfl)
				pp.pd.soundLoop = AssetsStorage.getSound(soundLoopSrc);
#end
				if (pp.pd.file != null) {

					// at the moment, grar fetches its data from embedded assets only
					ret = XmlToPart.parseContent(pp, AssetsStorage.getXml(pd.file)); // { p : Part, pps : Array<PartialPart> }

				} else if (xml.elements.hasNext()) {

					ret = XmlToPart.parseContent(pp, innerXml);
					
				}
				var cnt : Int = pp.pd.partialSubParts.length;

				if (cnt == 0) {

					ret.p.loaded = true; // TODO check if still useful
					onInnerSuccess( ret.p );

				} else {

					for ( spp in pp.pd.partialSubParts ) {

						fetchPartContent( spp.pd.xml, spp, function(sp : Part) {

								cnt--;

								ret.p.elements.push(Part(sp));
								sp.parent = ret.p;

								if (sp.file == null) {

									sp.file = ret.p.file;
								}
								if (cnt == 0) {

									onInnerSuccess( ret.p );

								}

							}, onInnerError );
					}
				}
			}

		try {

			var pp : PartialPart = XmlToPart.parse(xml);

			fetchPartContent( xml, pp, onSuccess, onError );

		} catch (e:String) {

			onInnerError(e);
			return;
		}
	}
}