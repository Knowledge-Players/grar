package com.knowledgeplayers.grar.event;

import nme.events.Event;

class PartEvent extends Event 
{
	public static var ENTER_PART (default, null): String = "ENTER PART";
	public static var EXIT_PART (default, null): String = "EXIT PART";
	public static var PART_LOADED (default, null): String = "PART LOADED";	

	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}