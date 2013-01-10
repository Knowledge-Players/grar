package com.knowledgeplayers.grar.tracking;
	
import nme.errors.Error;
import nme.events.Event;
import nme.events.IOErrorEvent;
import nme.external.ExternalInterface;
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLRequestMethod;
import nme.net.URLVariables;
import nme.utils.Timer;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;

class AiccTracking extends Tracking
{
	
	public var _aicc_sid:String;
	public var _aicc_url:String;
	
	public var lesson_location:String;
	public var isNote:Bool;
	
	public var isActive:Bool;
	public var startTime:Int;
	public var timer: Timer;
	
	public var scriptRequest:URLRequest;
	public var scriptLoader:URLLoader;
	public var scriptVars:URLVariables;
	
	public var note:Bool;
	
	public function new() {
		super();
		this.lessonStatus = "";
		this.score = "0";
		this.masteryScore = 0;
		this.lesson_location = "";
		this.isNote = false;

		this.timer = new Timer(1000, 0);

	}
	
	override function activation(activation:String):Void {
		switch (activation) {
			case "off" :this.isActive = false;
						this.studentId = "LMS Out";
						this.studentName = "Apprenant non suivi";
						this.lesson_location =suivi;
						this.score = "0";
						this.masteryScore = 80;
						this.lessonStatus = "n,a";
			case "on" :	this.isActive = true;
						timer.start();
		}
	}
	
	override function init(isNote: Bool = false, activation: String = "on") : Void 
	{
		var is_EI_available: Bool = ExternalInterface.available;
		if(is_EI_available){
			var bool:Bool= cast(ExternalInterface.call("aicc.isAvailable"), Bool);
			if (bool){
				var aicc_url:String = Std.string(ExternalInterface.call("aicc.aicc_url"));
				var aicc_sid:String = Std.string(ExternalInterface.call("aicc.aicc_sid"));
				_aicc_sid = aicc_sid;
				_aicc_url = aicc_url;
			}
		}
		
		note=isNote;
		if(_aicc_sid == null){
			_aicc_sid = "undefined";
		}
		
		if(_aicc_url == null){
			_aicc_url = "undefined";
		}
		this.activation(activation);

		startTime = timer.currentCount;
		this.isNote = isNote;
		
		var bgColor:Int = 0x00CCFF;
		var size:Int = 1;
		
		if (this.isActive) {
			if (  _aicc_sid != "undefined" && _aicc_url != "undefined" ) {
				scriptLoader= new URLLoader();
				scriptVars = new URLVariables();
				scriptRequest =new URLRequest(_aicc_url);
				
				scriptLoader.addEventListener(Event.COMPLETE, getParamSuccessful);
				scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, getParamError);
				
				scriptVars.command = "getparam";
				scriptVars.session_id = _aicc_sid;
				
				scriptRequest.data =scriptVars;
				scriptRequest.method = URLRequestMethod.POST;
				
				scriptLoader.load(scriptRequest);
				
				dispatchEvent(new Event(Event.INIT));
			} else {
				init(isNote,"off");
			}
		} else {
			dispatchEvent(new Event(Event.INIT));
		}
	}
	
	public function getParamSuccessful(e: Event) : Void
	{
		this.loadDatas(Std.string(e.target.data),note);
		scriptLoader.removeEventListener(Event.COMPLETE, getParamSuccessful);
		scriptLoader.removeEventListener(IOErrorEvent.IO_ERROR, getParamError);
	}
	
	public function getParamError(e: IOErrorEvent) : Void
	{
		
	}
	
	
	public function loadDatas(datas: String, isNote: Bool) : Void
	{
		var listeDatas = new Array<String>();
		if (datas != "undefined"){
			if (datas.split("\r\n").length>5)
				listeDatas = datas.split("\r\n");
			else if (datas.split("\r").length>5)
				listeDatas = datas.split("\r");
			else if (datas.split("\n").length>5)
				listeDatas = datas.split("\n");
			else
				listeDatas = null;

			if (listeDatas != null) {
				for (z in 0...listeDatas.length) {
					listeDatas[z] = listeDatas[z].split(" ").join("");
					
					switch (listeDatas[z].split("=")[0].toUpperCase()) {
						case "LESSON_LOCATION" :
							lesson_location = listeDatas[z].split("=")[1];
						case "LESSON_STATUS" :
							lessonStatus = listeDatas[z].split("=")[1];
						case "SCORE" :
							score = listeDatas[z].split("=")[1];
						case "MASTERY_SCORE" :
							masteryScore = Std.parseInt(listeDatas[z].split("=")[1]);
						case "STUDENT_ID" :
							studentId = listeDatas[z].split("=")[1];
						case "STUDENT_NAME" :
							studentName = listeDatas[z].split("=")[1];
					}
				}
				dispatchEvent(new Event(Event.INIT));
				
			} else {
				init(isNote,"off");
			}
		} else {
			init(isNote,"off");
		}	
	}

	override function getLocation() : String
	{
		return lesson_location;
	}

	override function setLocation(location: String) : Void
	{
		lesson_location = location;
		putparam();
	}
	
	override function getStatus() : String
	{
		return lessonStatus;
	}
	
	override function setStatus(status: Bool) : Void
	{
		var stringStatus:String = "";
		if (this.isNote) {
			if (status) {
				stringStatus = "passed";
			} else if (this.getStatus() != "passed") {
				stringStatus = "failed";
			} else {
				stringStatus = "failed";
			}
		} 
		else{
			if (status) {
				stringStatus = "completed";
			} else if (this.getStatus() != "completed") {
				stringStatus = "incomplete";
			} else {
				stringStatus = "incomplete";
			}
		}
		lessonStatus = stringStatus;
		setLocation(lesson_location);
	}
	
	override function setSuspend(suspention: String) : Void
	{
		throw new Error("setSuspend AICC");
	}
	
	override function getSuspend() : String
	{
		throw new Error("getSuspend AICC");
		return null;
	}
	
	override function setScore(score: Int) : Void
	{
		if ((Std.string(this.getScore()) == "") || (this.getScore()<= score)) {
			this.score = Std.string(score);
			if (this.getScore()>=this.getMasteryScore()) {
				this.setStatus(true);
			} else {
				this.setStatus(false);
			}
		}
	}
	
	override function getMasteryScore() : Int
	{
		return masteryScore;
	}
	
	public function returnFormatedTime() : String
	{
		var secondsTime:Int = Math.round((timer.currentCount-startTime));
		var time:String = "";
		var hours:Int = Math.floor(secondsTime/3600);
		var minutes:Int = Math.floor((secondsTime % 3600)/60);
		var seconds:Int = secondsTime % 60;
		if (hours<10) {
			time = time+"0";
		}
		time = time+(hours+":");
		if (minutes<10) {
			time = time+"0";
		}
		time = time+(minutes+":");
		if (seconds<10) {
			time = time+"0";
		}
		time = time+seconds;
		return time;
	}
	
	override function putparam():Void
	{
		if ( _aicc_sid != "undefined" && _aicc_url != "undefined") {
			
			scriptLoader= new URLLoader();
			scriptVars = new URLVariables();
			scriptRequest =new URLRequest(_aicc_url);
			
			scriptLoader.addEventListener(Event.COMPLETE, putParamSuccessful);
			scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, putParamError);
			
			scriptVars.command = "putparam";
			scriptVars.session_id = _aicc_sid;
			scriptVars.version = "2.2";
			
			var aicc_data:String = "[core]";
			aicc_data += "\r\nstudentId="+studentId;
			aicc_data += "\r\nstudentName="+studentName;
			aicc_data += "\r\nlesson_location="+lesson_location;
			aicc_data += "\r\ncredit=no-credit";
			aicc_data += "\r\nlessonStatus="+lessonStatus;
			aicc_data += "\r\nscore="+score;
			aicc_data += "\r\ntime="+returnFormatedTime();
			aicc_data += "\r\n[core_lesson]";
			
			scriptVars.aicc_data = aicc_data;
			
			scriptRequest.data =scriptVars;
			scriptRequest.method = URLRequestMethod.POST;
			
			scriptLoader.load(scriptRequest);
		}
	}
	
	public function putParamSuccessful(e: Event) : Void
	{
		scriptLoader.removeEventListener(Event.COMPLETE, getParamSuccessful);
		scriptLoader.removeEventListener(IOErrorEvent.IO_ERROR, getParamError);
	}
	
	public function putParamError(e: IOErrorEvent) : Void
	{
		
	}
	
	override function exitAU() : Void
	{
		ExternalInterface.call("exitAU");
	}
}