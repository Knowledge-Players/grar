package grar.view.component;

import js.html.VideoElement;

/*typedef SliderData = {

	var x : Float;
	var y : Float;
	var bar : { tile : TileImageData, x : Float, y : Float };
	var cursor : { tile : TileImageData, ref : String, x : Float, y : Float, vol : Float };
}

typedef ProgressBarData = {

	var x : Float;
	var y : Float;
	var mask : TileImageData;
	var bar : { color : Int, alpha : Float, x : Float, y : Float };
	var cursor : { tile : TileImageData, ref : String, x : Float };
}

typedef VideoBackgroundData = {

	var color : Int;
	var alpha : Float;
	var x : Float;
	var y : Float;
	var w : Float;
	var h : Float;
}*/

class VideoPlayer{

	public var root (default, null): VideoElement;

	public function new(){

	}

	dynamic private function onVideoPlay(){};

	public function init(root:VideoElement):Void
	{
		this.root = root;
	}

	public function setVideo(url: String, autoStart: Bool = false, loop: Bool = false, defaultVolume : Float = 1, capture: Float = 0, fullscreen : Bool = false, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void) : Void {
		root.src = url;
		root.autoplay = autoStart;
		root.loop = loop;
		root.volume = defaultVolume;
		if(fullscreen)
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