package grar;

import grar.model.Config;
import grar.model.State;
import grar.model.Grar;

import grar.service.GameService;

import grar.controller.TrackingController;

/**
 * GRAR main controller
 */
class Controller {

	public function new(c : Config) {

		config = c;
		state = new State();

		gameSrv = new GameService();

		trackingCtrl = new TrackingController(this);

		init();
	}

	var config : Config;
	var state : State;

	var gameSrv : GameService;

	var trackingCtrl : TrackingController;

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

						// langs
						gameSrv.fetchLangs( langs, function(l : StringMap<Locale>){ state.locales = l; }, onError );

						// display (styles, ui, transitions, filters, templates)
						gameSrv.fetchSpriteSheet( display.node.Ui.att.display, function(t:TilesheetEx){ state.module.tilesheet = t; }, onError );

						gameSrv.fetchTransitions( display.node.Transitions.att.display, function(t:TransitionTemplate){  }, onError );

						gameSrv.fetchFilters( display.node.Filters.att.display, function(f:FilterTemplate){  }, onError );

						// structure (parts, contextuals)

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

				trackingCtrl.initTracking(state.module);
			}

		state.onCurrentLanguageChanged = function() {

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