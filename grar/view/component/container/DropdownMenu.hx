package grar.view.component.container;

import grar.view.Color;
import grar.view.style.KpTextDownElement;
import grar.view.component.container.WidgetContainer;

import grar.parser.style.KpTextDownParser;

import flash.geom.Point;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

/**
 * Drop down menu component
 */
class DropdownMenu extends WidgetContainer {

	//public function new( ? xml : Fast, blankItem = false) {
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, dmd : Null<WidgetContainerData> , blankItem = false) {

		super(callbacks, applicationTilesheet, dmd);

		blank = blankItem;
		buttonMode = true;
		items = new GenericStack<String>();
		sprites = new StringMap();
		list = new Sprite();
		labelSprite = new Sprite();
		list.visible = false;

		addEventListener(Event.ADDED_TO_STAGE, onAdd);
		addEventListener(MouseEvent.CLICK, onClick);

		if (dmd != null) {

	        this.color = switch(dmd.type){ case DropdownMenu(c): c; default: null; };
		}
	}

	public var items (default, default) : GenericStack<String>;
	public var currentLabel (default, set) : String;

	private var list : Sprite;
	private var labelSprite : Sprite;
	private var sprites : StringMap<Sprite>;
	private var blank : Bool;
	private var color : Color;

	/**
     * Add an item at the top of the menu
     * @param	item : Item to add
     */

	public function addItem(item:String):Void
	{
		items.add(item);
	}

	// Private

	private function set_currentLabel(label:String):String
	{
		currentLabel = label;
		
		if (labelSprite.numChildren > 0) {

			labelSprite.removeChildAt(0);
		}
		
		var kpTxt : KpTextDownElement = KpTextDownParser.parse(label)[0];
// FIXME		// kpTxt.styleSheet = ???
		kpTxt.tilesheet = tilesheet;

		labelSprite.addChild(kpTxt.createSprite(maskWidth));


		dispatchEvent(new Event(Event.CHANGE));
		return label;
	}

	public function onAdd(e:Event):Void
	{
		var yOffset:Float = 0;

		for (item in items) {

			if (item != null) {

				var kpTxt : KpTextDownElement = KpTextDownParser.parse(item)[0];
// FIXME				// kpTxt.styleSheet = ???
				kpTxt.tilesheet = tilesheet;

				var sprite = kpTxt.createSprite(maskWidth);
				sprite.buttonMode = true;
				sprite.y = yOffset;
				yOffset += sprite.height;
				sprite.addEventListener(MouseEvent.CLICK, onItemClick);
				list.addChild(sprite);
				sprites.set(item, sprite);
			}
		}
		if (localToGlobal(new Point(0, 0)).y+list.height > stage.stageHeight) {

			list.y = y - list.height;
		}

        list.visible = false;

		if (!blank) {

			set_currentLabel(items.first());
		
		} else {

			labelSprite.graphics.beginFill(color.color, color.alpha);
			labelSprite.graphics.drawRect(0, 0, list.getChildAt(0).width, list.getChildAt(0).height);
			labelSprite.graphics.endFill();
		}
		addChild(labelSprite);

		addChild(list);
	}

	private function onItemClick(e : MouseEvent) : Void {

		for (label in sprites.keys()) {

			if (e.currentTarget == sprites.get(label)) {

				set_currentLabel(label);
			}
		}
		list.visible = false;
		labelSprite.visible = true;
		e.stopImmediatePropagation();
		addEventListener(MouseEvent.CLICK, onClick);
	}

	private function onClick(e : MouseEvent) : Void {

		labelSprite.visible = false;
		list.visible = true;
		removeEventListener(MouseEvent.CLICK, onClick);
	}
}