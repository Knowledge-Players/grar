package grar.service;

import grar.model.Tracking;

#if flash
//import flash.errors.Error;
//import flash.events.Event;
import flash.net.SharedObject;
//import flash.net.SharedObjectFlushStatus;
#end

class AutoService {

	public function new() { }

#if flash
	var mySo : SharedObject;
#end

	/**
	 * Attempts to init an Auto-typed Tracking object.
	 */
	public function init( isNote : Bool, activation : String, onSuccess : Tracking -> Void, onError : String -> Void ) : Void {

		var isActive : Bool = false;
		var studentId : Null<String> = null;
		var studentName : Null<String> = null;
		var lesson_location : Null<String> = null;
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
		}
		if (isActive) {

			try {
#if flash
				mySo = SharedObject.getLocal("saveFile");
			
				lessonStatus = mySo.data.lessonStatus;
				score = mySo.data.score;
				studentName = mySo.data.studentName;
				studentId = mySo.data.studentId;
				lesson_location = mySo.data.lesson_location;
#end
			} catch(e : String) {

				onError(e);		
			}
// dispatchEvent(new Event(Event.INIT));
//		} else {
// dispatchEvent(new Event(Event.INIT));
		}
		onSuccess( new Tracking(isActive, studentId, studentName, null, score, masteryScore, lessonStatus, isNote, Auto(lesson_location)) );
	}

	public function setLocation(isActive : Bool, location : String) : Void {

		if (isActive) {
#if flash
			mySo.data.lesson_location = location;
#end
		}
	}

	public function setStatus(isActive : Bool, status : String) : Void {

		if (isActive) {
#if flash
			mySo.data.lessonStatus = status;
#end
		}
	}

	public function setScore(isActive : Bool, score : Int) : Void {

		if (isActive) {
#if flash
			mySo.data.score = Std.string(score);
#end
		}
	}
}