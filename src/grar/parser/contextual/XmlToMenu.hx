package grar.parser.contextual;

import grar.view.contextual.menu.MenuDisplay.MenuData;

class XmlToMenu {

	static public parse(xml : Xml) : MenuData {

		var md : MenuData = { levels: [] };

		for (elem in xml.firstElement().elements()) {

			md.levels.push({ name: elem.nodeName, id: elem.get("id"), icon: elem.get("icon") });
		}

		return md;
	}
}