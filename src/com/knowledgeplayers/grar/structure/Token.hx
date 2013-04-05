package com.knowledgeplayers.grar.structure;

import haxe.xml.Fast;

/**
* A token that can be earn during parts or activities and store into the inventory
**/
class Token {
    public var ref:String;
    public var type:String;
    public var isActivated (default, default):Bool = false;

    /**
    * Constructor
    * @param    fast : Xml descriptor of the token
**/

    public function new(?_fast:Fast):Void
    {
        if(_fast != null){
            ref = _fast.att.ref;
            type = _fast.att.type;
        }
    }

}