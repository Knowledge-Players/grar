package com.knowledgeplayers.grar.structure.part.strip;

import com.knowledgeplayers.grar.structure.part.strip.box.Box;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import nme.events.EventDispatcher;
import com.knowledgeplayers.grar.structure.part.Part;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.events.Event;

class StripPart  extends StructurePart {
/**
 * Group of cases
 */

    private var roundIndex: Int = 0;

    public function new()
    {
        super();

    }

    public function getCurrentBox():Box
    {
        return cast(patterns[roundIndex],Box);
    }
    public function nextBox():Void{
        roundIndex++;
    }
    override public function isStrip(): Bool
    {
        return true;

    }


// Private

    override private function parseContent(content: Xml): Void
    {
        super.parseContent(content);

    }

}