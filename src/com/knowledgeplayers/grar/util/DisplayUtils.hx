package com.knowledgeplayers.grar.util;

/**
 * ...
 * @author jbrichardet
 */

/**
 * Utility class for display
 */
class DisplayUtils 
{
	private function new() {}
	
	/**
	 * Get the pressed ID of a button
	 * @param	buttonId : ID of the button
	 * @return the pressed ID for this button
	 */
	public static function getPressedId(buttonId: String) : String
	{
		var strings: Array<String> = buttonId.split(".");
		return strings[0]+"_pressed."+strings[1];
	}
}