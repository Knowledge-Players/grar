package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.part.dialog.pattern.Pattern;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.CollectPattern;
import com.knowledgeplayers.grar.structure.part.dialog.pattern.ActivityPattern;

import nme.Lib;
import haxe.xml.Fast;

/**
 * ...
 * @author jbrichardet
 */

class PatternFactory 
{
	
	private function new() 
	{
		
	}
	
	public static function createPattern(patternType: String, patternName: String) : Null<Pattern> 
	{
		var creation: Pattern = null;
		switch(patternType.toLowerCase()) {
			case "link": creation = new Pattern(patternName);
			case "collect": creation = new CollectPattern(patternName);
			case "activity": creation = new ActivityPattern(patternName);
			default: Lib.trace(patternType + ": Unsupported pattern type");
		}
		
		return creation;
	}
	
	public static function createPatternFromXml(xml: Fast, patternName: String) : Null<Pattern> 
	{
		return createPattern(xml.att.Type, patternName);
	}
}