package grar.view.element;

import grar.view.component.container.WidgetContainer;
import grar.view.component.Image;
import grar.view.component.container.ScrollPanel;

import haxe.Timer;

/**
 * Graphic representation of a token of the game
 */
class TokenNotification extends WidgetContainer {

	//public function new(fast : Fast) : Void {
	public function new(callbacks : grar.view.DisplayCallbacks, applicationTilesheet : aze.display.TilesheetEx, tnd : WidgetContainerData) : Void {

		//super(fast);
		super(callbacks, applicationTilesheet, tnd);

		switch(tnd.type) {

			case TokenNotification(d):

				this.duration = d;

			default: throw "Wrong WidgetContainerData type passed to TokenNotification constructor";

		};
	}

	/**
     * Time (in ms) before the notification disappear
     **/
	public var duration (default, default) : Int;

	public function setToken(tokenName : String, tokenIcon : String) : Void {

		if (displaysRefs.exists("icon")) {

			cast(displaysRefs.get("icon"), grar.view.component.Image).setBmp(tokenIcon);
		}

//		cast(displaysRefs.get("name"), ScrollPanel).setContent(Localiser.instance.getItemContent(tokenName));
		cast(displaysRefs.get("name"), grar.view.component.container.ScrollPanel).setContent(onLocalizedContentRequest(tokenName));

//		cast(displaysRefs.get("title"), ScrollPanel).setContent(Localiser.instance.getItemContent("unlock"));
		cast(displaysRefs.get("title"), grar.view.component.container.ScrollPanel).setContent(onLocalizedContentRequest("unlock"));


		Timer.delay(hideNotification, duration);
	}

	public function hideNotification() : Void {
		// TODO
		//parent.removeChild(this);
	}
}