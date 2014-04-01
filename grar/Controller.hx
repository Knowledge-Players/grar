package grar;

import grar.model.contextual.MenuData;
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
import grar.controller.PartController;

import grar.view.Application;

import haxe.ds.StringMap;

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
		partCtrl = new PartController(this, state, application);
	}

	var config : Config;
	var state : State;

	var gameSrv : GameService;

	var trackingCtrl : TrackingController;
	var localizationCtrl : LocalizationController;
	var partCtrl : PartController;

	var application : Application;

	/**
	 * Inits the MVC part of the Controller
	 */
	public function init() : Void {

		partCtrl.onLocaleDataPathRequest = function(uri, ?onSuccess){
			localizationCtrl.setLocaleDataPath(uri, onSuccess);
		}

		partCtrl.onRestoreLocaleRequest = function(){
			localizationCtrl.restoreLocaleData();
		}

		state.onReadyStateChanged = function() {

				if (state.readyState && config.structureFileUri != null) {
					gameSrv.fetchModule( config.structureFileUri, function(m:Grar){ state.module = m; }, onError );
				}
			}

		state.onModuleStateChanged = function() {
				switch(state.module.readyState) {

					case Loading(langsUri, structureXml):

						// layout ref for the view
						//application.mainLayoutRef = state.module.ref;

						// tracking
						trackingCtrl.initTracking(state.module, function(){}, onError);

						// langs list
						gameSrv.fetchLangs( langsUri, function(l:StringMap<Locale>){

							state.module.locales = l;

						}, onError );

						state.module.readyState = LoadingGame(structureXml);

					case LoadingGame(structureXml):
						// TODO MenuController
						var menuData : MenuData = null;

						// game model & views (parts, contextuals)

						for (contextual in structureXml.nodes.Contextual) {

							var contextualType : ContextualType = Type.createEnum(ContextualType, contextual.att.type.toUpperCase());

							switch(contextualType) {

								case NOTEBOOK:

									gameSrv.fetchNotebook(contextual.att.file, function(m:Notebook,i:StringMap<grar.model.InventoryToken>){

											//application.createNotebook();
											state.module.inventory = i;
											state.module.notebook = m;

										}, onError);

								case MENU:

									gameSrv.fetchMenu(contextual.has.file ? contextual.att.file : null, function(m:Null<MenuData>){

											//application.createMenu(d);
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

								state.module.readyState = Ready;
							}

						gameSrv.fetchParts(structureXml.x, function(pa:Array<Part>){
				        		state.module.parts = pa;

			        		}, onError);


				    case Ready:
				    	launchGame();
				}
			}

		state.onModuleNotebookChanged = function() {

			if (state.module.notebook != null) {

				//application.notebook.model = state.module.notebook;
			}
		}

		state.onModuleChanged = function() {

				// place here cleaning code for any potential previous module

				state.module.currentLocale = null;
			}

		state.onPartFinished = function(p : grar.model.part.Part) {

				onPartFinished(p);

				for (part in state.module.getAllParts()) {

					if (!part.isDone && state.module.canStart(part)) {

						//application.menu.unlockNextPart(part.id);
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

		application.onMenuUpdateDynamicFieldsRequest = function() {

				/*for (field in application.menu.dynamicFields) {

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

										if (state.module.canStart(part)) {

											numUnlocked++;
										}
									}
								}
								application.menu.updateDynamicFields(numUnlocked, totalChildren);

							} else {

								for (child in children) {

									if (state.module.canStart(child)) {

										numUnlocked++;
									}
								}
								application.menu.updateDynamicFields(numUnlocked, children.length);
							}
						}
					}
				}*/
			}

		application.onMenuButtonStateRequest = function(partName : String) : { l : Bool, d : Bool } {

				for (part in state.module.getAllParts()) {

					if (part.name == partName) {

						return { l: !state.module.canStart(part), d: part.isDone };
					}
				}
				return null;
			}

		application.onMenuClicked = function(partId : String) {

				if (displayPartById(partId)) {

					//application.menu.setMenuExit();
				}
			}

		application.onMenuAdded = function() {

				var i = 0;

				var allParts : Array<Part> = state.module.getAllParts();

				while (i < allParts.length && allParts[i].isDone) {

					i++;
				}
				//application.menu.setCurrentPart(allParts[i]);
			}

		application.onLayoutsChanged = function() {

				// last call before the user experience actually starts
        		//application.initMenu();
			}

		/*application.onActivateTokenRequest = function(tokenId : String) {

				state.module.activateInventoryToken(tokenId);

			}*/

		application.onQuitGameRequest = function() {

				gameOver();
			}

		state.readyState = true;
	}

	public function gameOver():Void
	{
		trace("GAME OVER");
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

	///
	// INTERNALS
	//

	// TODO MenuController
	/*function createMenuLevel(p : Part, ? l : Int = 1) : Dynamic {

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
	}*/

	// TODO MenuController
	function addPartsInfoToLevel(la : Array<Dynamic>) : Array<Dynamic> {

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

	// TODO MenuController
	function addMenuPartsInfo(md : Dynamic) : Dynamic {

		md.levels = addPartsInfoToLevel(md.levels);

		return md;
	}

	function createDefaultMenu() : Void {

    	var md : MenuData = { levels: [] };

    	/*for (part in state.module.parts) {

            md.levels.push(createMenuLevel(part));
        }*/
        application.menuData = addMenuPartsInfo(md);
	}

	/*function loadlayouts(uri : String, templates : StringMap<Xml>) : Void { // actually, code below also requires the templates to be fetch already (and styles too ?)

        gameSrv.fetchLayouts(uri, templates, function(lm : StringMap<grar.view.layout.Layout.LayoutData>, lp : Null<String>){

				if (lp != null) {

					// lp is the id/path to the application wide localization file (used by the menu)
					state.module.interfaceLocaleDataPath = lp;
				}
				application.createLayouts(lm);

				state.module.readyState = Ready; // FIXME reorganize init tasks and place in the safest place

        	}, onError );
	}*/

	function displayPart(p : Part) : Bool {

#if !kpdebug
		// Part doesn't meet the requirements to start
		if (!state.module.canStart(p)) {

			return false;
		}
#end
		partCtrl.displayPart(p);

		return true;
	}

	function displayPartById(? partId : String) : Bool {

		return displayPart(state.module.start(partId));
	}

	function launchGame() : Void {

		application.startMenu();

		application.changeLayout("default");

		var startingPart : String = null;

		if (state.module.bookmark > 0) {

			switch (state.module.getAllItems()[state.module.bookmark]) {

				case Part(p):

					startingPart = p.id;
			}
		}
		displayPartById(startingPart);
	}

	function onPartFinished(p : Part) {

		//application.setFinishedPart(p.id);

		if (p.next != null) {

			var i = 0;

			for (next in p.next) {

				var nextPart = state.module.start(next);

				if (nextPart != null) {

					displayPart(nextPart);

				} else {

					application.displayContextual(Type.createEnum(ContextualType, next.toUpperCase()), (i == 0));
				}
				i++;
			}

		}
		else {
			gameOver();
		}
	}

	/**
	 * TODO print a nice error message ?
	 */
	public function onError(e:String) : Void {

		trace("ERROR", e);
		trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
		throw "exit";
	}
}