package com.knowledgeplayers.grar.display.component.button;

import nme.Lib;
import com.eclecticdesignstudio.motion.Actuate;
import aze.display.TileClip;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
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

	/**
    * Different states of the button
    **/
	public var states (default, null):Hash<Hash<{dpo:DisplayObject, z:Int, trans:String}>>;

	/**
     * Type of the event to dispatch
     */
	public var eventType (default, default):String;

	/**
     * Control whether or not the native event (CLICK) must be propagated
     */
	public var propagateNativeEvent (default, default):Bool = false;

	private var toggle:String = "active";

	private var currentState:String;

	private var clip:TileClip;

	/**
     * Constructor.
     * @param	tilesheet : UI Sheet
     * @param	tile : Tile containing the upstate
     */

	public function new(pStates:Hash<Hash<{dpo:DisplayObject, z:Int, trans:String}>>, action:String = "next")
	{
		super();

		states = pStates;

		eventType = action.toLowerCase();

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

	/**
	* Define if the button is in state active or inactive
	**/

	public function setToggle(toggle:Bool):Void
	{
		this.toggle = toggle ? "active" : "inactive";
		renderState("out");
	}

	// Abstract

	private function onMouseOver(event:MouseEvent):Void
	{

	}

	private function onMouseOut(event:MouseEvent):Void
	{}

	private function onClick(event:MouseEvent):Void
	{
		if(!propagateNativeEvent)
			event.stopImmediatePropagation();

		var e = new ButtonActionEvent(eventType);
		dispatchEvent(e);
	}

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
		renderState("over");
	}

	private function onOut(event:MouseEvent):Void
	{
		renderState("out");
	}

	private function onClickDown(event:MouseEvent):Void
	{
		renderState("press");
	}

	private function onClickUp(event:MouseEvent):Void
	{
		renderState("out");
	}

	private function init():Void
	{
		enabled = true;

		setAllListeners(onMouseEvent);

		renderState("out");

		// Hack for C++ hitArea (NME 3.5.5)
		#if cpp
			graphics.beginFill (0xFFFFFF, 0.01);
			graphics.drawRect (-width/2, -height/2, width, height);
			graphics.endFill();
		#end
	}

	private function renderState(state:String)
	{
		var changeState = false;
		var list:Hash<{dpo:DisplayObject, z:Int, trans:String}>;
		if(states.exists(toggle + "_" + state)){
			list = states.get(toggle + "_" + state);
			if(currentState != toggle + "_" + state){
				currentState = toggle + "_" + state;
				changeState = true;
			}
		}
		else if(states.exists(toggle + "_" + "out")){
			list = states.get(toggle + "_" + "out");
			if(currentState != toggle + "_" + "out"){
				currentState = toggle + "_" + "out";
				changeState = true;
			}
		}
		else if(states.exists("active" + "_" + state)){
			list = states.get("active" + "_" + state);
			if(currentState != "active" + "_" + state){
				currentState = "active" + "_" + state;
				changeState = true;
			}
		}
		else{
			list = states.get("active_out");
			if(currentState != "active_out"){
				currentState = "active_out";
				changeState = true;
			}
		}
		if(changeState){
			// Clear state
			while(numChildren > 0){
				removeChildAt(numChildren - 1);
			}

			var array = new Array<{dpo:DisplayObject, z:Int, trans:String}>();

			if(list == null)
				throw "There is no information for state \"" + currentState + "\" for button \"" + ref + "\".";
			for(elem in list){
				array.push(elem);
			}

			array.sort(sortDisplayObjects);
			for(obj in array){
				if(obj.trans != ""){
					TweenManager.resetTransform(obj.dpo);
					TweenManager.applyTransition(obj.dpo, obj.trans);

				}
				addChild(obj.dpo);

			}

		}
	}

	public function setText(pContent:String, ?pKey:String):Void
	{
		for(state in states){
			if(pKey != null && state.exists(pKey)){
				cast(state.get(pKey).dpo, ScrollPanel).setContent(pContent);
			}
			else if(pKey == null){
				for(elem in state){
					if(Std.is(elem.dpo, ScrollPanel))
						cast(elem.dpo, ScrollPanel).setContent(pContent);
				}
			}
		}
	}

	private function sortDisplayObjects(x:{dpo:DisplayObject, z:Int, trans:String}, y:{dpo:DisplayObject, z:Int, trans:String}):Int
	{
		if(x.z < y.z)
			return -1;
		else if(x.z > y.z)
			return 1;
		else
			return 0;
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