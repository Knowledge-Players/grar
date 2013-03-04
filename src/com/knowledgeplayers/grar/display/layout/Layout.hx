package com.knowledgeplayers.grar.display.layout;

import com.knowledgeplayers.grar.event.LayoutEvent;
import nme.events.Event;
import nme.Lib;
import haxe.xml.Fast;

/**
* Layout of the application
**/
class Layout {
    /**
    * All the child zones of this layout
    **/
    public var zones: Hash<Zone>;

    /**
    * Content of the layout
    **/
    public var content (getContent, null): Zone;

    /**
    * Name of this layout
    **/
    public var name: String;

    /**
    * Constructor
    * @param    name : Name of the layout
    * @param    content : Content of the layout
    * @param    fast : XML description of the layout
    **/

    public function new(?_name: String, ?_content: Zone, ?_fast: Fast): Void
    {

        zones = new Hash<Zone>();

        if(_fast != null){
            content = new Zone(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
            content.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
            content.init(_fast);
            name = _fast.att.layoutName;
        }
        else{
            name = _name;
            content = _content;
        }
    }

    public function getContent(): Zone
    {
        return content;
    }

    // Handlers

    private function onNewZone(e: LayoutEvent): Void
    {
        zones.set(e.ref, e.zone);
    }
}
