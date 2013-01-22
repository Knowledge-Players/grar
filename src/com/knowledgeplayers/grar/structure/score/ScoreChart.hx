package com.knowledgeplayers.grar.structure.score;
import com.knowledgeplayers.grar.structure.activity.Activity;

/**
 * Concatenates all the score from the activities and organizes it per skills
 */

class ScoreChart 
{
	/**
	 * Instance
	 */
	public static var instance (getInstance, null): ScoreChart;
	
	/**
	 * Hash of all the perks in the game
	 */
	public var perks (default, null): Hash<Perk>;
	
	/**
	 * @return the instance
	 */
	public static function getInstance() : ScoreChart 
	{
		if (instance == null)
			instance = new ScoreChart();
		return instance;
	}
	
	/**
	 * Link an activity to a perk
	 * @param	perkName : Name of the perk
	 * @param	activity : Activity to link
	 */
	public function subscribe(perkName: String, activity: Activity)
	{
		var perk: Perk;
		if (!perks.exists(perkName)) {
			perk = new Perk(perkName);
			perks.set(perkName, perk);
		}
		else
			perk = perks.get(perkName);
			
		perk.susbscribeActivity(activity);		
	}
	
	/**
	 * @return a string-based representation of the object
	 */
	public function toString() : String 
	{
		return perks.toString();
	}
	
	// Private 
	
	private function new() 
	{
		perks = new Hash<Perk>();
	}
	
}