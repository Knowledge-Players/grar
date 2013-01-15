package com.knowledgeplayers.grar.event;

import nme.events.Event;

/**
 * Localisation related event
 */
class LocaleEvent extends Event 
{
	/**
	 * The locale is fully loaded
	 */
	public static var LOCALE_LOADED (default, null): String = "LOCALE_LOADED";

	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}