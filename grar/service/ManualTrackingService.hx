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
			untyped __js__("setBookmark(moduleId, location)");
	}

	public function getLocation(isActive: Bool, moduleId: String):String
	{
		if(isActive)
			return untyped __js__("getBookmark(moduleId)");
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
	public function setTime(isActive: Bool, time: Int, moduleId: String):Void
	{
		if(isActive){
			var formattedTime = getFormatTime(Std.int(time/1000));
			untyped __js__("setTime(moduleId, formattedTime)");
		}
	}

	public function getTime(isActive: Bool, moduleId: String):Int
	{
		if(isActive)
			return untyped __js__("getTime(moduleId)");
		else
			return null;
	}

	// TODO TimeUtils
	private function getFormatTime(time : Int) : String {

		var output : StringBuf = new StringBuf();
		//var time:Int = timer.currentCount - startTime;
		var hours : Int = Math.floor(time / 3600);
		var minutes : Int = Math.floor((time - (hours * 3600)) / 60);
		var seconds : Int = (time - (hours * 3600)) - (minutes * 60);

		if (hours < 10) {

			output.add("0");
		}
		output.add(hours + ":");

		if (minutes < 10) {

			output.add("0");
		}
		output.add(minutes + ":");

		if (seconds < 10) {

			output.add("0");
		}
		output.add(seconds);

		return output.toString();
	}
}