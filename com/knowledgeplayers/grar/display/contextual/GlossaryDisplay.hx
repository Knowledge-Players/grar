package com.knowledgeplayers.grar.display.contextual;

import com.knowledgeplayers.grar.display.style.KpTextDownParser;
import com.knowledgeplayers.grar.display.style.Style;
import com.knowledgeplayers.grar.display.text.StyledTextField;
import com.knowledgeplayers.grar.structure.contextual.Glossary;
import flash.display.Sprite;

/**
 * Display for a glossary
 */
class GlossaryDisplay extends Sprite implements ContextualDisplay{

	public static var instance (get_instance, null): GlossaryDisplay;

	public var layout (default, default):String;

	private var style:Style;
	private var xOffset:Float = 10;

	public static function get_instance():GlossaryDisplay
	{
		if(instance == null)
			instance = new GlossaryDisplay();
		return instance;
	}

	private function new(?wordStyle:Style)
	{
		super();
		style = wordStyle;
		displayGlossary();
	}

	// Private

	private function displayGlossary():Void
	{
		var lastLetter:String = " ";
		var yOffset:Float = 0;
		for(word in Glossary.instance.words){
			var def = Glossary.instance.getDefinition(word);
			if(word.charAt(0) > lastLetter){
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