package grar.view.layout;

import aze.display.TileLayer;

import grar.view.contextual.NotebookDisplay;
import grar.view.component.container.DropdownMenu;
import grar.view.component.Widget;
import grar.view.component.container.DefaultButton;
import grar.view.component.ProgressBar;
import grar.view.contextual.menu.MenuDisplay;
import grar.view.Display;

import com.knowledgeplayers.grar.event.LayoutEvent;
import com.knowledgeplayers.grar.event.PartEvent;

import com.knowledgeplayers.grar.factory.UiFactory;

import grar.util.DisplayUtils;

import flash.display.Sprite;
import flash.ui.Keyboard;
import flash.events.KeyboardEvent;
import flash.events.Event;
import flash.Lib;

/**
 * Graphic zone in the layout
 **/
class Zone extends Display {

	//public function new(_width:Float, _height:Float):Void
	public function new(_width:Float, _height:Float) : Void {

		super();

		zoneWidth = _width;
		zoneHeight = _height;
		// FIXME GameManager.instance.game.addEventListener(PartEvent.PART_LOADED, onGameLoaded);
	}

	/**
	 * Reference
	 **/
	public var ref : String;
	public var fastnav (default,null) : DropdownMenu;

	private var zoneWidth : Float;
	private var zoneHeight : Float;
//	private var layer:TileLayer;
	private var soundState : Bool = true;

// FIXME	private var menuXml : Fast;

	
	///
	// API
	//

	//public function init(_zone:Fast) : Void
	public function init(d : DisplayData) : Void {

		switch (d.type) {

			case Zone(? bgColor : Null<Int>, ? ref : Null<String>, ? rows : Null<String>, ? columns : Null<String>, ? zones : Null<Array<DisplayData>>):

				if (bgColor != null) {

					DisplayUtils.initSprite(this, zoneWidth, zoneHeight, bgColor);
				
				} else {

					DisplayUtils.initSprite(this, zoneWidth, zoneHeight);
				}
				if (ref != null) {

// FIXME					layers.set("ui", new TileLayer(UiFactory.tilesheet));

// FIXME					dispatchEvent(new LayoutEvent(LayoutEvent.NEW_ZONE, ref, this));

// FIXME					addChild(layers.get("ui").view);

					for (e in d.displays.keys) {

						createElement(d.displays.get(e), e);
					}
				
				} else if(rows != null) {

					var heights = initSize(rows, zoneHeight);
					var yOffset : Float = 0;
					var i = 0;
					
					for (row in zones) {

						var zone = new Zone(zoneWidth, heights[i]);
						zone.x = 0;
						zone.y = yOffset;
// FIXME						zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
						zone.init(row);
						yOffset += zone.zoneHeight;
						addChild(zone);
						i++;
					}
				
				} else if (columns != null) {

					var widths = initSize(columns, zoneWidth);
					var xOffset : Float = 0;
					var j = 0;

					for (column in zones) {

						var zone = new Zone(widths[j], zoneHeight);
						zone.x = xOffset;
						zone.y = 0;
// FIXME						zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
						zone.init(column);
						xOffset += zone.zoneWidth;
						addChild(zone);
						j++;
					}
				}

				// Listeners on menu state
				if (buttonGroups.exists(groupMenu)) {

// FIXME				    MenuDisplay.instance.addEventListener(PartEvent.ENTER_PART, enterMenu);
				}
				if (buttonGroups.exists(groupNotebook)) {

// FIXME					NotebookDisplay.instance.addEventListener(PartEvent.EXIT_PART, exitNotebook);
// FIXME					NotebookDisplay.instance.addEventListener(PartEvent.ENTER_PART, enterNotebook);
				}
		}
	}

// FIXME	public function createMenu(element:Fast):Void
// FIXME	{

// FIXME	    MenuDisplay.instance.parseContent(element.x);
// FIXME		menuXml = element;
// FIXME	}


	///
	// INTERNALS
	//

	private function exitNotebook(e:Event):Void
	{
		for(button in buttonGroups.get(groupNotebook))
			button.toggle(true);
	}

	private function enterNotebook(e:Event):Void
	{
		for(button in buttonGroups.get(groupNotebook))
			button.toggle(false);
	}

	private function exitMenu(e:Event):Void
	{
		for(button in buttonGroups.get(groupMenu))
			button.toggle(true);

		MenuDisplay.instance.removeEventListener(PartEvent.EXIT_PART, exitMenu);

		MenuDisplay.instance.addEventListener(PartEvent.ENTER_PART, enterMenu);
	}

	private function enterMenu(e:Event):Void
	{
		for(button in buttonGroups.get(groupMenu))
			button.toggle(false);

		MenuDisplay.instance.removeEventListener(PartEvent.ENTER_PART, enterMenu);

		MenuDisplay.instance.addEventListener(PartEvent.EXIT_PART, exitMenu);
	}

	override private function setButtonAction(button:DefaultButton, action:String):Bool
	{
		if(super.setButtonAction(button, action))
			return true;
		button.buttonAction = switch(action){
			case "sound_toggle": activeSound;
			default: null;
		}

		return button.buttonAction != null;
	}

	private function activeSound(?_target:DefaultButton):Void
	{
		if(soundState){
			GameManager.instance.changeVolume(0);
			soundState = false;
			if(_target != null) _target.toggle(false);
		}
		else{
			GameManager.instance.changeVolume(1);
			soundState = true;
			if(_target != null) _target.toggle(true);
		}
	}

	private function initSize(sizes:String, maxSize:Float):Array<Dynamic>
	{
		var sizeArray:Array<Dynamic> = sizes.split(",");
		var starPosition:Int = -1;
		for(i in 0...sizeArray.length){
			sizeArray[i] = StringTools.trim(sizeArray[i]);
			if(sizeArray[i].indexOf("%") > 0){
				sizeArray[i] = Std.parseFloat(sizeArray[i].substr(0, sizeArray[i].length - 1)) * maxSize / 100;
			}
			else if(sizeArray[i] == "*"){
				starPosition = i;
			}
		}
		for(size in sizeArray){
			if(size != "*")
				maxSize -= Std.parseFloat(size);
		}
		if(starPosition != -1)
			sizeArray[starPosition] = maxSize;

		return sizeArray;
	}
// FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
	//override private function createElement(elemNode:Fast):Widget
	private function createElement(e : ElementData, r : String) : Widget {

		var elem : Widget = super.createElement(e, r);

		switch (e) {

			case "menu": createMenu(elemNode);
			
			case "progressbar": createProgressBar(elemNode);
#if kpdebug
			case "fastnav":	fastnav = new DropdownMenu(elemNode, true);
#end
		}

		//layer.render();
		return elem;
	}

// FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
	override private function addElement(elem:Widget, node:Fast):Void
	{
		super.addElement(elem, node);
		addChild(elem);
	}

	// Handlers

	private function onNewZone(e:LayoutEvent):Void
	{
		dispatchEvent(e);
	}

	private function onGameLoaded(e:PartEvent =null):Void
	{

        if(fastnav != null){

			for(item in GameManager.instance.game.getAllItems()){
				fastnav.addItem(item.name);
			}

			fastnav.addEventListener(Event.CHANGE, onFastNav);
			fastnav.addEventListener(Event.ADDED_TO_STAGE, fastnav.onAdd);
			addChild(fastnav);
            fastnav.visible = false;
		}
	}

	private function onFastNav(e: Event):Void
	{
		var track = fastnav.currentLabel;
		var items = GameManager.instance.game.getAllItems();
		var i = 0;
		while(i < items.length && items[i].name != track)
			i++;
		if(i == items.length)
			throw '[Zone] There is no trackable item with the name "$track".';
		GameManager.instance.displayTrackable(items[i]);

        fastnav.visible = false;
	}
}