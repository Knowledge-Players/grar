package com.knowledgeplayers.grar.structure.part.dialog.item;

import com.knowledgeplayers.grar.factory.ActivityFactory;
import com.knowledgeplayers.grar.structure.activity.Activity;
import haxe.xml.Fast;
import nme.Lib;

class RemarkableEvent extends Item 
{
	public var activity (default, default): Activity;
	
	public function new(?xml: Fast)
	{
		super();
		activity = ActivityFactory.createActivityFromXml(xml.node.Activity);
	}

	override public function hasActivity() : Bool 
	{
		return true;
	}
}