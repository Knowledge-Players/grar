package grar.view.element;


// TODO
//import grar.view.component.container.WidgetContainer;
//import com.knowledgeplayers.grar.display.component.Image;
//import com.knowledgeplayers.grar.display.component.container.ScrollPanel;
//import com.knowledgeplayers.grar.localisation.Localiser;

import haxe.Timer;
import haxe.xml.Fast;

/**
 * Graphic representation of a token of the game
 */
class TokenNotification { // TODO extends WidgetContainer {

	/**
     * Time (in ms) before the notification disappear
     **/
	public var duration (default, default) : Int;

	public function new(d : Int) : Void {

		// TODO super(fast);
		duration = d;
	}

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