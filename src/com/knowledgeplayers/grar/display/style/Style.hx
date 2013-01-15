package com.knowledgeplayers.grar.display.style;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.text.Font;
import nme.Assets;

/**
 * Style of a text
 */
class Style extends Hash<String>
{
	/**
	 * Name of the style
	 */
	public var name: String;
	
	/**
	 * Icon in the style
	 */
	public var icon: BitmapData;
	
	/**
	 * Position of the icon
	 */
	public var iconPosition: String;
	
	/**
	 * Background propertie
	 */
	public var background: Bitmap;

	/**
	 * Add a rule to the style
	 * @param	name : Name of the rule
	 * @param	value : Value of the rule;
	 */
	public function addRule(name: String, value: String) : Void
	{
		set(name, value);
	}

	/**
	 * @return the font of the style
	 */
	public function getFont() : Null<Font>
	{
		return Assets.getFont(get("font"));
	}

	/**
	 * @return the size of the style
	 */
	public function getSize() : Null<Int>
	{
		return Std.parseInt(get("size"));
	}

	/**
	 * @return the color of the style
	 */
	public function getColor() : Null<Int> 
	{
		return Std.parseInt(get("color"));
	}

	/**
	 * @return whether or not the style is bold
	 */
	public function getBold() : Null<Bool> 
	{
		return get("bold") == "true";
	}

	/**
	 * @return whether or not the style is italic
	 */
	public function getItalic() : Null<Bool>
	{
		return get("italic") == "true";
	}

	/**
	 * @return whether or not the style is underline
	 */
	public function getUnderline() : Null<Bool>
	{
		return get("underline") == "true";
	}
}