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

		state.onTrackingLocationChanged = {

				switch(state.tracking.type) {

					case Scorm( is2004, ss, sd ):

						// WIP

						var success:Bool;
						//if(isActive){
							if(is2004){
								success = scormSrv.set("cmi.location", state.tracking.location);
							}
							else{
								success = scormSrv.set("cmi.core.lesson_location", state.tracking.location);
							}
						//}

					case Aicc( u, i ):

						// TODO

					case Auto( lesson_location ):

						// TODO


				}				
			}
	}

	public function initTracking(m : Grar) : Void {

        //connection.initConnection(this.mode,false,activationTracking);
        switch (m.mode) {

			case AICC :
				aiccSrv.init( false, m.state.tracking, function(t:Tracking){ state.tracking = t; initFromState(m, t); }, parent.onError );

			case SCORM:
				scormSrv.init( false, m.state.tracking, false, function(t:Tracking){ state.tracking = t; initFromState(m, t); }, parent.onError );

			case SCORM2004:
				scormSrv.init( false, m.state.tracking, true, function(t:Tracking){ state.tracking = t; initFromState(m, t); }, parent.onError );

			case AUTO:
				autoSrv.init( false, m.state.tracking, function(t:Tracking){ state.tracking = t; initFromState(m, t); }, parent.onError );
		}
		//tracking.init(isNote, activation);
	}

	///
	// Internals
	//

	function loadStateInfos(stateStr : String) : Void {
		
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
	}

	function initFromState(m : Grar, t : Tracking) : Void {

		/** WIP **
		- store Tracking model in state
		- sort out MVC Tracking layer
		- Explode StateInfos, Trackings
		- init Styles on currentLang
		*********/

        //stateInfos = connection.revertTracking();
        var s : String = t.location;

		if (s != "" && s != "undefined" && s != "null" && s != null) {

			loadStateInfos(s);
		}
        if (state.currentLanguage == null && state.bookmark == -1 && state.completionOrdered.length == 0) {

            loadStateInfos(m.state.value);
        }
	    var status = t.getStatus();
	    if(status == null || status == "") {

		    t.setStatus(false);
	    }
		//Localiser.instance.currentLocale = stateInfos.currentLanguage;
	}
}