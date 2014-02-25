package grar.view.element;

import grar.view.component.container.WidgetContainer;
import grar.view.component.Image;
import grar.view.component.container.ScrollPanel;
// FIXME import com.knowledgeplayers.grar.localisation.Localiser;

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

	public function setToken(tokenName : String) : Void {
/* TODO
		if (displays.exists("icon")) {

			cast(displays.get("icon"), Image).setBmp(GameManager.instance.inventory.get(tokenName).icon);
		}
		cast(displays.get("name"), ScrollPanel).setContent(Localiser.instance.getItemContent(GameManager.instance.inventory.get(tokenName).name));
		cast(displays.get("title"), ScrollPanel).setContent(Localiser.instance.getItemContent("unlock"));
		Timer.delay(hideNotification, duration);
*/
	}

	public function hideNotification() : Void {
		// TODO
		//parent.removeChild(this);
	}
}