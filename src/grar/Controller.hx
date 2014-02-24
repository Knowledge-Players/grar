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

								if (state.currentLocale != null && application.tilesheet != null) {

									state.module.readyState = LoadingStyles(displayXml);
								}
							}


						// tracking
						trackingCtrl.initTracking(state.module, function(){ changeState(); }, onError);


						// langs
						gameSrv.fetchLangs( langs, function(l:StringMap<Locale>){ state.locales = l; }, onError );


						// display (styles, ui, transitions, filters, templates)
						gameSrv.fetchSpriteSheet( displayXml.node.Ui.att.display, function(t:TilesheetEx){

									application.tilesheet = t;

									changeState();

								}, onError );

						gameSrv.fetchTransitions( displayXml.node.Transitions.att.display, function(t:StringMap<TransitionTemplate>){ state.module.transitions = t; }, onError );

						gameSrv.fetchFilters( displayXml.node.Filters.att.display, function(f:StringMap<FilterData>){ application.filters = f; }, onError );

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

									gameSrv.fetchMenu(contextual.att.display, contextual.has.file ? contextual.att.file : null, function(d:Displaydata, m:Null<MenuData>){

											application.createMenu(d);
											application.menuData = m;

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

				        // Load part models
				        var parts : Array<Part> = [];

				        for (partXml in structureXml.nodes.Part) {

				        	var part : Part = gameSrv.fetchPart(partXml, function(p:Part){

				        			parts.push(p);

				        		}, onError);
				        }
				        state.module.parts = parts;


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

							gameSrv.fetchStyle( localePath, extension, application.tilesheet, onStyle, onError );
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

		state.onModulePartsChanged = function() { // actually code below also require the templates to be fetch already

			// WIP **********************
				// if (getLoadingCompletion() == 1 && (numStyleSheet == numStyleSheetLoaded)) {

		        	// Menu hasn't been set, creating the default
		            if (application.menuData == null) {

		            	var md : MenuData = { levels: [] };

		            	var createMenuLevel = function(p : Part, ? l : Int = 1) : LevelData {

		            			var name : String = "h" + l;
		            			var id : String = p.id;
		            			var icon : Null<String> = null;
		            			var items : Array<LevelData> = [];

		            			for (pe in p.elements) {

		            				switch (pe) {

		            					Part(sp):

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

		                for (part in state.module.parts) {

		                    md.levels.push(createMenuLevel(part));
		                }
		                application.menu = md;
		            }
		            if (!layoutLoaded) {

			            if (stateInfos.tmpState != null) {

		                    //stateInfos.initTrackable();
			                stateInfos.loadStateInfos(stateInfos.tmpState);
		                }
			            for (part in getAllParts()) {

		                    part.isDone = stateInfos.isPartFinished(part.id);
		                    part.isStarted = stateInfos.isPartStarted(part.id);
		                }
		                // Load Layout
		                LayoutManager.instance.parseXml(AssetsStorage.getXml(structureXml.node.Grar.node.Parameters.node.Layout.att.file));
		            
		            } else {

		                // Menu must be init after the event is dispatched. Trust me.
			            dispatchEvent(new PartEvent(PartEvent.PART_LOADED));
			            
			            if (MenuDisplay.instance.exists) {

		                    MenuDisplay.instance.init();
			            }
		            }
		        // }
		    // *****************************
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