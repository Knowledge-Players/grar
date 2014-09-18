package grar.parser;

import grar.parser.part.XmlToItem;
import grar.model.part.Part.ImageData;
import grar.model.part.item.Item;
import grar.model.InventoryToken;
import grar.model.contextual.Note;

import haxe.xml.Fast;

class XmlToInventory {

	static public function parse(xml : Xml): Map<String, InventoryToken> {

		var f : Fast = null;

		// No Document node
		if(xml.nodeType == Xml.Element)
			f = new Fast(xml);
		else
			f = new Fast(xml.firstElement());

		var i : Map<String, InventoryToken> = new Map();

		for (token in f.nodes.Token)
			i.set(token.att.id, parseInventoryToken(token));

		return i;
	}

	static public function parseNoteToken(xml : Xml) : Note {

		var f : Fast = new Fast(xml);

		var td : Null<TokenData> = parseTokenData(f);

		var video : Null<String> = null;

		if (f != null) {

			video = f.has.video ? f.att.video : null;
		}
		return new Note(td, video);
	}

	static public function parseInventoryToken(f : Fast) : InventoryToken {

		var td : Null<TokenData> = parseTokenData(f);

		return new InventoryToken(td);
	}

	static function parseTokenData(f : Fast) : Null<TokenData> {

		if (f != null) {

			var isActivated : Bool = f.has.unlocked ? f.att.unlocked == "true" : false;
			var content: Map<String, Item> = new Map();
			var images: Map<String, ImageData> = new Map();
			var tc: Float = null;
			for(node in f.elements){
				switch(node.name.toLowerCase()){
					case "text":
						content[node.att.ref] = XmlToItem.parse(node.x);
					case "image":
						images[node.att.ref] = {src: node.att.src, ref: node.att.ref};
				}
			}
			if(f.has.timecode)
				tc = Std.parseFloat(f.att.timecode);

			return {id: f.att.id, ref: f.att.ref, isActivated: isActivated, content: content, images: images, timecode: tc};
		}

		return null;
	}
}