package com.knowledgeplayers.grar.structure.part.dialog.pattern;

import com.knowledgeplayers.grar.factory.ItemFactory;
import haxe.xml.Fast;

/**
* Junction pattern with multiple choices for multiple direction
**/
class ChoicePattern extends Pattern
{
    /**
    * Minimum choices that needs to be explored before leaving the pattern
    **/
    public var minimumChoice (default, default): Int;

    /**
    * All the choices for this pattern
    **/
    public var choices (default, default): Hash<Choice>;

    /**
    * Reference to the tooltip area
    **/
    public var tooltipRef (default, default):String;

    /**
    * Constructor
    * @param    name : Name of the pattern
    **/
    public function new(name: String)
    {
        super(name);
        choices = new Hash<Choice>();
    }

    override public function init(xml: Fast): Void
    {
        super.init(xml);
        tooltipRef = xml.att.toolTip;

        for(choiceNode in xml.nodes.Choice){
            var choice = {ref: choiceNode.att.ref, content: choiceNode.att.content, toolTip: choiceNode.att.toolTip, goTo: choiceNode.att.goTo};
            choices.set(choiceNode.att.ref, choice);
        }
    }

    override public function getNextItem(): Null<TextItem>
    {
        return patternContent[0];
    }

    /**
    * @return true
    **/
    override public function hasChoices(): Bool
    {
        return true;
    }

}

typedef Choice = {
    var ref: String;
    var content: String;
    var toolTip: String;
    var goTo: String;
}
