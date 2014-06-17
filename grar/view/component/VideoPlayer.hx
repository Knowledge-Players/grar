package grar.view.component;

import js.Browser;
import grar.model.part.item.Item.VideoData;
import js.html.VideoElement;

using Lambda;

class VideoPlayer{

	public var root (default, null): VideoElement;

	var apiPrefix: String;

	public function new(){

	}

	dynamic private function onVideoPlay(){};

	public function init(root:VideoElement):Void
	{
		this.root = root;
		untyped __js__("if (this.root.mozRequestFullScreen)
				this.apiPrefix = 'moz';
			else if (this.root.webkitRequestFullscreen)
				this.apiPrefix = 'webkit';
			else if (this.root.msRequestFullscreen)
				this.apiPrefix = 'ms';");
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
		if(videoData.fullscreen){
			if(apiPrefix == null)
				untyped __js__("this.root.requestFullscreen();");
			else
				Reflect.callMethod(root, apiPrefix+"RequestFullScreen()", null);
			//root.enterFullScreen();
		}
		root.addEventListener("play", function(_){
			onVideoPlay();
		});
		root.addEventListener("ended", function(_){
			if(apiPrefix == null)
				untyped __js__("this.exitFullscreen();");
			else if(apiPrefix == "webkit")
				untyped __js__("this.webkitExitFullScreen();");
			else if(apiPrefix == "moz")
				untyped __js__("this.mozCancelFullScreen();");
			else
				untyped __js__("this.msExitFullScreen();");
			//root.exitFullScreen();
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