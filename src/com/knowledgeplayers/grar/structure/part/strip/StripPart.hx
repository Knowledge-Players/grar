package com.knowledgeplayers.grar.structure.part.strip;

import com.knowledgeplayers.grar.structure.part.strip.pattern.BoxPattern;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import nme.events.EventDispatcher;
import com.knowledgeplayers.grar.structure.part.Part;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.events.Event;

class StripPart extends StructurePart {

    public function new()
    {
        super();

    }

    public function getCurrentBox(): BoxPattern
    {
        return cast(elements[elemIndex], BoxPattern);
    }

    /*public function nextBox(): Void
    {
        roundIndex++;
    }*/

    override public function isStrip(): Bool
    {
        return true;

    }

    // Private

    /*override private function parseContent(content: Xml): Void
    {
        super.parseContent(content);

    }*/

}