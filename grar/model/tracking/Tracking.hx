package grar.model.tracking;

import haxe.Timer;

enum TrackingType {
	Aicc( url : String, is : String );
	Auto( lessonLocation : String );
	Scorm( is2004 : Bool, successStatus : String, suspendData : String );
}

class Tracking {

	static inline var TIME_INTERVAL : Int = 1000;

	public function new(ia : Bool, si : String, sn : String, l : Null<String>, s : String, ms : Null<Int>, ls : Null<String>, isn : Null<Bool>, t : TrackingType) {

		this.isActive = ia;
		this.studentId = si;
		this.studentName = sn;
		if (l != null) {
			this.location = l;
		}
		if (s != null) {
			this.score = s;
		}
		if (ms != null) {
			this.masteryScore = ms;
		}
		if (ls != null) {
			this.lessonStatus = ls;
		}
		if (isn != null) {
			this.isNote = isn;
		}
		this.type = t;

		if (isActive && Type.enumConstructor(t) != Type.enumConstructor(Auto(""))) {
			#if (flash || flash8 || java || js)
			this.timer = new Timer(TIME_INTERVAL);
			this.timer.run = updateCurrentTime;
			#end
		}
	}

	public var studentId : String;
	public var studentName : String;
	public var lessonStatus : String = "";
	@:isVar public var location (get,set) : String = "";
	public var score : String = "0";
	public var masteryScore (default, null) : Int = 0;
	public var suivi : String;
	public var timer : Null<Timer>;
	public var startTime : Int = 0;
	public var currentTime : Int = 0;
	public var isNote : Bool = false;
	public var isActive : Bool;
	public var type : TrackingType;

	function updateCurrentTime() : Void {

		currentTime += TIME_INTERVAL;
	}


	///
	// API
	//

	public function getStatus() : String {

		return lessonStatus;
	}

	public function setStatus(status : Bool) : Void {

		var stringStatus : String = "";

		if (this.isNote) {

			if (status) {

				stringStatus = "passed";

			} else if(this.getStatus() != "passed") {

				stringStatus = "failed";

			} else {

				stringStatus = "failed";
			}

		} else {

			if (status) {

				stringStatus = "completed";

			} else if(this.getStatus() != "completed") {

				stringStatus = "incomplete";

			} else {

				stringStatus = "incomplete";
			}
		}
		lessonStatus = stringStatus;

		onStatusChanged();
	}

	/**
	 * SCORM ONLY
	 */
	public function getSuccessStatus() : String {

		switch(type) {

			case Scorm( is2004, ss, sd ):

				if (is2004) {

					return ss;

				} else {

					return getStatus();
				}

			default:

				throw "unsupported success_status for this Tracking type: "+type;
		}
	}

	/**
	 * SCORM ONLY
	 */
	public function setSuccessStatus(isSuccess : Bool) : Void {

		switch(type) {

			case Scorm( is2004, ss, sd ):

				if (is2004) {

					var _local2 : String = "";

					if (isSuccess) {

						_local2 = "passed";

					} else if(this.getSuccessStatus() != "passed") {

						_local2 = "failed";

					} else {

						_local2 = "failed";
					}
					type = Scorm( is2004, _local2, sd );

					onSuccessStatusChanged();

				} else {

					setStatus(isSuccess);
				}

			default:

				throw "unsupported setSuccessStatus method for this Tracking type: "+type;
		}
	}

	public function getScore() : Int {

		if (score == "") {

			return 0;

		} else {

			return Std.parseInt(score);
		}
	}

	public function setScore(v : Int) : Void {

		if((Std.string(this.getScore()) == "") || (this.getScore() <= v)) {

			this.score = Std.string(v);

			onScoreChanged();
		}
	}

	/**
	 * SCORM ONLY
	 */
	public function getSuspend() : String {

		switch(type) {

			case Scorm( is2004, ss, sd ):

				return sd;

			default :

				throw "unsupported getSuspend() for type "+type;
		}
	}

	/**
	 * SCORM ONLY
	 */
	public function setSuspend(suspention : String) : Void {

		switch(type) {

			case Scorm( is2004, ss, sd ):

				type = Scorm( is2004, ss, suspention );

				onSuspendDataChanged();

			default :

				throw "unsupported setSuspend() for type "+type;

		}
	}


	///
	// GETTERS / SETTERS
	//

	public function get_location() : String {

		switch(type) {

			case Scorm(_), Aicc(_):

				return location;

			case Auto(lesson_location):

				return lesson_location;
		}
	}

	public function set_location(v : String) : String {

		location = v;

		onLocationChanged();

		return location;
	}


	///
	// CALLBACKS
	//

	public dynamic function onStatusChanged() : Void { }

	public dynamic function onSuccessStatusChanged() : Void { } // SCORM ONLY

	public dynamic function onLocationChanged() : Void { }

	public dynamic function onScoreChanged() : Void { }

	public dynamic function onSuspendDataChanged() : Void { } // SCORM ONLY
}