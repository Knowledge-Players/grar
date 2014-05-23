package grar.service;

import pipwerks.Scorm;
import grar.model.tracking.Tracking;

/**
 * The Scorm service handles all SCORM 1.2 / SCORM 2004 related tasks.
 * Note that this service class is stateful.
 */
class ScormService {

	public function new() {
	}

	var activeConnection : Bool = false;

	/**
	 * Attempts to init an Scorm-typed Tracking object.
	 */
	public function init( isNote : Bool, activation : String, is2004 : Bool, onSuccess : Tracking -> Void, onError : String -> Void ) : Void {

		var isActive : Bool = false;
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
				// FIXME location = suivi;
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

			var success : Bool = connect();

			if (!success) {
				// Warn user he's offline
				trace("Can't connect to SCORM plateform! Going offline.");
				init(isNote, "off", is2004, onSuccess, onError);
				return;
			}

			if (is2004) {
				lessonStatus = get("cmi.completion_status");
				success_status = get("cmi.success_status");
				score = get("cmi.score.raw");
				studentName = get("cmi.learner_name");
				studentId = get("cmi.learner_id");
				location = get("cmi.location");
				suspend_data = get("cmi.suspend_data");
			} else {
				lessonStatus = get("cmi.core.lessonStatus");
				score = get("cmi.core.score.raw");
				studentName = get("cmi.core.studentName");
				studentId = get("cmi.core.studentId");
				location = get("cmi.core.lesson_location");
				suspend_data = get("cmi.suspend_data");
			}
		}

		onSuccess( new Tracking(isActive, studentId, studentName, location, score, masteryScore, lessonStatus, isNote, Scorm(is2004, success_status, suspend_data)) );
	}

	public function setLocation(isActive : Bool, is2004 : Bool, location : String) : Void {
		var success : Bool;

		if (isActive) {
			if (is2004)
				success = set("cmi.location", location);
			else
				success = set("cmi.core.lesson_location", location);
		}
	}

	public function setStatus(isActive : Bool, is2004 : Bool, status : String) : Void {

		var success : Bool;
		trace("Setting status to "+status);

		if (isActive) {
			if (is2004) {
				success = set("cmi.completion_status", status);
				if (status == "completed") // FIXME, should this be here ?
					setScore(isActive, is2004, 100);
			}
			else
				success = set("cmi.core.lesson_status", status);
		}
	}

	/**
	 * Scorm 2004 only
	 */
	public function setSuccessStatus(isActive : Bool, status : String) : Void {

		var success : Bool;

		if (isActive) {
			success = set("cmi.success_status", status);
		}
	}

	public function setScore(isActive : Bool, is2004 : Bool, score : Int) : Void {

		if (isActive) {

			if (is2004) {

				set("cmi.score.scaled", Std.string(score / 100));
				set('cmi.score.raw', Std.string(score));

			} else {

				set("cmi.core.score.raw", Std.string(score));
			}
		}
	}

	public function setSuspendData(isActive : Bool, is2004 : Bool, sdata : String) : Void {

		if (isActive) {

			var success : Bool;

			if (is2004) {

				success = set("cmi.suspend_data", sdata);

			} else {

				success = set("cmi.suspend_data", sdata);
			}
		}
	}

	public function exit() : Bool {
		return pipwerks.Scorm.quit();
	}


	///
	// Internals
	//

	private function connect() : Bool {

		var result : Bool = false;

		if (!activeConnection) {

			result = pipwerks.Scorm.init();

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

		} else {

			displayDebugInfo("pipwerks.SCORM.init aborted: connection already active.");
		}
		displayDebugInfo("__connectionActive: " + activeConnection);

		return result;
	}

	private function set(key : String, value : String) : Bool {

		var result : Bool = false;

		if (!activeConnection) {

			displayDebugInfo("pipwerks.SCORM.set(" + key + ") failed: connection is inactive.");
			return result;
		}

		var result = pipwerks.Scorm.set(key,value);
		if (!result) {

			var errorCode : Int = getDebugCode();
			var debugInfo : String = getDebugInfo(errorCode);
			displayDebugInfo("pipwerks.SCORM.set(" + key + ") failed. \n"
							+ "Error code: " + errorCode + "\n"
							+ "Error info: " + debugInfo);
		}
		return result;
	}

	private function get(key : String) : String {

		var returnedValue : String = "";

		if (!activeConnection) {

			displayDebugInfo("pipwerks.SCORM.get(" + key + ") failed: connection is inactive.");
			return returnedValue;
		}

		returnedValue = pipwerks.Scorm.get(key);
		var errorCode : Int = getDebugCode();

		//GetValue returns an empty string on errors
		//Double-check errorCode to make sure empty string
		//is really an error and not field value
		if (returnedValue == "" && errorCode != 0) {

			var debugInfo : String = getDebugInfo(errorCode);
			displayDebugInfo("pipwerks.SCORM.get(" + key + ") failed. \n"
							+ "Error code: " + errorCode + "\n"
							+ "Error info: " + debugInfo);
		}
		return returnedValue;
	}

	private function getDebugCode() : Int {

		var code : Int = -1;
		var wrapper = pipwerks.Scorm.debug.getCode();
		return wrapper;
	}

	private function getDebugInfo(errorCode : Int) : String {

		var result : String = "";
		result = pipwerks.Scorm.debug.getInfo(errorCode);

		return result;
	}

	private function __getDiagnosticInfo(errorCode : Int) : String {

		var result : String = "";

		result = pipwerks.Scorm.debug.getDiagnosticInfo(errorCode);

		return result;
	}

	private function displayDebugInfo(msg : String) : Void {

		Utils.trace(msg);
	}
}