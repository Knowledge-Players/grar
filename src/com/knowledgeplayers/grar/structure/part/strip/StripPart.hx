package com.knowledgeplayers.grar.structure.part.strip;

import com.knowledgeplayers.grar.factory.PatternFactory;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import haxe.xml.Fast;

class StripPart extends StructurePart {

    public function new()
    {
        super();

    }

    /**
    * @return true
**/

    override public function isStrip(): Bool
    {
        return true;

    }

    // Private

    override private function parseContent(content: Xml): Void
    {
        super.parseContent(content);

        var partFast: Fast = new Fast(content).node.Part;

        for(patternNode in partFast.nodes.Pattern){
            var pattern: Pattern = PatternFactory.createPatternFromXml(patternNode);
            pattern.init(patternNode);
            elements.push(pattern);
        }
    }

}