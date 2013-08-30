package com.knowledgeplayers.grar.structure.part.video;

import com.knowledgeplayers.grar.factory.PatternFactory;
import haxe.xml.Fast;
class VideoPart extends StructurePart
{

	public function new()
	{
		super();
	}

	override public function isVideo():Bool
	{
		return true;
	}

	// Private

	override private function parseContent(content:Xml):Void
	{
		var partFast:Fast = new Fast(content).node.Part;

		for(patternNode in partFast.nodes.Pattern){
			var pattern:Pattern = PatternFactory.createPatternFromXml(patternNode);
			pattern.init(patternNode);
			elements.push(pattern);
		}
		super.parseContent(content);
	}
}
