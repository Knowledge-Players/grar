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
		super(xml, tilesheet);
		textFields = new Map<String, ScrollPanel>();
		var sprite = new TileSprite(layer, xml.att.tile);
		sprite.x = sprite.width /2;
		sprite.y = sprite.height /2;
		layer.addChild(sprite);
		layer.render();

		for(textNode in xml.nodes.Text){
			var text = new ScrollPanel(textNode);
			content.addChild(text);
			textFields.set(text.ref, text);
		}

		addEventListener(Event.ADDED_TO_STAGE, function(e){
			displayContent();
		});
		//initSize();
	}
}
