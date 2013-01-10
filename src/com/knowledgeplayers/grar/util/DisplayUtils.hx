package com.knowledgeplayers.grar.util;

/**
 * ...
 * @author jbrichardet
 */

class DisplayUtils 
{
	private function new() {}
	
	public static function getPressedId(buttonId: String) : String
	{
		var strings: Array<String> = buttonId.split(".");
		return strings[0]+"_pressed."+strings[1];
	}
}