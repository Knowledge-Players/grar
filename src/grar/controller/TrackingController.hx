package grar.controller;

import grar.Controller;

import grar.model.State;
import grar.model.Config;
import grar.model.Grar;

class TrackingController {
	
	public function new(parent : Controller) {

		this.parent = parent;

		this.config = parent.config;
		this.state = parent.state;

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


	public function init() {

		state.onTrackingLocationChanged = function() {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):

						scormSrv.setLocation(state.tracking.isActive, is2004, state.tracking.location);

					case Aicc( u, i ):

						aiccSrv.putParams(state.tracking);

					case Auto( lesson_location ):

						autoSrv.setLocation(state.tracking.isActive, lesson_location);
				}				
			}

		state.onTrackingStatusChanged = function() {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):

						scormSrv.setStatus(is2004, state.tracking.getStatus());

					case Aicc( u, i ):

						aiccSrv.putParams(state.tracking);

					case Auto( l ):

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
	}

	public function initTracking(m : Grar, onSuccess : Void -> Void, onError : Void -> Void ) : Void {

		var loadStateInfos = function(stateStr:String):Void {
				
				// TODO commented code
				//allItem = GameManager.instance.game.getAllItems();
				var stateInfosArray : Array<String> = stateStr.split("@");
				state.currentLanguage = stateInfosArray[0];
				state.bookmark = Std.parseInt(stateInfosArray[1]);

				/*
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
				state.checksum = Std.parseInt(stateInfosArray[3]);

				//state.module.readyState = 

				onSuccess();
			}

		var onTrackingObject = function(t : Tracking) : Void {

				state.tracking = t;

		        //stateInfos = connection.revertTracking();
		        var s : String = t.location;

				if (s != "" && s != "undefined" && s != "null" && s != null) {

					loadStateInfos(s);
				}
		        if (state.currentLanguage == null && state.bookmark == -1 && state.completionOrdered.length == 0) {

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