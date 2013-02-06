package com.knowledgeplayers.grar.structure.part.strip.pattern;

import com.knowledgeplayers.grar.structure.part.Pattern;
import nme.events.EventDispatcher;
import haxe.xml.Fast;
import nme.Lib;

class BoxPattern extends Pattern {

    public var ref: String;

    public function new(?name: String): Void
    {
        super(name);

        this.ref = name;

    }

}