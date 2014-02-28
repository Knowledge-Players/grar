package grar.parser;

import grar.model.InventoryToken;
import grar.model.contextual.Note;

import grar.view.component.container.WidgetContainer;

import grar.parser.component.container.XmlToWidgetContainer;

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

	static public function parseDisplayToken(xml : Xml, templates : StringMap<Xml>) : { tn : WidgetContainerData, ti : StringMap<{ small : String, large : String }> } {

		var dtf : Fast = new Fast(xml.firstElement());

		var tn : WidgetContainerData = XmlToWidgetContainer.parseWidgetContainerData(dtf, TokenNotification(null), templates); // dtf.node.Hud.att.duration

		var ti : StringMap<{ small : String, large : String }> = new StringMap();
		
		for (t in dtf.nodes.Token) {

			ti.set(t.att.ref, { small: t.att.src.substr(0, t.att.src.indexOf(",")), large: t.att.src.substr(t.att.src.indexOf(",") + 1) });
		}

		return { tn: tn, ti: ti };
	}
	
	static function parseTokenData(f : Fast) : Null<TokenData> {

		if (f != null) {

			var id : String = f.has.id ? f.att.id : f.att.name;
			var ref : String = f.att.ref;
			var type : Null<String> = f.has.type ? f.att.type : null;
			var isActivated : Bool = f.has.unlocked ? f.att.unlocked == "true" : false;
			var name : Null<String> = f.has.name ? f.att.name : null;
			var content : String = f.att.content;
			var icon : String = f.att.icon;
			var image : String = f.att.src;
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
		var td : Null<TokenData>;

		for (tf in f.nodes.Token) {
	
			td = parseTokenData(tf);
		}		

		var video : Null<String> = null;

		if (f != null) {

			video = f.has.video ? f.att.video : null;
		}
		return new Note(td, video);
	}
}