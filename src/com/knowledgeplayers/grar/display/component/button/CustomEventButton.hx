package com.knowledgeplayers.grar.display.component.button;
import nme.Lib;
import aze.display.TilesheetEx;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import nme.events.MouseEvent;

/**
 * Button with a customizable event
 * @author jbrichardet
 */

class CustomEventButton extends DefaultButton {
    /**
     * Type of the event to dispatch
     */
    public var eventType (default, default):String;

    /**
     * Control whether or not the native event (CLICK) must be propagated
     */
    public var propagateNativeEvent (default, default):Bool = false;

    /**
     * Constructor
     * @param	eventName : Name of the customed event to dispatch
     * @param	tilesheet : UI sheet
     * @param	tile : Tile containing the button
     */

    public function new(tilesheet:TilesheetEx, tile:String, eventName:String)
    {
        super(tilesheet, tile);
        this.eventType = eventName.toLowerCase();

    }

    override private function onClick(event:MouseEvent):Void
    {
        if(!propagateNativeEvent)
            event.stopImmediatePropagation();

        var e = new ButtonActionEvent(eventType);
        dispatchEvent(e);
    }

}