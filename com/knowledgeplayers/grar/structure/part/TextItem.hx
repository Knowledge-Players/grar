package com.knowledgeplayers.grar.structure.part;

import haxe.ds.GenericStack;
import haxe.xml.Fast;

class TextItem extends Item {

	/**
     * Character who says this text
     */
	public var author (default, default):String;

	/**
     * Transition between this item and the one before
     */
	public var transition (default, default):String;

	/**
    * Graphicals items associated with this item
    **/
	public var images (default, default):GenericStack<String>;

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
		super(xml, content);
		images = new GenericStack<String>();
		if(xml != null){
			if(xml.has.author)
				author = xml.att.author;
			if(xml.has.transition)
				transition = xml.att.transition;
			if(xml.hasNode.Sound)
				sound = xml.node.Sound.att.src;
			if(xml.hasNode.Intro)
				introScreen = {ref: xml.node.Intro.att.ref, content: xml.node.Intro.att.content};

			for(elem in xml.elements){
				if(elem.name.toLowerCase() == "image" || elem.name.toLowerCase() == "character")
					images.add(elem.att.ref);
			}
		}
	}

	override public function isText():Bool
	{
		return true;
	}
}