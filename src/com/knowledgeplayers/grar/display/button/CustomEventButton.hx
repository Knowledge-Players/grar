package com.knowledgeplayers.grar.display.button;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import nme.events.MouseEvent;

/**
 * ...
 * @author jbrichardet
 */

class CustomEventButton extends DefaultButton
{
	public var eventType (default, default): String;
	public var propagateNativeEvent (default, default): Bool = false;

	public function new(eventName: String, tilesheet: TilesheetEx, tile: String) 
	{
		super(tilesheet, tile);
		this.eventType = eventName;
	}
	
	override private function onClick(event: MouseEvent)
	{
		if(!propagateNativeEvent)
			event.stopImmediatePropagation();
		dispatchEvent(new ButtonActionEvent(eventType));
	}
	
}