package grar.parser.contextual;

import grar.model.contextual.MenuData;

import haxe.xml.Fast;

class XmlToMenu {

	static public function parse(xml : Xml) : MenuData {

		var f : Fast = new Fast(xml.firstElement());

		var md : MenuData = { levels: [], title: f.att.title };

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

		var levelData: LevelData = {name: f.name, id: f.att.id}
		if(f.has.icon)
			levelData.icon = f.att.icon;
		levelData.items = items;

		return levelData;
	}
}