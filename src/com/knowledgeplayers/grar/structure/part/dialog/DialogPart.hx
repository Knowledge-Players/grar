package com.knowledgeplayers.grar.structure.part.dialog;

import Std;
import com.knowledgeplayers.grar.event.TokenEvent;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.TextItem;
import haxe.xml.Fast;
import nme.Lib;

import com.knowledgeplayers.grar.structure.part.StructurePart;
import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.factory.PatternFactory;

class DialogPart extends StructurePart {

    public function new()
    {
        super();

    }

    override public function isDialog():Bool
    {
        return true;

    }

    override public function restart():Void
    {
        super.restart();
        if(elements[elemIndex].isPattern())
            cast(elements[elemIndex], Pattern).restart();
    }

    // Private

    override private function parseContent(content:Xml):Void
    {
        var partFast:Fast = new Fast(content).node.Part;

        for(patternNode in partFast.nodes.Pattern){

            var pattern:Pattern = PatternFactory.createPatternFromXml(patternNode);
            pattern.init(patternNode);
            elements.push(pattern);
        }
        super.parseContent(content);
    }

}