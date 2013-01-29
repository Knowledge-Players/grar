package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.part.strip.box.Box;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.Pattern;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.CollectPattern;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.ActivityPattern;

import nme.Lib;
import haxe.xml.Fast;

/**
 * Factory to create dialog pattern
 * @author jbrichardet
 */
class PatternFactory 
{
	
	private function new() 
	{
		
	}
	
	/**
	 * Create a pattern
	 * @param	patternType : Type of the pattern
	 * @param	patternName : Name of the pattern
	 * @return the pattern or null if the type is not supported
	 */
	public static function createPattern(patternType: String, patternName: String) : Null<Pattern> 
	{
		var creation: Pattern = null;
		switch(patternType.toLowerCase()) {
			case "link": creation = new Pattern(patternName);
            case "box": creation  = new Box(patternName);
			case "collect": creation = new CollectPattern(patternName);
			case "activity": creation = new ActivityPattern(patternName);
			default: Lib.trace(patternType + ": Unsupported pattern type");
		}
		
		return creation;
	}
	
	/**
	 * Create a pattern from XML infos
	 * @param	xml : fast XML node with infos
	 * @param	patternName : Name of the pattern
	 * @return the pattern or null if the type is not supported
	 */
	public static function createPatternFromXml(xml: Fast, patternName: String) : Null<Pattern> 
	{
		return createPattern(xml.att.Type, patternName);
	}
}