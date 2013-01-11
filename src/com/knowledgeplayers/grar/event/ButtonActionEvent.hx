package com.knowledgeplayers.grar.event;
import nme.events.Event;

/**
 * ...
 * @author jbrichardet
 */

class ButtonActionEvent extends Event
{
	public static var NEXT (default, null): String = "next";
	public static var VERTICAL_FLOW (default, null): String = "vertical_flow";

	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}