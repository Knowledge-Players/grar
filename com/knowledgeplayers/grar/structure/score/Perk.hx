package com.knowledgeplayers.grar.structure.score;

import com.knowledgeplayers.grar.tracking.Trackable;
import haxe.ds.GenericStack;

/**
 * Pedagogic skill representation
 */

class Perk {
	/**
     * Name of the perk
     */
	public var name (default, default):String;

	/**
     * Activities who subscribes to this perk
     */
	public var subscribed (default, null):GenericStack<Trackable>;

	private var score: Int = 0;

		/**
     * Constructor
     * @param	name : Name of the perk
     */
	public function new(name:String)
	{
		this.name = name;
		subscribed = new GenericStack<Trackable>();
	}

	/**
     * Subscribe an activity to this perk. The score of this activity will be
     * added to the perk score
     * @param	activity
     */

	public function susbscribe(activity:Trackable):Void
	{
		subscribed.add(activity);
	}

	/**
     * @return the total score for this perk
     */

	public function getScore():Int
	{
		var tmpScore = score;
		for(activity in subscribed){
			tmpScore += activity.score;
		}

		return tmpScore;
	}

	public function addToScore(delta:Int):Void
	{
		score += delta;
	}

	/**
     * @return a string-based representation of the object
     */

	public function toString():String
	{
		return name + ": " + getScore();
	}

}