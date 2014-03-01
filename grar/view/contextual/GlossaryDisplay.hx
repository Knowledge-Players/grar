package grar.view.contextual;

import grar.parser.style.KpTextDownParser;

import grar.view.style.Style;
import grar.view.text.StyledTextField;

import grar.model.contextual.Glossary;

import flash.display.Sprite;

/**
 * Display for a glossary
 */
class GlossaryDisplay extends Sprite /* implements ContextualDisplay */ {

	public var layout (default, default) : String;

	private var style : Style;
	private var xOffset : Float = 10;

	var glossary : Glossary;

	public function new(glossary : Glossary, ? wordStyle : Style)
	{
		super();

		this.glossary = glossary;
		this.style = wordStyle;

		displayGlossary();
	}

	// Private

	private function displayGlossary():Void
	{
		var lastLetter:String = " ";
		var yOffset:Float = 0;

		for (word in glossary.words) {

			var def = glossary.getDefinition(word);
			
			if (word.charAt(0) > lastLetter) {

				lastLetter = word.charAt(0);
				var letter = new StyledTextField(style);
				letter.text = word.charAt(0).toUpperCase();
				letter.y = yOffset;
				addChild(letter);
				yOffset += letter.height;
			}
			var wordTf = new StyledTextField(style);
			wordTf.text = word + " : ";
			wordTf.x = xOffset;
			wordTf.y = yOffset;
			addChild(wordTf);
			var defKPTD = KpTextDownParser.parse(def);
			var defSprite = defKPTD[0].createSprite(width);
			defSprite.x = wordTf.x + wordTf.width;
			defSprite.y = wordTf.y + (wordTf.height - defSprite.height);
			addChild(defSprite);
			yOffset += wordTf.height;
		}
	}

}