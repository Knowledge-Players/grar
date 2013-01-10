package com.knowledgeplayers.grar.structure.part.dialog.item;

import haxe.xml.Fast;
import nme.Lib;

class Item 
{
	public var content (default, default): String;
	public var tag (default, default): String;
	public var author (default, default): String;
	public var direction (default, default): String;

	public function new(?xml: Fast, content: String = "", tag: String = "")
	{
		if (xml != null) {
			this.content = xml.att.Content;
			this.tag = xml.att.Tag;
			if(xml.has.Author){
				author = xml.att.Author;
				direction = xml.att.Direction;
			}
		}
		else{
			this.content = content;
			this.tag = tag;
		}
	}
	
	public function hasVerticalFlow() : Bool
	{
		return false;
	}
	
	public function hasActivity() : Bool
	{
		return false;
	}
}