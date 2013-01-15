package com.knowledgeplayers.grar.event;
import nme.events.Event;

/**
 * Token related event
 */

class TokenEvent extends Event
{
	/**
	 * Add token to the inventory
	 */
	public static var ADD (default, null): String = "Add";
	
	/**
	 * Add token to the global inventory
	 */
	public static var ADD_GLOBAL (default, default): String = "Add_global";
	
	/**
	 * ID of the token
	 */
	public var tokenId (default, default): String;
	
	/**
	 * Type of the token
	 */
	public var tokenType (default, default): String;
	
	/**
	 * Inventory targeted by the token
	 */
	public var tokenTarget (default, default): String;
	
	public function new(type : String, ?tokenId: String, ?tokenType: String, ?tokenTarget: String, bubbles : Bool = false, cancelable : Bool = false)
	{
		super(type, bubbles, cancelable);
		this.tokenId = tokenId;
		this.tokenTarget = tokenTarget;
		this.tokenType = tokenType;
	}
}