package grar.parser;

import grar.model.InventoryToken;
import grar.model.contextual.Note;

import grar.view.component.container.WidgetContainer;

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

	static public function parseDisplayToken(xml : Xml) : { tn : WidgetContainerData, ti : StringMap<{ small : String, large : String }> } {

		var dtf : Fast = new Fast(xml.firstElement());

		var tn : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(dtf, TokenNotification); // dtf.node.Hud.att.duration

		var ti : StringMap<{ small : String, large : String }> = new StringMap();
		
		for (t in dtf.nodes.Token) {

			ti.set(t.att.ref, { small: t.att.src.substr(0, t.att.src.indexOf(",")), large: t.att.src.substr(t.att.src.indexOf(",") + 1) });
		}

		return { tn: tn, ti: ti };
	}
	
	static function parseTokenData(xml : Xml) : Null<TokenData> {

		var f : Fast = new Fast(xml);
		
		for (tf in f.nodes.Token) { // TODO check why for loop here

			if (tf != null) {

				var id : String = tf.att.id;
				var ref : String = tf.att.ref;
				var type : Null<String> = tf.has.type ? tf.att.type : null;
				var isActivated : Bool = tf.has.unlocked ? tf.att.unlocked == "true" : false;
				var name : Null<String> = tf.has.name ? tf.att.name : null;
				var content : String = tf.att.content;
				var icon : String = tf.att.icon;
				var image : String = tf.att.src;
				var fullScreenContent : Null<String> = tf.has.fullScreenContent ? tf.att.fullScreenContent : null;

				return { id: id, ref: ref, type: type, isActivated: isActivated, name: name, content: content, 
							icon: icon, image: image, fullScreenContent: fullScreenContent };
			}
			return null;
		}
	}
	
	static function parseInventoryToken(xml : Xml) : InventoryToken {

		var td : Null<TokenData> = parseTokenData(xml);
		
		return new InventoryToken(td);
	}

	static public function parseNoteToken(xml : Xml) : Note {

		var td : Null<TokenData> = parseTokenData(xml);
		
		var f : Fast = new Fast(xml);

		var video : Null<String> = null;

		if (f != null) {

			video = f.has.video ? f.att.video : null;
		}
		return new Note(td, video);
	}
}