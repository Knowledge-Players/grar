package grar.view.part;

import grar.view.part.PartDisplay;

import grar.model.part.Part;
import grar.model.part.item.Item;
import grar.model.part.strip.BoxPattern;
/**
 * Display for the strip parts, like a comic
 */
class StripDisplay extends PartDisplay {

	public function new(callbacks) {

		super(callbacks);

		//boxes = new StringMap();
	}

	private var currentBox : BoxPattern;
	private var currentBoxItem : Item;


	///
	// API
	//

	/*override public function next():Void
	{
		if(Lambda.count(currentBox.buttons) == 0)
			startPattern(currentBox);
		else
			exitPart();
	}*/


	///
	// INTERNALS
	//

	/*private function onBoxVisible():Void
	{
		if(Lambda.count(currentBox.buttons) == 0 && currentBox.nextPattern != ""){
			currentBox.restart();
			goToPattern(currentBox.nextPattern);
		}
	}*/
}