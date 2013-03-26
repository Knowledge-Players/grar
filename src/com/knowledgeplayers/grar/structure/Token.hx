package com.knowledgeplayers.grar.structure;

import haxe.xml.Fast;
import nme.events.EventDispatcher;


class Token extends EventDispatcher {

    public var ref:String;
    public var img:String;
    public var target:String;
    public var type:String;

    public function new(_fast:Fast):Void{
        super();

        ref = _fast.att.ref;
        img = _fast.att.img;
        type = _fast.att.type;
        target = _fast.att.target;
    }

}