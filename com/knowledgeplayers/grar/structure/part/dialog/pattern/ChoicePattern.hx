package com.knowledgeplayers.grar.structure.part.dialog.pattern;

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
    * Number of choices currently explored
    **/
	public var numChoices (default, default):Int;

	/**
    * All the choices for this pattern
    **/
	public var choices (default, default):Map<String, Choice>;

	/**
    * Reference to the tooltip area
    **/
	public var tooltipRef (default, default):String;

	/**
    * Reference to the tooltip transition
    **/
	public var tooltipTransition (default, default):String;

	/**
    * Constructor
    * @param    name : Name of the pattern
    **/

	public function new(name:String)
	{
		super(name);
		choices = new Map<String, Choice>();
		numChoices = 0;
	}

    public function reInit():Void{

        for (choice in choices){

           choice.viewed = false;
        }

    }
	override public function init(xml:Fast):Void
	{
		super.init(xml);
		if(xml.has.toolTip && xml.att.toolTip != "")
			tooltipRef = xml.att.toolTip;
		if(xml.has.toolTipTransition && xml.att.toolTipTransition != "")
			tooltipTransition = xml.att.toolTipTransition;
		minimumChoice = xml.has.minChoice ? Std.parseInt(xml.att.minChoice) : -1;

		for(choiceNode in xml.nodes.Choice){
			var tooltip = null;
			if(choiceNode.has.toolTip && choiceNode.att.toolTip != "")
				tooltip = choiceNode.att.toolTip;
			var choice = {ref: choiceNode.att.ref, toolTip: tooltip, goTo: choiceNode.att.goTo, viewed:false};
			choices.set(choiceNode.att.ref, choice);
		}
	}

	override public function getNextItem():Null<Item>
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
	var toolTip:String;
	var goTo:String;
	var viewed:Bool;
}
