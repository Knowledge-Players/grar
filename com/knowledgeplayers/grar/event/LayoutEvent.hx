package com.knowledgeplayers.grar.event;
import com.knowledgeplayers.grar.display.layout.Zone;
import flash.events.Event;

/**
 * Event for the layouts
 */
class LayoutEvent extends Event {

	/**
     * Move to the next item
     */
	public static var NEW_ZONE (default, null):String = "NEW_ZONE";

	/**
    * Reference of the zone which dispatched the event
    **/
	public var ref (default, default):String;

	/**
    * Zone which dispatched the event
    **/
	public var zone (default, default):Zone;

	public function new(type:String, _ref:String, _zone:Zone, bubbles:Bool = false, cancelable:Bool = false)
	{
		ref = _ref;
		zone = _zone;
		super(type, bubbles, cancelable);
	}

	override public function clone():Event
	{
		return new LayoutEvent(type, ref, zone, bubbles, cancelable);
	}
}