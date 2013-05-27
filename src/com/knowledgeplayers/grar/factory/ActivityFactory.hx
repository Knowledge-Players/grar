package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.structure.activity.cards.Cards;
import com.knowledgeplayers.grar.structure.activity.folder.Folder;
import com.knowledgeplayers.grar.structure.activity.quiz.Quiz;
import com.knowledgeplayers.grar.structure.activity.scanner.Scanner;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.score.ScoreChart;
import haxe.xml.Fast;

/**
 * Factory for activities creation
 */
class ActivityFactory {

	private function new()
	{

	}

	/**
     * Create an activity
     * @param	activityName : Name of the activity, define the type of the creation
     * @param	content : Path to a content file for the creation
     * @return an newly created activity, or null if the given name doesn't correspond to a valid type
     */

	public static function createActivity(activityType:String, id:String, name:String, ?content:String, ?tokenRef:String, ?tresholds:Array<{score:String, next:String}>, ?perk:String, ?container:Part):Null<Activity>
	{
		var creation:Activity = null;
		switch (activityType.toLowerCase()) {
			case "quiz": creation = new Quiz(content);
			case "scanner": creation = new Scanner(content);
			case "folder": creation = new Folder(content);
			case "cards": creation = new Cards(content);
				throw "Factory - " + activityType + " :  Unsupported activity";
		}

		ScoreChart.instance.subscribe(perk, creation);
		if(tresholds != null){
			for(treshold in tresholds)
				creation.addTreshold(treshold.score, treshold.next);
		}
		creation.name = name;
		creation.id = id;
		creation.token = tokenRef;
		if(container != null)
			creation.container = container;

		return creation;
	}

	/**
     * Create an activity from XML infos
     * @param	xml : fast xml node with structure infos
     * @return an newly created activity, or null if the given name doesn't correspond to a valid type
     */

	public static function createActivityFromXml(xml:Fast, ?container:Part):Null<Activity>
	{
		var tresholds = new Array<{score:String, next:String}>();
		for(treshold in xml.nodes.Threshold)
			tresholds.push({score: treshold.att.minValue, next: treshold.att.goTo});
		return createActivity(xml.att.type, xml.att.id, xml.att.name, xml.att.content, xml.hasNode.Token ? xml.node.Token.att.ref : null, tresholds, xml.att.perk, container);
	}
}