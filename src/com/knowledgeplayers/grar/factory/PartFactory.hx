package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import nme.Lib;

import haxe.xml.Fast;

/**
 * ...
 * @author jbrichardet
 */

class PartFactory 
{

	private function new() 
	{
		
	}
	
	public static function createPart(partType: String) : Null<Part> 
	{
		var creation: Part = null;
		switch(partType.toLowerCase()) {
			case "dialog": creation = new DialogPart();
			// TODO : creer une partie map
			case "map": creation = new StructurePart();
			case "": creation = new StructurePart();
			default: Lib.trace(partType + ": Unsupported part type");
		}
		
		return creation;
	}
	
	public static function createPartFromXml(xml: Fast) : Null<Part> 
	{
		return createPart(xml.att.Type);
	}
}