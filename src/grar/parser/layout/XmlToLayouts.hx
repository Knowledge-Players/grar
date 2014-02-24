package grar.parser.layout;

import grar.view.layout.Layout;
import grar.view.Display.DisplayData

import grar.parser.XmlToDisplay;

import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToLayouts {

	static public function parse(xml : Xml) : { lp : Null<String>, lm : StringMap<LayoutData> } {

		var f : Fast = new Fast(xml).node.Layouts;

		var lm : StringMap<LayoutData> = new StringMap();

		var interfaceLocale : Null<String> = f.has.text ? f.att.text : null;

		for (l in f.elements) {

			var ld : LayoutData = { name: l.att.layoutName, content: XmlToDisplay.parseDisplayData(l, Zone) };

			lm.set(ld.name, ld);
		}

		return { lp: interfaceLocale, lm: lm };
	}
}