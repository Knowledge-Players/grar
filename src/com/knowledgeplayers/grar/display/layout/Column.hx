package com.knowledgeplayers.grar.display.layout;

import haxe.xml.Fast;
class Column {
    public var zones:Array<Zone>;
    public var size:String;


    public function new(_col:Fast):Void {

        zones = new Array<Zone>();
        for(_zone in _col.elements){

            initZone(_zone);
        }


    }

    private function initZone(_zone:Fast):Void{

        var zone = new Zone(_zone);
        zones.push(zone);
    }
}
