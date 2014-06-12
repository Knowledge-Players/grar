package grar.view.component;

import js.Browser;
import grar.model.part.item.Item.VideoData;
import js.html.VideoElement;

using Lambda;

class VideoPlayer{

	public var root (default, null): VideoElement;

	public function new(){

	}

	dynamic private function onVideoPlay(){};

	public function init(root:VideoElement):Void
	{
		this.root = root;
	}

	public function setVideo(url: String, videoData: VideoData, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void, ?locale: String) : Void {
		root.src = url;
		root.autoplay = videoData.autoStart;
		root.loop = videoData.loop;
		root.volume = videoData.defaultVolume;
		if(!videoData.subtitles.empty()){
			var track = Browser.document.createElement("track");
			track.setAttribute("kind", "subtitles");
			var subLocale = locale == null ? videoData.subtitles.keys().next() : locale;
			if(!videoData.subtitles.exists(subLocale))
				throw "No subtitles for locale: '"+subLocale+"'.";
			track.setAttribute("src", videoData.subtitles[subLocale].src);
			track.setAttribute("srclang", subLocale);
			track.setAttribute("default", "");
			track.setAttribute("label", "Subtitles");

			root.appendChild(track);
		}
		if(videoData.fullscreen)
			root.enterFullScreen();
		root.addEventListener("play", function(_){
			onVideoPlay();
		});
		root.addEventListener("ended", function(_){
			onVideoEnd();
		});
	}

	public function play():Void
	{
		root.play();
	}

	public function pause():Void
	{
		root.pause();
	}

	public function stop():Void
	{
		//root.currentTime = 0;
		root.pause();
	}

	private function playOrPause()
	{
		if(root.paused)
			play();
		else
			pause();
	}
}