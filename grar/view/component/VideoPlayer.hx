package grar.view.component;

import js.Browser;
import grar.model.part.item.Item.VideoData;
import js.html.VideoElement;
import js.html.Element;

using Lambda;
using grar.util.HTMLTools;

/**
* View of a video player
**/
class VideoPlayer{

	public var root (default, null): Element;

	private var videoElement:VideoElement;

	public dynamic function onFullscreenRequest(?button: Element): Void {}
	public dynamic function onExitFullscreenRequest(?button: Element): Void {}
	public dynamic function onToggleFullscreenRequest(?button: Element): Void {}

	public function new(){

	}

	dynamic private function onVideoPlay(){}

	public function init(root:Element):Void
	{
		this.root = root;
		if(root.nodeName.toLowerCase() == "video")
			videoElement = cast root;
		else{
			videoElement = cast root.getElementsByTagName("video")[0];
			videoElement.controls = false;

			// Init play buttons
			for(play in root.getElementsByClassName("play")){
				var playElement: Element = play.getElement();
				playElement.onclick = function(_) playOrPause(playElement);
			}

			// Init fullscreen buttons
			for(fullscreen in root.getElementsByClassName("fullscreen")){
				var fsElement: Element = fullscreen.getElement();
				fsElement.onclick = function(_) onToggleFullscreenRequest(fsElement);
			}
		}
	}

	public function setVideo(url: String, videoData: VideoData, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void, ?locale: String) : Void {
		videoElement.src = url;
		videoElement.autoplay = videoData.autoStart;
		videoElement.loop = videoData.loop;
		videoElement.volume = videoData.defaultVolume;
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

			videoElement.appendChild(track);
		}
		if(videoData.fullscreen)
			onFullscreenRequest();

		videoElement.addEventListener("play", function(_){
			onVideoPlay();
		});
		videoElement.addEventListener("ended", function(_){
			//root.classList.remove("fullscreenOn");
			onVideoEnd();
		});
	}

	public inline function play(?button: Element):Void
	{
		videoElement.play();
		if(button != null)
			button.classList.add("playing");
	}

	public inline function pause(?button: Element):Void
	{
		videoElement.pause();
		if(button != null)
			button.classList.remove("playing");
	}

	public inline function stop():Void
	{
		videoElement.pause();
		videoElement.currentTime = 0;
	}

	///
	// Internals
	//

	private inline function playOrPause(button: Element)
	{
		if(videoElement.paused)
			play(button);
		else
			pause(button);
	}
}