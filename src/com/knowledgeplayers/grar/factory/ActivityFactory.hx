package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.animagic.Animagic;
import com.knowledgeplayers.grar.structure.activity.quizz.Quizz;
import com.knowledgeplayers.grar.structure.score.ScoreChart;
import haxe.xml.Fast;
import nme.Lib;


/**
 * Factory for activities creation
 */
class ActivityFactory 
{
	private function new()
	{
		
	}

	/**
	 * Create an activity
	 * @param	activityName : Name of the activity, define the type of the creation
	 * @param	content : Path to a content file for the creation
	 * @return an newly created activity, or null if the given name doesn't correspond to a valid type
	 */
	public static function createActivity(activityName: String, ?content: String, ?perk: String) : Null<Activity>
	{
		var creation: Activity = null;
		switch (activityName.toLowerCase()) {
			case "quizz": creation = new Quizz(content);
			case "animagic":creation =new Animagic(content);
			default: Lib.trace("Factory - "+activityName+" :  Unsupported activity");
		}
		
		if(creation != null)
			ScoreChart.instance.subscribe(perk, creation);

		return creation;
	}

	/**
	 * Create an activity from XML infos
	 * @param	xml : fast xml node with structure infos
	 * @return an newly created activity, or null if the given name doesn't correspond to a valid type
	 */
	public static function createActivityFromXml(xml: Fast) : Null<Activity>
	{
		return createActivity(xml.att.Type, xml.att.Content, xml.att.Perk);
	}
}