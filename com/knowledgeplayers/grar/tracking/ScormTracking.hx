package com.knowledgeplayers.grar.tracking;

class ScormTracking extends Tracking {

	public var success_status:String = "";
	public var suspend_data:String = "";
	public var isNote:Bool = false;

	public var isActive:Bool = false;
	public var is2004:Bool;

	public var scorm:Scorm;

	public function new(is2004:Bool = false)
	{
		super();
		this.is2004 = is2004;
		score = "";
		masteryScore = 0;

	}

	override function init(isNote:Bool = false, activation:String = "on"):Void
	{
		this.activation(activation);
		timer.start();
		startTime = timer.currentCount;
		this.isNote = isNote;
		if(isActive){
			scorm = new Scorm();
			var success:Bool = scorm.connect();
			if(success){
				if(is2004){
					lessonStatus = scorm.get("cmi.completion_status");
					success_status = scorm.get("cmi.success_status");
					score = scorm.get("cmi.score.raw");
					studentName = scorm.get("cmi.learner_name");
					studentId = scorm.get("cmi.learner_id");
					location = scorm.get("cmi.location");
					suspend_data = scorm.get("cmi.suspend_data");
				}
				else{
					lessonStatus = scorm.get("cmi.core.lessonStatus");

					score = scorm.get("cmi.core.score.raw");
					studentName = scorm.get("cmi.core.studentName");
					studentId = scorm.get("cmi.core.studentId");
					location = scorm.get("cmi.core.lesson_location");
					suspend_data = scorm.get("cmi.suspend_data");
				}

			}
			else{
				init(isNote, "off");
			}
		}
	}

	override function getLocation():String
	{
		return location;
	}

	override function setLocation(location:String):Void
	{
		this.location = location;
		var success:Bool;
		if(isActive){
			if(is2004){
				success = scorm.set("cmi.location", location);
			}
			else{
				success = scorm.set("cmi.core.lesson_location", location);
			}
		}
	}

	override function getSuspend():String
	{
		return (suspend_data);
	}

	override function setSuspend(suspention:String):Void
	{
		suspend_data = suspention;
		if(isActive){
			var success:Bool;
			if(is2004){
				success = scorm.set("cmi.suspend_data", suspention);
			}
			else{
				success = scorm.set("cmi.suspend_data", suspention);
			}
		}
	}

	override function getStatus():String
	{
		return (lessonStatus);
	}

	public function getSuccessStatus():String
	{
		var s:String = "";
		if(is2004){
			s = success_status;
		}
		else{
			s = getStatus();
		}
		return s;
	}

	public function setSuccessStatus(isSucces:Bool):Void
	{
		if(is2004){
			var _local2:String = "";
			if(isSucces){
				_local2 = "passed";
			}
			else if(this.getSuccessStatus() != "passed"){
				_local2 = "failed";
			}
			else{
				_local2 = "failed";
			}
			success_status = _local2;
			var success:Bool = scorm.set("cmi.success_status", _local2);
		}
		else{
			setStatus(isSucces);
		}
	}

	override function setStatus(status:Bool):Void
	{
		var stringStatus:String = "";
		if(isNote){
			if(is2004){
				setSuccessStatus(status);
			}
			else{
				if(status){
					stringStatus = "passed";
				}
				else if(getStatus() != "passed"){
					stringStatus = "failed";
				}
				else{
					stringStatus = "failed";
				}
			}
		}
		else{
			if(status){
				stringStatus = "completed";
			}
			else if(getStatus() != "completed"){
				stringStatus = "incomplete";
			}
			else{
				stringStatus = "completed";
			}
		}
		lessonStatus = stringStatus;
		var success:Bool;
		if(this.isActive){
			if(is2004){
				success = scorm.set("cmi.completion_status", stringStatus);
				if(!isNote && status){
					setScore(100);
				}
			}
			else{
				success = scorm.set("cmi.core.lesson_status", stringStatus);
			}
		}
	}

	override function setScore(score:Int):Void
	{
		if((Std.string(getScore()) == "") || (getScore() <= score)){
			this.score = Std.string(score);
			if(this.isActive){
				if(is2004){
					scorm.set("cmi.score.scaled", Std.string(score / 100));
					scorm.set('cmi.score.raw', Std.string(score));
				}
				else{
					var success:Bool = scorm.set("cmi.core.score.raw", Std.string(score));
				}
			}
			if(getScore() >= this.getMasteryScore()){
				setSuccessStatus(true);
			}
			else{
				setSuccessStatus(false);
			}
		}
	}

	override function getMasteryScore():Int
	{
		return masteryScore;
	}

	override function putparam():Void
	{
		if(isActive){
			if(is2004){
				scorm.set("cmi.session_time", getFormatTime2K4(timer.currentCount - startTime));
				scorm.set("cmi.completion_status", lessonStatus);
				scorm.set("cmi.success_status", success_status);
				scorm.set("cmi.score.raw", score);
				scorm.set("cmi.location", location);
				scorm.set("cmi.exit", "suspend");
			}
			else{
				scorm.set("cmi.core.session_time", getFormatTime(timer.currentCount - startTime));
				scorm.set("cmi.core.lessonStatus", lessonStatus);
				scorm.set("cmi.core.score.raw", score);
				scorm.set("cmi.core.lesson_location", location);
				scorm.set("cmi.exit", "suspend");
			}
			scorm.save();
		}
	}

    private  function getFormatTime2K4(_time: Int):String{
        //format 00:00:54 to PT00H00M54S
        var _format:String = getFormatTime(_time);
        var timeArray:Array<String> = _format.split(':');
        var timeformated:String = 'PT'+timeArray[0]+'H'+timeArray[1]+'M'+timeArray[2]+'S';

        return timeformated;
    }

	public function navigateToSco(identifier:String):Bool
	{
		var success:Bool = scorm.set("adl.nav.request", "{target=" + identifier + "}choice");
		if(success){
            scorm.set("cmi.session_time", getFormatTime2K4(timer.currentCount - startTime));
			exitAU();
		}
		return success;
	}

	public function isScoAvailable(identifier:String):Bool
	{
		var s:String = scorm.get("adl.nav.request_valid.choice.{target=" + identifier + "}");
		var success:Bool = s == "true";
		return success;
	}

	override function exitAU():Void
	{
		scorm.disconnect();
	}

	override function clearDatas():Void
	{

	}

	// Private

	private function activation(activation:String):Void
	{
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
	}
}