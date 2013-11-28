package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.util.ParseUtils;
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
	private var defaultState: String;
	private var enabledState: Map<String, Bool>;

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
		enabledState = new Map<String, Bool>();

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
			defaultState = xml.has.defaultState ? xml.att.defaultState : "active";
			if(tmpXml == null)
				initStates(xml);

			if(xml.has.toggle)
				isToggleEnabled = xml.att.toggle == "true";
			if(xml.has.group)
				group = xml.att.group.toLowerCase();

			enabled = (xml.has.action || xml.name != "Button");
		}
		else{
			defaultState = "active";
			enabled = true;
		}

		mouseChildren = false;
		useHandCursor = buttonMode = enabled;

		setAllListeners(onMouseEvent);

		// Hack for C++ hitArea (NME 3.5.5)
		#if cpp
			graphics.beginFill (0xFFFFFF, 0.01);
			graphics.drawRect (-width/2, -height/2, width, height);
			graphics.endFill();
		#end
	}

	public function initStates(?xml: Fast, ?timelines: Map<String, Timeline>):Void
	{
		if(xml != null)
			tmpXml = xml;
		if(tmpXml != null){
			for(state in tmpXml.elements){
				if(timelines != null && state.has.timeline)
					this.timelines.set(state.name, timelines.get(state.att.timeline));
				if(state.has.enable)
					enabledState.set(state.name, state.att.enable == "true");
				else
					enabledState.set(state.name, true);
				for(elem in state.elements){
					states.set(state.name+"_" + elem.name, createStates(elem));
				}
			}
			// Simplified XML
			if(Lambda.count(states) == 0)
				states.set(defaultState+"_out", createStates(tmpXml));
			tmpXml = null;
			toggleState = defaultState;
		}

	}

	@:setter(alpha)
	override public function set_alpha(alpha:Float):Void
	{
		enabled = enabledState.get(toggleState) ? alpha == 1 : false;
		super.alpha = alpha;
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
		if(states.exists(state+"_out")){
			toggleState = state;
			timeline = timelines.get(toggleState);
			renderState("out");
		}
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
		// Don't do anything if the toggle doesn't change
		if(toggle != (toggleState == "active")){
			// If param is null, switch state
			if(toggle == null)
				toggle = toggleState == "inactive";
			toggleState = toggle ? "active" : "inactive";
		}
	}

	public function setText(pContent:String, ?pKey:String):Void
	{
		if(pKey != null && pKey != " "){
			for(state in states){
				if(state.exists(pKey)){
					cast(state.get(pKey), ScrollPanel).setContent(pContent);
					break;
				}
			}
		}
		else{
			for(state in states){
				for(elem in state){
					if(Std.is(elem, ScrollPanel)){
						cast(elem, ScrollPanel).setContent(pContent);
						break;
					}
				}
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
			scale = scaleX = scaleY = 1;

			// Reset children
			children = new Array<Widget>();

			if(list == null)
				throw "There is no information for state \"" + currentState + "\" for button \"" + ref + "\".";

			var array = new Array<Widget>();
			var layerIndex: Int = -1;
			for(widget in list){
				if(!Std.is(widget, TileImage))
					array.push(widget);
				else{
					widget.visible = true;
					if(layerIndex == -1) layerIndex = widget.zz;
				}
			}

			array.sort(sortDisplayObjects);
			for(obj in array){
				content.addChild(obj);
				children.push(obj);
			}

			var j = 0;
			while(j < content.numChildren && cast(content.getChildAt(j), Widget).zz < layerIndex)
				j++;
			content.addChildAt(layer.view, j);

			TweenManager.stop(layer.view);

			renderNeeded = true;
			enabled = enabledState.get(toggleState);
			displayContent();
			dispatchEvent(new Event(Event.CHANGE));
		}
	}

	// Private

	private function onClick(event:MouseEvent):Void
	{
		var timelineOut = timeline;
		if(isToggleEnabled)
			onToggle();
		if(timelineOut != null){
			timelineOut.addEventListener(Event.COMPLETE,function(e){
				buttonAction(this);
			});
			timelineOut.play();
		}else
			buttonAction(this);
	}

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

		for(elem in node.elements){
			var widget = createElement(elem);
			list.set(widget.ref, widget);
		}
		return list;
	}

	// Listener

	private inline function onMouseEvent(event:MouseEvent):Void
	{
		if(!enabled)
			return ;
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
}