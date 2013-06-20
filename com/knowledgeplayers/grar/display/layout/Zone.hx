package com.knowledgeplayers.grar.display.layout;

import com.knowledgeplayers.grar.display.component.TileImage;
import com.knowledgeplayers.grar.display.component.Image;
import nme.events.MouseEvent;
import aze.display.TileLayer;
import aze.display.TileSprite;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
import com.knowledgeplayers.grar.display.component.ProgressBar;
import com.knowledgeplayers.grar.display.part.MenuDisplay;
import com.knowledgeplayers.grar.event.LayoutEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.localisation.Localiser;
import com.knowledgeplayers.grar.util.DisplayUtils;
import haxe.xml.Fast;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
* Graphic zone in the layout
* //TODO extends WidgetContainer
**/
class Zone extends KpDisplay {
	public var ref:String;

	private var zoneWidth:Float;
	private var zoneHeight:Float;
	private var menu:MenuDisplay;
	private var layer:TileLayer;
	private var soundState:Bool = true;
	private var menuXml:Fast;

	public function new(_width:Float, _height:Float):Void
	{
		super();

		zoneWidth = _width;
		zoneHeight = _height;
		GameManager.instance.game.addEventListener(PartEvent.PART_LOADED, onGameLoaded);
	}

	public function init(_zone:Fast):Void
	{

		if(_zone.has.text){
			Lib.trace(Localiser.instance.currentLocale);
		}
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
			Lib.trace("[Zone] This zone is empty. Are you sure your XML is correct ?");
		}
	}

	private function createHeader():Void
	{

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
		GameManager.instance.menuLoaded = false;
		menu = new MenuDisplay(Std.parseFloat(element.att.width), Std.parseFloat(element.att.height));
		menuXml = element;
		menu.transitionIn = element.att.transitionIn;
		menu.transitionOut = element.att.transitionOut;
		menu.x = Std.parseFloat(element.att.x);
		menu.y = Std.parseFloat(element.att.y);

		addChild(menu);
	}

	public function onActionEvent(e:Event):Void
	{
		switch(e.type){
			case "open_menu": TweenManager.applyTransition(menu, menu.transitionIn);
			case "sound_toggle": activeSound(e);
		}
	}

	private function activeSound(e:Event):Void
	{
		var button:DefaultButton = Std.is(e.target, DefaultButton) ? cast(e.target, DefaultButton) : null;
		if(soundState){
			GameManager.instance.changeVolume(0);
			soundState = false;
			if(button != null) button.setToggle(false);
		}
		else{
			GameManager.instance.changeVolume(1);
			soundState = true;
			if(button != null) button.setToggle(true);
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

	override private function createElement(elemNode:Fast):Void
	{
		super.createElement(elemNode);
		switch(elemNode.name.toLowerCase()){
			case "menu":createMenu(elemNode);
			case "progressbar": createProgressBar(elemNode);
		}

		for(widget in displays){
			addChild(widget);
		}
	}

	override private function createImage(itemNode:Fast):Void
	{
		if(itemNode.has.src || itemNode.has.filters){
			addElement(new Image(itemNode, layer.tilesheet), itemNode);
		}
		else{
			var tile = new TileImage(itemNode, layer);
			tile.tileSprite.x += tile.tileSprite.width/2;
			tile.tileSprite.y += tile.tileSprite.height/2;
			addElement(tile, itemNode);
		}
	}

	// Handlers

	private function onNewZone(e:LayoutEvent):Void
	{
		dispatchEvent(e);
	}

	private function onGameLoaded(e:PartEvent):Void
	{
		if(menu != null)
			menu.initMenu(menuXml);
	}
}