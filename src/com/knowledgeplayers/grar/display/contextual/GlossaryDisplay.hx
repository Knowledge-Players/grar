package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.Style;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.structure.contextual.Glossary;
import nme.display.Sprite;

/**
 * Display for a glossary
 */
class GlossaryDisplay extends Sprite
{

	private var style: Style;
	private var xOffset: Float = 10;
	
	public function new(?wordStyle: Style) 
	{
		super();
		style = wordStyle;
		displayGlossary();
	}
	
	// Private
	
	private function displayGlossary() : Void
	{
		var lastLetter: String = " ";
		var yOffset: Float = 0;
		for (word in Glossary.instance.getWords()) {
			var def = Glossary.instance.getDefinition(word);
			if (word.charAt(0) > lastLetter) {
				lastLetter = word.charAt(0);
				var letter = new StyledTextField(style);
				letter.text = word.charAt(0).toUpperCase();
				letter.y = yOffset;
				addChild(letter);
				yOffset += letter.height;
			}
			var wordTf = new StyledTextField(style);
			wordTf.text = word+" : ";
			wordTf.x = xOffset;
			wordTf.y = yOffset;
			addChild(wordTf);
			var defSprite = KpTextDownParser.parse(def);
			defSprite.x = wordTf.x + wordTf.width;
			defSprite.y = wordTf.y + (wordTf.height-defSprite.height);
			addChild(defSprite);
			yOffset += wordTf.height;
		}
	}
	
}