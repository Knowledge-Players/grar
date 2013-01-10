package com.knowledgeplayers.grar.display.part;

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.structure.Game;
import com.knowledgeplayers.grar.structure.part.Part;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.Lib;

/**
 * ...
 * @author jbrichardet
 */

class MenuDisplay extends Sprite
{
	private var parts: Array<Part>;
	
	public function new(game: Game) 
	{
		super();
		addChild(KpTextDownParser.parse("Bienvenu dans le menu"));
		
		var yOffset: Float = getChildAt(0).height;
		parts = game.getAllParts();
		for (part in parts) {
			var sprite = KpTextDownParser.parse(part.name);
			sprite.name = part.name;
			sprite.buttonMode = true;
			sprite.y = yOffset;
			yOffset += sprite.height;
			sprite.addEventListener(MouseEvent.CLICK, onPartClick);
			var status = KpTextDownParser.parse(": "+(part.isDone?"fini":"pas fini"));
			status.x = 100;
			sprite.addChild(status);
			addChild(sprite);
		}
		
	}
	
	private function onPartClick(e: MouseEvent) : Void 
	{
		var target = cast(e.target, Sprite).parent;
		for (part in parts) {
			Lib.trace("target name: " + target.name + " part name: " + part.name);
			if (part.name == target.name){
				launchPart(part);
				break;
			}
		}
	}
	
	dynamic public function launchPart(part: Part){}
	
}