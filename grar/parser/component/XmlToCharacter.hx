package grar.parser.component;

import grar.view.component.TileImage;
import grar.view.component.CharacterDisplay;

import grar.parser.component.XmlToImage;

import haxe.xml.Fast;

class XmlToCharacter {

	static public function parseCharacterData(f : Fast) : CharacterData {

		var cd : CharacterData = cast { };

		f.x.remove("spritesheet");

		cd.tid = XmlToImage.parseTileImageData(f, null, false);
		cd.charRef = f.att.ref;
		cd.nameRef = f.has.nameRef ? f.att.nameRef : null;

		return cd;
	}
}