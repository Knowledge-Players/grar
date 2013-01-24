package com.knowledgeplayers.grar.structure.activity;

import nme.events.EventDispatcher;
import haxe.xml.Fast;
import nme.Lib;


class Box extends EventDispatcher
{




    public var items (default, null): List<Dynamic>;

	public function new():Void
	{
		super();
		items = new List<Dynamic>();
		

	}

	public function addXmlItem(item: Fast) : Void
	{
		Lib.trace(item.att.Ref);
		items.add(item);
	}

}