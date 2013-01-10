package com.knowledgeplayers.grar.display.style;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.text.Font;
import nme.Assets;

class Style extends Hash<String>
{
	public var name: String;
	public var icon: BitmapData;
	public var iconPosition: String;
	public var background: Bitmap;

	public function addRule(name: String, value: String) : Void
	{
		set(name, value);
	}

	public function getFont() : Null<Font>
	{
		return Assets.getFont(get("font"));
	}

	public function getSize() : Null<Int>
	{
		return Std.parseInt(get("size"));
	}

	public function getColor() : Null<Int> 
	{
		return Std.parseInt(get("color"));
	}

	public function getBold() : Null<Bool> 
	{
		return get("bold") == "true";
	}

	public function getItalic() : Null<Bool>
	{
		return get("italic") == "true";
	}

	public function getUnderline() : Null<Bool>
	{
		return get("underline") == "true";
	}
}