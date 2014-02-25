package grar.parser.contextual;

import grar.view.contextual.menu.MenuDisplay.MenuData;
import grar.view.contextual.menu.MenuDisplay.LevelData;

import haxe.xml.Fast;

class XmlToMenu {

	static public function parse(xml : Xml) : MenuData {

		var f : Fast = new Fast(xml.firstElement());

		var md : MenuData = { levels: [] };

		for (elem in f.elements) {

			md.levels.push(parseLevelData(elem));
		}

		return md;
	}

	static function parseLevelData(f : Fast) : LevelData {

		var items : Null<Array<LevelData>> = null;

		if (f.elements.hasNext()) {

			items = [];

			for (e in f.elements) {

				items.push(parseLevelData(e));
			}
		}

		return { name: f.name, id: f.att.id, icon: f.att.icon };
	}
}