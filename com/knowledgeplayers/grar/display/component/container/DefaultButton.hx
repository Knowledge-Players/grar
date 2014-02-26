package com.knowledgeplayers.grar.display.component.container;

import haxe.Timer;
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
	* Number of seconds before the button can render again
	**/
	private static var RENDER_INTERVAL: Float = 0.08;

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
	public var states (default, null):Map<String, State>;

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
	private var innerTimelines: Map<String, Timeline>;
	private var tmpContent:Sprite;
	private var lastRender:Float;

	/**
     * Action to execute on click
     */
	public dynamic function buttonAction(?target: DefaultButton): Void{}
	/**
     * Constructor.
     * @param	tilesheet : UI Sheet
     * @param	tile : Tile containing the upstate
     */
	public function new(?xml: Fast, ?pStates:Map<String, State>)
	{
		super(xml);
		timelines = new Map<String, Timeline>();
		enabledState = new Map<String, Bool>();
		innerTimelines = new Map<String, Timeline>();
		lastRender = 0;

		if(pStates != null)
			states = pStates;
		else
			states = new Map<String, State>();

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

		addEventListener(Event.ADDED_TO_STAGE, function(e){
			if(toggleState == null)
				toggleState = defaultState;
		});
	}

	public function initStates(?xml: Fast, ?timelines: Map<String, Timeline>):Void
	{
		if(xml != null)
			tmpXml = xml;
		if(tmpXml != null){
			for(state in tmpXml.elements){
				if(state.name.toLowerCase() != "timeline"){
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
				else{
					var timeline = new Timeline(state.att.ref);

					for (elem in state.elements){
						var delay = elem.has.delay?Std.parseFloat(elem.att.delay):0;
						var mock = new Image();
						mock.ref = elem.att.ref;
						timeline.addElement(mock, elem.att.transition, delay);
					}

					innerTimelines.set(state.att.ref,timeline);
				}
			}
			// Simplified XML
			if(Lambda.count(states) == 0)
				states.set(defaultState+"_out", createStates(tmpXml));
			tmpXml = null;
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
		// Init toggle
		if(toggleState == null)
			toggleState = defaultState;
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
				if(state.widgets.exists(pKey)){
					cast(state.widgets.get(pKey), ScrollPanel).setContent(pContent);
				}
			}
		}
		else{
			for(state in states){
				for(elem in state.widgets){
					if(Std.is(elem, ScrollPanel)){
						cast(elem, ScrollPanel).setContent(pContent);
						break;
					}
				}
			}
		}
	}

	public function renderState(stateName:String)
	{
		var changeState = false;
		var oldState: State = states[currentState];
		var state:State = null;
		if(states.exists(toggleState + "_" + stateName)){
			state = states.get(toggleState + "_" + stateName);
			if(currentState != toggleState + "_" + stateName){
				currentState = toggleState + "_" + stateName;
				changeState = true;
			}
		}
		else if(states.exists(toggleState + "_" + "out")){
			state = states.get(toggleState + "_" + "out");
			if(currentState != toggleState + "_" + "out"){
				currentState = toggleState + "_" + "out";
				changeState = true;
			}
		}
		else if(states.exists("active" + "_" + stateName)){
			state = states.get("active" + "_" + stateName);
			if(currentState != "active" + "_" + stateName){
				currentState = "active" + "_" + stateName;
				changeState = true;
			}
		}
		else{
			state = states.get("active_out");
			if(currentState != "active_out"){
				currentState = "active_out";
				changeState = true;
			}
		}
		if(changeState && Timer.stamp()-lastRender > RENDER_INTERVAL){
			tmpContent = new Sprite();
			if(state == null)
				throw "There is no information for state \"" + currentState + "\" for button \"" + ref + "\".";

			var array = new Array<Widget>();
			var layerIndex: Int = -1;
			for(widget in state.widgets){
				array.push(widget);
			}

			array.sort(sortDisplayObjects);
			for(obj in array){
				tmpContent.addChild(obj);
				children.push(obj);
				if(Std.is(obj, TileImage)){
					if(layerIndex == -1) layerIndex = obj.zz;
				}
			}

			var j = 0;
			while(j < tmpContent.numChildren && cast(tmpContent.getChildAt(j), Widget).zz < layerIndex)
				j++;
			tmpContent.addChildAt(layer.view, j);

			enabled = enabledState.get(toggleState);

			if(oldState != null && oldState.timelineOut != null){
				// Update timeline
				for(elem in oldState.widgets){
					insertWidget(elem, oldState.timelineOut);
				}
				oldState.timelineOut.onComplete = onChangeStateFinished;
				oldState.timelineOut.play();
			}
			else{
				onChangeStateFinished();
			}

			if(tmpContent != content)
				addChildAt(tmpContent, getChildIndex(content));

			if(state.timelineIn != null){
				// Update timeline
				for(elem in state.widgets){
					insertWidget(elem, state.timelineIn);
				}
				state.timelineIn.play();
			}
			lastRender = Timer.stamp();
		}
	}

	public function addState(stateName: String, stateXml:Xml, enable: Bool = true):Void
	{
		states.set(stateName, createStates(new Fast(stateXml.firstElement())));
		enabledState.set(stateName.split("_")[0], enable);
	}

	public function setAllListeners(listener:MouseEvent -> Void):Void
	{
		removeAllEventsListeners(listener);
		addEventListener(MouseEvent.ROLL_OVER, listener);
		addEventListener(MouseEvent.ROLL_OUT, listener);
		addEventListener(MouseEvent.CLICK, listener);
		addEventListener(MouseEvent.DOUBLE_CLICK, listener);
		addEventListener(MouseEvent.MOUSE_UP, listener);
		addEventListener(MouseEvent.MOUSE_DOWN, listener);
	}

	public inline function resetToggle():Void
	{
		toggleState = defaultState;
	}

	// Private

	private inline function onChangeStateFinished():Void
	{
		// Clear state
		while(content.numChildren > 0){
			content.removeChildAt(content.numChildren - 1);
		}
		if(layer != null)
			for(child in layer.children)
				child.visible = false;
		scale = scaleX = scaleY = 1;
		layer.render();

		// Reset children
		children = new Array<Widget>();

		addChildAt(tmpContent, getChildIndex(content));
		content = tmpContent;

		displayContent();
		dispatchEvent(new Event(Event.CHANGE));
	}

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
		/*removeEventListener(MouseEvent.MOUSE_OUT, listener);
		removeEventListener(MouseEvent.MOUSE_OVER, listener);*/
		removeEventListener(MouseEvent.ROLL_OVER, listener);
		removeEventListener(MouseEvent.ROLL_OUT, listener);
		removeEventListener(MouseEvent.CLICK, listener);
		removeEventListener(MouseEvent.DOUBLE_CLICK, listener);
		removeEventListener(MouseEvent.MOUSE_UP, listener);
		removeEventListener(MouseEvent.MOUSE_DOWN, listener);
	}

	private inline function createStates(node:Fast):State
	{
		var list = new Map<String, Widget>();
		var timelineIn: Timeline = node.has.timelineIn ? innerTimelines.get(node.att.timelineIn) : null;
		var timelineOut: Timeline = node.has.timelineOut ? innerTimelines.get(node.att.timelineOut) : null;

		for(elem in node.elements){
			var widget = createElement(elem);
			list.set(widget.ref, widget);
		}
		return {name: node.name, timelineIn: timelineIn, timelineOut: timelineOut, widgets: list};
	}

	// Listener

	override private function createButton(buttonNode:Fast):Widget
	{
		mouseChildren = true;
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
		return super.createButton(buttonNode);
	}

	private inline function onMouseEvent(event:MouseEvent):Void
	{
		if(!enabled)
			return ;
		switch (event.type) {
			/*case MouseEvent.MOUSE_OUT: onOut(event);
			case MouseEvent.MOUSE_OVER: onOver(event);*/
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

	private inline function insertWidget(widget: Widget, timeline:Timeline):Void
	{
		if(timeline != null)
			for(elem in timeline.elements)
				if(elem.widget.ref == widget.ref)
					elem.widget = widget;
	}
}

typedef State = {
	var name: String;
	var timelineIn: Timeline;
	var timelineOut: Timeline;
	var widgets: Map<String, Widget>;
}