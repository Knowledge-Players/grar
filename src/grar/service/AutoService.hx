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

	/**
	 * Attempts to init an Auto-typed Tracking object.
	 */
	public function init( isNote : Bool, activation : String, onSuccess : Tracking -> Void, onError : String -> Void ) : Void {

		var isActive : Bool;
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
				lesson_location = suivi;
				score = "0";
				masteryScore = 80;
				lessonStatus = "n,a";

			case "on" :
				isActive = true;
		}
		if (isActive) {

			try {
#if flash
				var mySo : SharedObject = SharedObject.getLocal("saveFile");
			
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
//		}
		onSuccess( new Tracking(isActive, studentId, studentName, null, score, masteryScore, lessonStatus, isNote, Auto(lesson_location)) );
	}
}