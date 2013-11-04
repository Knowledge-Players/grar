package com.knowledgeplayers.grar.tracking;
#if flash
import flash.external.ExternalInterface;
#end
import flash.errors.Error;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Timer;

class AiccTracking extends Tracking {

	public var _aicc_sid:String;
	public var _aicc_url:String;

	public var isNote:Bool;

	public var isActive:Bool;

	public var scriptRequest:URLRequest;
	public var scriptLoader:URLLoader;
	public var scriptVars:URLVariables;

	public var note:Bool;

	public function new()
	{
		super();
		this.lessonStatus = "";
		this.score = "0";
		this.masteryScore = 0;
		this.location = "";
		this.isNote = false;

		this.timer = new Timer(1000, 0);

	}

	override function init(isNote:Bool = false, activation:String = "on"):Void
	{
		#if flash
		var is_EI_available:Bool = ExternalInterface.available;
		if(is_EI_available){
			var bool:Bool = cast(ExternalInterface.call("aicc.isAvailable"), Bool);
			if(bool){
				_aicc_sid = Std.string(ExternalInterface.call("aicc.aicc_sid"));
				_aicc_url = Std.string(ExternalInterface.call("aicc.aicc_url"));
			}
		}
		#elseif js
			var aiccAvailable: Bool = untyped __js__('aicc.isAvailable') == true;
			if(aiccAvailable){
				_aicc_sid = untyped __js__('aicc.aicc_sid');
				_aicc_url = untyped __js__('aicc.aicc_url');
			}
		#end

		note = isNote;
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

		if(this.isActive){
			if(_aicc_sid != "undefined" && _aicc_url != "undefined"){
				scriptLoader = new URLLoader();
				scriptVars = new URLVariables();
				scriptRequest = new URLRequest(_aicc_url);

				scriptLoader.addEventListener(Event.COMPLETE, getParamSuccessful);
				scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, getParamError);

				scriptVars.command = "getparam";
				scriptVars.session_id = _aicc_sid;

				scriptRequest.data = scriptVars;
				scriptRequest.method = URLRequestMethod.POST;

				scriptLoader.load(scriptRequest);

				dispatchEvent(new Event(Event.INIT));
			}
			else{
				init(isNote, "off");
			}
		}
		else{
			dispatchEvent(new Event(Event.INIT));
		}
	}

	override function getLocation():String
	{
		return location;
	}

	override function setLocation(location:String):Void
	{
		this.location = location;
		putparam();
	}

	override function getStatus():String
	{
		return lessonStatus;
	}

	override function setStatus(status:Bool):Void
	{
		var stringStatus:String = "";
		if(this.isNote){
			if(status){
				stringStatus = "passed";
			}
			else if(this.getStatus() != "passed"){
				stringStatus = "failed";
			}
			else{
				stringStatus = "failed";
			}
		}
		else{
			if(status){
				stringStatus = "completed";
			}
			else if(this.getStatus() != "completed"){
				stringStatus = "incomplete";
			}
			else{
				stringStatus = "incomplete";
			}
		}
		lessonStatus = stringStatus;
		setLocation(location);
	}

	override function setSuspend(suspention:String):Void
	{
		throw new Error("setSuspend AICC");
	}

	override function getSuspend():String
	{
		throw new Error("getSuspend AICC");
		return null;
	}

	override function setScore(score:Int):Void
	{
		if((Std.string(this.getScore()) == "") || (this.getScore() <= score)){
			this.score = Std.string(score);
			if(this.getScore() >= this.getMasteryScore()){
				this.setStatus(true);
			}
			else{
				this.setStatus(false);
			}
		}
	}

	override function getMasteryScore():Int
	{
		return masteryScore;
	}

	override function putparam():Void
	{
		if(_aicc_sid != "undefined" && _aicc_url != "undefined"){

			scriptLoader = new URLLoader();
			scriptVars = new URLVariables();
			scriptRequest = new URLRequest(_aicc_url);

			scriptLoader.addEventListener(Event.COMPLETE, putParamSuccessful);
			scriptLoader.addEventListener(IOErrorEvent.IO_ERROR, putParamError);

			scriptVars.command = "putparam";
			scriptVars.session_id = _aicc_sid;
			scriptVars.version = "2.2";

			var aicc_data:String = "[core]";
			aicc_data += "\r\nstudentId=" + studentId;
			aicc_data += "\r\nstudentName=" + studentName;
			aicc_data += "\r\nlesson_location=" + location;
			aicc_data += "\r\ncredit=no-credit";
			aicc_data += "\r\nlessonStatus=" + lessonStatus;
			aicc_data += "\r\nscore=" + score;
			aicc_data += "\r\ntime=" + getFormatTime(timer.currentCount - startTime);
			aicc_data += "\r\n[core_lesson]";

			scriptVars.aicc_data = aicc_data;

			scriptRequest.data = scriptVars;
			scriptRequest.method = URLRequestMethod.POST;

			scriptLoader.load(scriptRequest);
		}
	}

	override function exitAU():Void
	{
		#if flash
		ExternalInterface.call("exitAU");
		#elseif js
		untyped __js__('exitAU()');
		#end
	}

	// Private

	private function putParamSuccessful(e:Event):Void
	{
		scriptLoader.removeEventListener(Event.COMPLETE, getParamSuccessful);
		scriptLoader.removeEventListener(IOErrorEvent.IO_ERROR, getParamError);
	}

	private function putParamError(e:IOErrorEvent):Void
	{

	}

	private function getParamSuccessful(e:Event):Void
	{
		this.loadDatas(Std.string(e.target.data), note);
		scriptLoader.removeEventListener(Event.COMPLETE, getParamSuccessful);
		scriptLoader.removeEventListener(IOErrorEvent.IO_ERROR, getParamError);
	}

	private function getParamError(e:IOErrorEvent):Void
	{

	}

	private function activation(activation:String):Void
	{
		switch (activation) {
			case "off" :this.isActive = false;
				this.studentId = "LMS Out";
				this.studentName = "Apprenant non suivi";
				this.location = suivi;
				this.score = "0";
				this.masteryScore = 80;
				this.lessonStatus = "n,a";
			case "on" : this.isActive = true;
				timer.start();
		}
	}

	private function loadDatas(datas:String, isNote:Bool):Void
	{
		var listeDatas = new Array<String>();
		if(datas != "undefined"){
			if(datas.split("\r\n").length > 5)
				listeDatas = datas.split("\r\n");
			else if(datas.split("\r").length > 5)
				listeDatas = datas.split("\r");
			else if(datas.split("\n").length > 5)
				listeDatas = datas.split("\n");
			else
				listeDatas = null;

			if(listeDatas != null){
				for(z in 0...listeDatas.length){
					listeDatas[z] = listeDatas[z].split(" ").join("");

					switch (listeDatas[z].split("=")[0].toUpperCase()) {
						case "LESSON_LOCATION" :
							location = listeDatas[z].split("=")[1];
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

			}
			else{
				init(isNote, "off");
			}
		}
		else{
			init(isNote, "off");
		}
	}
}