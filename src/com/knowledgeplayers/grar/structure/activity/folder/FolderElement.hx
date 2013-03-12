package com.knowledgeplayers.grar.structure.activity.folder;

import String;

class FolderElement {
    /**
    * Content of the element
    **/
    public var content (default, default):String;

    /**
    * Target of the element
    **/
    public var target (default, default):String;

    /**
    * Reference of the element
    **/
    public var ref (default, default):String;

    /**
    * Target where the element is currently positionned
    **/
    public var currentTarget (default, default):String = "";

    public function new(content:String, ref:String, target:String = "")
    {
        this.content = content;
        this.ref = ref;
        this.target = target;
    }
}
