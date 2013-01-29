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
    public var boxes: Array<Box>;

    private var roundIndex: Int = 0;

    public function new()
    {
        super();
        boxes = new Array<Box>();
    }

    public function getCurrentBox(): Box
    {
        return boxes[roundIndex];
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

       /* var anim = new Fast(content).node.Part;
        for(round in anim.nodes.Pattern){
            var box = new Box(round.att.Ref);

            for(element in round.elements){
                box.addXmlItem(element);

            }
            boxes.push(box);

        }  */

    }

}