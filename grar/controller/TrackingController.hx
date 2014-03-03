package grar.controller;

import grar.view.Application;

import grar.Controller;

import grar.model.State;
import grar.model.Config;
import grar.model.Grar;
import grar.model.tracking.Tracking;

import grar.service.AiccService;
import grar.service.AutoService;
import grar.service.ScormService;

class TrackingController {
	
	public function new(parent : Controller, state : State, config : Config, application : Application) {

		this.parent = parent;

		this.config = config;
		this.state = state;

		this.application = application;

		this.aiccSrv = new AiccService();
		this.autoSrv = new AutoService();
		this.scormSrv = new ScormService();

		init();
	}

	var state : State;
	var config : Config;

	var parent : Controller;

	var aiccSrv : AiccService;
	var autoSrv : AutoService;
	var scormSrv : ScormService;

	var application : Application;


	public function init() {

		state.onTrackingLocationChanged = function() {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):

						scormSrv.setLocation(state.tracking.isActive, is2004, state.tracking.location);

					case Aicc( u, i ):

						aiccSrv.putParams(state.tracking, function(t:Tracking){ /* nothing */ }, function(e:String) { /* TODO ? */ });

					case Auto( lesson_location ):

						autoSrv.setLocation(state.tracking.isActive, lesson_location);
				}				
			}

		state.onTrackingStatusChanged = function() {

				switch(state.tracking.type) {

					case Scorm(is2004, ss, sd):

						scormSrv.setStatus(state.tracking.isActive, is2004, state.tracking.getStatus());

					case Aicc(u, i):

						aiccSrv.putParams(state.tracking, function(t:Tracking){ /* nothing */ }, function(e:String) { /* TODO ? */ });

					case Auto(l):

						autoSrv.setStatus(state.tracking.isActive, state.tracking.getStatus());
				}
			}

		state.onTrackingSuccessStatusChanged = function() {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):

						scormSrv.setSuccessStatus(state.tracking.isActive, ss);

					default: // can't happen
				}
			}

		state.onTrackingScoreChanged = function() {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):

						scormSrv.setScore(state.tracking.isActive, is2004, state.tracking.getScore());

						if (state.tracking.getScore() >= state.tracking.masteryScore) {

							state.tracking.setSuccessStatus(true);
						
						} else {

							state.tracking.setSuccessStatus(false);
						}

					case Aicc( u, i ):

						if (state.tracking.getScore() >= state.tracking.masteryScore) {
						
							state.tracking.setStatus(true);
						
						} else {

							state.tracking.setStatus(false);
						}

					case Auto( l ):

						autoSrv.setScore(state.tracking.isActive, state.tracking.getScore());

						if (state.tracking.getScore() >= state.tracking.masteryScore) {
						
							state.tracking.setStatus(true);
						
						} else {

							state.tracking.setStatus(false);
						}
				}
			}

		state.onTrackingSuspendDataChanged = function() {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):

						scormSrv.setSuspendData(state.tracking.isActive, is2004, sd);

					default: // can't happen
				}
			}

		application.onSetBookmarkRequest = function(partId : String) {

				// TODO
				/*
				function setBookmark(partId:String):Void
				{
					var i = 0;
					while(i < game.getAllItems().length && game.getAllItems()[i].id != partId){
						i++;
					}
					if(i < game.getAllItems().length){
						game.stateInfos.bookmark = i;
						game.connection.computeTracking(game.stateInfos);
					}
				}
				*/
			}

		application.onGameOverRequested = function() {

				// TODO
// FIXME				game.connection.tracking.setStatus(true);
// FIXME				game.connection.computeTracking(game.stateInfos);

				application.setGameOver();

			}
	}

	public function initTracking(m : Grar, onSuccess : Void -> Void, onError : String -> Void ) : Void {

		var loadStateInfos = function(stateStr:String):Void {
				
				// TODO commented code
				//allItem = GameManager.instance.game.getAllItems();
				var stateInfosArray : Array<String> = stateStr.split("@");
				state.module.currentLocale = stateInfosArray[0];
				state.module.bookmark = Std.parseInt(stateInfosArray[1]);

				/* TODO This will have to be done once parts loaded !!!
				var trackable:Array<String> = stateInfosArray[2].split("-");

				if(allItem.length > 0){
		            if (allItem.length != trackable.length)
		                trackable = initTrackable();
					for(i in 0...trackable.length){
						if(i < allItem.length){
							completion.set(allItem[i].id, Std.parseInt(trackable[i]));
							completionOrdered.push(allItem[i].id);
						}
					}

				} else {

					tmpState = stateStr;
				}
				*/
				state.module.checksum = Std.parseInt(stateInfosArray[3]);

				onSuccess();
			}

		var onTrackingObject = function(t : Tracking) : Void {

				state.tracking = t;

		        //stateInfos = connection.revertTracking();
		        var s : String = t.location;

				if (s != "" && s != "undefined" && s != "null" && s != null) {

					loadStateInfos(s);
				}
		        if (state.module.currentLocale == null && state.module.bookmark == -1 && state.module.completionOrdered != null && state.module.completionOrdered.length == 0) {

		            loadStateInfos(m.state.value);
		        }
			    var status = t.getStatus();
			    
			    if (status == null || status == "") {

				    t.setStatus(false);
			    }
			}

        //connection.initConnection(this.mode,false,activationTracking);
        switch (m.mode) {

			case AICC :
				aiccSrv.init( false, m.state.tracking, onTrackingObject, onError );

			case SCORM:
				scormSrv.init( false, m.state.tracking, false, onTrackingObject, onError );

			case SCORM2004:
				scormSrv.init( false, m.state.tracking, true, onTrackingObject, onError );

			case AUTO:
				autoSrv.init( false, m.state.tracking, onTrackingObject, onError );
		}
		//tracking.init(isNote, activation);
	}
}