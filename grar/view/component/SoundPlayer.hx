package grar.view.component;

import js.html.AudioElement;

class SoundPlayer{

	public var root (default, null): AudioElement;

	public function new(){

	}

	public function init(root:AudioElement):Void
	{
		this.root = root;
	}

	public function setSound(url:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1){
		root.src = url;
		root.autoplay = autoStart;
		root.loop = loop;
		root.volume = defaultVolume;
	}

	public function play():Void
	{
		root.play();
	}

	public function pause():Void
	{
		root.pause();
	}
}