package com.knowledgeplayers.grar.tracking;

import nme.events.IEventDispatcher;

interface ITracking extends IEventDispatcher {
	public function activation(activation:String):Void;
	public function init (isNote:Bool = false, activation:String = "on"):Void;
	public function getLocation():String;
	public function setLocation(location:String):Void;
	public function getStatus():String;
	public function setStatus(status:Bool):Void;
	public function getScore():Int;
	public function setScore(score:Int):Void;
	public function putparam ():Void;
	public function exitAU ():Void;
	public function getMasteryScore ():Int;
	public function getSuspend():String;
	public function setSuspend (suspention:String):Void;
	public function clearDatas():Void;
}