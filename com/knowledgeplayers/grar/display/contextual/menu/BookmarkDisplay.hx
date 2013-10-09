package com.knowledgeplayers.grar.display.contextual.menu;

import aze.display.TilesheetEx;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;

class BookmarkDisplay extends WidgetContainer{

	private var xOffset: Float;
	private var yOffset: Float;

	public function new(?xml: Fast, ?tilesheet: TilesheetEx)
	{
		super(xml, tilesheet);

		if(xml.has.animation){
			onComplete = function(){
				TweenManager.applyTransition(this, xml.att.animation);
			}
		}
		xOffset = xml.has.xOffset ? Std.parseFloat(xml.att.xOffset) : 0;
		yOffset = xml.has.yOffset ? Std.parseFloat(xml.att.yOffset) : 0;

	}

	public function updatePosition(x:Float, y:Float):Void
	{
		lockPosition = true;
		this.x = x + xOffset;
		this.y = y + yOffset;
	}
}