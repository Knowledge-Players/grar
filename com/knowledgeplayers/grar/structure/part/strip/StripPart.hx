package com.knowledgeplayers.grar.structure.part.strip;

import com.knowledgeplayers.grar.factory.PatternFactory;
import com.knowledgeplayers.grar.structure.part.StructurePart;
import haxe.xml.Fast;

class StripPart extends StructurePart {

	public function new()
	{
		super();
	}

	/**
    * @return true
**/

	override public function isStrip():Bool
	{
		return true;

	}
	// Private

	override private function parseElement(node: Fast):Void
	{
		super.parseElement(node);

		if(node.name.toLowerCase() == "pattern"){
			var pattern:Pattern = PatternFactory.createPatternFromXml(node);
			pattern.init(node);
			elements.push(pattern);
		}
	}

}