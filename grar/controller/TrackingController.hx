package grar.controller;

import grar.service.ManualTrackingService;
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
		this.manualSrv = new ManualTrackingService();

		init();
	}

	var state : State;
	var config : Config;

	var parent : Controller;

	var aiccSrv : AiccService;
	var autoSrv : AutoService;
	var scormSrv : ScormService;
	var manualSrv: ManualTrackingService;

	var application : Application;


	public function init() {

		state.onTrackingLocationChanged = function() {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):
						scormSrv.setLocation(state.tracking.isActive, is2004, state.tracking.location);

					case Aicc( u, i ):
						aiccSrv.putParams(state.tracking, function(t:Tracking){ /* nothing */ }, function(e:String) { /* TODO ? */ });

					case Auto( lessonLocation ):
						autoSrv.setLocation(state.tracking.isActive, lessonLocation);

					case Manual:
						manualSrv.setLocation(state.tracking.isActive, state.tracking.location, state.module.id);
						manualSrv.setTime(state.tracking.isActive, state.tracking.currentTime, state.module.id);
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

					case Manual:
						manualSrv.setStatus(state.tracking.isActive, state.tracking.getStatus(), state.module.id);
						manualSrv.setTime(state.tracking.isActive, state.tracking.currentTime, state.module.id);
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

					default: // doesn't care
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

	public function updateTracking():Void
	{
		var stateStr : String = saveStateInfos();

		if (!(state.module.currentLocale == null && state.module.bookmark == -1 &&
		state.module.completionOrdered.length == 0)) {

			state.tracking.location = stateStr;
		}
	}

	public function initTracking(m : Grar, onSuccess : Void -> Void, onError : String -> Void) : Void {

		var loadStateInfos = function(stateStr : String) : Void {

				var stateInfosArray : Array<String> = stateStr.split("@");

				state.module.currentLocale = stateInfosArray[0];
				state.module.bookmark = Std.parseInt(stateInfosArray[1]);

				state.trackingInitString = stateStr;

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

        switch (m.mode) {

			case AICC :
				aiccSrv.init( false, m.state.tracking, onTrackingObject, onError );

			case SCORM:
				scormSrv.init( false, m.state.tracking, false, onTrackingObject, onError );

			case SCORM2004:
				scormSrv.init( false, m.state.tracking, true, onTrackingObject, onError );

			case AUTO:
				autoSrv.init( false, m.state.tracking, onTrackingObject, onError );

	        case MANUAL:
	            manualSrv.init(false, m.state.tracking, m.id, onTrackingObject, onError);
		}
	}

	public function updatePartsCompletion() : Void {

		var allParts = state.module.getAllParts();

		var stateInfosArray : Array<String> = state.trackingInitString.split("@");

		var trackable : Array<String> = stateInfosArray[2].split("-");

		if (allParts.length > 0) {

            if (allParts.length != trackable.length) {

                trackable = initTrackable();
            }
			for (i in 0...trackable.length) {

				if (i < allParts.length) {
					state.module.completion.set(allParts[i].id, Std.parseInt(trackable[i]));
					state.module.completionOrdered.push(allParts[i].id);
				}
			}
		}

		// parts completion
		for (p in allParts) {
		    if(state.module.isPartFinished(p.id))
			    p.state = FINISHED;
			else if(state.module.isPartStarted(p.id))
			    p.state = STARTED;
		}
	}

	public function exitModule(m : Grar, onSuccess : Void -> Void, onError : String -> Void) : Void {

		state.tracking.setStatus(true);

		// TODO verify this isn't closing the window
		var ret = true; /*: Bool = switch (m.mode) {
			case AICC : aiccSrv.exit();
			case SCORM, SCORM2004: scormSrv.exit();
			default: true; // nothing
		}*/

		if (ret)
			onSuccess();
		else if(state.tracking.isActive)
			onError("Exiting module with error from tracking system");
	}


	///
	// INTERNALS
	//

    private function initTrackable() : Array<String> {

        var a : Array<String> = new Array<String>();

        var allItem = state.module.getAllParts();

        for (i in 0...allItem.length) {

            a.push("0");
        }
        return a;
    }

	private function saveStateInfos() : String {

		var stringBuf : StringBuf = new StringBuf();

		stringBuf.add(state.module.currentLocale);
		stringBuf.add("@");
		stringBuf.add(state.module.bookmark);
		stringBuf.add("@");
		stringBuf.add(completionString());

		return stringBuf.toString();
	}

	private function completionString() : String {

		var buffer = new StringBuf();

		for (i in 0...state.module.completionOrdered.length) {

			buffer.add(state.module.completion.get(state.module.completionOrdered[i]));

			if (i != state.module.completionOrdered.length - 1) {

				buffer.add("-");
			}
		}
		return buffer.toString();
	}
}