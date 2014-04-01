package grar.parser;

import grar.model.InventoryToken;
import grar.model.contextual.Note;

import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToInventory {

	static public function parse(xml : Xml) : { m : StringMap<InventoryToken>, d : String } {

		var tf : Fast = new Fast(xml.firstElement());
		var i : StringMap<InventoryToken> = new StringMap();

		var d : String = tf.att.display;

		for (token in tf.nodes.Token) {

			i.set(token.att.id, parseInventoryToken(token));
		}

		return { m: i, d: d };
	}

	static function parseTokenData(f : Fast) : Null<TokenData> {

		if (f != null) {

			var id : String = f.has.id ? f.att.id : f.att.name;
			var ref : String = f.att.ref;
			var type : Null<String> = f.has.type ? f.att.type : null;
			var isActivated : Bool = f.has.unlocked ? f.att.unlocked == "true" : false;
			var name : Null<String> = f.has.name ? f.att.name : null;
			var content : String = f.att.content;
			var icon : String = f.has.icon ? f.att.icon : null;
			var image : String = f.has.src ? f.att.src : null;
			var fullScreenContent : Null<String> = f.has.fullScreenContent ? f.att.fullScreenContent : null;

			return { id: id, ref: ref, type: type, isActivated: isActivated, name: name, content: content,
						icon: icon, image: image, fullScreenContent: fullScreenContent };
		}

		return null;
	}

	static function parseInventoryToken(f : Fast) : InventoryToken {

		var td : Null<TokenData> = parseTokenData(f);

		return new InventoryToken(td);
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
}