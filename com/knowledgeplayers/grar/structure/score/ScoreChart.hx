package com.knowledgeplayers.grar.structure.score;

import com.knowledgeplayers.grar.tracking.Trackable;

/**
 * Concatenates all the score from the activities and organizes it per skills
 */

class ScoreChart {
	/**
	 * Instance
	 */
	public static var instance (get_instance, null):ScoreChart;

	/**
	 * Hash of all the perks in the game
	 */
	public var perks (default, null):Map<String, Perk>;

	/**
	 * @return the instance
	 */

	public static function get_instance():ScoreChart
	{
		if(instance == null)
			instance = new ScoreChart();
		return instance;
	}

	/**
	 * Link an activity to a perk
	 * @param	perkName : Name of the perk
	 * @param	activity : Activity to link
	 */

	public function subscribe(perkName:String, activity:Trackable)
	{
		var perk:Perk;
		if(!perks.exists(perkName)){
			perk = new Perk(perkName);
			perks.set(perkName, perk);
		}
		else
			perk = perks.get(perkName);

		perk.susbscribe(activity);
	}

	public function addScoreToPerk(perk:String, score:Int):Void
	{
		if(!perks.exists(perk))
			perks.set(perk, new Perk(perk));
		//else
			perks.get(perk).addToScore(score);
	}

	/**
	 * @return a string-based representation of the object
	 */

	public function toString():String
	{
		return perks.toString();
	}

	// Private

	private function new()
	{
		perks = new Map<String, Perk>();
	}

}