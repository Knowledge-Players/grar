package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.display.activity.ActivityDisplay;
import com.knowledgeplayers.grar.display.activity.quizz.QuizzDisplay;
import com.knowledgeplayers.grar.display.part.DialogDisplay;
import com.knowledgeplayers.grar.display.part.PartDisplay;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class DisplayFactory 
{

	private function new() 
	{
	}
	
	public static function createPartDisplay(part: Part) : Null<PartDisplay>
	{
		if (part == null)
			return null;
		var creation: PartDisplay = null;
		if (part.isDialog()) {
			creation = new DialogDisplay(cast(part, DialogPart));
		}
		else {
			creation = new PartDisplay(part);
		}
		
		return creation;
	}
}