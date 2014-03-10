package grar.service;

import openfl.Assets;
import com.knowledgeplayers.utils.assets.AssetsStorage;

import grar.model.Grar;
import grar.model.InventoryToken;
import grar.model.localization.Locale;
import grar.model.localization.LocaleData;
import grar.model.contextual.Glossary;
import grar.model.contextual.Bibliography;
import grar.model.contextual.Notebook;
import grar.model.part.Part;

import grar.view.Display;
import grar.view.FilterData;
import grar.view.TransitionTemplate;
import grar.view.style.StyleSheet;
import grar.view.element.TokenNotification;
import grar.view.layout.Layout.LayoutData;
import grar.view.contextual.menu.MenuDisplay.MenuData;
import grar.view.contextual.NotebookDisplay;
import grar.view.component.container.WidgetContainer;

import grar.parser.XmlToDisplay;
import grar.parser.XmlToGrar;
import grar.parser.XmlToTransition;
import grar.parser.XmlToFilter;
import grar.parser.XmlToInventory;
import grar.parser.contextual.XmlToBibliography;
import grar.parser.contextual.XmlToGlossary;
import grar.parser.contextual.XmlToNotebook;
import grar.parser.contextual.XmlToMenu;
import grar.parser.layout.XmlToLayouts;
import grar.parser.part.XmlToPart;
import grar.parser.localization.XmlToLocale;
import grar.parser.style.XmlToStyleSheet;
import grar.parser.style.JsonToStyleSheet;

import aze.display.TilesheetEx;

import com.knowledgeplayers.utils.assets.loaders.concrete.TextAsset;

import haxe.ds.StringMap;

class GameService {

	public function new() { }

	public function fetchLocaleData(locale : String, path : String, onSuccess : LocaleData -> Void, onError : String -> Void) : Void {

		var ret : LocaleData;

		try {

			ret = XmlToLocale.parseData(locale, AssetsStorage.getXml(path));

		} catch(e:String) {

			onError(e);
			return;
		}
		onSuccess(ret);
	}

	public function fetchLayouts(path : String, templates : StringMap<Xml>, onSuccess : StringMap<LayoutData> -> Null<String> -> Void, onError : String -> Void) : Void {

		var ret : { lp : Null<String>, lm : StringMap<LayoutData> };

		try {

			ret = XmlToLayouts.parse(AssetsStorage.getXml(path), templates);

		} catch(e:String) {

			onError(e);
			return;
		}
		onSuccess(ret.lm, ret.lp);
	}

	public function fetchModule(uri : String, onSuccess : Grar -> Void, onError : String -> Void) : Void {

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

	public function fetchFilters(uri : String, onSuccess : StringMap<FilterData> -> Void, onError : String -> Void) : Void {

		var f : StringMap<FilterData>;

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
			l = XmlToLocale.parseLangList(AssetsStorage.getXml(uri));

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

		    	var tXml : Xml = cast(temp, TextAsset).getXml().firstElement();

		    	tmpls.set( tXml.get("ref"), tXml );
		    }

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(tmpls);
	}

	public function fetchNotebook(mPath : String, vPath : String, templates : StringMap<Xml>, onSuccess : Notebook -> StringMap<InventoryToken> -> DisplayData -> Void, onError : String -> Void) : Void {

		var m : { n: Notebook, i: StringMap<InventoryToken> };
		var v : DisplayData;

		try {

			// at the moment, grar fetches its data from embedded assets only
			m = XmlToNotebook.parseModel(mPath, AssetsStorage.getXml(mPath));

			v = XmlToDisplay.parseDisplayData(AssetsStorage.getXml(vPath), Notebook(null, null, null, null, null), templates);

			v.spritesheets = new StringMap();

			for (sk in v.spritesheetsSrc.keys()) {

				v.spritesheets.set(sk, AssetsStorage.getSpritesheet(sk));

			}

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(m.n, m.i, v);
	}

	public function fetchMenu(vPath : String, mPath : Null<String>, templates : StringMap<Xml>, onSuccess : DisplayData -> Null<MenuData> -> Void, onError : String -> Void) : Void {

		var v : DisplayData;
		var m : Null<MenuData> = null;

		try {

			// at the moment, grar fetches its data from embedded assets only
			v = XmlToDisplay.parseDisplayData(AssetsStorage.getXml(vPath), Menu(null, null, null, null, null), templates);

			v.spritesheets = new StringMap();

			for (sk in v.spritesheetsSrc.keys()) {

				v.spritesheets.set(sk, AssetsStorage.getSpritesheet(sk));
			}

			if (mPath != null) {

				m = XmlToMenu.parse(AssetsStorage.getXml(mPath));
			}

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(v, m);
	}

	public function fetchGlossary(path : String, onSuccess : Glossary -> Void, onError : String -> Void) : Void {

		var g : Glossary;

		try {

			// at the moment, grar fetches its data from embedded assets only
			g = XmlToGlossary.parse(AssetsStorage.getXml(path));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(g);
	}

	public function fetchBibliography(path : String, onSuccess : Bibliography -> Void, onError : String -> Void) : Void {

		var b : Bibliography;

		try {

			// at the moment, grar fetches its data from embedded assets only
			b = XmlToBibliography.parse(AssetsStorage.getXml(path));

		} catch (e:String) {

			onError(e);
			return;
		}
		onSuccess(b);
	}

#if (flash || openfl)
	public function fetchInventory(path : String, templates : StringMap<Xml>, onSuccess : StringMap<InventoryToken> -> WidgetContainerData -> StringMap<{ small : flash.display.BitmapData, large : flash.display.BitmapData }> -> Void, onError : String -> Void) : Void {
#else
	public function fetchInventory(path : String, templates : StringMap<Xml>, onSuccess : StringMap<InventoryToken> -> WidgetContainerData -> StringMap<{ small : String, large : String }> -> Void, onError : String -> Void) : Void {
#end

		var i : { m : StringMap<InventoryToken>, d : String };
		var id : { tn : WidgetContainerData, ti : StringMap<{ small : String, large : String }> };
#if (flash || openfl)
		var ti : StringMap<{ small : flash.display.BitmapData, large : flash.display.BitmapData }> = new StringMap();
#end
		try {

			var tXml : Xml = AssetsStorage.getXml(path);

			i = XmlToInventory.parse(tXml);

			var dtXml : Xml = AssetsStorage.getXml(i.d);

			id = XmlToInventory.parseDisplayToken(dtXml, templates);
#if (flash || openfl)
			for (k in id.ti.keys()) {

				ti.set(k, { small: AssetsStorage.getBitmapData(id.ti.get(k).small), large: AssetsStorage.getBitmapData(id.ti.get(k).large) });
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

	public function fetchStyles(localizedPathes : Array<{ p : String, e : String }>, onSuccess : Array<StyleSheetData> -> Void, onError : String -> Void) : Void {

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

						st.font =  Assets.getFont(st.values.get("font"));// trace("got font "+st.values.get("font")+" => "+st.font);
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
	}

	public function fetchParts(xml : Xml, templates : StringMap<Xml>, onSuccess : Array<Part> -> Void, onError : String -> Void) : Void {

		try {

			var pa : Array<Part> = [];

			var f : haxe.xml.Fast = new haxe.xml.Fast(xml);

			var cnt : Int = f.nodes.Part.length;

			for (partXml in f.nodes.Part) {

				var pp : PartialPart = XmlToPart.parse(partXml.x);

				fetchPartContent( partXml.x, pp, templates, null, function(p : Part) {

						pa.push(p);

						cnt--;

						if (cnt == 0) {

							onSuccess(pa);
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

	private function fetchPartContent(innerXml : Xml, pp : PartialPart, templates : StringMap<Xml>, parentDisplaySrc : Null<String>, onInnerSuccess : Part -> Void, onInnerError : String -> Void) {

		var ret : { p : Part, pps : Array<PartialPart> } = null;
#if (flash || openfl)
		if (pp.pd.soundLoopSrc != null) {

			pp.pd.soundLoop = AssetsStorage.getSound(pp.pd.soundLoopSrc);// trace("fetch sound "+pp.pd.soundLoopSrc);
		}
#end
		if (pp.pd.displaySrc == null && parentDisplaySrc != null) {

trace("spp.pd.displaySrc was "+pp.pd.displaySrc+" and is now "+parentDisplaySrc);
			pp.pd.displaySrc = parentDisplaySrc;
		}
		if (pp.pd.displaySrc != null) {

			// fetch part display
			pp.pd.display = fetchPartDisplay(pp, templates);

		}
		if (pp.pd.file != null) {

			// at the moment, grar fetches its data from embedded assets only
			ret = XmlToPart.parseContent(pp, AssetsStorage.getXml(pp.pd.file)); // { p : Part, pps : Array<PartialPart> }

		} else if (innerXml.elements().hasNext()) {

			ret = XmlToPart.parseContent(pp, innerXml);
			
		}

		//var cnt : Int = pp.pd.partialSubParts.length;
		var cnt : Int = ret.pps.length;
//trace("found "+cnt+" sub parts");
		if (cnt == 0) {

			//ret.p.loaded = true; // TODO check if still useful
			onInnerSuccess( ret.p );

		} else {
//trace("ret.pps = "+pp.pd.partialSubParts);
			for ( spp in ret.pps ) {

				fetchPartContent(spp.pd.xml, spp, templates, pp.pd.displaySrc, function(sp : Part) {

						cnt--;

						ret.p.elements.push(Part(sp));
						sp.parent = ret.p;
						sp.onActivateTokenRequest = ret.p.onActivateTokenRequest;

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

	function fetchPartDisplay(pp : PartialPart, templates : StringMap<Xml>) : DisplayData {

		var pd : DisplayData = switch (pp.type) {

				case Dialog, Part: XmlToDisplay.parseDisplayData(AssetsStorage.getXml(pp.pd.displaySrc), Part, templates);

				case Strip: XmlToDisplay.parseDisplayData(AssetsStorage.getXml(pp.pd.displaySrc), Strip, templates);

				case Activity: XmlToDisplay.parseDisplayData(AssetsStorage.getXml(pp.pd.displaySrc), Activity(null), templates);
			}

		pd.spritesheets = new StringMap();

		for (sk in pd.spritesheetsSrc.keys()) {

			pd.spritesheets.set(sk, AssetsStorage.getSpritesheet(pd.spritesheetsSrc.get(sk)));

		}
		return pd;
	}
}