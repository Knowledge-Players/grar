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
	public static inline var NEXT:String = "next";

	/**
     * Move to a specific pattern
     */
	public static inline var GOTO:String = "goto";

	/**
	* Toggle the state
	**/
	public static inline var TOGGLE: String = "toggle";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}