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
	public function new(tnd : WidgetContainerData) : Void {

		//super(fast);
		super(tnd);

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

		if (displays.exists("icon")) {

			cast(displays.get("icon"), Image).setBmp(tokenIcon);
		}

//		cast(displays.get("name"), ScrollPanel).setContent(Localiser.instance.getItemContent(tokenName));
		cast(displays.get("name"), ScrollPanel).setContent(onLocalizedContentRequest(tokenName));

//		cast(displays.get("title"), ScrollPanel).setContent(Localiser.instance.getItemContent("unlock"));
		cast(displays.get("title"), ScrollPanel).setContent(onLocalizedContentRequest("unlock"));


		Timer.delay(hideNotification, duration);
	}

	public function hideNotification() : Void {
		// TODO
		//parent.removeChild(this);
	}
}