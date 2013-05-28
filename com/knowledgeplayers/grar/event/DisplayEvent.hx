package com.knowledgeplayers.grar.event;

import nme.events.Event;

/**
* Event dispatch by display
**/
class DisplayEvent extends Event {

	/**
     * Display loaded
     */
	public static var LOADED (default, null):String = "loaded";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}
