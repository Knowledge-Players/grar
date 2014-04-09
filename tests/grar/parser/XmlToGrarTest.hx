package grar.parser;

import haxe.Resource;
import grar.model.tracking.TrackingMode;
import utest.Assert;
import utest.Assert;

class XmlToGrarTest {

	private var goodXml:Xml;

	public function new(){}

	public function setup():Void
	{
		goodXml = Xml.parse(Resource.getString('goodStructure'));
	}

	public function testGoodParsing() {
		var grarObject = XmlToGrar.parse(goodXml);
		Assert.equals(TrackingMode.SCORM, grarObject.mode);
		var expectedState = {value : "en@0@1-1-1-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0@@@1", tracking: "off"};
		Assert.equals(expectedState.value, grarObject.state.value);
		Assert.equals(expectedState.tracking, grarObject.state.tracking);
		Assert.equals("Test", grarObject.id);
		switch(grarObject.readyState){
			case Loading(langs, structureNode):
				Assert.equals("xml/lang.xml", langs);
			case _: "none";
		}
	}

	public function testBadParsing():Void
	{
		var badStructure = Xml.parse(Resource.getString('badStructure'));
		Assert.raises(function(){ XmlToGrar.parse(badStructure);}, String);
	}
}