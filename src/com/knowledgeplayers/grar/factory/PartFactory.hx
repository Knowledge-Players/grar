package com.knowledgeplayers.grar.factory;

import com.knowledgeplayers.grar.structure.part.strip.StripPart;
import com.knowledgeplayers.grar.structure.part.Part;
import com.knowledgeplayers.grar.structure.part.dialog.DialogPart;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import nme.Lib;

import haxe.xml.Fast;

/**
 * Factory to create parts
 * @author jbrichardet
 */

class PartFactory 
{

	private function new() 
	{
		
	}
	
	/**
	 * Create a part
	 * @param	partType : Type of the part
	 * @return the part, or null if the type is not supported
	 */
	public static function createPart(partType: String) : Null<Part> 
	{
		var creation: Part = null;
		switch(partType.toLowerCase()) {
			case "dialog": creation = new DialogPart();
            case "strip" : creation = new StripPart();

			// TODO : creer une partie map
			case "map": creation = new StructurePart();

			case "": creation = new StructurePart();
			default: Lib.trace(partType + ": Unsupported part type");
		}
		
		return creation;
	}
	
	/**
	 * Create a part from XML infos
	 * @param	xml : Fast XML node with info
	 * @return the part, or null if the type is not supported
	 */
	public static function createPartFromXml(xml: Fast) : Null<Part> 
	{
		return createPart(xml.att.Type);
	}
}