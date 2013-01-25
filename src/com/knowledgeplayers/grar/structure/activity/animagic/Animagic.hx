package com.knowledgeplayers.grar.structure.activity.animagic;

import haxe.xml.Fast;
import com.knowledgeplayers.grar.structure.activity.Activity;
import com.knowledgeplayers.grar.util.XmlLoader;
import nme.events.Event;

class Animagic extends Activity {
    /**
     * Group of cases
     */
    public var boxes: Array<Box>;

    private var roundIndex: Int = 0;

    public function new(?content: String)
    {
        super(content);
        boxes = new Array<Box>();
        var xml = XmlLoader.load(content, onLoadComplete);
        #if !flash
	parseContent(xml);
        #end

    }

    public function getCurrentBox(): Box
    {
        return boxes[roundIndex];
    }

    override public function startActivity(): Void
    {
        nme.Lib.trace("start Animagic");
    }

    override private function parseContent(content: Xml): Void
    {
        var anim = new Fast(content).node.Animagic;
        for(round in anim.nodes.Round){
            var box = new Box();

            for(element in round.elements){
                box.addXmlItem(element);

            }
            boxes.push(box);

        }
    }

}