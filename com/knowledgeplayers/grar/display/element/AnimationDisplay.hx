package com.knowledgeplayers.grar.display.element;

import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.component.Widget;
import aze.display.TileClip;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import nme.display.Sprite;
import nme.events.Event;

class AnimationDisplay extends WidgetContainer
{
	private var clip:TileClip;
	private var loop: Int;

	public function new(?xml: Fast, ?_id:String, ?_tileSheet:TilesheetEx, _loop:Int = 0)
	{
		super(xml);

		if(_tileSheet != null)
			tilesheet = _tileSheet;
		if(_id != null){
			clip = new TileClip(layer, _id);
			layer.addChild(clip);
			layer.render();
		}
		loop = _loop;

		addEventListener(Event.ADDED_TO_STAGE, animate);
	}

	/**
    * Play the animation with an Enter_Frame
    **/

	public function animate(?e:Event):Void
	{
		clip.play();
		clip.loop = false;
		clip.onComplete = onAnimationEnd;
		layer.render();
	}

	/**
    * Stop the animation
    **/

	public function stopElement():Void
	{
		clip.stop();
		clip.currentFrame = 0;
		layer.render();
	}
	/*
     Goto the frame you want;
     */

	public function goto(_frame:Int):Void
	{
		clip.currentFrame = _frame;
		layer.render();
	}

	private function onAnimationEnd(clip:TileClip):Void
	{
		loop--;
		if(loop > 0){
			clip.currentFrame = 0;
			clip.play();
			layer.render();
		}
	}
}