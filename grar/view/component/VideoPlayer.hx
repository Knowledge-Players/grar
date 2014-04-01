package grar.view.component;

import js.html.Element;

typedef SuperBool = {

	var isSet: Bool;
	var value : Bool;
}

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

	public function new(){

	}

	dynamic private function onVideoPlay(){};

	public function init(root:Element):Void
	{

	}

	public function setVideo(url: String, autoStart: Bool = false, loop: Bool = false, defaultVolume : Float = 1, capture: Float = 0, fullscreen : Bool = false, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void) : Void {

	}

	public function playVideo():Void
	{

	}

	public function statusHandler():Void
	{

	}

	public function pauseVideo():Void
	{

	}

	public function stopVideo():Void
	{

	}

	private function playOrPause()
	{

	}

	public function unsetVideo ():Void
	{

	}
}