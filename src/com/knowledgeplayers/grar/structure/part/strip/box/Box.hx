package com.knowledgeplayers.grar.structure.activity;

import nme.events.EventDispatcher;
import haxe.xml.Fast;
import nme.Lib;


class Box extends EventDispatcher
{


	public var ref:String;

    	public var items: List<Fast>;

	public function new(?ref:String):Void
	{
		super();
		items = new List<Fast>();

		this.ref = ref;
		

	}

	public function addXmlItem(item: Fast) : Void
	{
		
		items.add(item);
	}

}