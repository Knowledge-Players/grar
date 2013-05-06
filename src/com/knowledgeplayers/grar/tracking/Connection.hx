package com.knowledgeplayers.grar.tracking;

import com.knowledgeplayers.grar.tracking.StateInfos;
import nme.events.EventDispatcher;
import nme.Lib;

class Connection extends EventDispatcher {
	public var tracking (default, null):Tracking;

	public function new()
	{
		super();
	}

	public function initConnection(mode:Mode, isNote:Bool = false):Void
	{
		switch(mode) {
			case AICC :
				tracking = new AiccTracking();
			case SCORM:
				tracking = new ScormTracking();
			case SCORM2004:
				tracking = new ScormTracking(true);
			case AUTO:
				tracking = new AutoTracking();
		}

		tracking.init(isNote, "on");
	}

	public function computeTracking(stateInfos:StateInfos):Void
	{
		var state:String = stateInfos.saveStateInfos();

		if(!stateInfos.isEmpty()){
			tracking.setLocation(state);
			tracking.putparam();
		}
	}

	public function revertTracking():StateInfos
	{
		var state:String = tracking.getLocation();
		var stateInfos:StateInfos = new StateInfos();

		if(state != "" && state != "undefined" && state != "null" && state != null){
			stateInfos.loadStateInfos(state);
		}

		return stateInfos;
	}
}

enum Mode {
	AICC;
	SCORM;
	SCORM2004;
	AUTO;
}