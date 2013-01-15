package com.knowledgeplayers.grar.event;

import nme.events.Event;

/**
 * Part related event
 */
class PartEvent extends Event 
{
	/**
	 * Enter the part
	 */
	public static var ENTER_PART (default, null): String = "ENTER PART";
	
	/**
	 * Exit the part
	 */
	public static var EXIT_PART (default, null): String = "EXIT PART";
	
	/**
	 * The part is fully loaded
	 */
	public static var PART_LOADED (default, null): String = "PART LOADED";	

	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}