package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.layout.Zone;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import haxe.xml.Fast;
import nme.display.Shape;
import nme.events.Event;

/**
 * Display of a menu
 */

class MenuDisplay extends Zone {
	/**
    * Orientation of the menu. Must be Horizontal or Vertical
    **/
	public var orientation (default, set_orientation):String;

	private var levelDisplays:Map<String, Fast>;
	private var xOffset:Float = 0;
	private var yOffset:Float = 0;

	// grid origin for elements in the menu (buttons)
	private var yBase:Float = 0;
	private var xBase:Float = 0;

	private var buttons:Map<String, DefaultButton>;

	public function new(_width:Float, _height:Float)
	{
		super(_width, _height);
		buttons = new Map<String, DefaultButton>();
		GameManager.instance.addEventListener(PartEvent.EXIT_PART, onFinishPart);
		// = UiFactory.tilesheet;
	}

	/**
    * @:setter for orientation
    * @param    orientation : The orientation set
    * @return the orientation
    **/

	public function set_orientation(orientation:String):String
	{
		this.orientation = orientation.toLowerCase();
		return this.orientation;
	}

    override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		switch(action){
			case "close_menu": button.buttonAction = closeMenu;
		}

	}

    private function closeMenu(?_target:DefaultButton):Void{
        TweenManager.applyTransition(this, transitionOut);
    }

	/**
    * Init the menu with an XML descriptor
    * @param    xml : XML descriptor
    **/

	public function initMenu(display:Fast):Void
	{
		orientation = display.att.orientation;

		levelDisplays = new Map<String, Fast>();
		var regEx = ~/h[0-9]+|hr|item/i;
		for(child in display.elements){
			if(regEx.match(child.name))
				levelDisplays.set(child.name, child);
		}

		for(child in display.elements){
			createElement(child);
		}
		if(display.has.xBase)
			xBase = Std.parseFloat(display.att.xBase);
		if(display.has.yBase)
			yBase = Std.parseFloat(display.att.yBase);

		var menuXml = GameManager.instance.game.menu;

		xOffset += xBase;
		yOffset += yBase;

		for(elem in menuXml.firstElement().elements()){
			createMenuLevel(elem);
		}

		GameManager.instance.menuLoaded = true;
	}

	// Private

	private function createMenuLevel(level:Xml):Void
	{
		if(!levelDisplays.exists(level.nodeName))
			throw "Display not specified for tag " + level.nodeName;

		var fast:Fast = levelDisplays.get(level.nodeName);

		if(level.nodeName == "hr"){
			addLine(fast);
		}
		else{
			var button = addButton(fast.node.Button, GameManager.instance.getItemName(level.get("id")));
			buttons.set(level.get("id"), button);

			button.x += xOffset;
			button.y += yOffset;
			addChild(button);
			if(orientation == "vertical"){
				yOffset += button.height;
			}
			else{
				xOffset += button.width + Std.parseFloat(fast.att.width);
			}
		}
		for(elem in level.elements())
			createMenuLevel(elem);
	}

	private function addLine(fast:Fast):Void
	{
		var line = new Shape();
		line.graphics.lineStyle(Std.parseFloat(fast.att.thickness), Std.parseInt(fast.att.color), Std.parseFloat(fast.att.alpha));
		var originCoord:Array<String> = fast.att.origin.split(';');
		var origin = {x: Std.parseFloat(originCoord[0]), y: Std.parseFloat(originCoord[1])};
		line.graphics.moveTo(origin.x, origin.y);
		var destCoord = fast.att.destination.split(";");
		var dest = {x: Std.parseFloat(destCoord[0]), y: Std.parseFloat(destCoord[1])};
		line.graphics.lineTo(dest.x, dest.y);

		line.x = Std.parseFloat(fast.att.x);
		line.y = Std.parseFloat(fast.att.y) + yOffset;

		addChild(line);

	}

	private function addButton(fast:Fast, text:String):DefaultButton
	{
		var button:DefaultButton = new DefaultButton(fast);

		button.setText(text);
		button.buttonAction = onClick;
		button.transitionOut = transitionOut;

		button.name = text;

		return button;
	}

	private function onClick(?_target:DefaultButton):Void
	{
		var target = _target;
		for(key in buttons.keys()){
			if(buttons.get(key) == target)
				GameManager.instance.displayPartById(key, true);
		}

		TweenManager.applyTransition(this, transitionOut);
	}

	private function onFinishPart(e:PartEvent):Void
	{
		var button:DefaultButton = buttons.get(e.partId);
		button.setToggle(false);
	}
}
