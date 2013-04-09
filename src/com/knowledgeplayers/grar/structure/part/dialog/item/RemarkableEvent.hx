package com.knowledgeplayers.grar.structure.part.dialog.item;

import com.knowledgeplayers.grar.factory.ActivityFactory;
import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.xml.Fast;
import nme.Lib;

class RemarkableEvent extends TextItem {
    /**
     * Activity to start when this item is reached
     */
    public var activity (default, default):Activity;

    /**
     * Constructor
     * @param	xml : fast xml node with structure infos
     */

    public function new(?xml:Fast)
    {
        super(xml);
        activity = ActivityFactory.createActivityFromXml(xml.node.Activity);
        token = activity.token;
    }

    override public function hasActivity():Bool
    {
        return true;
    }
}