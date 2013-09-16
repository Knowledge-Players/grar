package com.knowledgeplayers.grar.display.component.container;

import com.knowledgeplayers.grar.display.element.AnimationDisplay;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.factory.UiFactory;
import haxe.xml.Fast;
import nme.Lib;
import motion.Actuate;
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

	public var toggle (default, null):String = "active";

	private var currentState:String;

	private var clip:TileClip;
	private var isToggleEnabled: Bool = false;

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

		if(pStates != null)
			states = pStates;
		else
			states = new Map<String, Map<String, Widget>>();

		if(xml != null){
			if(xml.hasNode.active){
				for(state in xml.node.active.elements){
					if(states.exists("active_out") || state.name == "out"){
						states.set("active_" + state.name, createStates(state));
					}
				}
			}
			if(xml.hasNode.inactive){
				for(state in xml.node.inactive.elements){
					if(states.exists("inactive_out") || state.name == "out"){
						states.set("inactive_" + state.name, createStates(state));
					}
				}
			}

			if(xml.has.toggle)
				isToggleEnabled = xml.att.toggle == "true";
			if(xml.has.group)
				group = xml.att.group.toLowerCase();
		}

		mouseChildren = false;
		useHandCursor = buttonMode = true;

		init();
	}

	/**
     * Enable or disable the button
     * @param	activate : True to activate the button
     * @return true if the button is now activated
     */

	public function set_enabled(activate:Bool):Bool
	{
		enabled = buttonMode = mouseEnabled = activate;

		return activate;
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

	public function setToggle(toggle:Bool):Void
	{
		this.toggle = toggle ? "active" : "inactive";
		renderState("out");
	}

	/*public function enableToggle(enable:Bool = true):Void
	{
		if(enable){
			trace("toggle enabled");
			addEventListener(MouseEvent.CLICK, onToggle);
		}
		else{
			if(hasEventListener(MouseEvent.CLICK))
				removeEventListener(MouseEvent.CLICK, onToggle);
		}
	}*/

	// Abstract

	private function onMouseOver(event:MouseEvent):Void
	{

	}

	private function onMouseOut(event:MouseEvent):Void
	{}

	private function onClick(event:MouseEvent):Void
	{
		if(isToggleEnabled)
			onToggle();
		buttonAction(this);
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
		var list:Map<String, Widget>;
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

			if(background != null){
				var image = new Sprite();
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

	private function sortDisplayObjects(x:Widget, y:Widget):Int
	{
		if(x.zz < y.zz)
			return -1;
		else if(x.zz > y.zz)
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

	private function createStates(node:Fast):Map<String, Widget>
	{
		var list = new Map<String, Widget>();
		if(node.has.background){
			var bkg = new Image();
			if(node.att.background.length == 10)
				bkg.graphics.beginFill(Std.parseInt("0x"+node.att.background.substr(4)), Std.parseInt(node.att.background.substr(2, 4))/10);
			else
				bkg.graphics.beginFill(Std.parseInt(node.att.background));
			bkg.graphics.drawRect(0, 0, width, height);
			bkg.graphics.endFill();
			list.set("bkg", bkg);
		}
			//background = node.att.background;

		for(elem in node.elements){
			var widget = createElement(elem);
			list.set(widget.ref, widget);
		}
		return list;
	}

	// Listener

	private function onMouseEvent(event:MouseEvent):Void
	{

		event.stopImmediatePropagation();

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

	private inline function onToggle():Void
	{
		setToggle(toggle != "active");
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