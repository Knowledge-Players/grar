package com.knowledgeplayers.grar.structure.activity;

import nme.events.EventDispatcher;


class Case extends EventDispatcher
{

    /**
    * Path to the content file
    */
    public var content (default, default): String;


    private function new(?content: String):Void
    {
        super();
        this.content = content;

    }

}