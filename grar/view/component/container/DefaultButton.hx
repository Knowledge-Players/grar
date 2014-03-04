package grar.view.component.container;

import aze.display.TileLayer;
import aze.display.TileSprite;
import aze.display.TilesheetEx;

import grar.view.element.Timeline;
import grar.view.component.container.WidgetContainer;
import grar.view.component.container.ScrollPanel;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import haxe.ds.StringMap;

/**
 * Custom base button class
 */
class DefaultButton extends WidgetContainer {

// public function new(?xml: Fast, ?pStates:Map<String, Map<String, Widget>>) // pStates never passed ??
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : TilesheetEx, 
							? dbd : Null<WidgetContainerData>) {
		
		this.timelines = new Map<String, Timeline>();
		this.enabledState = new Map<String, Bool>();
		this.states = new Map<String, Map<String, Widget>>();

		if (dbd == null) {

			super(callbacks, applicationTilesheet);

			this.defaultState = "active";
			this.enabled = true;

		} else {

			super(callbacks, applicationTilesheet, dbd);

			switch(dbd.type) {

				case DefaultButton(ds, ite, a, g, e, st, ste):

					for (state in st) {

						if (state.timeline != null) {

							tmpdata = dbd;
							break;
						}
					}
					this.defaultState = ds;
					
					if (tmpdata != null) {

						initStates(dbd);
					}
					this.isToggleEnabled = ite;

					if (g != null) {

						this.group = g;
					}
					this.enabled = e;

				default: throw "Wrong WidgetContainerData type passed to DefaultButton constructor";
			}
		}

		this.mouseChildren = false;
		this.useHandCursor = this.buttonMode = this.enabled;

		setAllListeners(onMouseEvent);

		// Hack for C++ hitArea (NME 3.5.5)
#if cpp
		graphics.beginFill (0xFFFFFF, 0.01);
		graphics.drawRect (-width/2, -height/2, width, height);
		graphics.endFill();
#end

		addEventListener(Event.ADDED_TO_STAGE, function(e){
//trace("*********** DEFAULT BUTTON ADDED TO STAGE !!!");
				this.toggleState = this.defaultState;

			});
	}

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
	private var tmpdata : WidgetContainerData;
	private var defaultState: String;
	private var enabledState: Map<String, Bool>;


	///
	// CALLBACKS
	//

	public dynamic function onToggle() : Void { }

	/**
     * Action to execute on click
     */
	public dynamic function buttonAction(? target : DefaultButton) : Void { }


	///
	// GETTER / SETTER
	//

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


	///
	// API
	//

	/**
	 * Define if the button is in state active or inactive
	 **/
	public inline function toggle(? toggle : Bool) : Void {

		// Don't do anything if the toggle doesn't change
		if (toggle != (toggleState == "active")) {

			// If param is null, switch state
			if (toggle == null) {

				toggle = toggleState == "inactive";
			}
			toggleState = toggle ? "active" : "inactive";
		}
	}

	public function setText(pContent:String, ?pKey:String):Void
	{
		if(pKey != null && pKey != " "){
			for(state in states){
				if(state.exists(pKey)){
					cast(state.get(pKey), ScrollPanel).setContent(pContent);
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
			if(layer != null)
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
				array.push(widget);
			}

			array.sort(sortDisplayObjects);
			for(obj in array){
				content.addChild(obj);
				children.push(obj);
				if(Std.is(obj, TileImage)){
					if(layerIndex == -1) layerIndex = obj.zz;
				}
			}

			var j = 0;
			while(j < content.numChildren && cast(content.getChildAt(j), Widget).zz < layerIndex)
				j++;
			content.addChildAt(layer.view, j);

			renderNeeded = true;
			enabled = enabledState.get(toggleState);
			displayContent();
			
			dispatchEvent(new Event(Event.CHANGE));
		}
	}

	//public function initStates(?xml: Fast, ?timelines: Map<String, Timeline>):Void
	public function initStates(? dbd : Null<WidgetContainerData>, ? timelines: Map<String, Timeline>):Void
	{
		if (dbd != null) {

			tmpdata = dbd;
		}
		if (tmpdata != null) {

			switch (tmpdata.type) {

				case DefaultButton(_, _, _, _, _, st, stElts):
// : Array<{ timeline : Null<String>, name : String, enabled : Bool }> 
// : haxe.ds.StringMap<haxe.ds.StringMap<grar.view.ElementData>>

					for (se in stElts.keys()) {

						states.set(se, createStates(stElts.get(se)));
					}
					for (s in st) {

						if (timelines != null && s.timeline != null) {

							this.timelines.set(s.name, timelines.get(s.timeline));
						}
						if (s.enabled) {

							enabledState.set(s.name, s.enabled);
						}
					}

				default: throw "Wrong WidgetContainerData type passed to DefaultButton.initStates()";
			}
			tmpdata = null;
		}
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


	///
	// INTERNALS
	//

	//private inline function createStates(node:Fast):Map<String, Widget>
	private inline function createStates(sm : StringMap<ElementData>) : Map<String, Widget> {

		var list = new Map<String, Widget>();

		for (sk in sm.keys()) {

			var w : Widget = createElement(sm.get(sk));

			list.set(w.ref, w);
		}

		return list;
	}

	// Private

	private function onClick(event : MouseEvent) : Void {

		var timelineOut = timeline;

		if (isToggleEnabled) {

			toggle(toggleState != "active");
//			dispatchEvent(new ButtonActionEvent(ButtonActionEvent.TOGGLE));
			onToggle();
		}
		if (timelineOut != null) {

			//timelineOut.addEventListener(Event.COMPLETE,function(e){
			timelineOut.onTimelineEnded = function(){

					buttonAction(this);

				}

			timelineOut.play();

		} else {

			buttonAction(this);
		}
	}

	private inline function onOver(event : MouseEvent) : Void {

		renderState("over");
	}

	private inline function onOut(event : MouseEvent) : Void {

		renderState("out");
	}

	private inline function onClickDown(event : MouseEvent) : Void {

		renderState("press");
	}

	private inline function onClickUp(event : MouseEvent) : Void {

		renderState("out");
	}

	private inline function sortDisplayObjects(x : Widget, y : Widget) : Int {

		if(x.zz < y.zz)
			return -1;
		else if(x.zz > y.zz)
			return 1;
		else
			return 0;
	}

	private inline function removeAllEventsListeners(listener : MouseEvent -> Void) : Void {

		removeEventListener(MouseEvent.MOUSE_OUT, listener);
		removeEventListener(MouseEvent.MOUSE_OVER, listener);
		removeEventListener(MouseEvent.ROLL_OVER, listener);
		removeEventListener(MouseEvent.ROLL_OUT, listener);
		removeEventListener(MouseEvent.CLICK, listener);
		removeEventListener(MouseEvent.DOUBLE_CLICK, listener);
		removeEventListener(MouseEvent.MOUSE_UP, listener);
		removeEventListener(MouseEvent.MOUSE_DOWN, listener);
	}

	override private function createButton(d : WidgetContainerData) : Widget {

		mouseChildren = true;
		removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);

		return super.createButton(d);
	}

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

	override private inline function addElement(elem : Widget) : Void {

//		elem.zz = zIndex;
//		zIndex++;
	}
}