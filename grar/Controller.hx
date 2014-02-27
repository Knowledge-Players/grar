package grar;

import grar.model.Config;
import grar.model.State;
import grar.model.Grar;
import grar.model.localization.Locale;
import grar.model.localization.LocaleData;
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
	}

	var config : Config;
	var state : State;

	var gameSrv : GameService;

	var trackingCtrl : TrackingController;

	var application : Application;

	/**
	 * Inits the MVC part of the Controller
	 */
	public function init() : Void {

		state.onReadyStateChanged = function() {

				if (state.readyState && config.structureFileUri != null) {

					gameSrv.fetchModule( config.structureFileUri, function(m:Grar){ state.module = m; }, onError );
				}
			}

		state.onModuleStateChanged = function() {

				switch(state.module.readyState) {

					case Loading(langsUri, layoutUri, displayXml, structureXml): // FIXME, no more Xml/Fast in ctrl
trace("Loading("+langsUri+", ...)");

						// layout ref for the view
						application.mainLayoutRef = state.module.ref;

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

						var templates : Null<StringMap<Xml>> = null;

						if (displayXml.hasNode.Templates) {

							gameSrv.fetchTemplates( displayXml.node.Templates.att.folder, function(tmpls:StringMap<Xml>){

									templates = tmpls;

									state.module.readyState = LoadingGame(layoutUri, displayXml, structureXml, templates);

								}, onError );
					    
					    } else {

					    	state.module.readyState = LoadingGame(layoutUri, displayXml, structureXml, templates);
					    }


					case LoadingGame(layoutUri, displayXml, structureXml, templates): // TODO passed templates to parsers...
trace("LoadingGame("+layoutUri+", ...)");
						var menuData : grar.view.contextual.menu.MenuDisplay.MenuData = null;

						// game model & views (parts, contextuals)

						for (contextual in structureXml.nodes.Contextual) {

							var contextualType : ContextualType = Type.createEnum(ContextualType, contextual.att.type.toUpperCase());

							switch(contextualType) {

								case NOTEBOOK:

									gameSrv.fetchNotebook(contextual.att.file, contextual.att.display, templates, function(m:Notebook,i:StringMap<grar.model.InventoryToken>,v:grar.view.Display.DisplayData){

											application.createNotebook(v);
											state.module.addInventoryTokens(i);
											state.module.notebook = m;

										}, onError);
								
								case GLOSSARY:

									gameSrv.fetchGlossary(contextual.att.file, function(g:grar.model.contextual.Glossary){
			
											// TODO create display ?
											state.module.glossary = g;

										}, onError);
								
								case BIBLIOGRAPHY:

									gameSrv.fetchBibliography(contextual.att.file, function(b:grar.model.contextual.Bibliography){
			
											// TODO create display ?
											state.module.bibliography = b;

										}, onError);
								
								case MENU:

									gameSrv.fetchMenu(contextual.att.display, contextual.has.file ? contextual.att.file : null, templates, function(d:grar.view.Display.DisplayData, m:Null<grar.view.contextual.menu.MenuDisplay.MenuData>){

											application.createMenu(d);
											menuData = m;

										}, onError);

								default: // nothing
							}
						}

				        if (structureXml.has.inventory) {
#if (flash || openfl)
				        	gameSrv.fetchInventory(structureXml.att.inventory, templates, function(i:StringMap<InventoryToken>, tn:grar.view.component.container.WidgetContainer.WidgetContainerData, ti:StringMap<{ small:flash.display.BitmapData, large:flash.display.BitmapData }>){
#else
				        	gameSrv.fetchInventory(structureXml.att.inventory, templates, function(i:StringMap<InventoryToken>, tn:grar.view.component.container.WidgetContainer.WidgetContainerData, ti:StringMap<{ small:String, large:String }>){
#end
				        			state.module.addInventoryTokens(i);
				        			application.createTokenNotification(tn);
									application.tokensImages = ti;

				        		}, onError);
				        }

				        // Load part models
						state.onModulePartsChanged = function() {

								// Menu hasn't been set, creating the default
						        if (menuData == null) {

						        	createDefaultMenu();
						        
						        } else {

						        	application.menuData = addMenuPartsInfo(menuData);
						        }

// FIXME / TODO in tracking controller            if (stateInfos.tmpState != null) {

// FIXME / TODO in tracking controller                stateInfos.loadStateInfos(stateInfos.tmpState);
// FIXME / TODO in tracking controller            }
// FIXME / TODO in tracking controller            for (part in getAllParts()) {

// FIXME / TODO in tracking controller                part.isDone = stateInfos.isPartFinished(part.id);
// FIXME / TODO in tracking controller                part.isStarted = stateInfos.isPartStarted(part.id);
// FIXME / TODO in tracking controller            }

						        loadlayouts(layoutUri, templates);
							}

						gameSrv.fetchParts(structureXml.x, templates, function(pa:Array<Part>){

				        		state.module.parts = pa;

			        		}, onError);


				    case Ready:
trace("Ready");
				    	launchGame();
				}
			}

		state.onModuleChanged = function() {

				// place here cleaning code for any potential previous module

				state.currentLocale = null;
			}

		state.onLocalesAdded = function() {

				// TODO ? doesn't seem to be used...
				// for each lang, flags.set(value, flagIconPath);

				// implement a loadCurrentLocale(); ?
			}

		state.onCurrentLocalePathChanged = function() {

				pushLocale(state.module.currentLocalePath);
			}

		state.onPartFinished = onPartFinished;

		application.onLayoutsChanged = function() {

				// last call before the user experience actually starts
        		application.initMenu();
			}

		application.onExitPart = function(pid : String) {

			state.module.setPartFinished(pid);
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

	function addPartsInfoToLevel(la : Array<grar.view.contextual.menu.MenuDisplay.LevelData>) : Array<grar.view.contextual.menu.MenuDisplay.LevelData> {

		for (l in la) {

			l.partName = state.module.getItemName(l.id);

			if (l.partName == null) {

				throw "can't find a name for '"+l.id+"'.";
			}
			if (l.items != null) {

				l.items = addPartsInfoToLevel(l.items);
			}
		}
		return la;
	}

	function addMenuPartsInfo(md : grar.view.contextual.menu.MenuDisplay.MenuData) : grar.view.contextual.menu.MenuDisplay.MenuData {

		md.levels = addPartsInfoToLevel(md.levels);
		
		return md;
	}

	function createDefaultMenu() : Void {

    	var md : grar.view.contextual.menu.MenuDisplay.MenuData = { levels: [] };

    	for (part in state.module.parts) {

            md.levels.push(createMenuLevel(part));
        }
        application.menuData = addMenuPartsInfo(md);
	}

	function loadStyles(displayXml : Fast) : Void { // FIXME avoid Fast in ctrl
trace("loadStyles");
		if (state.currentLocale != null && application.tilesheet != null) { // check if enought
trace("actually load styles");
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

	function loadlayouts(uri : String, templates : StringMap<Xml>) : Void { // actually, code below also requires the templates to be fetch already (and styles too ?)
trace("loadlayouts "+uri);
        gameSrv.fetchLayouts(uri, templates, function(lm : StringMap<grar.view.layout.Layout.LayoutData>, lp : Null<String>){

				if (lp != null) {

					// lp is the id/path to the application wide localization file (used by the menu)
					state.module.interfaceLocale = lp;
				}
				application.createLayouts(lm);

				state.module.readyState = Ready; // FIXME reorganize init tasks and place in the safest place

        	}, onError );
	}

	/**
	 * FIXME this shouldn't be here
	 */
	function pushLocale(l : String) : Void {

		var fullPath = l.split("/");

		var localePath : StringBuf = new StringBuf();
		localePath.add(fullPath[0] + "/");
		localePath.add(state.currentLocale + "/");

		for (i in 1...fullPath.length-1) {

			localePath.add(fullPath[i] + "/");
		}
		localePath.add(fullPath[fullPath.length-1]);

		var ld : LocaleData = new LocaleData(state.currentLocale);
		ld.setLocaleFile(localePath.toString());

		application.localeData = ld;
	}

	function launchGame() : Void {
trace("launch game");
		application.startMenu();

		application.changeLayout("default");

		application.displayPart(state.module.start(null));
	}
/*
	function startGame(game : Game, layout : String = "default"):Void
	{
		this.game = game;

		changeLayout(layout);

		if(!MenuDisplay.instance.exists || menuLoaded){
			launchGame();
		}
	}

	private function launchGame():Void
	{
		var startingPart:String = null;

		if(game.stateInfos.bookmark > 0)
			startingPart = game.getAllItems()[game.stateInfos.bookmark].id;

		displayPartById(startingPart);
	}

	public function displayPartById(?id:String, interrupt:Bool = false):Bool
	{
		return displayPart(game.start(id), interrupt);
	}
*/
	function onPartFinished(p : Part) {

		application.setFinishedPart(p.id);

		if (p.next != null) {

			var i = 0;
			
			for (next in p.next) {

				var nextPart = state.module.start(next);
				
				if (nextPart != null) {

					application.displayPart(nextPart);
				
				} else {

					application.displayContextual(Type.createEnum(ContextualType, next.toUpperCase()), (i == 0));
				}
				i++;
			}

		} else {

			application.displayNext(p);
		}
	}

	function onError(e:String) : Void {

		trace("ERROR", e);
		trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
	}
}