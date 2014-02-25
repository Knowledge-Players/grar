package grar;

import grar.model.Config;
import grar.model.State;
import grar.model.Grar;
import grar.model.Locale;
import grar.model.InventoryToken;
import grar.model.ContextualType;
import grar.model.contextual.Notebook;
import grar.model.part.Part;

import grar.service.GameService;

import grar.controller.TrackingController;

import grar.view.Application;

import haxe.ds.StringMap;

import haxe.xml.Fast; // FIXME

/**
 * GRAR main controller
 */
class Controller {

	public function new(c : Config) {

		config = c;
		state = new State();

		gameSrv = new GameService();

		trackingCtrl = new TrackingController(this, state, config);

		application = new Application();

		init();
	}

	var config : Config;
	var state : State;

	var gameSrv : GameService;

	var trackingCtrl : TrackingController;

	var application : Application;

	/**
	 * Inits the MVC part of the Controller
	 */
	function init() : Void {

		state.onReadyStateChanged = function() {

				if (state.readyState && config.structureFileUri != null) {

					gameSrv.fetchModule( config.structureFileUri, function(m:Grar){ state.module = m; }, onError );
				}
			}

		state.onModuleStateChanged = function() {

				switch(state.module.readyState) {

					case Loading(langsUri, layoutUri, displayXml, structureXml):

						// tracking
						trackingCtrl.initTracking(state.module, function(){ loadStyles(displayXml); }, onError);


						// langs list
						gameSrv.fetchLangs( langsUri, function(l:StringMap<Locale>){

							state.locales = l;

						}, onError );


						// view (styles, ui, transitions, filters, templates)
						gameSrv.fetchSpriteSheet( displayXml.node.Ui.att.display, function(t:aze.display.TilesheetEx){

									application.tilesheet = t;

									loadStyles(displayXml);

								}, onError );

						gameSrv.fetchTransitions( displayXml.node.Transitions.att.display, function(t:StringMap<grar.view.TransitionTemplate>){ application.transitions = t; }, onError );

						gameSrv.fetchFilters( displayXml.node.Filters.att.display, function(f:StringMap<grar.view.FilterData>){ application.filters = f; }, onError );

						if (displayXml.hasNode.Templates) {

							gameSrv.fetchTemplates( displayXml.node.Templates.att.folder, function(tmpls:StringMap<Xml>){ /* FIXME state.module.templates = tmpls; */ }, onError );
					    }


						// game model (parts, contextuals)

						for (contextual in structureXml.nodes.Contextual) {

							var contextualType : ContextualType = Type.createEnum(ContextualType, contextual.att.type.toUpperCase());

							switch(contextualType) {

								case NOTEBOOK:

									gameSrv.fetchNotebook(contextual.att.file, contextual.att.display, function(m:Notebook,i:StringMap<grar.model.InventoryToken>,v:grar.view.Display.DisplayData){

											application.createNotebook(v);
											state.module.addInventoryTokens(i);
											state.module.notebook = m;

										}, onError);
								
								case GLOSSARY:

									gameSrv.fetchGlossary(contextual.att.file, function(g:grar.model.contextual.Glossary){
			
											state.module.glossary = g;

										}, onError);
								
								case BIBLIOGRAPHY:

									gameSrv.fetchBibliography(contextual.att.file, function(b:grar.model.contextual.Bibliography){
			
											state.module.bibliography = b;

										}, onError);
								
								case MENU:

									gameSrv.fetchMenu(contextual.att.display, contextual.has.file ? contextual.att.file : null, function(d:grar.view.Display.DisplayData, m:Null<grar.view.contextual.menu.MenuDisplay.MenuData>){

											application.createMenu(d);
											application.menuData = m;

										}, onError);

								default: // nothing
							}
						}
				        if (structureXml.has.inventory) {
#if (flash || openfl)
				        	gameSrv.fetchInventory(structureXml.att.inventory, function(i:StringMap<InventoryToken>, tn:grar.view.component.container.WidgetContainer.WidgetContainerData, ti:StringMap<{ small:flash.display.BitmapData, large:flash.display.BitmapData }>){
#else
				        	gameSrv.fetchInventory(structureXml.att.inventory, function(i:StringMap<InventoryToken>, tn:grar.view.component.container.WidgetContainer.WidgetContainerData, ti:StringMap<{ small:String, large:String }>){
#end
				        			state.module.addInventoryTokens(i);
				        			application.createTokenNotification(tn);
									application.tokensImages = ti;

				        		}, onError);
				        }

				        // Load part models
				        var parts : Array<Part> = [];

				        for (partXml in structureXml.nodes.Part) {

				        	gameSrv.fetchPart(partXml.x, function(p:Part){

				        			parts.push(p);

				        		}, onError);
				        }

						state.onModulePartsChanged = function() {

								// Menu hasn't been set, creating the default
						        if (application.menuData == null) {

						        	createDefaultMenu();
						        }

// FIXME / TODO in tracking controller            if (stateInfos.tmpState != null) {

// FIXME / TODO in tracking controller                stateInfos.loadStateInfos(stateInfos.tmpState);
// FIXME / TODO in tracking controller            }
// FIXME / TODO in tracking controller            for (part in getAllParts()) {

// FIXME / TODO in tracking controller                part.isDone = stateInfos.isPartFinished(part.id);
// FIXME / TODO in tracking controller                part.isStarted = stateInfos.isPartStarted(part.id);
// FIXME / TODO in tracking controller            }

						        loadlayouts(layoutUri);
							}

				        state.module.parts = parts;


					default: // nothing
				}
			}

		state.onModuleChanged = function() {

				// place here cleaning code for any potential previous module

				state.currentLocale = null;
			}

		state.onCurrentLocaleChanged = function() {

				if (state.currentLocale == null) {

					return;
				}

				loadCurrentLocale();
			}

		state.onLocalesAdded = function() {

				// TODO 
				// for each lang, flags.set(value, flagIconPath);

				loadCurrentLocale();
			}

		application.onLayoutsChanged = function() {

				// last call before the user experience actually starts
        		application.initMenu();
			}

		state.readyState = true;
	}

	function createMenuLevel(p : Part, ? l : Int = 1) : grar.view.contextual.menu.MenuDisplay.LevelData {

		var name : String = "h" + l;
		var id : String = p.id;
		var icon : Null<String> = null;
		var items : Array<grar.view.contextual.menu.MenuDisplay.LevelData> = [];

		for (pe in p.elements) {

			switch (pe) {

				case Part(sp):

					if (sp.hasParts()) {

						items.push(createMenuLevel(sp, l++));
					
					} else {

						items.push({ name: "item", id: sp.id });
					}
				
				default: // nothing
			}
        }
        return { name: name, id: id, icon: icon, items: items };
	}
	function createDefaultMenu() : Void {

    	var md : grar.view.contextual.menu.MenuDisplay.MenuData = { levels: [] };

    	for (part in state.module.parts) {

            md.levels.push(createMenuLevel(part));
        }
        application.menuData = md;
	}

	function loadStyles(displayXml : Fast) : Void { // FIXME avoid Fast in ctrl

		if (state.currentLocale != null && application.tilesheet != null) { // check if enought

			// only when tilesheet loaded and currentLocale known
	        var localizedPathes : Array<{ p : String, e : String }> = [];

			for (s in displayXml.nodes.Style) {

	            var fullPath = s.att.file.split("/");
	            var lp : String = "";

	            for (i in 0...fullPath.length - 1) {

	                lp += fullPath[i] + "/";
	            }
	            lp += state.currentLocale + "/";
	            lp += fullPath[fullPath.length - 1];

		        var extension : String = lp.substr(lp.lastIndexOf(".") + 1);

		        localizedPathes.push({ p: lp, e: extension });
	        }

			gameSrv.fetchStyles( localizedPathes, function(s : Array<grar.view.style.StyleSheet.StyleSheetData>) {

					application.createStyles(s);

				}, onError );
		}
	}

	function loadlayouts(uri : String) : Void { // actually, code below also requires the templates to be fetch already (and styles too ?)

        gameSrv.fetchLayouts(uri, function(lm : StringMap<grar.view.layout.Layout.LayoutData>, lp : Null<String>){

				if (lp != null) {

					// FIXME Localiser.instance.layoutPath = lp;
					// lp is the id/path to the aplication wide localization file (used by the menu)
				}
				application.createLayouts(lm);

        	}, onError );
	}

	function loadCurrentLocale() : Void {

		if (state.currentLocale == null || state.locales == null) {

			return;
		}
		// TODO load lang file for current "view"
	}

	function onError(e:String) : Void {

		trace("ERROR", e);
	}
}