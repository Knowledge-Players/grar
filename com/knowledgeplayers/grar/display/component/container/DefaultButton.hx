package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.display.element.Timeline;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import haxe.xml.Fast;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * Custom base button class
 */

class DefaultButton extends WidgetContainer {

	/**
     * Switch to enable the button
     */
	public var enabled (default, set_enabled):Bool;

	/**
    * Class of style for the button
    **/
	public var className (default, default):String;

	/**
    * Different states of the button
    **/
	public var states (default, null):Map<String, Map<String, Widget>>;

	/**
	* Group of buttons containing it
	**/
	public var group (default, default):String;

	/**
	* State of the button.
	**/
	public var toggleState (default, set_toggleState):String;

	/**
	* Timeline that will play on the next click
	**/
	public var timeline (default, default):Timeline;

	private var currentState:String;
	private var isToggleEnabled: Bool = false;
    private var timelines: Map<String, Timeline>;
	private var tmpXml: Fast;

		/**
     * Action to execute on click
     */
	public dynamic function buttonAction(?target: DefaultButton): Void{}

	/**
     * Constructor.
     * @param	tilesheet : UI Sheet
     * @param	tile : Tile containing the upstate
     */

	public function new(?xml: Fast, ?pStates:Map<String, Map<String, Widget>>)
	{
		super(xml);
		timelines = new Map<String, Timeline>();

		if(pStates != null)
			states = pStates;
		else
			states = new Map<String, Map<String, Widget>>();

		if(xml != null){
			for(state in xml.elements){
				if(state.has.timeline){
					tmpXml = xml;
					break;
				}
			}
			if(tmpXml == null)
				initStates(xml);

			if(xml.has.toggle)
				isToggleEnabled = xml.att.toggle == "true";
			if(xml.has.group)
				group = xml.att.group.toLowerCase();
			if(xml.has.defaultState)
				toggleState = xml.att.defaultState;

		}

		mouseChildren = false;
		useHandCursor = buttonMode = true;

		init();
	}

	public function initStates(?xml: Fast, ?timelines: Map<String, Timeline>):Void
	{
		if(xml != null)
			tmpXml = xml;
		if(tmpXml != null){
			for(state in tmpXml.elements){
				if(timelines != null && state.has.timeline)
					this.timelines.set(state.name, timelines.get(state.att.timeline));
				for(elem in state.elements){
					if(states.exists(state.name+"_out") || elem.name == "out"){
						states.set(state.name+"_" + elem.name, createStates(elem));
					}
				}
			}
			tmpXml = null;
		}

		if(toggleState == null)
			toggleState = "active";


	}

	/**
     * Enable or disable the button
     * @param	activate : True to activate the button
     * @return true if the button is now activated
     */

	public inline function set_enabled(activate:Bool):Bool
	{
		enabled = buttonMode = mouseEnabled = activate;

		return activate;
	}

	public inline function set_toggleState(state:String):String
	{
		toggleState = state;
		timeline = timelines.get(toggleState);
		renderState("out");
		return toggleState;
	}

	override public function set_mirror(mirror:Int):Int
	{
		for(sprite in layer.children)
			cast(sprite, TileSprite).mirror = mirror;

		layer.render();
		return this.mirror = mirror;
	}

	/**
	* Define if the button is in state active or inactive
	**/

	public inline function toggle(?toggle:Bool):Void
	{
		if(toggle == null)
			toggle = toggleState == "inactive";
		toggleState = toggle ? "active" : "inactive";
	}

	public function setText(pContent:String, ?pKey:String):Void
	{
		for(state in states){
			if(pKey == null){
				for(elem in state){
					if(Std.is(elem, ScrollPanel)){
						cast(elem, ScrollPanel).setContent(pContent);
					}
				}
			}
			else if(state.exists(pKey)){
				cast(state.get(pKey), ScrollPanel).setContent(pContent);
			}
		}
	}

	public function renderState(state:String)
	{
		var changeState = false;
		var list:Map<String, Widget>;
		if(states.exists(toggleState + "_" + state)){
			list = states.get(toggleState + "_" + state);
			if(currentState != toggleState + "_" + state){
				currentState = toggleState + "_" + state;
				changeState = true;
			}
		}
		else if(states.exists(toggleState + "_" + "out")){
			list = states.get(toggleState + "_" + "out");
			if(currentState != toggleState + "_" + "out"){
				currentState = toggleState + "_" + "out";
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
			while(content.numChildren > 0){
				content.removeChildAt(content.numChildren - 1);
			}
			for(child in layer.children)
				child.visible = false;

			if(list == null)
				throw "There is no information for state \"" + currentState + "\" for button \"" + ref + "\".";

			var array = new Array<Widget>();
			for(widget in list){
				if(!Std.is(widget, TileImage))
					array.push(widget);
				else{
					cast(widget, TileImage).set_visible(true);
				}
			}
			content.addChild(layer.view);

			array.sort(sortDisplayObjects);
			for(obj in array){
				content.addChild(obj);
			}
			//trace(ref, "stop tween");
			TweenManager.stop(layer.view);

			if(list.exists("backgroundDrawn")){
				var image: Image = cast(list.get("backgroundDrawn"), Image);
				if(background.length == 10)
					image.graphics.beginFill(Std.parseInt("0x"+background.substr(4)), Std.parseInt(background.substr(2, 4))/10);
				else
					image.graphics.beginFill(Std.parseInt(background));
				image.graphics.drawRect(0, 0, width, height);
				image.graphics.endFill();
				content.addChildAt(image, 0);
			}

			renderNeeded = true;
			displayContent();
		}
	}

	// Abstract

	private function onClick(event:MouseEvent):Void
	{
		if(timeline != null){
			timeline.addEventListener(Event.COMPLETE,function(e){buttonAction(this);});
			timeline.play();
		}else
			buttonAction(this);
		if(isToggleEnabled)
			onToggle();
	}

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

	private inline function onOver(event:MouseEvent):Void
	{
		renderState("over");
		//dispatchEvent(new ButtonActionEvent(ButtonActionEvent.OVER));
	}

	private inline function onOut(event:MouseEvent):Void
	{
		renderState("out");
	}

	private inline function onClickDown(event:MouseEvent):Void
	{
		renderState("press");
	}

	private inline function onClickUp(event:MouseEvent):Void
	{
		renderState("out");
	}

	private inline function init():Void
	{
		enabled = true;

		setAllListeners(onMouseEvent);

		// Hack for C++ hitArea (NME 3.5.5)
		#if cpp
			graphics.beginFill (0xFFFFFF, 0.01);
			graphics.drawRect (-width/2, -height/2, width, height);
			graphics.endFill();
		#end
	}

	private inline function sortDisplayObjects(x:Widget, y:Widget):Int
	{
		if(x.zz < y.zz)
			return -1;
		else if(x.zz > y.zz)
			return 1;
		else
			return 0;
	}

	private inline function removeAllEventsListeners(listener:MouseEvent -> Void):Void
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

	private inline function createStates(node:Fast):Map<String, Widget>
	{
		var list = new Map<String, Widget>();
		if(node.has.background){
			var bkg = new Image();
			background = node.att.background;
			list.set("backgroundDrawn", bkg);
		}

		for(elem in node.elements){
			var widget = createElement(elem);
			list.set(widget.ref, widget);
		}
		return list;
	}

	// Listener

	private inline function onMouseEvent(event:MouseEvent):Void
	{
		//event.stopImmediatePropagation();

		switch (event.type) {
			case MouseEvent.MOUSE_OUT: onOut(event);
			case MouseEvent.MOUSE_OVER: onOver(event);
			case MouseEvent.ROLL_OVER: onOver(event);
			case MouseEvent.ROLL_OUT: onOut(event);
			case MouseEvent.CLICK: onClick(event);
			case MouseEvent.MOUSE_DOWN: onClickDown(event);
			case MouseEvent.MOUSE_UP: onClickUp(event);
		}
	}

	private inline function onToggle():Void
	{
		toggle(toggleState != "active");
		dispatchEvent(new ButtonActionEvent(ButtonActionEvent.TOGGLE));
	}

	override private inline function addElement(elem:Widget):Void
	{
		elem.zz = zIndex;
		zIndex++;
	}

	override public function maskSprite(sprite:Sprite,  maskWidth: Float = 1, maskHeight: Float = 1, maskX: Float = 0, maskY: Float = 0): Void
	{
	}

}