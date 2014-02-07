package grar.service;

import haxe.Http;

import grar.model.Tracking;

#if flash
import flash.external.ExternalInterface;
#end

class AiccService {

	public function new() { }

	/**
	 * Attempts to init an Aicc-typed Tracking object.
	 */
	public function init( isNote : Bool, activation : String, onSuccess : Tracking -> Void, onError : String -> Void ) : Void {
	//	init(isNote:Bool = false, activation:String = "on"):Void

		var _aicc_sid : String = "undefined";
		var _aicc_url : String = "undefined";
		var isActive : Null<Bool> = null;
		var studentId : Null<String> = null;
		var studentName : Null<String> = null;
		var location : Null<> = null;
		var score : Null<String> = null;
		var masteryScore : Null<Int> = null;
		var lessonStatus : Null<String> = null;

		var isAiccAvailable : Bool;
#if flash
		if(ExternalInterface.available) {

			isAiccAvailable = cast ExternalInterface.call("aicc.isAvailable");
		
			if (isAiccAvailable) {

				_aicc_sid = Std.string(ExternalInterface.call("aicc.aicc_sid"));
				_aicc_url = Std.string(ExternalInterface.call("aicc.aicc_url"));
			}
		}
#elseif js
		isAiccAvailable = untyped __js__('aicc.isAvailable') == true;

		if (isAiccAvailable) {

			_aicc_sid = untyped __js__('aicc.aicc_sid');
			_aicc_url = untyped __js__('aicc.aicc_url');
		}
#end
//this.activation(activation);
		switch (activation) {

			case "off" :
				isActive = false;
				studentId = "LMS Out";
				studentName = "Apprenant non suivi";
				//location = suivi; TODO check why this ?
				score = "0";
				masteryScore = 80;
				lessonStatus = "n,a";
			
			case "on" :
				isActive = true;
		}
//startTime = timer.currentCount; // TODO check but seems useless
		if (isActive) {

			if (_aicc_sid != "undefined" && _aicc_url != "undefined") {

				var http : Http = new Http( _aicc_url );

				http.onData = function(d:String){
						
						if (d == "undefined") {

							init(isNote, "off", onSuccess, onError);
							return;
						}
						var da : Array<String>;

						if (d.split("\r\n").length > 5)
							da = d.split("\r\n");
						else if (d.split("\r").length > 5)
							da = d.split("\r");
						else if (d.split("\n").length > 5)
							da = d.split("\n");
						else
							da = null;

						if (da == null) {

							init(isNote, "off", onSuccess, onError);
							return;
						}
						for (z in 0...da.length) {

							da[z] = da[z].split(" ").join("");

							switch (da[z].split("=")[0].toUpperCase()) {

								case "LESSON_LOCATION" :
									location = da[z].split("=")[1];
								
								case "LESSON_STATUS" :
									lessonStatus = da[z].split("=")[1];
								
								case "SCORE" :
									score = da[z].split("=")[1];
								
								case "MASTERY_SCORE" :
									masteryScore = Std.parseInt(da[z].split("=")[1]);
								
								case "STUDENT_ID" :
									studentId = da[z].split("=")[1];
								
								case "STUDENT_NAME" :
									studentName = da[z].split("=")[1];
							}
						}
//dispatchEvent(new Event(Event.INIT));
						onSuccess( new Tracking(isActive, studentId, studentName, location, score, masteryScore, lessonStatus, isNote, Aicc(_aicc_url, _aicc_sid)) );
					}

				http.onError = onError;

				http.setPostData("command=getparam&session_id="+_aicc_sid);

				http.request(true);
// dispatchEvent(new Event(Event.INIT));
			
			} else {

				init(isNote, "off", onSuccess, onError);
				return;
			}
		}
		onSuccess( new Tracking(isActive, studentId, studentName, location, score, masteryScore, lessonStatus, isNote, Aicc(_aicc_url, _aicc_sid)) );
// dispatchEvent(new Event(Event.INIT));
	}
}