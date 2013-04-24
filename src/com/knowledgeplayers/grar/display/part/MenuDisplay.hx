package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.structure.part.PartElement;
import nme.display.Shape;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.display.component.button.MenuButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.event.ButtonActionEvent;
import com.knowledgeplayers.grar.display.layout.Zone;
import com.knowledgeplayers.grar.factory.UiFactory;
import nme.events.Event;
import nme.filters.DropShadowFilter;
import com.knowledgeplayers.grar.display.component.button.AnimationButton;
import com.knowledgeplayers.grar.display.component.button.CustomEventButton;
import com.knowledgeplayers.grar.display.component.button.TextButton;
import haxe.FastList;
import com.knowledgeplayers.grar.structure.activity.Activity;
import nme.Lib;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.factory.UiFactory;
import aze.display.TileLayer;
import com.knowledgeplayers.grar.display.component.button.DefaultButton;
import haxe.xml.Fast;
import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.display.Sprite;
import nme.events.MouseEvent;

/**
 * Display of a menu
 */

class MenuDisplay extends Zone {
	/**
    * Orientation of the menu. Must be Horizontal or Vertical
    **/
	public var orientation (default, setOrientation):String;

	/**
    * transition open menu
    **/
	public var transitionIn:String;
	/**
    * transition close menu
    **/
	public var transitionOut:String;

	private var levelDisplays:Hash<Fast>;
	private var xOffset:Float = 0;
	private var yOffset:Float = 0;
	private var yBase:Float = 0;
	private var xBase:Float = 0;

	public function new(_width:Float, _height:Float)
	{
		super(_width, _height);
	}

	/**
    * @:setter for orientation
    * @param    orientation : The orientation set
    * @return the orientation
    **/

	public function setOrientation(orientation:String):String
	{
		this.orientation = orientation.toLowerCase();
		return this.orientation;
	}

	override public function onActionEvent(e:Event):Void
	{
		switch(e.type){
			case "close_menu": TweenManager.applyTransition(this, transitionOut);
		}

	}

	/**
    * Init the menu with an XML descriptor
    * @param    xml : XML descriptor
    **/

	public function initMenu(display:Fast):Void
	{
		orientation = display.att.orientation;

		levelDisplays = new Hash<Fast>();
		var regEx = ~/h[0-9]+|hr|item/i;
		for(child in display.elements){
			if(regEx.match(child.name))
				levelDisplays.set(child.name, child);
		}

		for(child in display.elements){
			switch(child.name.toLowerCase()){
				case "background":createBackground(child);
				case "image": createImage(child);
				case "text":createText(child);
				case "button":createButton(child);
			}
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
			// Lib.trace("createMenu : "+elem);
		}
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
		var button:DefaultButton = null;
		button = UiFactory.createButtonFromXml(fast);

		if(Std.is(button, TextButton))
			cast(button, TextButton).setText(text);
		if(Std.is(button, MenuButton)){
			cast(button, MenuButton).alignElements();
			cast(button, MenuButton).menuD = this;
			cast(button, MenuButton).transitionOut = transitionOut;
		}

		button.name = text;

		return button;
	}
}