package com.knowledgeplayers.grar.tracking;

import nme.errors.Error;
import nme.events.Event;
import nme.Lib;
import nme.net.SharedObject;
import nme.net.SharedObjectFlushStatus;

class AutoTracking extends Tracking
{
	public var lesson_location:String;
	public var isNote:Bool;
	public var isActive:Bool;
	
	private var mySo:SharedObject;
	
	
	public function new()
	{
		super();
		this.lessonStatus = "";
		this.score = "0";
		this.masteryScore = 0;
		this.lesson_location = "";
		this.isNote = false;
	}
	
	override function activation(activation:String) : Void
	{
		
		switch (activation) {
			case "off" :this.isActive = false;
						this.studentId = "42";
						studentName = "wayne";
						this.lesson_location =suivi;
						this.score = "0";
						this.masteryScore = 80;
						this.lessonStatus = "n,a";
			case "on" :	this.isActive = true;
		}
		
	}
	override function init (isNote:Bool = false, activation:String = "on") : Void
	{
		this.activation(activation);

		if (isActive) {
			mySo = SharedObject.getLocal("saveFile");
			load();
			dispatchEvent(new Event(Event.INIT));
		}
		else
		{
			dispatchEvent(new Event(Event.INIT));
		}
	}
	
	override function getLocation():String
	{
		return lesson_location;
	}

	override function setLocation(location:String):Void {
		lesson_location = location;
		
		if (isActive) {
			mySo.data.lesson_location =lesson_location;
		}
	}
	
	override function getStatus() : String
	{
		return lessonStatus;
	}
	
	override function setStatus(status:Bool) : Void
	{
		var _local2:String = "";
		if (this.isNote) {
			if (status) {
				_local2 = "passed";
			} else if (this.getStatus() != "passed") {
				_local2 = "failed";
			} else {
				_local2 = "failed";
			}
		} else {
			if (status) {
				_local2 = "completed";
			} else if (this.getStatus() != "completed") {
				_local2 = "incomplete";
			} else {
				_local2 = "incomplete";
			}
		}
		lessonStatus = _local2;
		mySo.data.lessonStatus = lessonStatus;
	}
	
	override function setScore(score: Int) : Void {

		if ((Std.string(this.getScore()) == "") || (this.getScore()<=score)) {
			this.score = Std.string(score);
			if (this.isActive)
			{
				mySo.data.score = this.score;
			}
			if (this.getScore()>=this.getMasteryScore()) {
				setStatus(true);
			} else {
				setStatus(false);
			}
		}
	}
	
	override function putparam() : Void
	{
		if (isActive) {
			save();
		}
	}
	
	
	
	override function exitAU() : Void
	{
		
	}
	
	public function save() : Void
	{
		mySo.data.lessonStatus = getStatus();
		mySo.data.score = getScore();
		mySo.data.studentName="student";
		mySo.data.studentId = "1";
		mySo.data.lesson_location = getLocation();

		#if flash
		var flushStatus:String = null;
		#else
		var flushStatus:SharedObjectFlushStatus = null;
		#end

		try {
				#if js
				flushStatus = mySo.flush();
				#else
				flushStatus = mySo.flush(10000);
				#end
		} catch (error:Error) {
			Lib.trace("Error...Could not write SharedObject to disk\n");
		}
	}
	
	public function load() : Void
	{
		lessonStatus =  mySo.data.lessonStatus;
		score = mySo.data.score;
		studentName = mySo.data.studentName;
		studentId = mySo.data.studentId;
		lesson_location = mySo.data.lesson_location;
	}
	
	override function getMasteryScore() : Int
	{
		return masteryScore;
	}
	
	override function setSuspend(suspention: String) : Void
	{
		throw new Error("setSuspend AUTO");
	}
	
	override function getSuspend() : String
	{		
		throw new Error("getSuspend AUTO");
		return null;
	}
	
	override function clearDatas() : Void
	{
		mySo.clear();
	}
	
	private function onFlushStatus(event: Event) : Void
	{
		//mySo.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
	}
}