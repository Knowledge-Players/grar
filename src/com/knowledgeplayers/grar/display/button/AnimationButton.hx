package com.knowledgeplayers.grar.display.button;

import aze.display.TileClip;
import aze.display.TileGroup;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import nme.events.Event;
import nme.events.MouseEvent;

/**
 * ...
 * @author kguilloteaux
 */

 class AnimationButton extends CustomEventButton
{
	public var iconGroup:TileGroup;
	public var fondIcon:TileSprite;
	public var arrowIcon:TileClip;

	public function new(tilesheet: TilesheetEx, tile: String, ?eventName: String) 
	{
		if (eventName == null) {
			this.eventType = "next";
			propagateNativeEvent = true;
		}
		else
			this.eventType = eventName;
		
		super(eventType, tilesheet,tile);
		addIcon();
	}
	
	private function addIcon():Void
	{
		this.iconGroup = new TileGroup();
		this.fondIcon = new TileSprite("btCircle");
		this.arrowIcon = new TileClip("fleche_mc");
		this.arrowIcon.animated = true;
		iconGroup.addChild(this.fondIcon);
		iconGroup.addChild(this.arrowIcon);
		layer.addChild(iconGroup);
		iconGroup.x= 100;

		layer.render();
	}
	
	override private function onOver(event:MouseEvent):Void 
	{
		super.onOver(event);
		startAnimIcon();
	}
	
	override private function onOut(event:MouseEvent):Void 
	{
		super.onOut(event);
		endAnimIcon();
	}

	private function animRender(e:Event=null):Void
	{
		layer.render();
	}

	private function endAnimIcon():Void
	{
		this.removeEventListener(Event.ENTER_FRAME, animRender);
		arrowIcon.currentFrame = 0;
		layer.render();
	}

	private function startAnimIcon():Void
	{
		this.addEventListener(Event.ENTER_FRAME,animRender);
	}



	
}