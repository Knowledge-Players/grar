package grar.view.contextual.menu;

import aze.display.TilesheetEx;

import grar.view.component.container.WidgetContainer;

class BookmarkDisplay extends WidgetContainer {

	//public function new( ? xml : Fast, ? tilesheet : TilesheetEx) {
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : TilesheetEx, 
							bdd : WidgetContainerData, ? tilesheet : TilesheetEx) {

		//super(xml, tilesheet);
		super(callbacks, applicationTilesheet, bdd, tilesheet);

		switch(bdd.type) {

			case BookmarkDisplay(a, xo, yo):

				if (a != null) {

					onComplete = function() {

// 							TweenManager.applyTransition(this, a);
							onTransitionRequest(this, a);
						}
				}
				this.xOffset = xo;
				this.yOffset = yo;

			default: // nothing
		}
	}

	private var xOffset : Float;
	private var yOffset : Float;

	public function updatePosition(x:Float, y:Float):Void
	{
		lockPosition = true;
		this.x = x + xOffset;
		this.y = y + yOffset;
	}
}