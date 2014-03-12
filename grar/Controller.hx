package grar;

import grar.model.Config;
import grar.model.State;
import grar.model.Grar;
import grar.model.localization.Locale;
import grar.model.InventoryToken;
import grar.model.ContextualType;
import grar.model.contextual.Notebook;
import grar.model.part.Part;

import grar.service.GameService;

import grar.controller.TrackingController;
import grar.controller.LocalizationController;

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

		application = new Application();

		trackingCtrl = new TrackingController(this, state, config, application);
		localizationCtrl = new LocalizationController(this, state, config, application, gameSrv);
	}

	var config : Config;
	var state : State;

	var gameSrv : GameService;

	var trackingCtrl : TrackingController;
	var localizationCtrl : LocalizationController;

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


						// layout ref for the view
						application.mainLayoutRef = state.module.ref;

						// tracking
						trackingCtrl.initTracking(state.module, function(){

								loadStyles(displayXml);

							}, onError);

						// langs list
						gameSrv.fetchLangs( langsUri, function(l:StringMap<Locale>){
 
							state.module.locales = l;

						}, onError );


						// view (styles, ui, transitions, filters, templates)
						gameSrv.fetchSpriteSheet( displayXml.node.Ui.att.display, function(t:aze.display.TilesheetEx){

								application.tilesheet = t;

								loadStyles(displayXml);

							}, onError );

						gameSrv.fetchTransitions( displayXml.node.Transitions.att.display, function(t:StringMap<grar.view.TransitionTemplate>){

								application.transitions = t;

							}, onError );

						gameSrv.fetchFilters( displayXml.node.Filters.att.display, function(f:StringMap<grar.view.FilterData>){

								application.createFilters(f);

							}, onError );

						var templates : Null<StringMap<Xml>> = null;

						if (displayXml.hasNode.Templates) {

							gameSrv.fetchTemplates( displayXml.node.Templates.att.folder, function(tmpls:StringMap<Xml>){

									templates = tmpls;

									state.module.readyState = LoadingGame(layoutUri, displayXml, structureXml, templates);

								}, onError );
					    
					    } else {

					    	state.module.readyState = LoadingGame(layoutUri, displayXml, structureXml, templates);
					    }


					case LoadingGame(layoutUri, displayXml, structureXml, templates):

						var menuData : grar.view.contextual.menu.MenuDisplay.MenuData = null;

						// game model & views (parts, contextuals)

						for (contextual in structureXml.nodes.Contextual) {

							var contextualType : ContextualType = Type.createEnum(ContextualType, contextual.att.type.toUpperCase());

							switch(contextualType) {

								case NOTEBOOK:

									gameSrv.fetchNotebook(contextual.att.file, contextual.att.display, templates, function(m:Notebook,i:StringMap<grar.model.InventoryToken>,v:grar.view.Display.DisplayData){

											application.createNotebook(v);
											state.module.inventory = i;
											state.module.notebook = m;

										}, onError);
								
								case MENU:

									gameSrv.fetchMenu(contextual.att.display, contextual.has.file ? contextual.att.file : null, templates, function(d:grar.view.Display.DisplayData, m:Null<grar.view.contextual.menu.MenuDisplay.MenuData>){

											application.createMenu(d);
											menuData = m;

										}, onError);
							}
						}

				        // Load part models
						state.onModulePartsChanged = function() {

								// Menu hasn't been set, creating the default
						        if (menuData == null) {

						        	createDefaultMenu();
						        
						        } else {

						        	application.menuData = addMenuPartsInfo(menuData);
						        }

						        trackingCtrl.updatePartsCompletion();

						        loadlayouts(layoutUri, templates);
							}

						gameSrv.fetchParts(structureXml.x, templates, function(pa:Array<Part>){

				        		state.module.parts = pa;

			        		}, onError);


				    case Ready:
//trace("Ready");
				    	launchGame();
				}
			}

		state.onModuleNotebookChanged = function() {

			if (state.module.notebook != null) {

				application.notebook.model = state.module.notebook;
			}
		}

		state.onModuleChanged = function() {

				// place here cleaning code for any potential previous module

				state.module.currentLocale = null;
			}

		state.onPartFinished = function(p : grar.model.part.Part) {
trace("state.onPartFinished");
				onPartFinished(p);

				for (part in state.module.getAllParts()) {

					if (!part.isDone && part.canStart()) {

						application.menu.unlockNextPart(part.id);
						/* Before we had this also (from MenuDisplay)
						if (!part.canStart()) {

							buttons.get(part.id).toggleState = "lock";

						}
						*/
					}
				}
			}

		state.onInventoryTokenActivated = function(t : InventoryToken) {

				application.setActivateToken(t);
			}

		application.onPartLoaded = function(p : Part) {

				application.setPartLoaded(p, state.module.getAllItems(), state.module.getAllParts());
			}

		application.onMenuUpdateDynamicFieldsRequest = function() {

				for (field in application.menu.dynamicFields) {

					if (field.content == "unlock_counter") {

						var parent : Part = state.module.getPartById(field.field.ref);
						var numUnlocked = 0;

						if (parent != null) {

							var children = parent.getAllParts();
							
							if (children.length <= 1) {

								var totalChildren = 0;
								var allParts = state.module.getAllParts();
								
								for (part in allParts) {

									if (StringTools.startsWith(part.id, field.field.ref) && part.id != field.field.ref) {

										totalChildren++;
										
										if (part.canStart()) {

											numUnlocked++;
										}
									}
								}
								application.menu.updateDynamicFields(numUnlocked, totalChildren);
							
							} else {

								for (child in children) {

									if (child.canStart()) {

										numUnlocked++;
									}
								}
								application.menu.updateDynamicFields(numUnlocked, children.length);
							}
						}
					}
				}
			}

		application.onMenuButtonStateRequest = function(partName : String) : { l : Bool, d : Bool } {

				for (part in state.module.getAllParts()) {

					if (part.name == partName) {

						return { l: !part.canStart(), d: part.isDone };
					}
				}
				return null;
			}

		application.onMenuClicked = function(partId : String) {

				if (displayPartById(partId)) {

					application.menu.setMenuExit();
				}
			}

		application.onMenuAdded = function() {
			
				var i = 0;

				var allParts : Array<Part> = state.module.getAllParts();

				while (i < allParts.length && allParts[i].isDone) {

					i++;
				}
				application.menu.setCurrentPart(allParts[i]);
			}

		application.onLayoutsChanged = function() {

				// last call before the user experience actually starts
        		//application.initMenu();
			}

		application.onExitPart = function(pid : String) {
trace("onExitPart");
				state.module.setPartFinished(pid);
			}

		application.onActivateTokenRequest = function(tokenId : String) {

				state.module.activateInventoryToken(tokenId);

			}

		application.onQuitGameRequest = function() {

				trackingCtrl.exitModule(state.module, function() {
#if flash
						if (flash.external.ExternalInterface.available) {

							flash.external.ExternalInterface.call("quitModule");
						
						} else {

							flash.system.System.exit(0);
						}
#end
					}, onError);
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

		if (state.module.currentLocale != null && application.tilesheet != null) { // check if enought

			// only when tilesheet loaded and currentLocale known
	        var localizedPathes : Array<{ p : String, e : String }> = [];

			for (s in displayXml.nodes.Style) {

	            var fullPath = s.att.file.split("/");
	            var lp : String = "";

	            for (i in 0...fullPath.length - 1) {

	                lp += fullPath[i] + "/";
	            }
	            lp += state.module.currentLocale + "/";
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

        gameSrv.fetchLayouts(uri, templates, function(lm : StringMap<grar.view.layout.Layout.LayoutData>, lp : Null<String>){

				if (lp != null) {

					// lp is the id/path to the application wide localization file (used by the menu)
					state.module.interfaceLocaleDataPath = lp;
				}
				application.createLayouts(lm);

				state.module.readyState = Ready; // FIXME reorganize init tasks and place in the safest place

        	}, onError );
	}

	function displayPartById(? partId : String, interrupt : Bool = false) : Bool {

		return application.displayPart(state.module.start(partId), interrupt);
	}

	function launchGame() : Void {
trace("=============> launch game");
		application.startMenu();

		application.changeLayout("default");

		var startingPart : String = null;

// FIXME		if(game.stateInfos.bookmark > 0)
// FIXME			startingPart = game.getAllItems()[game.stateInfos.bookmark].id;

		displayPartById(startingPart);
	}

	function onPartFinished(p : Part) {

		application.setFinishedPart(p.id);
trace("p.next = "+p.next);
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

	public function onError(e:String) : Void {

		trace("ERROR", e);
		trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
		throw "exit";
	}
}