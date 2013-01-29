package com.knowledgeplayers.grar.structure.part.strip.box;

import com.knowledgeplayers.grar.structure.part.dialog.pattern.Pattern;
import nme.events.EventDispatcher;
import haxe.xml.Fast;
import nme.Lib;

class Box extends Pattern {

    public var ref: String;

    public var items: List<Fast>;

    public function new(?name: String): Void
    {
        super(name);
        items = new List<Fast>();

        this.ref = name;

    }

    override public function init(xml: Fast): Void
    {
        for(element in xml.elements){
            addXmlItem(element);
        }
    }

    public function addXmlItem(item: Fast): Void
    {

        items.add(item);
    }

}