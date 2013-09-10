package com.knowledgeplayers.grar.event;
import nme.events.Event;

/**
 * Event for the buttons
 * @author jbrichardet
 */

class ButtonActionEvent extends Event {
	/**
     * Move to the next item
     */
	public static var NEXT (default, null):String = "next";

	/**
     * Move to a specific pattern
     */
	public static var GOTO (default, null):String = "goto";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}