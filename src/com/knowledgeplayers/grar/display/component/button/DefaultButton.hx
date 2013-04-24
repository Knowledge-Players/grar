package com.knowledgeplayers.grar.display.component.button;

import nme.events.Event;
import aze.display.TileClip;
import nme.geom.Point;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Custom base button class
 * @author jbrichardet
 */

class DefaultButton extends Sprite {

	/**
     * Layer of the button
     */
	public var layer:TileLayer;

	/**
     * Switch to enable the button
     */
	public var enabled (default, enable):Bool;

	/**
    * Reference of the button
    **/
	public var ref (default, default):String;

	/**
    * Scale of the button
    **/
	public var scale (default, setScale):Float;

	/**
    * Mirror
    **/
	public var mirror (default, setMirror):Int;

	/**
    * Class of style for the button
    **/
	public var className (default, default):String;

	/**
	* Transition when the button appears
	**/
	public var transitionIn (default, setTransitionIn):String;

	/**
	* Transition when the button disappears
	**/
	public var transitionOut (default, setTransitionOut):String;

	private var clip:TileClip;

	/**
     * Constructor.
     * @param	tilesheet : UI Sheet
     * @param	tile : Tile containing the upstate
     */

	public function new(tilesheet:TilesheetEx, tile:String)
	{
		super();

		if(tilesheet != null && tile != ""){
			layer = new TileLayer(tilesheet);
			clip = new TileClip(tile);
		}
		mouseChildren = false;

		init();
	}

	public function setTransitionIn(transition:String):String
	{
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transition);
		});

		return transitionIn = transition;
	}

	public function setTransitionOut(transition:String):String
	{
		addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event)
		{
			TweenManager.applyTransition(this, transition);
		});
		return transitionOut = transition;
	}

	/**
     * Enable or disable the button
     * @param	activate : True to activate the button
     * @return true if the button is now activated
     */

	public function enable(activate:Bool):Bool
	{
		enabled = buttonMode = mouseEnabled = activate;

		return activate;
	}

	public function setScale(scale:Float):Float
	{
		return scaleX = scaleY = this.scale = scale;
	}

	public function setMirror(mirror:Int):Int
	{
		for(sprite in layer.children)
			cast(sprite, TileSprite).mirror = mirror;

		layer.render();
		return this.mirror = mirror;
	}

	// Abstract

	private function onMouseOver(event:MouseEvent):Void
	{

	}

	private function onMouseOut(event:MouseEvent):Void
	{}

	private function onClick(event:MouseEvent):Void
	{}

	private function onDblClick(event:MouseEvent):Void
	{}

	private function open(event:MouseEvent):Void
	{}

	private function close(event:MouseEvent):Void
	{}

	// Private

	private function setAllListeners(listener:MouseEvent -> Void):Void
	{
		removeAllEventsListeners(listener);
		addEventListener(MouseEvent.MOUSE_OUT, listener);
		addEventListener(MouseEvent.MOUSE_OVER, listener);
		addEventListener(MouseEvent.ROLL_OVER, listener);
		addEventListener(MouseEvent.ROLL_OUT, listener);
		addEventListener(MouseEvent.CLICK, listener);
		addEventListener(MouseEvent.DOUBLE_CLICK, listener);
		addEventListener(MouseEvent.MOUSE_DOWN, listener);
		addEventListener(MouseEvent.MOUSE_UP, listener);
	}

	private function onOver(event:MouseEvent):Void
	{
		clipOver();

	}

	private function onOut(event:MouseEvent):Void
	{
		clipOut();
	}

	private function onClickDown(event:MouseEvent):Void
	{
		clipDown();
	}

	private function onClickUp(event:MouseEvent):Void
	{
		clipOut();
	}

	private function init():Void
	{
		enabled = true;

		setAllListeners(onMouseEvent);

		if(layer != null){
			layer.addChild(clip);
			addChild(layer.view);
			layer.render();
		}

		// Hack for C++ hitArea (NME 3.5.5)
		#if cpp
			graphics.beginFill (0xFFFFFF, 0.01);
			graphics.drawRect (-width/2, -height/2, width, height);
			graphics.endFill();
		#end
	}

	public function clipOver():Void
	{
		if(layer != null){
			if(clip.frames.length > 0){
				clip.currentFrame = 1;
			}

			layer.render();
		}
	}

	public function clipOut():Void
	{
		if(layer != null){
			if(clip.frames.length > 0){
				clip.currentFrame = 0;
			}

			layer.render();
		}
	}

	public function clipDown():Void
	{
		if(layer != null){
			if(clip.frames.length > 1){
				clip.currentFrame = 2;
			}
			else{
				clip.currentFrame = 0;
			}
			layer.render();
		}
	}

	private function removeAllEventsListeners(listener:MouseEvent -> Void):Void
	{
		removeEventListener(MouseEvent.MOUSE_OUT, listener);
		removeEventListener(MouseEvent.MOUSE_OVER, listener);
		removeEventListener(MouseEvent.ROLL_OVER, listener);
		removeEventListener(MouseEvent.ROLL_OUT, listener);
		removeEventListener(MouseEvent.CLICK, listener);
		removeEventListener(MouseEvent.DOUBLE_CLICK, listener);
		removeEventListener(MouseEvent.MOUSE_DOWN, listener);
		removeEventListener(MouseEvent.MOUSE_UP, listener);
	}

	// Listener

	private function onMouseEvent(event:MouseEvent):Void
	{
		if(!enabled){
			event.stopImmediatePropagation();
			return;
		}

		switch (event.type) {
			case MouseEvent.MOUSE_OUT: onOut(event);
			case MouseEvent.MOUSE_OVER: onOver(event);
			case MouseEvent.ROLL_OVER: onOver(event);
			case MouseEvent.ROLL_OUT: onOut(event);
			case MouseEvent.CLICK: onClick(event);
			case MouseEvent.MOUSE_DOWN: onClickDown(event);
			case MouseEvent.MOUSE_UP: onClickUp(event);
			case MouseEvent.DOUBLE_CLICK: onDblClick(event);
		}
	}
}

enum ButtonState {
	UP;
	DOWN;
	OVER;
}