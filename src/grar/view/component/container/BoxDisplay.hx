package grar.view.component.container;

import grar.view.component.container.WidgetContainer;

import aze.display.TilesheetEx;

/**
 * Box Widget for strip part
 **/
class BoxDisplay extends WidgetContainer {

	/**
	 * Text fields contained in the box
	 **/
	public var textFields (default, default) : StringMap<ScrollPanel>;

	public function new(bdd : WidgetContainerData) {

		textFields = new StringMap();

		super(bdd);
	}
/* FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
	override private inline function createText(textNode:Fast):Widget
	{

		var text = new ScrollPanel(textNode);
		addElement(text);
		textFields.set(text.ref, text);
		return text;
	}

	override private function addElement(elem:Widget):Void
	{
		if(zIndex == 0)
			zIndex++;
		super.addElement(elem);
	}
*/
}
