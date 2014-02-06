package grar;

import grar.model.Config;
import grar.model.State;
import grar.model.Structure;

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
						gameSrv.fetchLangs( langs, function(){  }, onError );

						// display (styles, ui, transitions, filters, templates)
						gameSrv.fetchSpriteSheet( display.node.Ui.att.display, function(t:TilesheetEx){  }, onError );

						gameSrv.fetchTransitions( display.node.Transitions.att.display, function(t:TransitionTemplate){  }, onError );

						gameSrv.fetchFilters( display.node.Filters.att.display, function(f:FilterTemplate){  }, onError );

						// structure (parts, contextuals)

					case LoadingStyles(displayXml):

						for (s in display.nodes.Style) {

				            var fullPath = s.att.file.split("/");

				            var localePath : String = "";
				            for (i in 0...fullPath.length - 1) {
				                localePath += fullPath[i] + "/";
				            }
				            localePath += Localiser.instance.currentLocale + "/";
				            localePath += fullPath[fullPath.length - 1];

					        var extension : String = localePath.substr(localePath.lastIndexOf(".") + 1);

							gameSrv.fetchStyle( localePath, extension, function(){  }, onError );
				        }
				}
			}

		state.onModuleChanged = function() {

				trackingCtrl.initTracking(state.module);
			}

		state.readyState = true;
	}


	function onError(e:String) : Void {

		trace("ERROR", e);
	}
}