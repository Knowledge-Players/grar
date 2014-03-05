package grar.view.layout;

import aze.display.TileLayer;

import grar.view.component.container.WidgetContainer;
import grar.view.component.container.DropdownMenu;
import grar.view.component.container.DefaultButton;
import grar.view.component.Widget;
import grar.view.component.ProgressBar;
import grar.view.Display;

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
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, _width : Float, _height : Float) : Void {

		super(callbacks, applicationTilesheet);

		zoneWidth = _width;
		zoneHeight = _height;
	}

	public var ref : String;
	public var fastnav (default,null) : DropdownMenu;

	private var zoneWidth : Float;
	private var zoneHeight : Float;
//	private var layer:TileLayer;
	private var soundState : Bool = true;


	///
	// CALLBACKS
	//

	public dynamic function onNewProgressBar(pb : ProgressBar) { }

	public dynamic function onNewZone(ref : String, zone : Zone) { }

	public dynamic function onVolumeChangeRequest(v : Float) : Void { }

	
	///
	// API
	//

// GameManager.instance.game.addEventListener(PartEvent.PART_LOADED, onGameLoaded);
	public function setGameLoaded() : Void {

        if (fastnav != null) {
/* TODO
			for (item in GameManager.instance.game.getAllItems()) {

				fastnav.addItem(item.name);
			}
			fastnav.addEventListener(Event.CHANGE, onFastNav);
			fastnav.addEventListener(Event.ADDED_TO_STAGE, fastnav.onAdd);
			
			addChild(fastnav);
            
            fastnav.visible = false;
*/
		}
	}

	//public function init(_zone:Fast) : Void
	public function init(d : DisplayData) : Void {

		switch (d.type) {

			case Zone(bgColor, ref, rows, columns, zones):

				if (bgColor != null) {

					DisplayUtils.initSprite(this, zoneWidth, zoneHeight, bgColor);
				
				} else {

					DisplayUtils.initSprite(this, zoneWidth, zoneHeight);
				}
				if (ref != null) {

					layers.set("ui", new TileLayer(applicationTilesheet));
//					dispatchEvent(new LayoutEvent(LayoutEvent.NEW_ZONE, ref, this));
					onNewZone( ref, this );

					addChild(layers.get("ui").view);

					for (e in d.displays) {
//trace("CREATE ZONE ELT "+d.displays.get(e));
						createElement(e.ed, e.ref);
					}
				
				} else if(rows != null) {
//trace("FOUND ONE ZONE WITH ROWS");
					var heights = initSize(rows, zoneHeight);
					var yOffset : Float = 0;
					var i = 0;
					
					for (row in zones) {

						var zone = new Zone(callbacks, applicationTilesheet, zoneWidth, heights[i]);
						zone.x = 0;
						zone.y = yOffset;

// 						zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
						zone.onNewZone = onNewZone;

						zone.init(row);
						yOffset += zone.zoneHeight;
						addChild(zone);
						i++;
					}
				
				} else if (columns != null) {
//trace("FOUND ONE ZONE WITH COLUMNS");
					var widths = initSize(columns, zoneWidth);
					var xOffset : Float = 0;
					var j = 0;

					for (column in zones) {

						var zone = new Zone(callbacks, applicationTilesheet, widths[j], zoneHeight);
						zone.x = xOffset;
						zone.y = 0;

// 						zone.addEventListener(LayoutEvent.NEW_ZONE, onNewZone);
						zone.onNewZone = onNewZone;

						zone.init(column);
						xOffset += zone.zoneWidth;
						addChild(zone);
						j++;
					}
				}

			default: throw "Wrong DisplayData type passed to Zone.init()";
		}
	}

	public function setExitNotebook() : Void {

		if (buttonGroups.get(groupNotebook) != null) {

			for (button in buttonGroups.get(groupNotebook)) {

				button.toggle(true);
			}
		}
	}

	public function setEnterNotebook() : Void {

		if (buttonGroups.get(groupNotebook) != null) {

			for (button in buttonGroups.get(groupNotebook)) {

				button.toggle(false);
			}
		}
	}

	public function setExitMenu() : Void {

		if (buttonGroups.get(groupMenu) != null) {

			for (button in buttonGroups.get(groupMenu)) {

				button.toggle(true);
			}
		}
	}

	public function setEnterMenu() : Void {

		if (buttonGroups.get(groupMenu) != null) {

			for (button in buttonGroups.get(groupMenu)) {

				button.toggle(false);
			}
		}
	}


	///
	// INTERNALS
	//

	override private function setButtonAction(button:DefaultButton, action:String):Bool
	{
		if (super.setButtonAction(button, action)) {

			return true;
		}
		button.buttonAction = switch (action) {

				case "sound_toggle": activeSound;
				
				default: null;
			}

		return button.buttonAction != null;
	}

	private function activeSound(?_target:DefaultButton):Void
	{
		if (soundState) {

// 			GameManager.instance.changeVolume(0);
			onVolumeChangeRequest(0);

			soundState = false;
			if(_target != null) _target.toggle(false);
		}
		else{
// 			GameManager.instance.changeVolume(1);
			onVolumeChangeRequest(1);

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

	//override private function createElement(elemNode:Fast):Widget
	override private function createElement(e : ElementData, r : String) : Widget {

		var elem : Widget = super.createElement(e, r);

		switch (e) {

			case Menu(d):

				// createMenu(d); this is now done in Application
			
			case ProgressBar(d):

				createProgressBar(d);
#if kpdebug
			case DropdownMenu(d):

				d.applicationTilesheet = applicationTilesheet;

				fastnav = new DropdownMenu(callbacks, applicationTilesheet, d, true);
#end
			default: // nothing
		}
		//layer.render();
		switch (e) {

			case DefaultButton(d):
//trace("ZONE => just created a => "+elem);

			elem.addEventListener(Event.ADDED_TO_STAGE, function(e){
//trace("*********** DEFAULT BUTTON ADDED TO STAGE !!!");
				//this.toggleState = this.defaultState;

			});
			default:
		}
		return elem;
	}

//	private function createProgressBar(element : Fast) : ProgressBar {
	private function createProgressBar(d : WidgetContainerData) : ProgressBar {

		var progress = new ProgressBar(callbacks, applicationTilesheet, d);

		addChild(progress);

		onNewProgressBar(progress);

		return progress;
	}

	//override private function addElement(elem:Widget, node:Fast):Void
	override private function addElement(elem : Widget, ref : String) : Void {

		super.addElement(elem, ref);

		addChild(elem);
	}

	// Handlers

	private function onFastNav(e: Event):Void
	{
/* FIXME
		var track = fastnav.currentLabel;
		var items = GameManager.instance.game.getAllItems();
		var i = 0;
		while(i < items.length && items[i].name != track)
			i++;
		if(i == items.length)
			throw '[Zone] There is no trackable item with the name "$track".';
		GameManager.instance.displayTrackable(items[i]);

        fastnav.visible = false;
*/
	}
}