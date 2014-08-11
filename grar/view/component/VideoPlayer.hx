package grar.view.component;

import grar.model.part.item.Item;

import js.Browser;

import js.html.Element;
import js.html.VideoElement;
import js.html.MediaElement;
import js.html.MouseEvent;

using Lambda;
using grar.util.HTMLTools;

/**
* View of a video player
**/
class VideoPlayer{

	public var root (default, null): Element;
	public var volume (default, set):Float;

	private var videoElement:VideoElement;
	private var previousVolume:Float;
	private var isNativePlayer:Bool;
	private var subs:SubtitleData;
	// Optim
	private var elapsedTimeElements:Array<Element>;
	private var bufferElements:Array<Element>;
	private var seekerElements:Array<Element>;

	///
	// CALLBACKS
	//

	public dynamic function onFullscreenRequest(?button: Element): Void {}
	public dynamic function onExitFullscreenRequest(?button: Element): Void {}
	public dynamic function onToggleFullscreenRequest(?button: Element): Void {}
	public dynamic function onAnimationFrameRequest(callback: Float -> Bool): Void {}
	public dynamic function onSubtitleRequest(path: String, callback: SubtitleData -> Void): Void {}

	public function new(){

	}

	///
	// GETTER/SETTER
	//

	private function set_volume(vol: Float):Float
	{
		return volume = videoElement.volume = vol;
	}

	///
	// API
	//

	public function init(root:Element):Void
	{
		this.root = root;
		if(root.nodeName.toLowerCase() == "video"){
			videoElement = cast root;
			isNativePlayer = true;
		}
		else{
			// Init vars
			previousVolume = 1;
			elapsedTimeElements = new Array();
			bufferElements = new Array();
			seekerElements = new Array();
			isNativePlayer = false;
			subs = null;

			videoElement = cast root.getElementsByTagName("video")[0];
			videoElement.controls = false;

			// Init play/stop buttons
			for(play in root.getElementsByClassName("play")){
				var playElement: Element = play.getElement();
				playElement.onclick = function(_) playOrPause();
			}
			for(stopBtn in root.getElementsByClassName("stop")){
				var stopElement: Element = stopBtn.getElement();
				stopElement.onclick = function(_) stop();
			}

			// Init fullscreen buttons
			for(fullscreen in root.getElementsByClassName("fullscreen")){
				var fsElement: Element = fullscreen.getElement();
				fsElement.onclick = function(_) onToggleFullscreenRequest(fsElement);
			}

			// Init sound buttons
			for(sound in root.getElementsByClassName("sound")){
				var soundElement: Element = sound.getElement();
				soundElement.onclick = function(e: MouseEvent){
					if(e.target == soundElement)
						toggleMute(soundElement);
				}
				for(slider in soundElement.getElementsByClassName("soundSliderContainer")){
					var sliderElement: Element = slider.getElement();
					sliderElement.onclick = function(e: MouseEvent){
						var rect = sliderElement.getBoundingClientRect();
						var ratio = -(e.clientY - rect.bottom)/rect.height;
						volume = ratio;
						for(range in sliderElement.getElementsByClassName("range"))
							range.getElement().style.height = (ratio*100)+"%";
					}
				}
			}

			// Init time
			for(elTime in root.getElementsByClassName("elapsedTime")){
				var timeElement: Element = elTime.getElement();
				timeElement.innerText = "00:00";
				elapsedTimeElements.push(timeElement);
			}
			for(total in root.getElementsByClassName("totalTime")){
				var totalElement: Element = total.getElement();
				totalElement.innerText = "00:00";
			}
			for(buff in root.getElementsByClassName("seekBar-buffer")){
				var buffElement: Element = buff.getElement();
				buffElement.style.width = "0";
				bufferElements.push(buffElement);
				buffElement.onclick = function(e: MouseEvent){
					var rect = buffElement.parentElement.getBoundingClientRect();
					var diff = e.clientX - rect.left;
					var ratio = diff/rect.width;
					seek(ratio*videoElement.duration);
				}
			}
			for(progress in root.getElementsByClassName("seekBar-progress")){
				var progressElement: Element = progress.getElement();
				progressElement.style.width = "0";
				seekerElements.push(progressElement);
				progressElement.onclick = function(e: MouseEvent){
					var rect = progressElement.parentElement.getBoundingClientRect();
					var diff = e.clientX - rect.left;
					var ratio = diff/rect.width;
					seek(ratio*videoElement.duration);
				}
			}
			onAnimationFrameRequest(updateTime);

			// Init subtitles
			for(sub in root.getElementsByClassName("subtitlesButton")){
				sub.getElement().onclick = function(_) toggleSubtitles();
			}

			// Toggle play on video click
			videoElement.onclick = function(_) playOrPause();
		}
	}

	public function setVideo(url: String, videoData: VideoData, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void, ?locale: String) : Void {
		// Buffering events
		videoElement.addEventListener("loadedmetadata", function(_){
			for(total in root.getElementsByClassName("totalTime")){
				var totalElement: Element = total.getElement();
				totalElement.innerText = formatTime(videoElement.duration);
			}
		});
		videoElement.addEventListener("progress", function(_){
			if(videoElement.buffered.length > 0)
				for(buff in bufferElements)
					buff.style.width = videoElement.buffered.end(0)*100/videoElement.duration+"%";
		});

		videoElement.src = url;
		videoElement.autoplay = videoData.autoStart;
		videoElement.loop = videoData.loop;
		videoElement.volume = videoData.defaultVolume;
		if(!videoData.subtitles.empty() && locale != null){
			// Native player
			if(isNativePlayer){
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
			else if(videoData.subtitles.exists(locale)){
				onSubtitleRequest(videoData.subtitles[locale].src, function(subData: SubtitleData){
					subs = subData;
				});
			}
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
		pause();
		if(videoElement.readyState != MediaElement.HAVE_NOTHING)
			videoElement.currentTime = 0;
	}

	public function toggleMute(button:Element):Void
	{
		if(videoElement.volume == 0)
			videoElement.volume = previousVolume;
		else{
			previousVolume = videoElement.volume;
			videoElement.volume = 0;
		}
		button.classList.toggle("muted");
	}

	public function seek(time:Float):Void
	{
		videoElement.currentTime = time;
	}

	public function toggleSubtitles():Void
	{
		for(sub in root.getElementsByClassName("subtitles")){
			var subtitles: Element = sub.getElement();
			if(root.ownerDocument.defaultView.getComputedStyle(subtitles, null).display == "none"){
				subtitles.style.display = "block";
				for(tooltip in root.getElementsByClassName("tooltipSubtitle"))
					tooltip.getElement().innerText = "Deactivate subtitles";
			}
			else{
				subtitles.style.display = "none";
				for(tooltip in root.getElementsByClassName("tooltipSubtitle"))
					tooltip.getElement().innerText = "Activate subtitles";
			}
		}
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

	/**
	* Transform time in seconds to a formatted string (hh):mm:ss
	**/
	private function formatTime(time: Float):String
	{
		var tempNum = time;
		var minutes = Math.floor(tempNum / 60);
		var hours: Float = 0;
		var currentTimeConverted: String;
		if (minutes/60 >= 1) {
			hours = Math.floor(minutes / 60);
			currentTimeConverted = hours+":";
		}
		else
			currentTimeConverted = "";
		var seconds = Math.round(tempNum - (minutes * 60));
		return currentTimeConverted + (minutes < 10 ? "0":"")+ minutes + ":" +(seconds < 10 ? "0":"")+seconds;

	}

	/**
	* Called on each frame to update time, progress bars and subtitles
	**/
	private function updateTime(timestamp: Float):Bool
	{
		for(elem in elapsedTimeElements)
			elem.innerText = formatTime(videoElement.currentTime);
		for(seek in seekerElements)
			seek.style.width = (videoElement.currentTime*100/videoElement.duration)+"%";

		if(subs != null){
			var i = 0;
			while(i < subs.content.length && subs.content[i].start < videoElement.currentTime)
				i++;

			if(i < subs.content.length){
				if(subs.content[i].end < videoElement.currentTime)
					displaySubtitles("");
				else
					displaySubtitles(subs.content[i].text);
			}
		}
		return true;
	}

	private inline function displaySubtitles(sub:String):Void
	{
		for(subtitle in root.getElementsByClassName("subtitles")){
			var elem: Element = subtitle.getElement();
			var p: Element = elem.getElementsByTagName("p")[0].getElement();
			p.innerHTML = sub;
		}
	}
}