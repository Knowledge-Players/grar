package grar.parser.part;

import grar.model.part.Item;
import grar.model.part.TextItem;
import grar.model.part.sound.SoundItem;
import grar.model.part.video.VideoItem;

import grar.util.ParseUtils;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToItem {
	
	static public function parse(xml : Xml) : Null<Item> {

		var f : Fast = new Fast(xml);

		var t : String = f.has.type ? f.att.type.toLowerCase() : "";

		var creation : Item = null;
		
		switch (t) {

			case "":

				creation = parseTextItem(xml);
			
			case "video":

				creation = parseVideoItem(xml);
			
			case "sound":

				creation = parseSoundItem(xml);
			
			default:

				throw "unexpected type attribute value " + t;
		}
		return creation;
	}

	static public function parseItem(f : Fast) : ItemData {

		var id : String = "";
		var content : String = "";
		var background : Null<String> = null;
		var button : Null<StringMap<StringMap<String>>> = null;
		var ref : Null<String> = null;
		var tokens : GenericStack<String> = new GenericStack<String>();
		var images : GenericStack<String> = new GenericStack<String>();
		var endScreen : Bool = false;
		var timelineIn : Null<String> = null;
		var timelineOut : Null<String> = null;

		if (f != null) {

			if (f.has.content) {

				content = f.att.content;
			}
			if (f.has.ref) {

				ref = f.att.ref;
			}
			if (f.has.background) {

				background = f.att.background;
			}
			if (f.has.timelineIn) {

				timelineIn = f.att.timelineIn;
			}
			if (f.has.timelineOut) {

				timelineOut = f.att.timelineOut;
			}
			for (node in f.nodes.Token) {

				tokens.add(node.att.ref);
			}
            button = new StringMap();

            for (elem in f.nodes.Button) {

                button.set(elem.att.ref, ParseUtils.parseHash(elem.att.content));
			}
			if (f.has.endScreen) {

				endScreen = f.att.endScreen == "true";
			}
			for (elem in f.elements) {
			
				images.add(elem.att.ref);
			}

		}
		id = content;

		return { id: id, content: content, background: background, button: button, ref: ref, 
					tokens: tokens, images: images, endScreen: endScreen, timelineIn: timelineIn, 
						timelineOut: timelineOut };
	}

	static public function parseTextItem(xml : Xml) : TextItem {

		var f : Fast = new Fast(xml);

		var id : ItemData = parseItem(f);

		var author : String = null;
		var transition : String = null;
		var sound : String = null;
		var introScreen : { ref : String, content : StringMap<String> } = null;

		if (f != null) {

			if (f.has.author) {

				author = f.att.author;
			}
			if (f.has.transition) {

				transition = f.att.transition;
			}
			if (f.hasNode.Sound) {

				sound = f.node.Sound.att.src;
			}
			if (f.hasNode.Intro) {

				introScreen = {ref: f.node.Intro.att.ref, content: ParseUtils.parseHash(f.node.Intro.att.content)};
			}
		}

		// Reverse pile order to match XML order
		var tmpStack : GenericStack<String> = new GenericStack<String>();
		
		for (img in id.images) {

			tmpStack.add(img);
		}
		id.images = tmpStack;

		return new TextItem(id, author, transition, sound, introScreen);
	}

	static public function parseVideoItem(xml : Xml) : VideoItem {

		var f : Fast = new Fast(xml);

		var id : ItemData = parseItem(f);

		var autoStart : Bool = false;
		var autoFullscreen : Bool = false;
		var loop : Bool = false;
		var defaultVolume : Float = 1;
		var capture : Float = 0;
		var thumbnail : Null<String> = null;

		if (f != null) {

			autoStart = f.has.autoStart ? f.att.autoStart == "true" : false;
			autoFullscreen = f.has.autoFullscreen ? f.att.autoFullscreen == "true" : false;
			loop = f.has.loop ? f.att.loop == "true" : false;
			defaultVolume = f.has.volume ? Std.parseFloat(f.att.volume) : 1;
			capture = f.has.capture ? Std.parseFloat(f.att.capture) : 0;
			thumbnail = f.has.thumbnail ? f.att.thumbnail : null;
		}

		return new VideoItem( id, autoStart, autoFullscreen, loop, defaultVolume, capture, thumbnail );
	}

	static public function parseSoundItem(xml : Xml) : SoundItem {

		var f : Fast = new Fast(xml);

		var id : ItemData = parseItem(f);

		var autoStart : Bool = false;
		var loop : Bool = false;
		var defaultVolume : Float = 1;

        if (f != null) {

            autoStart = f.has.autostart ? f.att.autostart == "true" : false;
            loop = f.has.loop ? f.att.loop == "true" : false;
            defaultVolume = f.has.volume ? Std.parseFloat(f.att.volume) : 1;
        }

        return new SoundItem( id, autoStart, loop, defaultVolume );
	}
}