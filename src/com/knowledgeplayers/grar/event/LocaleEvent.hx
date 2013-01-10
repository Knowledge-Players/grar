package com.knowledgeplayers.grar.event;

import nme.events.Event;

class LocaleEvent extends Event 
{
	public static var LOCALE_LOADED (default, null): String = "LOCALE_LOADED";

	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
	}
}