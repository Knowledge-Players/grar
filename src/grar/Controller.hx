package grar;

import grar.model.Config;
import grar.model.State;
import grar.model.Grar;
import grar.model.ContextualType;

import grar.service.GameService;

import grar.controller.TrackingController;

import grar.view.Application;

/**
 * GRAR main controller
 */
class Controller {

	public function new(c : Config) {

		config = c;
		state = new State();

		gameSrv = new GameService();

		trackingCtrl = new TrackingController(this);

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

				if (state.readyState && c.structureFileUri != null) {

					gameSrv.fetchModule( c.structureFileUri, function(m:Grar){ state.module = m; }, onError );
				}
			}

		state.onModuleStateChanged = function() {

				switch(state.module.readyState) {

					case Loading(langsUri, layoutUri, displayXml, structureXml):

						var changeState = function() {

								if (state.currentLocale != null && state.module.tilesheet != null) {

									state.module.readyState = LoadingStyles(displayXml);
								}
							}


						// tracking
						trackingCtrl.initTracking(state.module, function(){ changeState(); }, onError);


						// langs
						gameSrv.fetchLangs( langs, function(l:StringMap<Locale>){ state.locales = l; }, onError );


						// display (styles, ui, transitions, filters, templates)
						gameSrv.fetchSpriteSheet( displayXml.node.Ui.att.display, function(t:TilesheetEx){

									state.module.tilesheet = t;

									changeState();

								}, onError );

						gameSrv.fetchTransitions( displayXml.node.Transitions.att.display, function(t:StringMap<TransitionTemplate>){ state.module.transitions = t; }, onError );

						gameSrv.fetchFilters( displayXml.node.Filters.att.display, function(f:StringMap<FilterType>){ state.module.filters = f; }, onError );

						if (displayXml.hasNode.Templates) {

							gameSrv.fetchTemplates( displayXml.node.Templates.att.folder, function(tmpls:StringMap<Xml>){ state.module.templates = tmpls; }, onError );
					    }


						// structure (parts, contextuals)

						for (contextual in structureXml.nodes.Contextual) {

							var contextualType : ContextualType = Type.createEnum(ContextualType, contextual.att.type.toUpperCase());

							switch(contextualType) {

								case NOTEBOOK:

									gameSrv.fetchNotebook(contextual.att.file, contextual.att.display, function(m:grar.model.Notebook,i:StringMap<grar.model.InventoryToken>,v:grar.view.NotebookDisplay){

											application.notebook = v;
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

									gameSrv.fetchMenu(contextual.att.display, contextual.has.file ? contextual.att.file : null, function(d:MenuDisplay, m:Xml){

											application.menu = d;
											// FIXME What is this menu Xml ??????
											// TODO menu = AssetsStorage.getXml(c);

										}, onError);

								default: // nothing
							}
						}
				        if (structureXml.has.inventory) {
#if (flash || openfl)
				        	gameSrv.fetchInventory(structureNode.att.inventory, function(i:StringMap<InventoryToken>, tn:TokenNotification, ti:StringMap<{ small:flash.display.BitmapData, large:flash.display.BitmapData }>){
#else
				        	gameSrv.fetchInventory(structureNode.att.inventory, function(i:StringMap<InventoryToken>, tn:TokenNotification, ti:StringMap<{ small:String, large:String }>){
#end
				        			state.module.addInventoryTokens(i);
				        			application.tokenNotification = tn;
									application.tokensImages = ti;

				        		}, onError);
				        }

					case LoadingStyles(displayXml): // only when tilesheet loaded and currentLocale known

						var onStyle = function(s : StyleSheet) {

								state.module.setStyleSheet(currentLocale, stylesheet);

								if (state.module.countStyleSheet(currentLocale) == 0) {

									state.currentStyleSheet = stylesheet.name;
								}
							}

						for (s in display.nodes.Style) {

				            var fullPath = s.att.file.split("/");
				            var localePath : String = "";

				            for (i in 0...fullPath.length - 1) {

				                localePath += fullPath[i] + "/";
				            }
				            localePath += state.currentLocale + "/";
				            localePath += fullPath[fullPath.length - 1];

					        var extension : String = localePath.substr(localePath.lastIndexOf(".") + 1);

							gameSrv.fetchStyle( localePath, extension, state.module.tilesheet, onStyle, onError );
				        }
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

		state.readyState = true;
	}

	function loadCurrentLocale() {

		if (state.currentLocale == null || state.locales == null) {

			return;
		}
		// TODO load lang file for current "view"
	}

	function onError(e:String) : Void {

		trace("ERROR", e);
	}
}