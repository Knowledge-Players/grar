package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.display.part.ActivityDisplay;
import com.knowledgeplayers.grar.display.part.DialogDisplay;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.display.part.StripDisplay;
import com.knowledgeplayers.grar.structure.part.Part;

/**
 * Factory to create displays
 */
class DisplayFactory {

	/**
     * Create a display for a part
     * @param	part : Part to display
     * @return the corresponding PartDisplay
     */
	public static function createPartDisplay(part:Part):Null<PartDisplay>
	{
		if(part == null)
			return null;
		part.restart();
		var creation:PartDisplay = null;
		if(part.isDialog())
			creation = new DialogDisplay(part);
		else if(part.isStrip())
			creation = new StripDisplay(part);
		else if(part.isActivity())
			creation = new ActivityDisplay(part);
		else
			creation = new PartDisplay(part);

		return creation;
	}
}