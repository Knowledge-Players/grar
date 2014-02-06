package grar.controller;

import grar.Controller;

import grar.model.Grar;

class TrackingController {
	
	public function new(parent : Controller) {

		this.parent = parent;

		this.aiccSrv = new AiccService();
		this.autoSrv = new AutoService();
		this.scormSrv = new ScormService();
	}

	var parent : Controller;

	var aiccSrv : AiccService;
	var autoSrv : AutoService;
	var scormSrv : ScormService;


	public function initTracking(m : Grar) : Void {

        //connection.initConnection(this.mode,false,activationTracking);
        switch (m.mode) {

			case AICC :
				aiccSrv.init( false, m.state.tracking, function(t:Tracking){ /* TODO */ initFromState(m, t); }, parent.onError );

			case SCORM:
				scormSrv.init( false, m.state.tracking, function(t:Tracking){ /* TODO */ initFromState(m, t); }, parent.onError );

			case SCORM2004:
				scormSrv.init( false, m.state.tracking, true, function(t:Tracking){ /* TODO */ initFromState(m, t); }, parent.onError );

			case AUTO:
				autoSrv.init( false, m.state.tracking, function(t:Tracking){ /* TODO */ initFromState(m, t); }, parent.onError );
		}
		//tracking.init(isNote, activation);
	}

	///
	// Internals
	//

	function initFromState(m : Grar, t : Tracking) : Void {

		/** WIP **
		- store Tracking model in state
		- sort out MVC Tracking layer
		- Explode StateInfos, Trackings
		- init Styles on currentLang
		*********/

        //stateInfos = connection.revertTracking();
        var s : String = t.location;
		var stateInfos : StateInfos = new StateInfos();

		if(s != "" && s != "undefined" && s != "null" && s != null){

			stateInfos.loadStateInfos(s);
		}


        if(stateInfos.isEmpty()) {

            stateInfos.loadStateInfos(m.state.value);
        }
	    var status = t.getStatus();
	    if(status == null || status == "") {

		    t.setStatus(false);
	    }
		//Localiser.instance.currentLocale = stateInfos.currentLanguage;
		state.locale = stateInfos.currentLanguage;
	}
}