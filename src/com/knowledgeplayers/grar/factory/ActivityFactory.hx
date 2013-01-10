package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.xml.Fast;
import nme.display.BitmapData;
import nme.Lib;

import com.knowledgeplayers.grar.structure.activity.quizz.Quizz;

class ActivityFactory 
{
	private function new()
	{
		
	}

	public static function createActivity(activityName: String, ?content:String) : Null<Activity>
	{
		var creation: Activity = null;
		switch (activityName.toLowerCase()) {
			case "quizz": creation = new Quizz(content);
			default: Lib.trace(activityName+" : Unsupported activity");
		}

		return creation;
	}

	public static function createActivityFromXml(xml: Fast) : Null<Activity>
	{
		return createActivity(xml.att.Type, xml.att.Content);
	}
}