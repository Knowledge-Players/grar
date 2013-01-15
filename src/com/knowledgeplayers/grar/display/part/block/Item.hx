package com.knowledgeplayers.grar.display.part.block;

import haxe.xml.Fast;

class Item 
{
	public var content (default, default): String;
	public var tag (default, default): String;

	public function new(xml: Fast = null, content: String = "", tag: String = "")
	{
		if (xml != null) {
			this.content = xml.att.Content;
			this.tag = xml.att.Tag;
		}
		else{
			this.content = content;
			this.tag = tag;
		}
	}
	
	public function hasVertivalFlow() : Bool
	{
		return false;
	}
}
