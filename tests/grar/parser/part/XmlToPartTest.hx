package grar.parser.part;

import grar.model.part.Part;
import utest.Assert;
import haxe.Resource;

class XmlToPartTest{

	var partialPart: PartialPart;
	var goodXml: Xml;

	public function new(){

	}

	public function setup():Void
	{
		goodXml = Xml.parse(Resource.getString('goodPart')).firstElement();
		partialPart = XmlToPart.parse(goodXml);
	}

	public function testParseGoodPart():Void
	{
		Assert.equals(PartType.Part, partialPart.type);
	}

	public function testParseContentGoodPart():Void
	{
		var data: { p : Part, pps : Array<PartialPart> } = XmlToPart.parseContent(partialPart, goodXml);
		Assert.equals(1, data.p.elements.length);
		Assert.equals(1, data.pps.length);
	}
}