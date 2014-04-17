package grar.model.part;

import grar.model.part.PartElement;
import grar.model.part.item.Item;
import utest.Assert;
import grar.parser.part.XmlToPart;
import haxe.Resource;

class PartTest{

	var part: Part;

	public function new(){

	}

	public function setup():Void
	{
		var xml = Xml.parse(Resource.getString('goodPart'));
		var partialPart = XmlToPart.parse(xml);
		part = XmlToPart.parseContent(partialPart, xml).p;
	}

	public function testElements():Void
	{
		Assert.equals(1, part.elements.length);
		var textElem: PartElement = part.elements[0];
		Assert.isTrue(~/item/i.match(Std.string(textElem)));
		switch(textElem){
			case Item(i):
				Assert.equals("intro_content", i.content);
				Assert.equals("text1", i.ref);
				Assert.isNull(i.videoData);
			default:
		}
	}
}