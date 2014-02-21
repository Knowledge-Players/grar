package grar.parser.component;

import grar.view.component.TileImage;
import grar.view.component.Character;

import grar.parser.component.XmlToImage;

import haxe.xml.Fast;

class XmlToCharacter {

	static public function parseCharacterData(f : Fast) : CharacterData {

		var cd : CharacterData = { };

		f.x.remove("spritesheet");

		cd.tid = XmlToImage.parseTileImageData(f, f.att.spritesheet, false);
		cd.charRef = f.att.ref;

		if (f.has.nameRef) {

			cd.nameRef = f.att.nameRef;
		}
		return cd;
	}
}