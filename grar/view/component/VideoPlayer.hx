package grar.view.component;

import js.Browser;

import grar.model.part.item.Item.VideoData;

import js.html.Element;
import js.html.VideoElement;
import js.html.MediaElement;

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
				playElement.onclick = function(_) playOrPause();
			}

			// Init fullscreen buttons
			for(fullscreen in root.getElementsByClassName("fullscreen")){
				var fsElement: Element = fullscreen.getElement();
				fsElement.onclick = function(_) onToggleFullscreenRequest(fsElement);
			}

			// Toggle play on video click
			videoElement.onclick = function(_) playOrPause();
		}
	}

	public function setVideo(url: String, videoData: VideoData, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void, ?locale: String) : Void {
		videoElement.src = url;
		videoElement.autoplay = videoData.autoStart;
		videoElement.loop = videoData.loop;
		videoElement.volume = videoData.defaultVolume;
		if(!videoData.subtitles.empty() && locale != null){
			var track = Browser.document.createElement("track");
			track.setAttribute("kind", "subtitles");
			if(!videoData.subtitles.exists(locale))
				throw "No subtitles for locale: '"+locale+"'.";
			track.setAttribute("src", videoData.subtitles[locale].src);
			track.setAttribute("srclang", locale);
			track.setAttribute("default", "");
			track.setAttribute("label", "Subtitles");

			videoElement.appendChild(track);
		}
		if(videoData.fullscreen)
			onFullscreenRequest();

		videoElement.addEventListener("play", function(_){
			onVideoPlay();
		});
		var endListener = null;
		endListener = function(_){
			onVideoEnd();
			videoElement.removeEventListener("ended", endListener);
		}
		videoElement.addEventListener("ended", endListener);
	}

	public inline function play():Void
	{
		videoElement.play();
		for(button in root.getElementsByClassName("play"))
			button.getElement().classList.add("playing");
		root.classList.add("playing");
	}

	public inline function pause():Void
	{
		videoElement.pause();
		for(button in root.getElementsByClassName("play"))
			button.getElement().classList.remove("playing");
		root.classList.remove("playing");
	}

	public inline function stop():Void
	{
		videoElement.pause();
		if(videoElement.readyState != MediaElement.HAVE_NOTHING)
			videoElement.currentTime = 0;
	}

	///
	// Internals
	//

	private inline function playOrPause()
	{
		if(videoElement.paused)
			play();
		else
			pause();
	}
}