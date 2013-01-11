package com.knowledgeplayers.grar.tracking;

import nme.events.Event;
import nme.utils.Timer;

class ScormTracking extends Tracking {
	
	public var success_status : String = "";
	public var lesson_location : String = "";
	public var suspend_data : String = "";
	public var isNote : Bool = false;
	
	public var isActive: Bool = false;
	public var startTime: Int = 0;
	public var timer: Timer;
	public var is2004:Bool;
	
	public var scorm:Scorm;

	public function new(is2004: Bool = false)
	{
		super();
		this.is2004 = is2004;
		this.timer = new Timer(1000, 0);
		score = "";
		masteryScore = 0;
		
	}

	override function activation(activation:String) : Void
	{
		switch (activation) {
			case "off" :
				isActive = false;
				lesson_location = suivi;
				score = "";
				masteryScore = 80;
				lessonStatus = "n,a";
				success_status = "unknow";
				suspend_data = "suspend";
				studentId = "12";
				studentName="miloose";
			case "on" :
				isActive = true;
		}
	}
	
	override function init (isNote:Bool = false, activation:String = "on") : Void
	{
		this.activation(activation);
		timer.start();
		startTime = timer.currentCount;
		this.isNote = isNote;
		if (isActive) {
			scorm = new Scorm();
			var success:Bool = scorm.connect();
			if(success){
				if (is2004) {
					lessonStatus = scorm.get("cmi.completion_status");
					success_status = scorm.get("cmi.success_status");
					score = scorm.get("cmi.score.raw");
					studentName = scorm.get("cmi.learner_name");
					studentId = scorm.get("cmi.learner_id");
					lesson_location = scorm.get("cmi.location");
					suspend_data = scorm.get("cmi.suspend_data");
				} else {
					lessonStatus = scorm.get("cmi.core.lessonStatus");
					
					score = scorm.get("cmi.core.score.raw");
					studentName = scorm.get("cmi.core.studentName");
					studentId = scorm.get("cmi.core.studentId");
					lesson_location = scorm.get("cmi.core.lesson_location");
					suspend_data = scorm.get("cmi.suspend_data");
				}
				
				dispatchEvent(new Event(Event.INIT));
			} else {
				init(isNote,"off");
			}
		} else {
			dispatchEvent(new Event(Event.INIT));
		}
				
	}
	
	override function getLocation() : String
	{
		return lesson_location;
	}
	
	override function setLocation(location:String) : Void
	{
		lesson_location = location;
		var success:Bool;
		if (isActive) {
			if (is2004) {
				success = scorm.set("cmi.location", location);
			} else {
				success = scorm.set("cmi.core.lesson_location", location);
			}
		}
	}
	
	override function getSuspend() : String
	{
		return (suspend_data);
	}
	
	override function setSuspend(suspention: String) : Void
	{
		suspend_data = suspention;
		if (isActive) {
			var success:Bool;
			if (is2004) {
				success = scorm.set("cmi.suspend_data", suspention);
			} else {
				success = scorm.set("cmi.suspend_data", suspention);
			}
		}
	}
	
	override function getStatus() : String
	{
		return (lessonStatus);
	}
	
	public function getSuccessStatus() : String
	{
		var s:String =  "";
		if (is2004) {
			s = success_status;
		} else {
			s = getStatus ();
		}
		return s;
	}
	
	public function setSuccessStatus(isSucces: Bool) : Void
	{
		if (is2004) {
			var _local2:String = "";
			if (isSucces) {
				_local2 = "passed";
			} else if (this.getSuccessStatus () != "passed") {
				_local2 = "failed";
			} else {
				_local2 = "failed";
			}
			success_status = _local2;
			var success:Bool = scorm.set("cmi.success_status", _local2);
		} else {
			setStatus(isSucces);
		}
	}
	
	override function setStatus(status: Bool) : Void
	{
		var stringStatus:String = "";
		if (isNote)
		{
			if (is2004) {
				setSuccessStatus(status);	
			} else {
				if (status) {
					stringStatus = "passed";
				} else if (getStatus () != "passed") {
					stringStatus = "failed";
				} else {
					stringStatus = "failed";
				}
			}
		} else {
			if (status) {
				stringStatus = "completed";
			} else if (getStatus () != "completed") {
				stringStatus = "incomplete";
			} else {
				stringStatus = "completed";
			}
		}
		lessonStatus = stringStatus;
		var success:Bool;
		if (this.isActive) {
			if (is2004) {
				success = scorm.set("cmi.completion_status", stringStatus);
				if (!isNote && status) {
					setScore(100);
				}
			} else {
				success = scorm.set("cmi.core.lesson_status", stringStatus);
			}
		}
	}
	
	override function setScore(score: Int) : Void
	{
		if ((Std.string(getScore()) == "") || (getScore () <= score))
		{
			this.score = Std.string(score);
			if (this.isActive) {
				if (is2004) {
					scorm.set("cmi.score.scaled", Std.string(score/100));
					scorm.set('cmi.score.raw',Std.string(score));
				} else {
					var success:Bool = scorm.set("cmi.core.score.raw", Std.string(score));
				}
			}
			if (getScore () >= this.getMasteryScore ()) {
				setSuccessStatus (true);
			} else {
				setSuccessStatus (false);
			}
		}
	}
	
	override function getMasteryScore() : Int
	{
		return masteryScore;
	}
	
	public function returnFormatedTime() : String
	{
		var _local4:Int = Math.round ((timer.currentCount - this.startTime) / 1000);
		var _local2:String = "";
		var _local3:Int = Math.floor (_local4 / 3600);
		var _local5:Int = Math.floor ((_local4 - (_local3 * 3600)) / 60);
		var _local6:Int = (_local4 - (_local3 * 3600)) - (_local5 * 60);
		if (_local3 < 10)
		{
			_local2 = _local2 + "0";
		}
		_local2 = _local2 + (_local3 + ":");
		if (_local5 < 10)
		{
			_local2 = _local2 + "0";
		}
		_local2 = _local2 + (_local5 + ":");
		if (_local6 < 10)
		{
			_local2 = _local2 + "0";
		}
		_local2 = _local2 + _local6;
		return (_local2);
	}
	
	override function putparam() : Void
	{
		if (isActive) {
			if (is2004) {
				scorm.set("cmi.session_time", returnFormatedTime());
				scorm.set("cmi.completion_status", lessonStatus);
				scorm.set("cmi.success_status", success_status);
				scorm.set("cmi.score.raw", score);
				scorm.set("cmi.location", lesson_location);
				scorm.set("cmi.exit", "suspend");
			} else {
				scorm.set("cmi.core.session_time", returnFormatedTime());
				scorm.set("cmi.core.lessonStatus", lessonStatus);
				scorm.set("cmi.core.score.raw", score);
				scorm.set("cmi.core.lesson_location", lesson_location);
				scorm.set("cmi.exit", "suspend");
			}
			scorm.save();
		}
	}
	
	public function navigateToSco(identifier: String) : Bool
	{
		var success:Bool = scorm.set("adl.nav.request", "{target="+identifier+"}choice");
		if (success) {
			exitAU ();
		}
		return success;
	}
	
		
	public function isScoAvailable(identifier: String) : Bool
	{
		var s:String = scorm.get("adl.nav.request_valid.choice.{target="+identifier+"}");
		var success:Bool = s == "true";
		return success;
	}
	
	override function exitAU() : Void
	{
		scorm.disconnect();
	}
	
	override function clearDatas() : Void
	{
		
	}
}