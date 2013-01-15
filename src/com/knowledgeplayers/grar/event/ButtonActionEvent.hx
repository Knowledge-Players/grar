package com.knowledgeplayers.grar.event;
import nme.events.Event;

/**
 * Event for the buttons
 * @author jbrichardet
 */

class ButtonActionEvent extends Event
{
	/**
	 * Move to the next item
	 */
	public static var NEXT (default, null): String = "next";
	
	/**
	 * Start a vertical flow
	 */
	public static var VERTICAL_FLOW (default, null): String = "vertical_flow";

	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}