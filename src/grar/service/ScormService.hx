package grar.service;

import grar.model.Tracking;

#if flash
import flash.external.ExternalInterface;
#end

class ScormService {

	public function new() { }

	/**
	 * Attempts to init an Scorm-typed Tracking object.
	 */
	public function init( isNote : Bool, activation : String, is2004 : Bool, onSuccess : Tracking -> Void, onError : String -> Void ) : Void {

		var isActive : Bool;
		var location : Null<String> = null;
		var score : String = "";
		var masteryScore : Null<Int> = null;
		var lessonStatus : Null<String> = null;
		var success_status : Null<String> = null;
		var suspend_data : Null<String> = null;
		var studentId : Null<String> = null;
		var studentName : Null<String> = null;

		switch (activation) {

			case "off" :
				isActive = false;
				location = suivi;
				score = "";
				masteryScore = 80;
				lessonStatus = "n,a";
				success_status = "unknow";
				suspend_data = "suspend";
				studentId = "12";
				studentName = "miloose";

			case "on" :
				isActive = true;
		}
//		timer.start();
//		startTime = timer.currentCount;

		if (isActive) {

//			scorm = new Scorm();
//			var success : Bool = scorm.connect();
			var success : Bool = connect();

			if (!success) {

				init(isNote, "off", is2004, onSuccess, onError);
				return;
			}

			if (is2004) {

				lessonStatus = scorm.get("cmi.completion_status");
				success_status = scorm.get("cmi.success_status");
				score = scorm.get("cmi.score.raw");
				studentName = scorm.get("cmi.learner_name");
				studentId = scorm.get("cmi.learner_id");
				location = scorm.get("cmi.location");
				suspend_data = scorm.get("cmi.suspend_data");

			} else {

				lessonStatus = scorm.get("cmi.core.lessonStatus");

				score = scorm.get("cmi.core.score.raw");
				studentName = scorm.get("cmi.core.studentName");
				studentId = scorm.get("cmi.core.studentId");
				location = scorm.get("cmi.core.lesson_location");
				suspend_data = scorm.get("cmi.suspend_data");
			}

//				dispatchEvent(new Event(Event.INIT));

//		} else {

//			dispatchEvent(new Event(Event.INIT));
//		}
		onSuccess( new Tracking(isActive, studentId, studentName, location, score, masteryScore, lessonStatus, isNote, Scorm(is2004, success_status, suspend_data)) );
	}


	///
	// Internals
	//

	function connect() : Bool {

		var result : Bool = false;

#if flash
//		if (!activeConnection) {

			var eiCall : String = null;
			if (ExternalInterface.available)
				eiCall = Std.string(ExternalInterface.call("pipwerks.SCORM.init"));
			result = eiCall == "true";

			if (result) {

				activeConnection = true;

			} else {

				var errorCode:Int = getDebugCode();

				if (errorCode == 0) {

					var debugInfo : String = getDebugInfo(errorCode);
					displayDebugInfo("pipwerks.SCORM.init() failed. \n"
					+ "Error code: " + errorCode + "\n"
					+ "Error info: " + debugInfo);

				} else {

					displayDebugInfo("pipwerks.SCORM.init failed: no response from server.");
				}
			}

//		} else {
//
//			displayDebugInfo("pipwerks.SCORM.init aborted: connection already active.");
//		}
//		displayDebugInfo("__connectionActive: " + activeConnection);
		
#elseif js
		var wrapper : Dynamic = untyped __js__('pipwerks.SCORM.init()');
		result = wrapper == "true";
#end
		return result;
	}

	function displayDebugInfo(msg:String) : Void {

//		if(debug){
#if flash
		if(ExternalInterface.available)
			ExternalInterface.call("pipwerks.UTILS.trace", msg);
#elseif js
		untyped __js__('pipwerks.UTILS.trace('+msg+')');
#end
//		}
	}
}