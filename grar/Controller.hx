package grar;

import grar.parser.XmlToInventory;
import grar.view.Application;
import grar.view.contextual.MenuDisplay;

import grar.service.KalturaService;
import grar.service.GameService;

import grar.model.contextual.MenuData;
import grar.model.Config;
import grar.model.State;
import grar.model.Grar;
import grar.model.localization.Locale;
import grar.model.InventoryToken;
import grar.model.contextual.Notebook;
import grar.model.part.Part;


import grar.controller.TrackingController;
import grar.controller.LocalizationController;
import grar.controller.PartController;

import haxe.ds.StringMap;

using Lambda;

/**
 * GRAR main controller
 */
class Controller {

	public function new(c : Config, #if (js || cocktail) ?root: js.html.IFrameElement #else ?root: String #end) {
		config = c;
		state = new State();

		gameSrv = new GameService(c.rootUri);

		application = new Application(root, c.isMobile);

		trackingCtrl = new TrackingController(this, state, config, application);
		localizationCtrl = new LocalizationController(this, state, config, application, gameSrv);
		partCtrl = new PartController(this, state, config, application);
		menuDisplays = new Map();
	}

	var config : Config;
	var state : State;

	var gameSrv : GameService;

	var trackingCtrl : TrackingController;
	var localizationCtrl : LocalizationController;
	var partCtrl : PartController;

	var application : Application;
	var hasMenu: Bool = false;
	var menuDisplays: Map<String, MenuDisplay>;

	/**
	 * Kaltura Session
	 */
	public var ks (default, null):String;

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

		partCtrl.onPartFinished = function(part: Part, next: Bool){
			onPartFinished(part, next);
		}

		partCtrl.onTrackingUpdateRequest = function() trackingCtrl.updateTracking();

		state.onReadyStateChanged = function() {

				if (state.readyState && config.structureFileUri != null) {
					gameSrv.fetchModule( config.structureFileUri, function(m:Grar){ state.module = m; }, onError );
				}
			}

		state.onModuleStateChanged = function() {
				switch(state.module.readyState) {

					case Loading(langsUri, structureXml):

						// tracking
						trackingCtrl.initTracking(state.module, function(){}, onError);

						// langs list
						gameSrv.fetchLangs( langsUri, function(l:StringMap<Locale>){
							state.module.locales = l;
						}, onError );

						state.module.readyState = LoadingGame(structureXml);

					case LoadingGame(structureXml):
						var menuData : MenuData = null;

						// game model & views (parts, contextuals)

						for (contextual in structureXml.nodes.Contextual) {

							var contextualType : ContextualType = Type.createEnum(ContextualType, contextual.att.type.toUpperCase());

							switch(contextualType) {

								case NOTEBOOK:

									gameSrv.fetchNotebook(contextual.att.file, function(m:Notebook, i:StringMap<grar.model.InventoryToken>){

											//application.createNotebook();
											state.module.inventory = i;
											state.module.notebook = m;

										}, onError);

								case MENU:
									hasMenu = true;
									gameSrv.fetchMenu(contextual.has.file ? contextual.att.file : null, function(m:Null<MenuData>){

											//application.createMenu(d);
											menuData = m;
											if(state.module.readyState == Ready)
												application.menuData = menuData;
										}, onError);

								case INVENTORY:
									if(contextual.elements.hasNext()){
										state.module.inventory = XmlToInventory.parse(contextual.x);
									}
									else{
										gameSrv.fetchInventory(contextual.att.file, function(i:StringMap<grar.model.InventoryToken>){
											state.module.inventory = i;
										}, onError);
									}
								default:
							}
						}

				        // Load part models
						state.onModulePartsChanged = function() {

								// Menu hasn't been set, creating the default
						        if(!hasMenu)
						        	createDefaultMenu();
								else if(menuData != null){
						        	application.menuData = menuData;
						        }

						        trackingCtrl.updatePartsCompletion();

								state.module.readyState = Ready;
							}

						gameSrv.fetchParts(structureXml.x, function(pa:Array<Part>){
				        		state.module.parts = pa;

			        		}, onError);

				    case Ready:
					    // Connect to Kaltura
					    if(state.module.kSettings != null){
					        var srv = new KalturaService();
						    srv.createSession(state.module.kSettings.partnerId, state.module.kSettings.secret, state.module.kSettings.serviceUrl, function(result){
							    ks = result;
							    launchGame();
						    });
					    }
				        else
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

				/*for (part in state.module.getAllParts()) {

					if (!part.isDone && state.module.canStart(part)) {

						//application.menu.unlockNextPart(part.id);
						// Before we had this also (from MenuDisplay)
						if (!part.canStart()) {

							buttons.get(part.id).toggleState = "lock";

						}
					}
				}*/
			}

		state.onInventoryTokenActivated = function(t : InventoryToken) {

				application.setActivateToken(t);
			}

		application.onMenuDataChanged = function(){
			var menuData: MenuData = application.menuData;

			// Set texts in the right locale
			localizationCtrl.setInterfaceLocaleData();
			menuData.levels = addPartsInfoToLevel(menuData.levels);
			for(menu in application.menus){
				menu.setTitle(state.module.getLocalizedContent(menuData.title));
				application.initMenu(menu.ref, menuData.levels);
			}
			localizationCtrl.restoreLocaleData();
			// end locale
		}

		application.onMenuClicked = function(partId : String, menuId: String) {

				partCtrl.exitPart(false, true);
				if (displayPartById(partId)) {

					hideMenu(menuId);
				}
			}

		application.onMasterVolumeChanged = function(){
				partCtrl.onMasterVolumeChanged();
			}

		application.sendReadyHook = function(){
			sendReadyHook();
		}
		application.sendNewPartHook = function(){
			sendNewPartHook();
		}
		application.sendFullscreenHook = function(){
			sendFullscreenHook();
		}

		state.readyState = true;
	}

	public function gameOver():Void
	{
		//updateMenuCompletion();
		trace("GAME OVER");
		for(menu in application.menus){
			menu.setGameOver();
		}

		partCtrl.onGameOver();

		trackingCtrl.exitModule(state.module, function() {
			trace("Successfully exited from the tracker");
		}, onError);
	}

	public function showMenu(ref: String){
		application.menus[ref].open();
	}

	public function hideMenu(ref: String){
		application.menus[ref].close();
	}

	public function setMasterVolume(volume:Float):Void
	{
		application.masterVolume = volume;
	}

	public function getMasterVolume():Float
	{
		return application.masterVolume;
	}

	public function validateInput(inputId: String, ?value: String, ?dragging: Bool = true):Bool
	{
		return partCtrl.validateInput(inputId, value, dragging);
	}

	public function getModuleId():String
	{
		return state.module.id;
	}

	///
	// INTERNALS
	//

	function createMenuLevel(p : Part, ? l : Int = 1) : LevelData {

		var name : String = "h" + l;
		var id : String = p.id;
		var icon : Null<String> = null;
		var items : Array<LevelData> = [];

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

	function addPartsInfoToLevel(la : Array<LevelData>) : Array<LevelData> {
		for (l in la) {
			l.partName = state.module.getItemName(l.id);
			if (l.partName == null)
				trace("Can't find a name for '"+l.id+"'.");

			if (l.items != null)
				l.items = addPartsInfoToLevel(l.items);
		}
		return la;
	}

	function createDefaultMenu() : Void {

    	var md : MenuData = { levels: [], title: "menu"};

    	for (part in state.module.parts) {

            md.levels.push(createMenuLevel(part));
        }
        application.menuData = md;
	}

	function updateMenuCompletion(){
		for(menu in application.menus){
			var currentId: String = null;
			for(level in application.menuData.levels){
				if(level.items != null){
					for(item in level.items){
						var status: ItemStatus = switch(state.module.completion[item.id]){
							case 0: ItemStatus.TODO;
							case 1: ItemStatus.STARTED;
							case 2: ItemStatus.DONE;
							default: throw 'Unkonwn completion "'+state.module.completion[item.id]+'".';
						}
						menu.setItemStatus(item.id, status);
					}
				}
			}
		}
	}

	function displayPart(p : Part, ?next: Bool = true) : Bool {
		#if !kpdebug
		// Part doesn't meet the requirements to start
		if (!state.module.canStart(p)) {

			return false;
		}
		#end
		partCtrl.displayPart(p, next);

		updateMenuCompletion();

		for(menu in application.menus)
			menu.setCurrentItem(p.id);

		return true;
	}

	function displayPartById(? partId : String) : Bool {

		return displayPart(state.module.start(partId));
	}

	function launchGame() : Void {

		var startingPart : String = null;

		localizationCtrl.setInterfaceLocaleData();
		application.updateModuleInfos(state.module.getLocalizedContent("moduleName"), state.module.getLocalizedContent("moduleType"), state.module.getLocalizedContent("moduleTheme"));
		application.theme = state.module.theme;
		localizationCtrl.restoreLocaleData();


		if (state.module.bookmark > 0) {
			var part: Part = state.module.getAllParts()[state.module.bookmark];
			if(part.parent != null)
				startingPart = part.parent.id;
			else
				startingPart = part.id;
		}
		else{
			startingPart = state.module.getAllParts()[0].id;
		}

		displayPartById(startingPart);
	}

	function onPartFinished(p : Part, ? next: Bool = true) {

		// Tracking
		trackingCtrl.updateTracking();

		if (next && p.next != null) {
			var i = 0;
			for (next in p.next) {
				var nextPart = state.module.start(next);
				if (nextPart != null)
					displayPart(nextPart);
				i++;
			}
		}
		else if(p.parent != null && p.parent.hasNextElement()){
			partCtrl.unloadPart(p.ref);
			partCtrl.displayPart(state.module.start(p.parent.id), true, true);
		}
		else{
			var futurePart: Part = null;
			if(next)
				futurePart = state.module.getNextPart(p);
			else{
				futurePart = state.module.getPreviousPart(p);
				futurePart.setIndexToEnd();
			}

			if(futurePart != null){
				state.module.start(futurePart.id);
				displayPart(futurePart, next);
			}
			else
				gameOver();
		}
	}

	/**
	 * TODO print a nice error message ?
	 */
	public function onError(e:String) : Void {

		trace("ERROR", e);
		trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
		throw "exit "+e;
	}

	// HOOKS

	public dynamic function sendReadyHook():Void
	{
	}

	public dynamic function sendNewPartHook():Void
	{
	}

	public dynamic function sendFullscreenHook(): Void {}
}