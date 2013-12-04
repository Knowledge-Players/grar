package com.knowledgeplayers.grar.structure.part;

import com.knowledgeplayers.grar.util.ParseUtils;
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
    * Sound to play during this item
    **/
	public var sound (default, default):String;

	/**
	* Introduction screen to show before this item
	**/
	public var introScreen (default, default):{ref:String, content:Map<String, String>};

	/**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	content : text of the item
     */

	public function new(?xml:Fast, content:String = "")
	{
		super(xml, content);
		if(xml != null){
			if(xml.has.author)
				author = xml.att.author;
			if(xml.has.transition)
				transition = xml.att.transition;
			if(xml.hasNode.Sound)
				sound = xml.node.Sound.att.src;
			if(xml.hasNode.Intro)
				introScreen = {ref: xml.node.Intro.att.ref, content: ParseUtils.parseHash(xml.node.Intro.att.content)};
		}

		// Reverse pile order to match XML order
		var tmpStack = new GenericStack<String>();
		for(img in images)
			tmpStack.add(img);
		images = tmpStack;
	}

	override public function isText():Bool
	{
		return true;
	}
}