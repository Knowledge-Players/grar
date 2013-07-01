package com.knowledgeplayers.grar.structure.activity.cards;

class CardsElement {
	public var content (default, default):String;

    /**
    * Reference of the element
    **/
    public var ref (default, default):String;


    public var viewed:Bool;


	public function new(content:String,ref:String)
	{
		this.content = content;
        this.ref = ref;
        this.viewed = false;
	}
}
