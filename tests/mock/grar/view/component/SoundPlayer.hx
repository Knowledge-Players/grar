package grar.view.component;

typedef AudioElement=String;

class SoundPlayer{

    public var root (default, null): AudioElement;

    public function new(){

    }
    public function init(root:AudioElement):Void
    {

    }
    public function setSound(url:String, autoStart:Bool = false, loop:Bool = false, defaultVolume:Float = 1){

    }

    public function play():Void
    {
    }

    public function pause():Void
    {
    }
}