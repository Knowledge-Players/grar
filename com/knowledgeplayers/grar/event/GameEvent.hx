package com.knowledgeplayers.grar.event;

import nme.events.Event;

/**
 * Events of the game
 */
class GameEvent extends Event {
	/**
	 * The game is over
	 */
	public static var GAME_OVER (default, null):String = "GAME_OVER";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}