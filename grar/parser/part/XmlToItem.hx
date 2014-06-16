package grar.parser.part;

import grar.model.part.Part.ImageData;
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
		var soundUrl: String = null;

		if (f != null) {

			if (f.has.content)
				content = f.att.content;

			if (f.has.ref)
				ref = f.att.ref;

			if (f.has.background)
				background = f.att.background;

			for (node in f.nodes.Token)
				tokens.add(node.att.ref);

			button = new List();
			for (elem in f.nodes.Button)
				button.add({ref: elem.att.ref, content: ParseUtils.parseHash(elem.att.content), action: elem.att.action});

			if (f.has.author)
				author = f.att.author;

			if (f.has.endScreen)
				endScreen = f.att.endScreen == "true";

			for (img in f.nodes.Image) {
				var image:ImageData ={src:img.att.src,ref:img.att.ref};
				images.add(image);
			}

			if(f.hasNode.Sound)
				soundUrl = f.node.Sound.att.src;

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

				var subtitles = new Map<String, SubtitleData>();
				for(sub in f.nodes.Subtitle){
					var s: SubtitleData = {src: sub.att.src, lang: sub.att.lang};
					subtitles[s.lang] = s;
				}

				videoData = {autoStart: autoStart, fullscreen: autoFullscreen, loop: loop, defaultVolume: defaultVolume, capture: capture, subtitles: subtitles};
			}
			// TODO SoundData
		}
		id = content;

		return new Item({ id: id, content: content, author: author, background: background, button: button, ref: ref, tokens: tokens, images: images, endScreen: endScreen, videoData: videoData, soundData: soundData, voiceOverUrl: soundUrl});
	}
}