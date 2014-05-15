package grar.parser.part;

import grar.model.part.ButtonData;
import grar.model.part.item.Item;

import grar.util.ParseUtils;

import haxe.ds.GenericStack;
import haxe.ds.StringMap;

import haxe.xml.Fast;

class XmlToItem {

	///
	// API
	//

	static public function parse(xml : Xml) : Null<Item> {

		var f : Fast = new Fast(xml);

		/*var t : String = f.has.type ? f.att.type.toLowerCase() : "";

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
		}*/

		return new Item(parseItem(f));
	}


	///
	// INTERNALS
	//

	static function parseItem(f : Fast) : ItemData {

		var id : String = "";
		var content : String = "";
		var background : Null<String> = null;
		var author: Null<String> = null;
		var button : Null<List<ButtonData>> = null;
		var ref : Null<String> = null;
		var tokens : GenericStack<String> = new GenericStack<String>();
		var images : List<ImageData> = new List<ImageData>();
		var endScreen : Bool = false;
		var videoData: VideoData = null;
		var soundData: SoundData = null;


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
			for (node in f.nodes.Token) {

				tokens.add(node.att.ref);
			}
            button = new List();

            for (elem in f.nodes.Button) {

                button.add({ref: elem.att.ref, content: ParseUtils.parseHash(elem.att.content), action: elem.att.action});
			}
			if (f.has.author) {

				author = f.att.author;
			}
			if (f.has.endScreen) {

				endScreen = f.att.endScreen == "true";
			}

			for (elem in f.elements) {
				var image:ImageData ={src:elem.att.src,ref:elem.att.ref};
				images.add(image);

			}

			if(f.has.type && f.att.type == "video"){
				var autoStart : Bool = false;
				var autoFullscreen : Bool = false;
				var loop : Bool = false;
				var defaultVolume : Float = 1;
				var capture : Float = 0;
				var thumbnail : Null<String> = null;

				autoStart = f.has.autoStart ? f.att.autoStart == "true" : false;
				autoFullscreen = f.has.autoFullscreen ? f.att.autoFullscreen == "true" : false;
				loop = f.has.loop ? f.att.loop == "true" : false;
				defaultVolume = f.has.volume ? Std.parseFloat(f.att.volume) : 1;
				capture = f.has.capture ? Std.parseFloat(f.att.capture) : 0;
				thumbnail = f.has.thumbnail ? f.att.thumbnail : null;

				videoData = {autoStart: autoStart, fullscreen: autoFullscreen, loop: loop, defaultVolume: defaultVolume, capture: capture};
			}
			// TODO SoundData
		}
		id = content;

		return { id: id, content: content, author: author, background: background, button: button, ref: ref, tokens: tokens, images: images, endScreen: endScreen, videoData: videoData, soundData: soundData};
	}

	/*static function parseTextItem(xml : Xml) : TextItem {

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

		var imgList : List<String> = new List<String>();

		for (img in id.images) {

			imgList.add(img);
		}
		id.images = imgList;

		return new TextItem(id, author, transition, sound, introScreen);
	}

	static function parseVideoItem(xml : Xml) : VideoItem {

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

	static function parseSoundItem(xml : Xml) : SoundItem {

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
	}*/
}