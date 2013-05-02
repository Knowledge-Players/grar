package com.knowledgeplayers.grar.structure.part;

import haxe.FastList;
import haxe.xml.Fast;

class TextItem implements PartElement {
	/**
     * Text of the item
     */
	public var content (default, default):String;

	/**
     * Character who says this text
     */
	public var author (default, default):String;

	/**
     * Transition between this item and the one before
     */
	public var transition (default, default):String;

	/**
    * Background when the item is displayed
    **/
	public var background (default, default):String;

	/**
    * ID of the button that will appear with this item
    **/
	public var button (default, default):{ref:String, content:Hash<String>};

	/**
    * Unique ref that will match the display
    **/
	public var ref (default, default):String;

	/**
    * Graphicals items associated with this item
    **/
	public var items (default, default):FastList<String>;

	/**
    * Reference to the token in this item
    **/
	public var token(default, null):String;

	/**
    * Sound to play during this item
    **/
	public var sound (default, default):String;

	/**
	* Introduction screen to show before this item
	**/
	public var introScreen (default, default):{ref:String, content:String};

	/**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	content : text of the item
     */

	public function new(?xml:Fast, content:String = "")
	{
		items = new FastList<String>();
		if(xml != null){
			if(xml.has.content)
				this.content = xml.att.content;
			if(xml.has.author)
				author = xml.att.author;
			if(xml.has.transition)
				transition = xml.att.transition;
			if(xml.has.ref)
				ref = xml.att.ref;
			if(xml.has.background)
				background = xml.att.background;
			if(xml.hasNode.Token)
				token = xml.node.Token.att.ref;
			if(xml.hasNode.Button){
				var content = new Hash<String>();
				if(xml.node.Button.has.content){
					if(xml.node.Button.att.content.indexOf("{") == 0){
						var contentString:String = xml.node.Button.att.content.substr(1, xml.node.Button.att.content.length - 2);
						var contents = contentString.split(",");
						for(c in contents)
							content.set(c.split(":")[0], c.split(":")[1]);
					}
					else
						content.set(xml.node.Button.att.content, xml.node.Button.att.content);
				}
				button = {ref: xml.node.Button.att.ref, content: content};
			}
			if(xml.hasNode.Sound)
				sound = xml.node.Sound.att.src;
			if(xml.hasNode.Intro)
				introScreen = {ref: xml.node.Intro.att.ref, content: xml.node.Intro.att.content};

			for(item in xml.nodes.Item){
				items.add(item.att.ref);
			}
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
		return true;
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

}