package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.util.ParseUtils;
import haxe.xml.Fast;

class Item implements PartElement {

	/**
     * Content of the item
     */
	public var content (default, default):String;

	/**
    * Background when the item is displayed
    **/
	public var background (default, default):String;

	/**
    * ID of the button that will appear with this item
    **/
	public var button (default, default): Map<String, Map<String, String>>;

	/**
    * Unique ref that will match the display
    **/
	public var ref (default, default):String;

	/**
    * Reference to the token in this item
    **/
	public var token(default, null):String;

	public var endScreen (default, null):Bool = false;

	/**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	content : text of the item
     */
	private function new(?xml:Fast, content:String = "")
	{
		if(xml != null){
			if(xml.has.content)
				this.content = xml.att.content;
			if(xml.has.ref)
				ref = xml.att.ref;
			if(xml.has.background)
				background = xml.att.background;
			if(xml.hasNode.Token)
				token = xml.node.Token.att.ref;
			if(xml.hasNode.Button){
				button = new Map<String, Map<String, String>>();
				button.set(xml.node.Button.att.ref, ParseUtils.parseButtonContent(xml.node.Button));
			}
			if(xml.has.endScreen)
				endScreen = xml.att.endScreen == "true";
		}
		else{
			this.content = content;
		}

	}

	/**
     * @return true if the item starts a vertical flow
     */

	public function hasVerticalFlow():Bool
	{
		return false;
	}

	/**
     * @return true if the item starts an activity
     */

	public function hasActivity():Bool
	{
		return false;
	}

	/**
    * @return true
    **/

	public function isText():Bool
	{
		return false;
	}

	/**
    * @return false
    **/

	public function isActivity():Bool
	{
		return false;
	}

	/**
    * @return false
    **/

	public function isPattern():Bool
	{
		return false;
	}

	/**
    * @return false
    **/

	public function isPart():Bool
	{
		return false;
	}

	/**
    * @return false
    **/

	public function isVideo():Bool
	{
		return false;
	}
}
