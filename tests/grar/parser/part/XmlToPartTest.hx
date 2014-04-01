package grar.parser.part;

import grar.model.part.Part.PartType;
import utest.Assert;
import haxe.Resource;
class XmlToPartTest{

	public function new(){

	}

	public function testGoodPart():Void
	{
		var partialPart = XmlToPart.parse(Xml.parse(Resource.getString('goodPart')));
		Assert.equals(PartType.Part, partialPart.type);
		trace(partialPart.pd);
	}
}