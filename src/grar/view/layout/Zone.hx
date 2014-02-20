package grar.view.layout;

import aze.display.TileLayer;

import com.knowledgeplayers.grar.display.contextual.NotebookDisplay;
import com.knowledgeplayers.grar.display.component.container.DropdownMenu;
import com.knowledgeplayers.grar.display.component.Widget;
import com.knowledgeplayers.grar.display.component.container.DefaultButton;
import com.knowledgeplayers.grar.display.component.ProgressBar;
import com.knowledgeplayers.grar.display.contextual.menu.MenuDisplay;
import grar.view.KpDisplay;
import com.knowledgeplayers.grar.event.LayoutEvent;
import com.knowledgeplayers.grar.event.PartEvent;
import com.knowledgeplayers.grar.factory.UiFactory;
import com.knowledgeplayers.grar.util.DisplayUtils;

import flash.ui.Keyboard;
import flash.Lib;
import flash.events.KeyboardEvent;
import flash.display.Sprite;
import flash.events.Event;

/**
 * Graphic zone in the layout
 **/
class Zone extends KpDisplay {

	public function new(kd : KpDisplayData, _width:Float, _height:Float) : Void {

		super(kd);

		zoneWidth = _width;
		zoneHeight = _height;
		// FIXME GameManager.instance.game.addEventListener(PartEvent.PART_LOADED, onGameLoaded);


		if (bgColor != null) {

			DisplayUtils.initSprite(this, zoneWidth, zoneHeight, bgColor);
		
		} else {
			
			DisplayUtils.initSprite(this, zoneWidth, zoneHeight);
		}
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
	private var menuXml : Fast;

	public function createMenu(element:Fast):Void
	{

	    MenuDisplay.instance.parseContent(element.x);
		menuXml = element;
	}

	// Private

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

	override private function createElement(elemNode:Fast):Widget
	{
		var elem = super.createElement(elemNode);
		switch(elemNode.name.toLowerCase()){
			case "menu": createMenu(elemNode);
			case "progressbar": createProgressBar(elemNode);
			#if kpdebug
			case "fastnav":	fastnav = new DropdownMenu(elemNode, true);
			#end
		}

		//layer.render();
		return elem;
	}


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