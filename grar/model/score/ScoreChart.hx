package grar.model.score;

import grar.model.part.Part;
import haxe.ds.StringMap;

/**
 * Concatenates all the score from the activities and organizes it per skills
 */
class ScoreChart {

	public function new() {

		this.perks = new StringMap();
	}

	/**
	 * Hash of all the perks in the game
	 */
	public var perks (default, null) : StringMap<Perk>;

	/**
	 * Link an activity to a perk
	 * @param	perkName : Name of the perk
	 * @param	activity : Activity to link
	 */
	public function subscribe(perkName : String, activity : Part) {

		var perk : Perk;

		if (!perks.exists(perkName)) {

			perk = new Perk(perkName);
			perks.set(perkName, perk);

		} else {

			perk = perks.get(perkName);
		}
		perk.susbscribe(activity);
	}

	public function addScoreToPerk(perk : String, score : Int) : Void {

		if (!perks.exists(perk)) {

			perks.set(perk, new Perk(perk));
		}
		perks.get(perk).addToScore(score);
	}

	/**
	 * @return a string-based representation of the object
	 */
	public function toString() : String {

		return perks.toString();
	}
}