package grar.service;

import grar.model.part.item.Item;

import haxe.Http;

using StringTools;

enum SubParserState {
	IGNORING_SPACES;
	TIMECODE;
	CONTENT;
}

class SubtitleService{

	var prefix: String;

	public function new(prefix: String){
		this.prefix = prefix;
	}

	///
	// API
	//

	/**
	* Fetch a subtitle file and return the content of the file
	*
	* @param uri: Path to the file
	* @return the content of the file
	**/
	public function fetchSubtitle(uri:String, onSuccess: SubtitleData -> Void, onError: String -> Void):Void
	{
		if(uri != null && uri != ""){
			var http = new Http(prefix != "" ? prefix+"/"+uri : uri);
			http.onData = function(data){
				onSuccess(parseSubtitles(data));
			}

			http.onError = function(msg){
				onError(msg);
			}
			http.request();
		}
	}

	///
	// Internals
	//

	private function parseSubtitles(content:String):SubtitleData
	{
		var state: SubParserState = IGNORING_SPACES;
		var subData: SubtitleData = {src: null, lang: null, content: new Array()};
		var currentSub: Subtitle = null;
		var webVTT: Bool = false;
		var buffer = new StringBuf();
		for(line in content.split("\n")){
			switch(state){
				case IGNORING_SPACES:
					if(line.toLowerCase() == "webvtt")
						webVTT = true;
					else if(!isEmpty(line)){
						currentSub = cast {id: line};
						state = TIMECODE;
					}

				case TIMECODE:
					var range = line.split("-->");
					currentSub.start = parseTC(range[0].trim(), webVTT);
					currentSub.end = parseTC(range[1].trim(), webVTT);
					state = CONTENT;

				case CONTENT:
					if(line != "")
						buffer.add(line);
					else{
						currentSub.text = buffer.toString();
						buffer = new StringBuf();
						subData.content.push(currentSub);
						currentSub = cast {};
						state = IGNORING_SPACES;
					}
			}
		}

		return subData;
	}

	private function parseTC(tc:String, isWebVTT: Bool):Float
	{
		var splitted = tc.split(":");
		var hours = Std.parseInt(splitted[0]);
		var min = Std.parseInt(splitted[1]);
		var sec;
		if(isWebVTT)
			sec = Std.parseFloat(splitted[2]);
		else{
			var milli = splitted[2].split(",");
			sec = Std.parseInt(milli[0])+(Std.parseInt(milli[1])/1000);
		}

		return (sec + min*60 + hours*3600);
	}

	private inline function isEmpty(line:String):Bool
	{
		var empty = false;
		if(line.length == 0)
			empty = true;
		else{
			var i = 0;
			while(i < line.length && line.isSpace(i))
				i++;
			empty = i == line.length;
		}
		return empty;
	}
}