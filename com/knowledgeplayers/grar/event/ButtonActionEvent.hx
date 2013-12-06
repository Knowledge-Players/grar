package com.knowledgeplayers.grar.event;

import flash.events.Event;

/**
 * Event for the buttons
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

	/**
	* Over
	**/
	public static inline var OVER: String = "over";

	/**
	* Exit the current part
	**/
	public static var EXIT: String = "exit";

    /**
	* Quit Application
	**/
	public static inline var QUIT: String = "quit";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}