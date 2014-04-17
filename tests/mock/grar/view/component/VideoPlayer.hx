package grar.view.component;

typedef VideoElement=String;

class VideoPlayer{
    public var root (default, null): VideoElement;

    public function new(){

    }

    public function init(root:VideoElement):Void
    {

    }

    public function setVideo(url: String, autoStart: Bool = false, loop: Bool = false, defaultVolume : Float = 1, capture: Float = 0, fullscreen : Bool = false, onVideoPlay: Void -> Void, onVideoEnd: Void -> Void) : Void {

    }

    public function play():Void
    {

    }

    public function pause():Void
    {

    }

    public function stop():Void
    {

    }
}