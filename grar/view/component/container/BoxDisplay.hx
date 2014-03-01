package grar.view.component.container;

import aze.display.TilesheetEx;

import grar.view.component.container.WidgetContainer;

import haxe.ds.StringMap;

/**
 * Box Widget for strip part
 **/
class BoxDisplay extends WidgetContainer {

	/**
	 * Text fields contained in the box
	 **/
	public var textFields (default, default) : StringMap<ScrollPanel>;

	public function new(callbacks : grar.view.DisplayCallbacks, bdd : WidgetContainerData) {

		textFields = new StringMap();

		super(callbacks, bdd);
	}

	//override private inline function createText(textNode : Fast) : Widget {
	override private function createText(d : WidgetContainerData) : ScrollPanel {

		d.applicationTilesheet = tilesheet;

		var text = new ScrollPanel(callbacks, d);
		addElement(text);
		textFields.set(text.ref, text);
		return text;
	}

	override private function addElement(elem : Widget) : Void {

		if (zIndex == 0) {

			zIndex++;
		}
		super.addElement(elem);
	}
}
