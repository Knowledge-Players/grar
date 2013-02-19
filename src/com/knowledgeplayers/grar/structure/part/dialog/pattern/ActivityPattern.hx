package com.knowledgeplayers.grar.structure.part.dialog.pattern;

import com.knowledgeplayers.grar.structure.part.Pattern;
import com.knowledgeplayers.grar.structure.part.dialog.item.RemarkableEvent;
import com.knowledgeplayers.grar.structure.part.TextItem;
import com.knowledgeplayers.grar.factory.ItemFactory;
import nme.Lib;

import haxe.xml.Fast;

class ActivityPattern extends Pattern {
    /**
     * Item that will trigger an activity
     */
    public var event: RemarkableEvent;

    public function new(name: String)
    {
        super(name);
    }

    override public function init(xml: Fast): Void
    {
        super.init(xml);

        for(item in patternContent){
            if(Std.is(item, RemarkableEvent))
                event = cast(item, RemarkableEvent);
        }
    }
}