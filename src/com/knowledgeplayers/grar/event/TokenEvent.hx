package com.knowledgeplayers.grar.event;
import nme.events.Event;

/**
 * ...
 * @author jbrichardet
 */

class TokenEvent extends Event
{
	public static var ADD (default, null): String = "Add";
	public static var ADD_GLOBAL (default, default): String = "Add_global";
	
	public var tokenId (default, default): String;
	public var tokenType (default, default): String;
	public var tokenTarget (default, default): String;
	
	public function new(type : String, ?tokenId: String, ?tokenType: String, ?tokenTarget: String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
		this.tokenId = tokenId;
		this.tokenTarget = tokenTarget;
		this.tokenType = tokenType;
	}
}