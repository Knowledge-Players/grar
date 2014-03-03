package grar.parser;

import grar.model.tracking.TrackingMode;
import utest.Assert;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class XmlToGrarTest {

	private var goodXml:Xml;

	public static function main() {
		var runner = new Runner();
		runner.addCase(new XmlToGrarTest());
		Report.create(runner);
		runner.run();
	}

	public function new(){}

	public function setup():Void
	{
		goodXml = Xml.parse('<?xml version="1.0" encoding="UTF-8"?>
<Grar>
    <Parameters>
        <Mode>SCORM</Mode>
        <Id>Test</Id>
        <State tracking="off">en@0@1-1-1-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0@@@1</State>
        <Layout file="xml/layout.xml"/>
        <Languages file="xml/lang.xml"/>
    </Parameters>
    <Display>
        <Style file="xml/style.json"/>
        <Transitions display="ui/transition.xml"/>
        <Filters display="ui/filters.xml"/>
        <Ui display="ui/ui_elements.xml"/>
        <Activity display="xml/quizDisplay.xml"/>
        <Templates folder="xml/templates"/>
    </Display>
    <Structure ref="main">
        <Part id="e0" name="e0" type="dialog" file="xml/e0.xml" display="xml/e0Display.xml"/>
        <Part id="e1" name="e1" type="" file="xml/e1.xml"/>
        <Part id="e2" name="e2" type="" file="xml/e2.xml"/>
        <Part id="e3" name="e3" type="" file="xml/e3.xml"/>
        <Contextual type="menu" file="xml/menu.xml" display="xml/menuDisplay.xml"/>
        <Contextual type="notebook" file="xml/inventaire.xml" display="xml/inventaireDisplay.xml"/>
    </Structure>
</Grar>');
	}

	public function testGoodParsing() {
		var grarObject = XmlToGrar.parse(goodXml);
		Assert.equals(TrackingMode.SCORM, grarObject.mode);
		var expectedState = {value : "en@0@1-1-1-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0@@@1", tracking: "off"};
		Assert.equals(expectedState.value, grarObject.state.value);
		Assert.equals(expectedState.tracking, grarObject.state.tracking);
		Assert.equals("Test", grarObject.id);
		Assert.equals("main", grarObject.ref);
		Assert.equals("main", grarObject.ref);
		switch(grarObject.readyState){
			case Loading(langs, layout, displayNode, structureNode):
				Assert.equals("xml/lang.xml", langs);
				Assert.equals("xml/layout.xml", layout);
			case _: "none";
		}
	}
}