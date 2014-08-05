package grar.service;

import grar.model.tracking.Tracking;

class ManualTrackingService{

	public function new(){}

	public function init( isNote : Bool, activation : String, moduleId: String, onSuccess : Tracking -> Void, onError : String -> Void ) : Void {
		var isActive : Bool = false;
		var studentId : Null<String> = null;
		var studentName : Null<String> = null;
		var lessonLocation : Null<String> = null;
		var score : Null<String> = null;
		var masteryScore : Null<Int> = null;
		var lessonStatus : Null<String> = null;

		switch (activation) {
			case "off" :
				isActive = false;
				studentId = "42";
				studentName = "wayne";
				// FIXME lesson_location = suivi;
				score = "0";
				masteryScore = 80;
				lessonStatus = "n,a";

			case "on" :
				isActive = true;
				lessonLocation = getLocation(isActive, moduleId);
				lessonStatus = getStatus(isActive, moduleId) ? "completed" : "incomplete";
		}

		onSuccess(new Tracking(isActive, studentId, studentName, lessonLocation, score, masteryScore, lessonStatus, isNote, Manual));
	}

	public function setLocation(isActive : Bool, location : String, moduleId: String) : Void {
		if(isActive)
			untyped __js__("setMarquePage(moduleId, location)");
	}

	public function getLocation(isActive: Bool, moduleId: String):String
	{
		if(isActive)
			return untyped __js__("getMarquePage(moduleId)");
		else
			return null;
	}

	public function setStatus(isActive : Bool, status : String, moduleId: String) : Void {
		if(isActive)
			untyped __js__("setStatus(moduleId, status == 'completed' ? true: false)");
	}

	public function getStatus(isActive:Bool, moduleId:String):Bool
	{
		if(isActive)
			return untyped __js__("getStatus(moduleId)");
		else
			return null;
	}
	public function setTime(isActive: Bool, time: String, moduleId: String):Void
	{
		if(isActive)
			untyped __js__("setTemps(moduleId, time)");
	}

	public function getTime(isActive: Bool, moduleId: String):Int
	{
		if(isActive)
			return untyped __js__("getTemps(moduleId)");
		else
			return null;
	}
}