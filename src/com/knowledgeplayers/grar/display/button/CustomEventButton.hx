package com.knowledgeplayers.grar.display.button;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import nme.display.DisplayObject;
import nme.events.MouseEvent;

/**
 * ...
 * @author jbrichardet
 */

class CustomEventButton extends DefaultButton
{
	public var eventType (default, default): String;
	public var propagateNativeEvent (default, default): Bool = false;

	public function new(eventName: String, layerPath: String, tile: String) 
	{
		super(layerPath, tile);
		this.eventType = eventName;
	}
	
	override private function onClick(event: MouseEvent)
	{
		if(!propagateNativeEvent)
			event.stopImmediatePropagation();
		dispatchEvent(new ButtonActionEvent(eventType));
	}
	
}