package com.knowledgeplayers.grar.tracking;

import nme.events.Event;
import nme.events.EventDispatcher;

class Tracking implements ITracking {

	public var studentId:String;
	public var studentName:String;
	public var lessonStatus:String;

	public var score:String;
	public var masteryScore:Int;
	public var suivi:String;

	private var event:EventDispatcher;

	private function new()
	{
		event = new EventDispatcher();
	}

	public function toString():String
	{
		return event.toString();
	}

	public function willTrigger(type:String):Bool
	{
		return event.willTrigger(type);
	}

	public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void
	{
		event.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function dispatchEvent(event:Event):Bool
	{
		return this.event.dispatchEvent(event);
	}

	public function hasEventListener(type:String):Bool
	{
		return event.hasEventListener(type);
	}

	public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false):Void
	{
		event.removeEventListener(type, listener, useCapture);
	}

	public function getScore():Int
	{
		if(score == "")
			return 0;
		else
			return Std.parseInt(score);
	}

	public function activation(activation:String):Void
	{}

	public function init(isNote:Bool = false, activation:String = "on"):Void
	{}

	public function getLocation():String
	{return "";}

	public function setLocation(location:String):Void
	{}

	public function getStatus():String
	{return "";}

	public function setStatus(status:Bool):Void
	{}

	public function setScore(score:Int):Void
	{}

	public function putparam():Void
	{}

	public function exitAU():Void
	{}

	public function getMasteryScore():Int
	{return 0;}

	public function getSuspend():String
	{return "";}

	public function setSuspend(suspention:String):Void
	{}

	public function clearDatas():Void
	{}
}