package grar.service;

// FIXME import com.knowledgeplayers.grar.display.TweenManager;
import grar.view.part.DialogDisplay;
// FIXME import com.knowledgeplayers.grar.display.GameManager;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.Lib;

/**
 * The keyboard service is a listener service, ie: you init it once and it then synchronously 
 * bubbles events to your application.
 */
class KeyboardService {

	public static function init() : Void {

		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
	}


	///
	// INTERNALS
	//

	private static function keyDownHandler(e : KeyboardEvent) : Void {
#if kpdebug
		switch (e.keyCode) {

			case Keyboard.S: 

				// FIXME TweenManager.fastForwardDiscover();
			
			case Keyboard.RIGHT: 

				if (GameManager.instance.parts != null && !GameManager.instance.parts.isEmpty() && 
						!GameManager.instance.parts.first().introScreenOn) {
				
					var part = GameManager.instance.parts.first();
					
					if (Std.is(part, DialogDisplay) && 
							Lambda.count(cast(part, DialogDisplay).currentPattern.buttons) == 1) {

						part.next();
					
					} else if (!Std.is(part, DialogDisplay)) {

						part.next();
					}
				}
			
			case Keyboard.D: 

				for (part in GameManager.instance.game.getAllParts()) {

					GameManager.instance.finishPart(part.id);
				}

            case Keyboard.X:

				if (e.ctrlKey) {

					for (zone in  GameManager.instance.layout.zones) {

						if (zone.fastnav!=null) {

							trace(zone.fastnav.ref + " : "+zone.fastnav.visible);
							zone.fastnav.visible = !zone.fastnav.visible;

							//zone.fastnav.onAdd();
						}
					}
				}
		}
#end
	}

	private static function keyUpHandler(ev : KeyboardEvent) : Void { }
}