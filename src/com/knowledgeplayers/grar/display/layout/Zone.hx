package com.knowledgeplayers.grar.display.layout;
import haxe.xml.Fast;

class Zone {

    public var ref:String;

    public function new(_zone:Fast):Void {
        if(_zone.has.ref)
            ref = _zone.att.ref;

    }
}
