package com.knowledgeplayers.grar.structure.part;

import haxe.xml.Fast;

class DynamicItem extends Item {

	dynamic public function fetch(param:String):List<String>{return new List<String>();}

	public var fetchMethod:String;
	public var fetchParam:String;


	/**
     * Constructor
     * @param	xml : fast xml node with structure info
     * @param	content : text of the item
     */
	public function new(?xml:Fast)
	{
		super(xml);
		var regexp = ~/([^(]*)\((.*)\)/;
		regexp.match(xml.att.fetch);
		fetchMethod = regexp.matched(1);
		fetchParam = regexp.matched(2);
	}

	/**
    * @return true
    **/
	override public function isText():Bool
	{
		return true;
	}
}
