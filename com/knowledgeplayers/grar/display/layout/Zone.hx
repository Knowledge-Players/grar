package com.knowledgeplayers.grar.display.layout;

import com.knowledgeplayers.grar.display.component.Widget;
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
			trace(Localiser.instance.currentLocale);
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

	private function createProgressBar(element:Fast):ProgressBar
	{
		var progress = new ProgressBar();
		progress.init(element);
		addChild(progress);

		return progress;
	}

	public function createMenu(element:Fast):Void
	{
		//GameManager.instance.menuLoaded = false;
		menu = new MenuDisplay(Std.parseFloat(element.att.width), Std.parseFloat(element.att.height));
		menuXml = element;
		menu.transitionIn = element.att.transitionIn;
		menu.transitionOut = element.att.transitionOut;
		menu.x = Std.parseFloat(element.att.x);
		menu.y = Std.parseFloat(element.att.y);

		addChild(menu);
	}

	override private function setButtonAction(button:DefaultButton, action:String):Void
	{
		switch(action){
			case "open_menu": button.buttonAction= showMenu;


			case "sound_toggle": button.buttonAction=activeSound;
		}
	}

    private function showMenu(?_target:DefaultButton):Void{
        TweenManager.applyTransition(menu, menu.transitionIn);
    }

	private function activeSound(?_target:DefaultButton):Void
	{

		if(soundState){
			GameManager.instance.changeVolume(0);
			soundState = false;
			if(_target != null) _target.setToggle(false);
		}
		else{
			GameManager.instance.changeVolume(1);
			soundState = true;
			if(_target != null) _target.setToggle(true);
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

	/*override private function createText(textNode:Fast):Void
	{
		var text = new ScrollPanel(textNode);
		text.setContent(Localiser.instance.getItemContent(textNode.att.content));
		addElement(text, textNode);
	}*/
    //TODO creation de background du menu (en attendant de le mettre au bon endroit ) kévin

    public function createSpriteFormXml(xml:Fast):Widget
    {
        var background = new Widget();

        var color:Int;

        var _alpha = xml.has.alpha ? Std.parseFloat(xml.att.alpha) : 1;

        if(xml.has.color)
            color = Std.parseInt(xml.att.color);
        else
            color = Std.parseInt("0xFFFFFF");
        background.graphics.beginFill(color, _alpha);
        background.graphics.drawRect(Std.parseFloat(xml.att.x), Std.parseFloat(xml.att.y), Std.parseFloat(xml.att.width), Std.parseFloat(xml.att.height));
        background.graphics.endFill();

        return background;
    }

	override private function createImage(itemNode:Fast):Void
	{
		 if(itemNode.has.src || itemNode.has.filters){
			addElement(new Image(itemNode, layer.tilesheet), itemNode);
		}
		else if(itemNode.has.color){
             var bkg = createSpriteFormXml(itemNode);

             addElement(bkg,itemNode);

         }else{
			var tile = new TileImage(itemNode, layer);
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