package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.util.DisplayUtils;
import aze.display.TilesheetEx;
import aze.display.TileLayer;
import haxe.xml.Fast;
import nme.events.Event;
import aze.display.TileSprite;

/**
* Box Widget for strip part
**/
class BoxDisplay extends WidgetContainer
{
	/**
	* Text fields contained in the box
	**/
	public var textFields (default, default):Map<String, ScrollPanel>;

	public function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
		textFields = new Map<String, ScrollPanel>();
		super(xml, tilesheet);
	}

	override private inline function createText(textNode:Fast):Widget
	{

		var text = new ScrollPanel(textNode);
		addElement(text);
		textFields.set(text.ref, text);
		return text;
	}

	override private inline function addElement(elem:Widget):Void
	{
		if(zIndex == 0)
			zIndex++;
		super.addElement(elem);
	}

}
