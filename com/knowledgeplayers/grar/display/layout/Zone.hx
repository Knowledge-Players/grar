package com.knowledgeplayers.grar.display.layout;

import com.knowledgeplayers.grar.util.ParseUtils;
import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.display.contextual.menu.MenuSphericalDisplay;
import com.knowledgeplayers.grar.display.component.container.DropdownMenu;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.display.component.Image;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.component.ProgressBar;
import com.knowledgeplayers.grar.display.contextual.menu.MenuDisplay;
import com.knowledgeplayers.grar.event.LayoutEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;
import haxe.xml.Fast;
import flash.display.Sprite;
import flash.events.Event;

/**
* Graphic zone in the layout
* //TODO extends WidgetContainer
**/
class Zone extends KpDisplay {

	/**
	* Reference
	**/
	public var ref:String;

	private var zoneWidth:Float;
	private var zoneHeight:Float;
	private var layer:TileLayer;
	private var soundState:Bool = true;
	private var menuXml:Fast;
	private var fastnav: DropdownMenu;

	public function new(_width:Float, _height:Float):Void
	{
		super();

		zoneWidth = _width;
		zoneHeight = _height;
		GameManager.instance.game.addEventListener(PartEvent.PART_LOADED, onGameLoaded);
	}

	public function init(_zone:Fast):Void
	{
		if(_zone.has.bgColor)
			DisplayUtils.initSprite(this, zoneWidth, zoneHeight, Std.parseInt(_zone.att.bgColor));
		else
			DisplayUtils.initSprite(this, zoneWidth, zoneHeight);
		if(_zone.has.ref){
			layer = new TileLayer(UiFactory.tilesheet);

			ref = _zone.att.ref;
			dispatchEvent(new LayoutEvent(LayoutEvent.NEW_ZONE, ref, this));
			addChild(layer.view);
			for(element in _zone.elements){
				createElement(element);
			}

			layer.render();

		}
		else if(_zone.has.rows){
			var heights = initSize(_zone.att.rows, zoneHeight);
			var yOffset:Float = 0;
			var i = 0;
			for(row in _zone.nodes.Row){
				var zone = new Zone(zoneWidth, heights[i]);
				zone.x = 0;
				zone.y = yOffset;
				zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
				zone.init(row);
				yOffset += zone.zoneHeight;
				addChild(zone);
				i++;
			}
		}
		else if(_zone.has.columns){
			var widths = initSize(_zone.att.columns, zoneWidth);
			var xOffset:Float = 0;
			var j = 0;
			for(column in _zone.nodes.Column){
				var zone = new Zone(widths[j], zoneHeight);
				zone.x = xOffset;
				zone.y = 0;
				zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
				zone.init(column);
				xOffset += zone.zoneWidth;
				addChild(zone);
				j++;
			}
		}
		else{
			trace("[Zone] This zone is empty. Are you sure your XML is correct ?");
		}
	}

	private function createProgressBar(element:Fast):ProgressBar
	{
		var progress = new ProgressBar();
		progress.init(element);
		addChild(progress);

		return progress;
	}

	public function createMenu(element:Fast):Void
	{
		if(element.att.type == "spheric")
			MenuSphericalDisplay.instance.parseContent(element.x);
		else
			MenuDisplay.instance.parseContent(element.x);
		menuXml = element;
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		button.buttonAction = switch(action){
			case "open_menu": showMenu;
			case "open_inventory":  function(?target: DefaultButton){
				GameManager.instance.displayContextual(NotebookDisplay.instance, NotebookDisplay.instance.layout);
			};
			case "sound_toggle": activeSound;
			default: null;
		}
	}

    private function showMenu(?_target:DefaultButton):Void{
        GameManager.instance.displayContextual(MenuDisplay.instance, MenuDisplay.instance.layout);
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

	override private function createElement(elemNode:Fast):Widget
	{
		var elem = super.createElement(elemNode);
		switch(elemNode.name.toLowerCase()){
			case "menu":createMenu(elemNode);
			case "progressbar": createProgressBar(elemNode);
			case "fastnav":	fastnav = new DropdownMenu(elemNode, true);
		}

		for(widget in displays){
			layer.render();
			addChild(widget);
		}
		return elem;
	}

	// TODO is this still useful ?
	override private function createImage(itemNode:Fast):Widget
	{
		var spritesheet = itemNode.has.spritesheet ? itemNode.att.spritesheet:"ui";
		var img: Widget;

		if(itemNode.has.src || itemNode.has.filters || (itemNode.has.extract && itemNode.att.extract == "true")){
			img = new Image(itemNode, spritesheets.get(spritesheet));
			addElement(img, itemNode);
			return img;
		}
		else{
			if(!layers.exists(spritesheet)){
				var layer = new TileLayer(UiFactory.tilesheet);
				layers.set(spritesheet, layer);
				addChild(layers.get(spritesheet).view);
			}
			var tile = new TileImage(itemNode, layers.get(spritesheet));
			addElement(tile, itemNode);
			return tile;
		}
	}

	// Handlers

	private function onNewZone(e:LayoutEvent):Void
	{
		dispatchEvent(e);
	}

	private function onGameLoaded(e:PartEvent):Void
	{
		if(fastnav != null){
			for(item in GameManager.instance.game.getAllItems()){
				fastnav.addItem(item.name);
			}
			addChild(fastnav);
			fastnav.addEventListener(Event.CHANGE, onFastNav);
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
	}
}