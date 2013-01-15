package com.knowledgeplayers.grar.structure.part.dialog.item;

import haxe.xml.Fast;
import nme.Lib;

class Item 
{
	/**
	 * Text of the item
	 */
	public var content (default, default): String;
	
	/**
	 * Character who says this text
	 */
	public var author (default, default): String;
	
	/**
	 * Position of the author
	 */
	public var direction (default, default): String;

	/**
	 * Constructor
	 * @param	xml : fast xml node with structure info
	 * @param	content : text of the item
	 */
	public function new(?xml: Fast, content: String = "")
	{
		if (xml != null) {
			this.content = xml.att.Content;
			if(xml.has.Author){
				author = xml.att.Author;
				direction = xml.att.Direction;
			}
		}
		else{
			this.content = content;
		}
	}
	
	/**
	 * @return true if the item starts a vertical flow
	 */
	public function hasVerticalFlow() : Bool
	{
		return false;
	}
	
	/**
	 * @return true if the item starts an activity
	 */
	public function hasActivity() : Bool
	{
		return false;
	}
}