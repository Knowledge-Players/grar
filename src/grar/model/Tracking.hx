package grar.model;

import haxe.Timer;

enum Type {
	Aicc( url : String, is : String );
	Auto( lesson_location : String );
	Scorm( is2004 : Bool, success_status : String, suspend_data : String );
}

class Tracking {

	static inline var TIME_INTERVAL : Int = 1000;
	
	public function new(ia : Bool, si : String, sn : String, l : Null<String>, s : String, ms : Null<Int>, ls : Null<String>, in : Null<Bool>, t : Type) {

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
		if (in != null) {
			this.isNote = in;
		}
		this.type = t;

		if (isActive && Type.enumConstructor(t) != Type.enumConstructor(Auto(""))) {
			this.timer = new Timer(TIME_INTERVAL);
			this.timer.run = updateCurrentTime;
		}
	}

	public var studentId : String;
	public var studentName : String;
	public var lessonStatus : String = "";
	public var location (get,set) : String = "";
	public var score : String = "0";
	public var masteryScore : Int = 0;
	public var suivi : String;
	public var timer : Null<Timer>;
	public var startTime : Int = 0;
	public var currentTime : Int = 0;
	public var isNote : Bool = false;
	public var isActive : Bool;
	public var type : Type;

	function updateCurrentTime() : Void {

		currentTime += TIME_INTERVAL;
	}


	///
	// GETTERS / SETTERS
	//

	public function get_location() : String {

		switch(t) {

			case Scorm( b, ss, sd ), Aicc( u, i ):

				return location;

			case Auto( lesson_location ):

				return lesson_location;
		}
	}

	public function set_location(v : String) : String {

		location = v;

		onLocationChanged();
	}


	///
	// CALLBACKS
	//

	public dynamic function onLocationChanged() : Void { }
}