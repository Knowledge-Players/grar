package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.display.component.Widget;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.contextual.ContextualDisplay;
import com.knowledgeplayers.grar.display.component.container.WidgetContainer;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.GameManager;
import com.knowledgeplayers.grar.display.layout.Zone;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import haxe.xml.Fast;
import flash.display.Shape;
import flash.events.Event;
import aze.display.TileLayer;
import aze.display.TileSprite;

/**
 * Display of a menu
 */

class MenuDisplay extends KpDisplay implements ContextualDisplay {

	public static var instance (get_instance, null) : MenuDisplay;
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

    public var exists(default,null):Bool=false;

	public static function get_instance():MenuDisplay
	{
		if(instance == null)
			instance = new MenuDisplay();
		return instance;
	}

	private function new()
	{
		super();
		buttons = new Map<String, DefaultButton>();
		GameManager.instance.addEventListener(PartEvent.EXIT_PART, onFinishPart);
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
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
    override public function parseContent(content:Xml):Void
    {
		// BAAAAAAAAAAHHH
        if(!Std.is(this, MenuSphericalDisplay) && content.firstElement().get("type") == "spheric"){
	        instance = MenuSphericalDisplay.instance;
	        instance.parseContent(content);
        }
	    else
            super.parseContent(content);

        exists = true;
    }

	public function init():Void
	{

		orientation = displayFast.att.orientation;

		levelDisplays = new Map<String, Fast>();
		var regEx = ~/h[0-9]+|hr|item/i;
		for(child in displayFast.elements){
			if(regEx.match(child.name))
				levelDisplays.set(child.name, child);
		}

		super.createDisplay();

		if(displayFast.has.xBase)
			xBase = Std.parseFloat(displayFast.att.xBase);
		if(displayFast.has.yBase)
			yBase = Std.parseFloat(displayFast.att.yBase);

		var menuXml = GameManager.instance.game.menu;

		xOffset += xBase;
		yOffset += yBase;



		Localiser.instance.pushLocale();
		Localiser.instance.layoutPath = LayoutManager.instance.interfaceLocale;

		var array = new Array<Widget>();
		for(key in displays.keys()){
			array.push(displays.get(key));
		}

		array.sort(sortDisplayObjects);
		for(obj in array)
			addChild(obj);
		addChild(layers.get("ui").view);

		for(elem in menuXml.firstElement().elements()){
			createMenuLevel(elem);
		}

		Localiser.instance.popLocale();

		GameManager.instance.menuLoaded = true;
	}

    private function closeMenu(?_target:DefaultButton):Void{
        GameManager.instance.hideContextual(MenuDisplay.instance);
    }


	// Private

	override private function createDisplay():Void
	{
	}

	private function createMenuLevel(level:Xml):Void
	{
		if(!levelDisplays.exists(level.nodeName))
			throw "Display not specified for tag " + level.nodeName;

		var fast:Fast = levelDisplays.get(level.nodeName);

		if(level.nodeName == "hr"){
			addLine(fast);
		}
		else{
			var partName = GameManager.instance.getItemName(level.get("id"));
			if(partName == null)
				throw "[MenuDisplay] Can't find a name for '"+level.get("id")+"'.";

			var button = addButton(fast.node.Button, partName);
			buttons.set(level.get("id"), button);
			for(part in GameManager.instance.game.getAllParts()){
				if(part.name == partName && part.isDone)
				  button.setToggle(false);
			}
			buttons.set(level.get("id"), button);

            button.x += xOffset;
            button.y += yOffset;
			if(orientation == "vertical"){
				yOffset += button.height+Std.parseFloat(fast.att.yOffset);
			}
			else if(fast.has.width){
				xOffset += xOffset+Std.parseFloat(fast.att.width);
			}
			else if(orientation == "horizontal")
			    xOffset += button.width+Std.parseFloat(fast.att.xOffset);



            addChild(button);
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

	// Handlers

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
		if(buttons.exists(e.partId))
			buttons.get(e.partId).setToggle(false);
	}

	private function onAdded(e:Event):Void
	{
		if (timelines.exists("in")){
			timelines.get("in").play();
		}
	}

	private function onRemove(e:Event):Void
	{
		for(elem in timelines.get("in").elements)
			elem.widget.reset();
	}
}
