package com.knowledgeplayers.grar.structure.part.dialog.pattern;

import com.knowledgeplayers.grar.factory.ItemFactory;
import haxe.xml.Fast;

/**
* Junction pattern with multiple choices for multiple direction
**/
class ChoicePattern extends Pattern {
	/**
    * Minimum choices that needs to be explored before leaving the pattern
    **/
	public var minimumChoice (default, default):Int;

	/**
    * All the choices for this pattern
    **/
	public var choices (default, default):Hash<Choice>;

	/**
    * Reference to the tooltip area
    **/
	public var tooltipRef (default, default):String;

	/**
    * Constructor
    * @param    name : Name of the pattern
    **/

	public function new(name:String)
	{
		super(name);
		choices = new Hash<Choice>();
	}

	override public function init(xml:Fast):Void
	{
		super.init(xml);
		tooltipRef = xml.has.toolTip ? xml.att.toolTip != "" ? xml.att.toolTip : null : null;

		for(choiceNode in xml.nodes.Choice){
			var tooltip = choiceNode.has.toolTip ? choiceNode.att.toolTip != "" ? choiceNode.att.toolTip : null : null ;
			var choice = {ref: choiceNode.att.ref, content: choiceNode.att.content, toolTip: tooltip, goTo: choiceNode.att.goTo, viewed:false};
			choices.set(choiceNode.att.ref, choice);
		}
	}

	override public function getNextItem():Null<TextItem>
	{
		return patternContent[0];
	}

	/**
    * @return true
    **/

	override public function hasChoices():Bool
	{
		return true;
	}

}

typedef Choice = {
	var ref:String;
	var content:String;
	var toolTip:String;
	var goTo:String;
	var viewed:Bool;
}
