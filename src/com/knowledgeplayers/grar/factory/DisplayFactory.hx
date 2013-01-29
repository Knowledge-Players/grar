package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.part.strip.StripPart;
import com.knowledgeplayers.grar.display.part.StripDisplay;
import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.quizz.QuizzDisplay;
import com.knowledgeplayers.grar.display.part.DialogDisplay;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.Lib;

/**
 * Factory to create displays
 * @author jbrichardet
 */

class DisplayFactory 
{

	private function new() 
	{
	}
	
	/**
	 * Create a display for a part
	 * @param	part : Part to display
	 * @return the corresponding PartDisplay
	 */
	public static function createPartDisplay(part: Part) : Null<PartDisplay>
	{
		if (part == null)
			return null;
		var creation: PartDisplay = null;
		if (part.isDialog()) {
			creation = new DialogDisplay(cast(part, DialogPart));
		}
        else if (part.isStrip()){
            creation = new StripDisplay(cast(part,StripPart));
        }
		else {
			creation = new PartDisplay(part);
		}
		
		return creation;
	}
}